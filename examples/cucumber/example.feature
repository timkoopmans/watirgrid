@Example
Feature: Watirgrid using WebDriver
  In order to use Watirgrid 
  Users must be able to create controllers, add providers and control a grid

  Scenario: Create a Controller with Providers
    Given I have created and started a Controller
    Then I should be able to create and start 2 "WebDriver" Providers

  # Note: WebDriver can only control one instance of any particular browser on a single host.
  # With Watirgrid, you'd typically have multiple instances across multiple hosts (Providers)
  # For the sake of a demo, we'll just control 2 difference instances on a single host.
  Scenario: Create a Grid and control the Providers
    Given I have created and started a Grid with 2 Providers
    Then I should be able to control the following browsers in parallel:
      | Chrome |
      | Firefox |
