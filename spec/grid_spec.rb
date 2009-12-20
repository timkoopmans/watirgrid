require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'WatirGrid' do
  before(:all) do
    controller = Controller.new(
      :ring_server_port => 12351,
      :loglevel => Logger::ERROR)
    controller.start
    1.upto(5) do 
      provider = Provider.new(
        :ring_server_port => 12351, 
        :loglevel => Logger::ERROR, :browser_type => 'safari')
      provider.start
    end
  end

  it 'should return how many grid are available in the tuplespace' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:read_all => true)
    grid.size.should == 5
  end

  it 'should read any 2 grid in the tuplespace' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:quantity => 2, :read_all => true)
    grid.size.should == 2
  end

  it 'should take any 1 browser in the tuplespace' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:quantity => 1, :take_all => true)
    grid.size.should == 1 
  end

  it 'should take all grid remaining in tuplespace' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:take_all => true)
    grid.size.should == 4
  end

  it 'should find no more grid in the tuplespace' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:read_all => true)
    grid.size.should == 0
  end

  it 'should register 4 new grid in the tuplespace' do
    1.upto(4) do 
      provider = Provider.new(:ring_server_port => 12351, 
        :loglevel => Logger::ERROR, :browser_type => 'safari')
      provider.start
    end
  end

  it 'should take any 1 browser based on browser type' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:quantity => 1,
      :take_all => true, :browser_type => 'safari')
    grid.size.should == 1
  end

  it 'should fail to find any grid based on a specific browser type' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:quantity => 1,
      :take_all => true, :browser_type => 'firefox')
    grid.size.should == 0
  end

  it 'should fail to find any grid based on a unknown browser type' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:quantity => 1,
      :take_all => true, :browser_type => 'penguin')
    grid.size.should == 0
  end

  it 'should take any 1 browser based on specific architecture type' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:quantity => 1, 
      :take_all => true, :architecture => Config::CONFIG['arch'])
    grid.size.should == 1
  end

  it 'should fail to find any grid based on unknown architecture type' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:quantity => 1, 
      :take_all => true, :architecture => 'geos-1992')
    grid.size.should == 0
  end

  it 'should take any 1 browser based on specific hostname' do
    hostname = `hostname`.strip
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:quantity => 1,
      :take_all => true, 
      :hostnames => { hostname => "127.0.0.1"}
      )
    grid.size.should == 1
  end

  it 'should fail to find any grid based on unknown hostname' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:quantity => 1,
      :take_all => true, :hostnames => { 
        "tokyo" => "127.0.0.1"})
    grid.size.should == 0
  end
  
  it 'should take the last browser and execute some watir commands' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:quantity => 1, :take_all => true)
    threads = []
    grid.browsers.each do |browser|
      threads << Thread.new do 
        browser[:hostname].should == `hostname`.strip
        browser[:architecture].should == Config::CONFIG['arch']
        browser[:browser_type].should == 'safari'
        b = browser[:object].new_browser
        b.goto("http://www.google.com")
        b.text_field(:name, 'q').set("watirgrid")
        b.button(:name, "btnI").click
      end
    end
    threads.each {|thread| thread.join}
    grid.size.should == 1
  end

  it 'should find no more tuples in the tuplespace' do
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:read_all => true)
    grid.size.should == 0
  end

end

