Feature: Configuration

  In order to make puppetshow work in my environment
  I need to be able to override default settings

Background 

  Scenario: create working directory
    Given the directory "/tmp/puppetshow.feature.test" does not exist
    And I have set workdir to in my configuration to "/tmp/puppetshow.feature.test"
    When I configure the system
    Then a directory named "/tmp/puppetshow.feature.test" should exist
