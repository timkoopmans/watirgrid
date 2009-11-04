#!/usr/bin/env ruby 
# provider.rb
# Rinda Ring Provider

require 'rinda/ring'
require 'rinda/tuplespace'
require 'logger'
require 'extend'

class Provider
  
  attr_accessor :drb_server_uri, :ring_server_uri
  
  def initialize(properties = {}, logfile=STDOUT)   
    @host = properties[:interface] || external_interface
    @drb_server_port  = properties[:drb_server_port] || 0
    @ring_server_port = properties[:ring_server_port] || Rinda::Ring_PORT
    @renewer = properties[:renewer] || Rinda::SimpleRenewer.new
    
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
    # create a DRb 'front' object
    watir_provider = Watir::Provider.new

     # start the DRb Server
    drb_server = DRb.start_service("druby://#{@host}:#{@drb_server_port}")  

    # obtain DRb Server uri
    @drb_server_uri = drb_server.uri
    
    # log DRb server uri
    @log.info("DRb server started on: #{@drb_server_uri}")

    # create a service tuple
    @tuple = [:name, :WatirProvider, watir_provider, 'A watir provider']   
    
    # locate the Rinda Ring Server via a UDP broadcast
    ring_server = Rinda::RingFinger.new(@host, @ring_server_port)
    ring_server = ring_server.lookup_ring_any
    
    # advertise this service on the primary remote tuple space
    ring_server.write(@tuple, @renewer)
    
    # log DRb server uri
    @log.info("Ring Provider started.")
  
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
  provider = Provider.new(:ring_server_port => 12358)
	provider.start
end

    

