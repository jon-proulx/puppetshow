Given /^the directory "([^"]*)" does not exist$/ do |d|
  if File.directory?(d)
    FileUtils.rm_rf(d)
  end
end

Given /^I have set (\S+) to in my configuration to "([^"]*)"$/ do |key,value|
  myconfig.set(key.to_sym,value)
end

Given /^I configure the system$/ do
  myconfig.write
  PuppetShow::VagrantBox.configure(myconfig.path)
end

When /^I create a vagrant vm (\S+)$/ do |box|
  PuppetShow::VagrantBox.new(box)
end

