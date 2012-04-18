Given /^the directory (\S+) does not exist$/ do |d|
  if File.directory?(d)
    FileUtils.rm_rf(d)
  end
end

Given /^I have set (\S+) to in my config\.yaml to  (.*)$/ do |key,value|
  myconfig.set(key,value)
end

Given /^I invoke PuppetShow::VagrantBox\.configure\(myconfig\)$/ do
  myconfig.write
  PuppetShow::VagrantBox.configure(myconfig.path)
end

When /^I create a new  PuppetShow::VagrantBox instance$/ do
  pending # express the regexp above with the code you wish you had
end

Then /^the directory \/tmp\/puppetshow\.feature\.test should exist$/ do
  pending # express the regexp above with the code you wish you had
end
