require 'tempfile'
require 'puppetshow/api'
require 'puppetshow/cucumber/hooks'

World(PuppetShow::Api)

## VM stepps

Given /^a vagrant vm (\S+) (?:is running|is up|)$/ do |box|
  @mybox=PuppetShow::VagrantBox.new(box)
  @mybox.up
end

Given /^(?:I freeze the vm|the vm is frozen)$/ do
  @mybox.freeze
end

Given /^I rollback the vm$/ do
  @mybox.rollback
end

When /^the command (.*) is executed on the vm$/ do |cmd|
  @mybox.execute(cmd)
end

When /^the command (.*) is executed on the vm as root$/ do |cmd|
  @mybox.sudo(cmd)
end

## Puppet steps

Given /^I apply the class (\w+)$/ do |puppet_class|
  @mybox.sudo(PuppetShow::VagrantBox.puppet_cmd + "  apply --modulepath=#{@mybox.guest_test_dir} -e \"include #{puppet_class}\"")
end
Then /^the package (\w+) should be (installed|purged|uninstalled)$/ do |package, expected_state|
  package_state=@mybox.execute(PuppetShow::VagrantBox.puppet_cmd + " resource package " + package)
  
  if expected_state == "installed"
    if package_state.include?("ensure => 'purged',")
      raise "Package #{package} should be installed but it is not"
    end
  else
    unless package_state.include?("ensure => 'purged',")
      raise "Package #{package} should not be installed but it is"
    end
  end
  
      
end
Then /^the service (\w+) should be (enabled|disabled) (?:on|in) the vm$/ do |service,state|
  
  # should be doing this directly with Net::SSH probably
  # also raises exception if <service> can't be found 
  service_state=@mybox.execute(PuppetShow::VagrantBox.puppet_cmd + " resource service " + service)
  
  if state == "enabled"
    expect_enable="true"
  elsif state == "disabled"
    expect_enable="false"
  end
  
  unless service_state.include?("enable => '" + expect_enable + "',")
    raise "Service #{service} NOT IN STATE: enable => #{expect_enable}"
  end
  
end

Then /^the service (\w+) should be (stopped|running) (?:on|in) the vm$/ do |service,expected_state|
      
  # should be doing this directly with Net::SSH probably
  # also raises exception if <service> can't be found 
  # And it shouldn't be duplicated...
  service_state=@mybox.execute(PuppetShow::VagrantBox.puppet_cmd + " resource service " + service)
  
  unless service_state.include?("ensure => '" + expected_state + "',")
    raise "Service #{service} NOT IN STATE: ensure => #{expected_state}"
  end
    end

Then /^the local file (\S+) should exist$/ do |file|
  unless File.exist?(@mybox.join_cwd(file))
    raise "#{@mybox.join_cwd(file)} does not exist"
  end
end

Then /^the contents of (\S+) should be (.*$)/ do |file,expected_contents|
  found_content=File.read(@mybox.join_cwd(file))
  unless found_content == found_content
    raise "In file #{file}, expected #{expected_content}, found #{found_content}"
  end
end

Then /^the files (\S+) and (\S+) should be the same$/ do |file1, file2|
  unless File.read(@mybox.join_cwd(file1)) == File.read(@mybox.join_cwd(file2))
    raise "#{file1} and #{file2} differ"
  end
end

#this one is starting to feel a bit stretched
Then /^the (local|host|remote|vm|guest) file (\S+) (should|should not) contain:$/ do |location,file,sense,table| 
  
  case location
      when "local", "host"
    check_file=@mybox.join_cwd(file)
  when "remote","vm","guest"
    host_temp_file=Tempfile.new("comparitor",@mybox.cwd)
    check_file=host_temp_file.path
    guest_check_file=File.join("/vagrant",File.basename(host_temp_file.path))
    @mybox.sudo("cp #{file} #{guest_check_file}")
  end
  
  substrings=table.raw.flatten
  substrings.each do |substring|
    
    if sense == "should"
      unless File.read(check_file).include?(substring)
        raise "#{check_file} does not contain: #{substring}"
      end
    else
      if File.read(checkfile).include?(substring)
        raise "#{check_file} should not not contain: #{substring}"
      end
    end
  end
end


