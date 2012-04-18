Feature: Configuration

  In order to make puppetshow work in my environment
  I need to be able to override default settings

Background 

  Scenario: create working directory
    Given the directory "/tmp/puppetshow.feature.test" does not exist
    And I have set :workdir to in my config.yaml to "/tmp/puppetshow.feature.test"
    And I invoke PuppetShow::VagrantBox.configure(config.yaml)
    When I create a vagrant vm ubuntu-oneric64 
    Then a directory named "/tmp/puppetshow.feature.test" should exist
