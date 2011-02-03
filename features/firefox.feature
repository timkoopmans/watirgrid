Feature: Firefox
  Users would like to automate firefox on the grid

Scenario: Start a controller on a specified port
  Given I have started a controller on port 12351
  Then I should have a controller listening on UDP port 12351

Scenario: Add 1 firefox provider and start a grid
  Given I have added 1 provider to the controller on port 12351
  When I start a grid using the read_all method on port 12351
  Then I should see 1 provider on the grid
