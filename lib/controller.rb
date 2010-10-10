#!/usr/bin/env ruby 
# controller.rb
# Rinda Ring Server Controlller

require 'rubygems'
require 'rinda/tuplespace'
require 'rinda/ring'
require 'logger'
require 'optparse'
require 'drb/acl'

module Rinda

  ##
  # Extend Rinda::RingServer to allow a hostname/ipaddress
  # to be passed in as parameter arguments. Also pass back
  # attribute for ring server uri.
  #
  class RingServer
    attr_accessor :uri

    def initialize(ts, host='', port=Ring_PORT)
      @uri = "druby://#{host}:#{port}"
      @ts = ts
      @soc = UDPSocket.open
      @soc.bind(host, port)
      @w_service = write_service
      @r_service = reply_service
    end
  end
end

class Controller

  attr_accessor :drb_server_uri, :ring_server_uri

  def initialize(params = {})
    @drb_server_host  = params[:drb_server_host]  || external_interface    
    @drb_server_port  = params[:drb_server_port]  || 0
    @ring_server_host = params[:ring_server_host] || external_interface
    @ring_server_port = params[:ring_server_port] || Rinda::Ring_PORT
    @acls = params[:acls]

    logfile = params[:logfile] || STDOUT
    @log  = Logger.new(logfile, 'daily')
    @log.level = params[:loglevel] || Logger::INFO
    @log.datetime_format = "%Y-%m-%d %H:%M:%S "    

    @log.debug("DRB Server Port #{@drb_server_port}\nRing Server Port #{@ring_server_port}")
  end

  ##
  # Start a new tuplespace on the ring server
  def start  
    # create a parent Tuple Space
    tuple_space = Rinda::TupleSpace.new

    # Setup the security--remember to call before DRb.start_service()
    DRb.install_acl(ACL.new(@acls))

    # start the DRb Server
    drb_server = DRb.start_service(
      "druby://#{@drb_server_host}:#{@drb_server_port}", tuple_space)  

    # obtain DRb Server uri
    @drb_server_uri = drb_server.uri
    @log.info("DRb server started on : #{@drb_server_uri}")

    # start the Ring Server
    ring_server = Rinda::RingServer.new(tuple_space, 
      @ring_server_host, @ring_server_port)

    # obtain Ring Server uri
    @ring_server_uri = ring_server.uri  
    @log.info("Ring server started on: #{@ring_server_uri}")

    # abort all threads on an exception
    Thread.abort_on_exception = true

    # wait for explicit stop via ctrl-c
    DRb.thread.join if __FILE__ == $0   
  end

  ##
  # Stop the controller by shutting down the DRb service
  def stop    
    DRb.stop_service
    @log.info("DRb server stopped on: #{@drb_server_uri}")    
  end

  private

  ##
  # Get the external facing interface for this server  
  def external_interface    
    begin
      UDPSocket.open {|s| s.connect('ping.watirgrid.com', 1); s.addr.last }      
    rescue
      '127.0.0.1'
    end
  end

end

