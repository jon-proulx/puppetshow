require 'helper'
require 'puppetshow/vagrantbox'

class TestVagrantBox < Test::Unit::TestCase
context "Setting up new test box" do 
    setup do
      uniquifier = Time.now.strftime("%s")
      @temp_name = "test_vagrantbox." + uniquifier 
      @myworkdir    =  "/tmp/ps_utest_workdir." +  uniquifier 
      @myconf         =  "/tmp/ps_utest_conf."  + uniquifier  + ".yaml"
      # override defaults so we don't stomp active data with tests
      @test_config = {
        :known_vagrants => {
          @temp_name => {
            :box_url => "http://rocky-mountain.csail.mit.edu/pub/vagrant/ubuntu-oneric64.box",
          },
        },
        :workdir              => @myworkdir,
      }
      File.open(@myconf, "w") do |f|
        f.write(@test_config.to_yaml)
      end
    end

    teardown do
      File.delete(@myconf)
      FileUtils.rm_rf @myworkdir
    end

    should "not raise an exception" do
      assert_nothing_raised { mybox=PuppetShow::VagrantBox.configure(@myconf) }
      assert_nothing_raised { mybox=PuppetShow::VagrantBox.new(@temp_name) }
    end
  end

end
