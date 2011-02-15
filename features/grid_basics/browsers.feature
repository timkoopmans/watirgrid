@Browsers
Feature: Watirgrid Browsers 
  In order to use watirgrid 
  Users must be able to start controllers and use providers on a grid

  @Controller
  Scenario: Start a controller on a specified port
    Given I have started a controller on port 12351
    Then I should have a controller listening on UDP port 12351

  @WebDriver-Firefox
  Scenario: Add a provider and take control using Firefox via WebDriver
    Given I have added 1 WebDriver provider to the controller on port 12351
    When I start a grid using the take_all method on port 12351
    Then I should see 1 provider on the grid
    And I should be able to visit http://google.com using FireFox

  @WebDriver-Chrome
  Scenario: Add another provider and take control using Chrome via WebDriver
    Given I have added 1 WebDriver provider to the controller on port 12351
    When I start a grid using the take_all method on port 12351
    Then I should see 1 provider on the grid
    And I should be able to visit http://google.com using Chrome

  @SafariWatir
  Scenario: Add another provider and take control using SafariWatir 
    Given I have added 1 SafariWatir provider to the controller on port 12351
    When I start a grid using the take_all method on port 12351
    Then I should see 1 provider on the grid
    And I should be able to visit http://google.com

  @FireWatir
  Scenario: Add another provider and take control using FireWatir 
    Given I have added 1 FireWatir provider to the controller on port 12351
    When I start a grid using the take_all method on port 12351
    Then I should see 1 provider on the grid
    And I should be able to visit http://google.com

  @Watir
  Scenario: Add another provider and take control using Watir (IE) 
    Given I have added 1 Watir provider to the controller on port 12351
    When I start a grid using the take_all method on port 12351
    Then I should see 1 provider on the grid
    And I should be able to visit http://google.com
