@Remote
Feature: Watirgrid WebDriver Remote Browser (Headless)
  In order to use watirgrid with WebDriver remote
  Users must be able to start controllers and use HtmlUnit providers on a grid

  @Controller
  Scenario: Start a controller on a specified port
    Given I have started a controller on port 12351
    Then I should have a controller listening on UDP port 12351

  @WebDriver-HtmlUnit
  Scenario: Add a remote provider and take control using HtmlUnit via WebDriver
    Given I have added a remote WebDriver provider to the controller on port 12351
    When I start a grid using the take_all method on port 12351
    Then I should see 1 remote provider on the grid
    And I should be able to visit http://google.com using HtmlUnit
