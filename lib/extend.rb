require 'rubygems'
require 'firewatir'
include FireWatir

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
  
  class Provider

    include DRbUndumped

    attr_reader :browser

    def initialize    
      @browser = FireWatir::Firefox    
    end

    def new_browser   
      @browser.new   
  	end 

  end
  
  
end
