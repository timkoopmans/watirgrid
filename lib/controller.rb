#!/usr/bin/env ruby 
# controller.rb
# Rinda Ring Server Controlller

require 'rinda/tuplespace'
require 'rinda/ring'
require 'logger'
require 'optparse'

class Controller
  
  attr_accessor :drb_server_uri, :ring_server_uri
  
  def initialize(params = {})    
    @host = params[:interface]  || external_interface
    @drb_server_port  = params[:drb_server_port]  || 0
    @ring_server_port = params[:ring_server_port] || Rinda::Ring_PORT
    
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
    
    # start the DRb Server
    drb_server = DRb.start_service("druby://#{@host}:#{@drb_server_port}", tuple_space)  
    
    # obtain DRb Server uri
    @drb_server_uri = drb_server.uri
    @log.info("DRb server started on : #{@drb_server_uri}")
    
    # start the Ring Server
    ring_server = Rinda::RingServer.new(tuple_space, @host, @ring_server_port)
    
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
      UDPSocket.open {|s| s.connect('watir.com', 1); s.addr.last }      
    rescue
      '127.0.0.1'
    end
  end
  
end

if __FILE__ == $0   
  options = {}
    OptionParser.new do |opts|
      opts.banner = "Usage: controller.rb [options]"
      opts.separator ""
      opts.separator "Specific options:"
      opts.on("-d PORT", "--drb-server-port", Integer, 
      "Specify DRb Server port to listen on") do |d|
        options[:drb_server_port] = d
      end              
      opts.on("-r PORT", "--ring-server-port", Integer, 
      "Specify Ring Server port to listen on") do |r|
        options[:ring_server_port] = r 
      end
      opts.on("-l LEVEL", "--log-level", String, 
      "Specify log level {DEBUG|INFO|ERROR}") do |l|
        case l
        when 'DEBUG'
          options[:loglevel] = Logger::DEBUG
        when 'INFO'
          options[:loglevel] = Logger::INFO 
        when 'ERROR'
          options[:loglevel] = Logger::ERROR
        else
          options[:loglevel] = Logger::ERROR
        end
      end
      opts.on_tail("-h", "--help", "Show this message") do
        puts opts
        exit
      end          
    end.parse!
  
  controller = Controller.new(
  :drb_server_port  => options[:drb_server_port]  || 11235, 
  :ring_server_port => options[:ring_server_port] || 12358,
  :loglevel => options[:loglevel]
  )
	controller.start	
end