#!/usr/bin/env ruby 
# controller.rb
# Rinda Ring Server Controlller
require 'rinda/tuplespace'
require 'rinda/ring'
require 'logger'
require 'extend'

class Controller
  
  attr_accessor :drb_server_uri, :ring_server_uri
  
  def initialize(properties = {}, logfile=STDOUT)    
    @host = properties[:interface] || external_interface
    @drb_server_port  = properties[:drb_server_port] || 0
    @ring_server_port = properties[:ring_server_port] || Rinda::Ring_PORT
    
    @logfile = logfile
    @log  = Logger.new(logfile, 'daily')
    @log.level = Logger::INFO
    @log.datetime_format = "%Y-%m-%d %H:%M:%S "    
  end  
  
  def external_interface    
    # get the external facing interface for this server
    UDPSocket.open {|s| s.connect('watir.com', 1); s.addr.last }      
  end
  
  def start  
    # create a parent Tuple Space
    tuple_space = Rinda::TupleSpace.new
    
    # start the DRb Server
    drb_server = DRb.start_service("druby://#{@host}:#{@drb_server_port}", tuple_space)  
    
    # obtain DRb Server uri
    @drb_server_uri = drb_server.uri
    
    # log DRb server uri
    @log.info("DRb server started on: #{@drb_server_uri}")
    
    # start the Ring Server
    ring_server = Rinda::RingServer.new(tuple_space, @host, @ring_server_port)
    
    # obtain Ring Server uri
    @ring_server_uri = ring_server.uri
    
    # log Ring Server uri
    @log.info("Ring server started on: #{@ring_server_uri}")

    # abort all threads on an exception
    Thread.abort_on_exception = true

    # wait for explicit stop via ctrl-c
    DRb.thread.join if __FILE__ == $0   
  end
  
  def stop    
    # stop the DRb Server
    DRb.stop_service
    
    # log server stopped
    @log.info("DRb server stopped on: #{@drb_server_uri}")    
  end
  
end

if __FILE__ == $0  
  controller = Controller.new(:drb_server_port => 11235, :ring_server_port => 12358)
	controller.start	
end