require 'rubygems'
require 'vagrant'
require 'sahara'

module PuppetShow
  class VagrantBox
    def initialize(basebox,testdir=nil)
      @name=basebox
      #brittle code...these should go in conf file soon###
      @cwd=File.join("/scratch/vagrant-boxen",@name)
      @known_vagrants = {
        "lucid64"                => { 
          :box_url => "http://files.vagrantup.com/lucid64.box",
        },
        "ubuntu-oneric64"        => {
          :box_url =>"http://rocky-mountain.csail.mit.edu/pub/vagrant/ubuntu-oneric64.box",
        },
        "ubuntu-oneric32"        => {
          :box_url =>"http://rocky-mountain.csail.mit.edu/pub/vagrant/ubuntu-oneric32.box",
        },
        "ubuntu-precise64-beta1" => {
          :box_url => "http://rocky-mountain.csail.mit.edu/pub/vagrant/ubuntu-precise64-beta1.box",
        },
        "freebsd9-64"              => {
          :box_url =>"http://rocky-mountain.csail.mit.edu/pub/vagrant/freebsd9-64.box",
          :config => '''  config.vm.guest = :freebsd
                            config.vm.network :hostonly, "172.19.1.231"
                            config.vm.share_folder("v-root", "/vagrant", ".", :nfs => true)
                       ''',
          :folder_defaults => ",:nfs => true",
        },
        "centos6.0-64"           => {
          :box_url => "http://dl.dropbox.com/u/1627760/centos-6.0-x86_64.box",
        },
        "gentoo-64"              => {
          :box_url =>"http://dl.dropbox.com/u/4270274/gentoo64-0.7.box",
        },
      }
      # this allows specifying an unkown but extant vagrant box in our
      # features
      @known_vagrants.default={} 
      ####################################################
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
        conf_file.write @known_vagrants[@name][:config]
        conf_file.write "  config.vm.box = \'#{@name}\'\n"
        if @known_vagrants[@name][:box_url]
          conf_file.write "  config.vm.box_url = \'#{@known_vagrants[@name][:box_url]}\'\n"
        end
        if testdir
          conf_file.write "  config.vm.share_folder(\"test\", \"/test\", \"#{testdir}\" #{@known_vagrants[@name][:folder_defaults]})\n"
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
