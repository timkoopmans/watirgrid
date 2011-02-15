@Operations
Feature: Watirgrid Operations 
  In order to use watirgrid 
  Users must be able to operate different utility methods on the grid

  Scenario: Start a controller on a specified port
    Given I have started a controller on port 12352
    Then I should have a controller listening on UDP port 12352

  # read_all method lets you consume providers as a shared resource 
  Scenario: Add 1 webdriver provider and start a grid
    Given I have added 1 webdriver provider to the controller on port 12352
    When I start a grid using the read_all method on port 12352
    Then I should see 1 provider on the grid
 
  # you can add more than 1 provider to a grid
  Scenario: Add 2 more webdriver providers and start a grid 
    Given I have added 2 webdriver providers to the controller on port 12352
    When I start a grid using the read_all method on port 12352
    Then I should see 3 providers on the grid

  # take_all method lets you consume providers exclusively 
  Scenario: Start a grid taking all the providers
    When I start a grid using the take_all method on port 12352
    Then I should see 3 providers on the grid

  # release lets you return providers to the grid 
  Scenario: Add, take and release 2 more providers on a grid 
    Given I have added 2 webdriver providers to the controller on port 12352
    When I start a grid using the take_all method on port 12352
    Then I should see 2 providers on the grid
    And if I release the providers on the grid
    When I start a grid using the take_all method on port 12352
    Then I should see 2 providers on the grid
  
  # use the :browser_type attribute
  Scenario: Add and take a provider based on a browser_type
    Given I have added 1 webdriver provider to the controller on port 12352
    When I start a grid using the take_all method with browser_type "foobar" on port 12352
    Then I should NOT see 1 provider on the grid
    When I start a grid using the take_all method with browser_type "webdriver" on port 12352
    Then I should see 1 provider on the grid 

  # use the :architecture attribute
  Scenario: Add and take a provider based on a specific architecture type
    Given I have added 1 webdriver provider to the controller on port 12352
    When I start a grid using the take_all method with architecture type "geos-2000" on port 12352
    Then I should NOT see 1 provider on the grid
    Given I have added 1 webdriver provider to the controller on port 12352
    When I start a grid using the take_all method with architecture type "universal-darwin10.0" on port 12352
    Then I should see 1 provider on the grid
#   it 'should take any 1 browser based on specific architecture type' do
#     grid = Watir::Grid.new(:ring_server_port => 12352, 
#     :ring_server_host => '127.0.0.1')
#     grid.start(:quantity => 1, 
#       :take_all => true, :architecture => Config::CONFIG['arch'])
#     grid.size.should == 1
#   end
# 
#   it 'should fail to find any grid based on unknown architecture type' do
#     grid = Watir::Grid.new(:ring_server_port => 12352, 
#     :ring_server_host => '127.0.0.1')
#     grid.start(:quantity => 1, 
#       :take_all => true, :architecture => 'geos-1992')
#     grid.size.should == 0
#   end
# 
#   it 'should take any 1 browser based on specific hostname' do
#     hostname = `hostname`.strip
#     grid = Watir::Grid.new(:ring_server_port => 12352, 
#     :ring_server_host => '127.0.0.1')
#     grid.start(:quantity => 1,
#       :take_all => true, 
#       :hostnames => { hostname => "127.0.0.1"}
#       )
#     grid.size.should == 1
#   end
# 
#   it 'should fail to find any grid based on unknown hostname' do
#     grid = Watir::Grid.new(:ring_server_port => 12352, 
#     :ring_server_host => '127.0.0.1')
#     grid.start(:quantity => 1,
#       :take_all => true, :hostnames => { 
#         "tokyo" => "127.0.0.1"})
#     grid.size.should == 0
#   end
#   
#   it 'should take the last browser and execute some watir commands' do
#     grid = Watir::Grid.new(:ring_server_port => 12352, 
#     :ring_server_host => '127.0.0.1')
#     grid.start(:quantity => 1, :take_all => true)
#     threads = []
#     grid.browsers.each do |browser|
#       threads << Thread.new do 
#         browser[:hostname].should == `hostname`.strip
#         browser[:architecture].should == Config::CONFIG['arch']
#         browser[:browser_type].should == 'safari'
#         b = browser[:object].new_browser
#         b.goto("http://www.google.com")
#         b.text_field(:name, 'q').set("watirgrid")
#         b.button(:name, "btnI").click
#       end
#     end
#     threads.each {|thread| thread.join}
#     grid.size.should == 1
#   end
# 
#   it 'should find no more tuples in the tuplespace' do
#     grid = Watir::Grid.new(:ring_server_port => 12352, 
#     :ring_server_host => '127.0.0.1')
#     grid.start(:read_all => true)
#     grid.size.should == 0
#   end
# 
# end
# 
