require 'rubygems'
require 'controller'
require 'provider'
begin
    require 'watir'
rescue LoadError
end

begin
    require 'safariwatir'
rescue LoadError
end

begin
    require 'firewatir'
    include FireWatir
rescue LoadError
end

module Rinda
  #
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

module Watir
  #
  # Extend Watir with a Provider class
  # to determine which browser type is supported by the 
  # remote DRb process. This returns the DRb front object.
  class Provider

    include DRbUndumped

    attr_reader :browser

    def initialize(browser = nil)
        browser = (browser || 'tmp').downcase.to_sym  
        case browser
        when :safari
          @browser = Watir::Safari
        when :firefox
          @browser = FireWatir::Firefox 
        when :ie
          @browser = Watir::IE
        else
          @browser = find_supported_browser
        end    
    end
    
    def find_supported_browser
        if Watir::Safari then return Watir::Safari end
        if Watir::IE then return Watir::IE end
        if FireWatir::Firefox then return FireWatir::Firefox end
    end

    def new_browser   
      if @browser.nil?
        find_supported_browser.new
      else
        @browser.new
      end 
  	end 

  end
  
  ##
  # Extend Watir with a Grid class which 
  # implements a grid of browsers by connecting to a tuplespace
  # and instatiating remote browser objects on nominated providers.
  class Grid

    attr_accessor :drb_server_uri, :ring_server, :browsers

    def initialize(params = {})   
      @host = params[:interface]  || external_interface
      @drb_server_port  = params[:drb_server_port]  || 0
      @ring_server_port = params[:ring_server_port] || Rinda::Ring_PORT
      @renewer = params[:renewer] || Rinda::SimpleRenewer.new

      @quantity = params[:quantity]
      
      logfile = params[:logfile] || STDOUT
      @log  = Logger.new(logfile, 'daily')
      @log.level = params[:loglevel] || Logger::ERROR
      @log.datetime_format = "%Y-%m-%d %H:%M:%S "   
    end  

    ##
    # Start required services
    def start(params = {})
      quantity = params[:quantity] || -1  
      start_drb_server
      find_ring_server
      read_all(quantity) if params[:read_all]
      take_all(quantity) if params[:take_all]
    end
    
    ##
    # Yield a browser object when iterating over the grid of browsers
    def each
      threads = []
      id = 0
      @browsers.each do |browser|
        threads << Thread.new do 
          id += 1
          yield(browser, id)
        end
      end
      threads.each {|thread| thread.join}
    end

    ##
    # Return the size (quantity) of browsers started on the grid
    def size
      @browsers.size
    end
    
    def index
      @browsers.index(self)
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

    ##
    # Start the DRb Server
    def start_drb_server
      drb_server = DRb.start_service("druby://#{@host}:#{@drb_server_port}")  
      @drb_server_uri = drb_server.uri
      @log.info("DRb server started on : #{@drb_server_uri}")
    end

    ##
    # Locate the Rinda Ring Server via a UDP broadcast
    def find_ring_server
      @ring_server = Rinda::RingFinger.new(@host, @ring_server_port)
      @ring_server = @ring_server.lookup_ring_any
      @log.info("Ring server found on : druby://#{@host}:#{@ring_server_port}")
    end

    ##
    # Read all tuple spaces on ringserver
    def read_all(quantity)
      @browsers = []
      all_services = @ring_server.read_all([:name, nil, nil, nil])

      @log.info("Found #{all_services.size} services.")
      all_services[1..quantity].each do |service|
        @browsers << service[2].new_browser
      end
    end

    ##
    # Take all tuple spaces on ringserver
    def take_all(quantity)
      @browsers = []
      all_services = @ring_server.read_all([:name, nil, nil, nil])

      @log.info("Found #{all_services.size} services.")
      all_services[1..quantity].each do |service|
        @ring_server.take(service)
        @browsers << service[2].new_browser
      end
    end

  end
  
    
end
