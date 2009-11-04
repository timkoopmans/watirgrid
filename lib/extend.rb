require 'rubygems'
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
  # Extend Watir with a Provider namespace
  # to determine which browser type is supported by the 
  # remote DRb process. This returns the DRb front object.
  #
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
    
end
