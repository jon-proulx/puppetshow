module KnowsConfig
  
  class PuppetShowConfig
    

    def initialize(outfile)
      @outfile=outfile
      @conf_data=Hash.new
    end
    
    def set (key,value)
      @conf_data[key]=value
    end

    def write
      File.open(path, "w") do |f|
        f.write(@conf_data.to_yaml)
      end
    end

    def path
      @outfile.path
    end

  end #class
  
  def myconfig 
    @myconfig ||= PuppetShowConfig.new(Tempfile.new('puppetshow_cuketest'))
  end

end #module

World(KnowsConfig)
