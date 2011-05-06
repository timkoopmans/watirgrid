@NFR-001
Feature: User logons
  In order to use the web application users must be
  able to logon and access the portal in 3 seconds

  Scenario: Logon with 50 users in 1 minute
    Given users navigate to the portal
    When they enter their credentials
    Then they should see their account settings

  Scenario: Bypass logon
    Given users navigate to the portal
    When they enter a direct url
