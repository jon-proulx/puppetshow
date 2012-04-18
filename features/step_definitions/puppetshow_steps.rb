Given /^the directory "([^"]*)" does not exist$/ do |d|
  if File.directory?(d)
    FileUtils.rm_rf(d)
  end
end

Given /^I have set (\S+) to in my config\.yaml to "([^"]*)"$/ do |key,value|
  myconfig.set(key,value)
end

Given /^I invoke PuppetShow::VagrantBox\.configure\(config.yaml\)$/ do
  myconfig.write
  PuppetShow::VagrantBox.configure(myconfig.path)
end

When /^I create a vagrant vm (\S+)$/ do |box|
  PuppetShow::VagrantBox.new(box)
end

