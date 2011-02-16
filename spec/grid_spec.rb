require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'Starting and Stopping Controllers on the Grid' do
  it 'should start a DRb and Ring Server when specifying NO interface or port' do
    controller = Controller.new(:loglevel => Logger::ERROR)
    controller.start
    controller.drb_server_uri.should =~ /druby/
    controller.stop
  end

  it 'should start a DRb and Ring Server on a specified interface' do
    controller = Controller.new(
      :drb_server_host => '127.0.0.1', 
      :ring_server_host => '127.0.0.1',
      :loglevel => Logger::ERROR)
    controller.start
    controller.drb_server_uri.should =~ /druby/
    controller.stop
  end

  it 'should start a DRb and Ring Server on specified ports' do
    controller = Controller.new(
      :drb_server_port => 11235, 
      :ring_server_port => 12358,
      :loglevel => Logger::ERROR)
    controller.start
    controller.drb_server_uri.should =~ /druby/
    controller.stop
  end
end

describe 'Starting and Stopping Providers on the Grid' do
  before(:all) do
    @controller = Controller.new(
      :drb_server_host => '127.0.0.1', 
      :ring_server_host => '127.0.0.1',
      :ring_server_port => 12350,
      :loglevel => Logger::ERROR)
    @controller.start
  end

  it 'should register a new provider on a specified port' do
    provider = Provider.new(
      :drb_server_host => '127.0.0.1', 
      :ring_server_host => '127.0.0.1',
      :ring_server_port => 12350,
      :loglevel => Logger::ERROR)
    provider.start
  end

  after(:all) do
    @controller.stop
  end
end

describe 'Using the Grid' do
  before(:all) do
    @controller = Controller.new(
      :ring_server_port => 12357,
      :loglevel => Logger::ERROR)
    @controller.start
    1.upto(5) do 
      provider = Provider.new(
        :ring_server_port => 12357, 
        :loglevel => Logger::ERROR, :browser_type => 'safari')
      provider.start
    end
  end

  after(:all) do
    @controller.stop
  end

  it 'should return how many providers are available on the grid' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:read_all => true)
    grid.size.should == 5
  end

  it 'should read any 2 providers on the grid' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:quantity => 2, :read_all => true)
    grid.size.should == 2
  end

  it 'should take any 1 provider on the grid' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:quantity => 1, :take_all => true)
    grid.size.should == 1 
  end

  it 'should take all providers remaining on the grid' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:take_all => true)
    grid.size.should == 4
  end

  it 'should find no more providers on the grid' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:read_all => true)
    grid.size.should == 0
  end

  it 'should register 4 new providers on the grid' do
    1.upto(4) do 
      provider = Provider.new(:ring_server_port => 12357, 
        :loglevel => Logger::ERROR, :browser_type => 'safari')
      provider.start
    end
  end

  it 'should take any 1 provider based on :browser_type from the grid' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:quantity => 1,
      :take_all => true, :browser_type => 'safari')
    grid.size.should == 1
  end

  it 'should fail to find any providers on the grid based on a specific :browser_type' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:quantity => 1,
      :take_all => true, :browser_type => 'firefox')
    grid.size.should == 0
  end

  it 'should fail to find any providers on the grid based on an unknown :browser_type' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:quantity => 1,
      :take_all => true, :browser_type => 'penguin')
    grid.size.should == 0
  end

  it 'should take any 1 provider on the grid based on specific :architecture' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:quantity => 1, 
      :take_all => true, :architecture => Config::CONFIG['arch'])
    grid.size.should == 1
  end

  it 'should fail to find any providers on the grid based on  an unknown :architecture' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:quantity => 1, 
      :take_all => true, :architecture => 'geos-2000')
    grid.size.should == 0
  end

  it 'should take any 1 provider on the grid based on specific :hostnames' do
    hostname = `hostname`.strip
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:quantity => 1,
      :take_all => true, 
      :hostnames => { hostname => '127.0.0.1'}
      )
    grid.size.should == 1
  end

  it 'should fail to find any providers on the grid based on unknown :hostnames' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:quantity => 1,
      :take_all => true, :hostnames => { 
        "tokyo" => "127.0.0.1"})
    grid.size.should == 0
  end

  it 'should get the UUID of the last provider on the grid' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:read_all => true)
    grid.browsers.each do |browser|
      @uuid = browser[:uuid]
    end
  end

  it 'should be able to find a provider by its UUID on the grid' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:read_all => true, :uuid => @uuid)
    grid.size.should == 1
  end
  
  it 'should take the last provider on the grid and execute some Watir code in Safari' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
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
        #b.button(:name, "btnI").click
        b.close
      end
    end
    threads.each {|thread| thread.join}
    grid.size.should == 1
  end

  it 'should find no more providers on the grid' do
    grid = Watir::Grid.new(:ring_server_port => 12357)
    grid.start(:read_all => true)
    grid.size.should == 0
  end 
end
