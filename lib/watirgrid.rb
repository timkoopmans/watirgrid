require 'controller'
require 'provider'

module Watir

  ##
  # Extend Watir with a Grid class which
  # implements a grid of browsers by connecting to a tuplespace
  # and instatiating remote browser objects on nominated providers.
  class Grid

    attr_accessor :drb_server_uri, :ring_server, :browsers, :tuples

    def initialize(params = {})
      @drb_server_host  = params[:drb_server_host]  || external_interface
      @drb_server_port  = params[:drb_server_port]  || 0
      @ring_server_host = params[:ring_server_host] || external_interface
      @ring_server_port = params[:ring_server_port] || Rinda::Ring_PORT
      @renewer = params[:renewer] || Rinda::SimpleRenewer.new

      logfile = params[:logfile] || STDOUT
      @log  = Logger.new(logfile, 'daily')
      @log.level = params[:loglevel] || Logger::ERROR
      @log.datetime_format = "%Y-%m-%d %H:%M:%S "

      @browsers = []
      @tuples = []
    end

    ##
    # Start required services
    def start(params = {})
      start_drb_server
      find_ring_server
      get_tuples(params)
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
      drb_server = DRb.start_service(
        "druby://#{@drb_server_host}:#{@drb_server_port}")
      @drb_server_uri = drb_server.uri
      @log.info("DRb server started on : #{@drb_server_uri}")
    end

    ##
    # Locate the Rinda Ring Server via a UDP broadcast
    def find_ring_server
      @ring_server = Rinda::RingFinger.new(
        @ring_server_host, @ring_server_port)
      @ring_server = @ring_server.lookup_ring_any
      @log.info("Ring server found on : druby://#{@ring_server_host}:#{@ring_server_port}")
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
        params[:browser_type]
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
      tuple_hash[:browser_type] = tuple[6]
      tuple_hash
    end

  end

end
