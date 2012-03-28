require 'rubygems'
require 'vagrant'
require 'sahara'
require 'yaml'

module PuppetShow
  class VagrantBox
    @@config_file=nil
    def self.configure(config_file=@@config_file)
      defaults=File.join(File.dirname(__FILE__),"defaults.yaml")
      config=YAML.load(File.read(defaults))
      if config_file
        @@config_file=config_file
        config.merge!(YAML.load(File.read(config_file)))
      end
      @@workdir        = config[:workdir]
      @@puppet_cmd     = config[:puppet_cmd]
      @@mounts         = config[:mounts]
      @@known_vagrants = config[:known_vagrants]
      # this default allows unknow but extant baseboxes
      @@known_vagrants.default = {}
      Dir.mkdir(@@workdir) unless File::directory?(@@workdir)
    end

    def self.puppet_cmd
      @@puppet_cmd
    end

    def initialize(basebox)
      VagrantBox.configure
      @cwd = File.join(@@workdir,basebox) 
      @name=basebox
      Dir.mkdir(@cwd) unless File::directory?(@cwd)
      
      @env=Vagrant::Environment.new(:cwd =>@cwd)
      @vagrant_file=File.join(@cwd,"Vagrantfile")
      @changed_conf = true
      
      #we really should check if this exists
      # if we change it it may be running whit stale config
      oldcontent=nil
      if File.exist?(@vagrant_file)
        oldcontent=File.read(@vagrant_file)
      end
      File.open(@vagrant_file,"w+") do |conf_file|
        conf_file.write "Vagrant::Config.run do |config|\n"
        conf_file.write @@known_vagrants[@name][:config] if @@known_vagrants[@name][:config]  
        conf_file.write "  config.vm.box = \'#{@name}\'\n"
        conf_file.write "  config.vm.box_url = \'#{@@known_vagrants[@name][:box_url]}\'\n" if @@known_vagrants[@name][:box_url]

        @@mounts.each do |name, mount|
          conf_file.write "  config.vm.share_folder(\"#{name}\",\"#{mount[:guest_side]}\" , \"#{mount[:host_side]}\""
          if  @@known_vagrants[@name][:folder_defaults] || mount[:options]
            conf_file.write ",\"#{mount[:options]} #{@@known_vagrants[@name][:folder_defaults]}\")\n"
          else
             conf_file.write  ")\n"
           end
        end
        conf_file.write "end\n"
      end
      newcontent=File.read(@vagrant_file)
      if newcontent == oldcontent
        @changed_conf = false
      end
    end
    
    def up
      # We might be created but suspended too, need to handle more cases 
      if @env.primary_vm.state != :running
        print "Booting #{@name} patience..."
        @env.cli("up")
      elsif @changed_conf
        print "Changed conf reloading  #{@name} patience..."
        @env.cli("reload")
      end
      raise "Failed to start vm #{@name} " if @env.primary_vm.state != :running
      puts "freezing mv state..."
      self.freeze
      puts "done"
    end
    
    def guest_test_dir
      @@mounts['test'][:guest_side]
    end
    ###########################################
    ##Sahara sandbox doesn't ingerit @cwd somehow
    ##eventhough we pass that to teh object that becomes @env
    def freeze
      Dir.chdir(@cwd)
      @env.cli("sandbox","on") 
    end
    
    def rollback
      Dir.chdir(@cwd)
      @env.cli("sandbox","rollback")
    end
    ###########################################
    
    def execute(cmd)
      output=String.new
      @env.primary_vm.channel.execute(cmd) do |type, data|
        output+=data
      end
      return output
    end
    
    def sudo(cmd)
      self.execute("sudo " + cmd)
    end
    attr_reader :cwd
    def join_cwd(file)
      File.join(@cwd,file)
    end
  end
end
