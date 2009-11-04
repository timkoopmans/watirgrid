#!/usr/bin/env ruby 
# client.rb
# Rinda Client
require 'rinda/ring'
require 'logger'

class Client
  
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
     # start the DRb Server
    drb_server = DRb.start_service("druby://#{@host}:#{@drb_server_port}")  

    # obtain DRb Server uri
    @drb_server_uri = drb_server.uri
    
    # log DRb server uri
    @log.info("DRb server started on: #{@drb_server_uri}")
     
    # locate the Rinda Ring Server via a UDP broadcast
    ring_server = Rinda::RingFinger.new(@host, @ring_server_port)
    ring_server = ring_server.lookup_ring_any

    # discover all named services on the Ring Server
    all_services = ring_server.read_all([:name, nil, nil, nil])

    puts "Found #{all_services.size} services."
    all_services.each do |svc|
      puts "Service Name: #{svc[1]}\nService Description: #{svc[3]}"
      @browser = svc[2].new_browser
    end
    
  end
  
end

if __FILE__ == $0 
  client = Client.new(:ring_server_port => 12358)
	client.start
end



