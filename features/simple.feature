Feature: Simple 
  In order to use watirgrid with webdriver
  Users must be able to start controllers and use providers on a grid

Scenario: Start a controller on a specified port
  Given I have started a controller on port 12351
  Then I should have a controller listening on UDP port 12351

Scenario: Add 1 provider and start a grid
  Given I have added 1 provider to the controller on port 12351
  When I start a grid using the read_all method on port 12351
  Then I should see 1 provider on the grid

Scenario: Add 2 more providers and start a grid 
  Given I have added 2 more providers to the controller on port 12351
  When I start a grid using the read_all method on port 12351
  Then I should see 3 providers on the grid

Scenario: Start a grid taking all the providers
  When I start a grid using the take_all method on port 12351
  Then I should see 3 providers on the grid
  
Scenario: Start another grid with remaining providers
  When I start a grid using the read_all method on port 12351
  Then I should see 0 providers on the grid

Scenario: Add, take and release 2 more providers on a grid 
  Given I have added 2 more providers to the controller on port 12351
  When I start a grid using the take_all method on port 12351
  Then I should see 2 providers on the grid
  And if I release the providers on the grid
  When I start a grid using the read_all method on port 12351
  Then I should see 2 providers on the grid


  

