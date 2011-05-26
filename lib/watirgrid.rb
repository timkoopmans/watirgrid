require 'controller'
require 'provider'
require 'listener'

module Watir

  ##
  # Extend Watir with a Grid class which
  # implements a grid of browsers by connecting to a tuplespace
  # and instatiating remote browser objects on nominated providers.
  class Grid

    attr_accessor :drb_server_uri, :ring_server, :browsers, :tuples, :providers

    def initialize(params = {})
      @drb_server_host      = params[:drb_server_host]  || external_interface
      @drb_server_port      = params[:drb_server_port]  || 0
      @controller_uri       = params[:controller_uri]
      @ring_server_host     = params[:ring_server_host] || external_interface unless @controller_uri
      @ring_server_port     = params[:ring_server_port] || Rinda::Ring_PORT
      @renewer              = params[:renewer] || Rinda::SimpleRenewer.new
      logfile               = params[:logfile] || STDOUT
      @log                  = Logger.new(logfile, 'daily')
      @log.level            = params[:loglevel] || Logger::ERROR
      @log.datetime_format  = "%Y-%m-%d %H:%M:%S "
      @browser_type         = params[:browser_type]
      @browsers             = []
      @tuples               = []
      @providers            = []
    end

    ##
    # Start required services
    def start(params = {})
      start_drb_server
      find_ring_server(params)
      get_tuples(params)
      setup if params[:initiate]
    end

    ##
    # Return the size (quantity) of browsers started on the grid
    def size
      @browsers.size
    end

    ##
    # Write tuple back to tuplespace when finished using it
    def release_tuples
      @tuples.each { |tuple| @ring_server.write(tuple) }
    end

    ##
    # Instantiate new browser object on each of the remote providers
    def setup
      @browsers.each_with_index do |browser, index|
        sleep 0.15
        @providers[index] ||= browser[:object].new_browser @browser_type
      end
    end

    ##
    # Iterate with a block over each of the remote providers
    def iterate &block
      threads = []
      @providers.each do |browser|
        threads << Thread.new do
          yield browser
        end
      end
      threads.each {|thread| thread.join}
    end

    ##
    # This is a helper method to control a grid.
    def self.control(params = {}, &block)
      log  = Logger.new(STDOUT, 'daily')
      log.level = params[:loglevel] || Logger::ERROR
      grid = self.new(params)
      grid.start(:read_all => true)
      threads = []
      grid.browsers.each_with_index do |browser, index|
        sleep rampup(grid.size, params)
        threads << Thread.new do
          start = ::Time.now
          @browser = browser[:object].new_browser params[:browser_type]
          yield @browser, "#{index}"
        end
      end
      threads.each {|thread| thread.join}
    end

    private

    ##
    # Calculate rampup in seconds
    def self.rampup(total_threads, params = {})
      if params[:rampup]
        params[:rampup] / total_threads
      else
        0.5
      end
    end

    ##
    # Get the external facing interface for this server
    def external_interface
      begin
        UDPSocket.open {|s| s.connect('ping.watirgrid.com', 1); s.addr.last }
      rescue
        '127.0.0.1'
      end
    end

    ##
    # Start the DRb Server
    def start_drb_server
      drb_server = DRb.start_service(
        "druby://#{@drb_server_host}:#{@drb_server_port}")
      @drb_server_uri = drb_server.uri
      @log.info("Watir Grid started on : #{@drb_server_uri}")
    end

    ##
    # Locate the Rinda Ring Server via a UDP broadcast or direct URI
    def find_ring_server(params = {})
      if @controller_uri
        @ring_server = DRbObject.new(nil, @controller_uri)
      else
        @ring_server = Rinda::RingFinger.new(
          @ring_server_host, @ring_server_port)
        @ring_server = @ring_server.lookup_ring_any
        @controller_uri = "druby://#{@ring_server_host}:#{@ring_server_port}"
      end
      @log.info("Controller found on   : #{@controller_uri}")
    end

    ##
    # Get all tuple spaces on ringserver
    def get_tuples(params = {})
      quantity = calculate_quantity(params[:quantity])
      read_tuples(params)
      @log.info("Found #{@tuples.size} tuples.")
      if @tuples.size > -1 then
        @tuples[0..quantity].each do |tuple|
          if params[:hostnames]
            filter_tuple_by_hostname(tuple, params)
          else
            add_tuple_to_browsers(tuple)
            take_tuple(tuple) if params[:take_all] == true
          end
        end
      end
    end

    ##
    # Sets the quantity (upper limit of array) of tuples to retrieve
    # This is because some users prefer not to specify a zero based
    # index when asking for n browsers
    def calculate_quantity(quantity)
      if (quantity.nil? or quantity == 0) then
        quantity = -1
      else
        quantity -= 1
      end
    end

    ##
    # Read all tuples filtered by architecture and browser type
    # then populate the tuples accessor
    def read_tuples(params={})
      @tuples = @ring_server.read_all([
        :WatirGrid,
        nil, # watir provider
        nil, # browser front object
        nil, # provider description
        nil, # hostname
        params[:architecture],
        params[:driver]
        ])
    end

    ##
    # Filter tuple by hostnames
    def filter_tuple_by_hostname(tuple, params={})
      hostname = tuple[4]
      if (params[:hostnames][hostname]) then
        add_tuple_to_browsers(tuple)
        take_tuple(tuple) if params[:take_all] == true
      end
    end

    ##
    # Add a tuple to the browsers accessor
    def add_tuple_to_browsers(tuple)
      @browsers <<  tuple_to_hash(tuple)
    end

    ##
    # Take a tuple from the tuple space
    def take_tuple(tuple)
      @ring_server.take(tuple)
    end

    ##
    # Convert tuple into a hash for easier handling
    def tuple_to_hash(tuple)
      tuple_hash = {}
      tuple_hash[:name]         = tuple[0]
      tuple_hash[:class]        = tuple[1]
      tuple_hash[:object]       = tuple[2]
      tuple_hash[:description]  = tuple[3]
      tuple_hash[:hostname]     = tuple[4]
      tuple_hash[:architecture] = tuple[5]
      tuple_hash[:driver]       = tuple[6]
      tuple_hash
    end

  end

end
