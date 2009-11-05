require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.dirname(__FILE__) + '/../lib/controller.rb'
require File.dirname(__FILE__) + '/../lib/provider.rb'
require File.dirname(__FILE__) + '/../lib/watirgrid.rb'

describe WatirGrid do
  before(:all) do
    @controller = Controller.new(:ring_server_port => 12351, :loglevel => Logger::ERROR)
    @controller.start
    @provider = Provider.new(:ring_server_port => 12351, :loglevel => Logger::ERROR, :browser_type => 'safari')
  	@provider.start
  end
  
  it 'should read all tuples' do
    grid = WatirGrid.new(:ring_server_port => 12351)
  	grid.start
  	grid.read_all
  	grid.browsers.size.should == 1
  end

  it 'should take all tuples' do
    grid = WatirGrid.new(:ring_server_port => 12351)
  	grid.start
  	grid.take_all
  	grid.browsers.size.should == 1
  end
  
  it 'should find no more tuples' do
    grid = WatirGrid.new(:ring_server_port => 12351)
  	grid.start
  	grid.read_all
  	grid.browsers.size.should == 0
  end
  
  it 'should provide a new tuple' do
    @provider = Provider.new(:ring_server_port => 12351, :loglevel => Logger::ERROR, :browser_type => 'safari')
  	@provider.start
  	grid = WatirGrid.new(:ring_server_port => 12351)
  	grid.start
  	grid.read_all
  	grid.browsers.size.should == 1
  end
  
  it 'should take the new tuple and create another one' do
    grid = WatirGrid.new(:ring_server_port => 12351)
  	grid.start
  	grid.take_all
  	grid.browsers.size.should == 1
  	@provider = Provider.new(:ring_server_port => 12351, :loglevel => Logger::ERROR, :browser_type => 'safari')
  	@provider.start
  	grid = WatirGrid.new(:ring_server_port => 12351)
  	grid.start
  	grid.read_all
  	grid.browsers.size.should == 1
  end
  
  it 'should register a tuple on a remote provider' do
    pending('provision of remote registration') do
      grid.browsers.size.should == 1
    end
  end
  
  after(:all) do
    @provider.stop
    @controller.stop
  end
end
