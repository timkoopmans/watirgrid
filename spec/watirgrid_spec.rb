require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require File.dirname(__FILE__) + '/../lib/controller.rb'

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
