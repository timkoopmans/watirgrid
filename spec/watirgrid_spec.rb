require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.dirname(__FILE__) + '/../lib/controller.rb'
require File.dirname(__FILE__) + '/../lib/provider.rb'
require File.dirname(__FILE__) + '/../lib/watirgrid.rb'

describe Controller do
  it 'should start a DRb and Ring Server when specifying NO interface or port' do
    controller = Controller.new
    controller.start
    controller.drb_server_uri.should =~ /druby/
    controller.stop
  end
  
  it 'should start a DRb and Ring Server on a specified interface' do
    controller = Controller.new(:interface => '127.0.0.1')
    controller.start
    controller.drb_server_uri.should =~ /druby/
    controller.stop
  end
	
	it 'should start a DRb and Ring Server on specified ports' do
		controller = Controller.new(:drb_server_port => 11235, :ring_server_port => 12358)
		controller.start
		controller.drb_server_uri.should =~ /druby/
		controller.stop
	end
end

describe Provider do
  before(:all) do
    @controller = Controller.new(:ring_server_port => 12350)
    @controller.start
  end
  
  it 'should register a new provider on a specified port' do
    provider = Provider.new(:ring_server_port => 12350)
  	provider.start
  end
  
  after(:all) do
    @controller.stop
  end
end

describe WatirGrid do
  before(:all) do
    @controller = Controller.new(:ring_server_port => 12351)
    @controller.start
    @provider = Provider.new(:ring_server_port => 12351)
  	@provider.start
  end
  
  it 'should find a default browser registered on a ring server specified by port' do
    grid = WatirGrid.new(:ring_server_port => 12351)
  	grid.start
  	grid.browsers.size.should == 1
  end
  
  it 'should find a safari browser registered on a ring server specified by port' do
    @provider = Provider.new(:ring_server_port => 12351, :browser => 'safari')
  	@provider.start
    grid = WatirGrid.new(:ring_server_port => 12351)
  	grid.start
  	grid.browsers.size.should == 2
  	threads = []
    grid.browsers.each { |browser|
        threads << Thread.new do 
            browser.goto("http://www.google.com")
            browser.text_field(:name, 'q').set("github watirgrid")
            browser.button(:name, "btnI").click
        end
    }
    threads.each {|thread| thread.join}
  end
  
  it 'should find a firefox browser registered on a ring server specified by port' do
    @provider = Provider.new(:ring_server_port => 12351, :browser => 'firefox')
  	@provider.start
    grid = WatirGrid.new(:ring_server_port => 12351)
  	grid.start
  	grid.browsers.size.should == 3
  	threads = []
    grid.browsers.each { |browser|
        threads << Thread.new do 
            sleep 5 # to wait for Firefox to startup
            browser.goto("http://www.google.com")
            browser.text_field(:name, 'q').set("github watirgrid")
            browser.button(:name, "btnI").click
        end
    }
    threads.each {|thread| thread.join}
  end
    
  after(:all) do
    @provider.stop
    @controller.stop
  end
end
