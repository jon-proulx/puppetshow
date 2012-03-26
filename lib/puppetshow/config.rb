module KnowsOurModules
  def moduledir
    @moduledir ||= File.expand_path(File.join(File.dirname(__FILE__), '..','..' , '..'))
  end
  
  def puppet_cmd
    'puppet'
  end
end
World(KnowsOurModules)
