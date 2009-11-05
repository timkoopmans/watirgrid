class WatirGrid

  attr_accessor :drb_server_uri, :ring_server, :browsers
  
  ##
  # initialize
  def initialize(properties = {})   
    @host = properties[:interface]  || external_interface
    @drb_server_port  = properties[:drb_server_port]  || 0
    @ring_server_port = properties[:ring_server_port] || Rinda::Ring_PORT
    @renewer = properties[:renewer] || Rinda::SimpleRenewer.new
    
    logfile = properties[:logfile] || STDOUT
    @log  = Logger.new(logfile, 'daily')
    @log.level = properties[:loglevel] || Logger::ERROR
    @log.datetime_format = "%Y-%m-%d %H:%M:%S "   
  end  
  
  ##
  # get the external facing interface for this server 
  
  def external_interface   
    UDPSocket.open {|s| s.connect('watir.com', 1); s.addr.last }     
  end
  
  ##
  # start required servers
  
  def start
    start_drb_server
    find_ring_server
  end
  
  ##
  # start the DRb Server
  
  def start_drb_server
    drb_server = DRb.start_service("druby://#{@host}:#{@drb_server_port}")  
    @drb_server_uri = drb_server.uri
    @log.info("DRb server started on : #{@drb_server_uri}")
  end
  
  ##
  # locate the Rinda Ring Server via a UDP broadcast
  
  def find_ring_server
    @ring_server = Rinda::RingFinger.new(@host, @ring_server_port)
    @ring_server = @ring_server.lookup_ring_any
    @log.info("Ring server found on : druby://#{@host}:#{@ring_server_port}")
  end
  
  ##
  # read all tuple spaces on ringserver
  
  def read_all
    @browsers = []
    all_services = @ring_server.read_all([:name, nil, nil, nil])

    @log.info("Found #{all_services.size} services.")
    all_services.each do |service|
      @browsers << service[2].new_browser
    end
  end
  
  ##
  # take all tuple spaces on ringserver
  
  def take_all
    @browsers = []
    all_services = @ring_server.read_all([:name, nil, nil, nil])

    @log.info("Found #{all_services.size} services.")
    all_services.each do |service|
      @ring_server.take(service)
      @browsers << service[2].new_browser
    end
  end

end
