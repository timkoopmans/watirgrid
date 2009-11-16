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

  it 'should return how many browsers are available in the tuplespace' do
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:read_all => true)
    browsers.size.should == 5
  end

  it 'should read any 2 browsers in the tuplespace' do
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:quantity => 2, :read_all => true)
    browsers.size.should == 2
  end

  it 'should take any 1 browser in the tuplespace' do
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:quantity => 1, :take_all => true)
    browsers.size.should == 1 
  end

  it 'should take all browsers remaining in tuplespace' do
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:take_all => true)
    browsers.size.should == 4
  end

  it 'should find no more browsers in the tuplespace' do
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:read_all => true)
    browsers.size.should == 0
  end

  it 'should register 4 new browsers in the tuplespace' do
    1.upto(4) do 
      provider = Provider.new(:ring_server_port => 12351, 
        :loglevel => Logger::ERROR, :browser_type => 'safari')
      provider.start
    end
  end

  it 'should take any 1 browser based on browser type' do
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:quantity => 1,
      :take_all => true, :browser_type => 'safari')
    browsers.size.should == 1
  end

  it 'should fail to find any browsers based on a specific browser type' do
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:quantity => 1,
      :take_all => true, :browser_type => 'firefox')
    browsers.size.should == 0
  end

  it 'should fail to find any browsers based on a unknown browser type' do
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:quantity => 1,
      :take_all => true, :browser_type => 'penguin')
    browsers.size.should == 0
  end

  it 'should take any 1 browser based on specific architecture type' do
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:quantity => 1, 
      :take_all => true, :architecture => 'universal-darwin10.0')
    browsers.size.should == 1
  end

  it 'should fail to find any browsers based on unknown architecture type' do
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:quantity => 1, 
      :take_all => true, :architecture => 'geos-1992')
    browsers.size.should == 0
  end

  it 'should take any 1 browser based on specific hostname' do
    hostname = `hostname`.strip
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:quantity => 1,
      :take_all => true, 
      :hostnames => { hostname => "127.0.0.1"}
      )
    browsers.size.should == 1
  end

  it 'should fail to find any browsers based on unknown hostname' do
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:quantity => 1,
      :take_all => true, :hostnames => { 
        "tokyo" => "127.0.0.1"})
    browsers.size.should == 0
  end

  it 'should take the last browser and execute some watir commands' do
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:quantity => 1,
      :take_all => true)
      browsers.each do |browser, browser_id, hostname, arch, type|
        browser_id.should == 1
        hostname.should == `hostname`.strip
        arch.should == Config::CONFIG['arch']
        type.should == 'safari'
        browser.goto(
          "http://localhost:4567/load/#{browser_id}/#{browser.object_id}")
      end
    browsers.size.should == 1
  end

  it 'should find no more browsers in the tuplespace' do
    browsers = Watir::Grid.new(:ring_server_port => 12351)
    browsers.start(:read_all => true)
    browsers.size.should == 0
  end

  it 'should register a new browser on a remote provider' do
    pending('provision of remote registration') do
      browsers.size.should == 0
    end
  end

end

