class WatirGrid

  attr_accessor :drb_server_uri, :ring_server, :browsers
  
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
    @ring_server = Rinda::RingFinger.new(@host, @ring_server_port)
    @ring_server = @ring_server.lookup_ring_any  
    
    @browsers = []
    all_services = @ring_server.read_all([:name, nil, nil, nil])

    @log.info("Found #{all_services.size} services.")
    all_services.each do |service|
      @browsers << service[2].new_browser
    end
  end

end
