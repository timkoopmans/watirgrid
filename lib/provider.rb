#!/usr/bin/env ruby
# provider.rb
# Rinda Ring Provider

require 'rinda/ring'
require 'rinda/tuplespace'
require 'logger'
require 'drb/acl'

module Watir

  ##
  # Extend Watir with a Provider class
  # to determine which driver type is supported by the
  # remote DRb process. This returns the DRb front object.
  class Provider

    include DRbUndumped # all objects will be proxied, not copied
    attr_reader :browser

    def initialize(driver=nil)
      case driver.downcase.to_sym
        when :safariwatir
          require 'safariwatir'
          @browser = Watir::Safari
        when :firewatir
          require 'firewatir'
          @browser = FireWatir::Firefox
        when :watir
          require 'watir'
          @browser = Watir::IE
        when :webdriver
          require 'watir-webdriver'
          @browser = Watir::Browser
        when :webdriver_performance
          require 'watir-webdriver'
          require 'watir-webdriver-performance'
          @browser = Watir::Browser
        when :webdriver_remote
          require 'watir-webdriver'
          require 'selenium-webdriver'
          @browser = Watir::Browser
        when :selenium
          require 'selenium-webdriver'
          @browser = Selenium::WebDriver
      end
    end

    def new_browser(browser_type='firefox')
      case @browser.inspect
      when "Selenium::WebDriver"
        if browser_type == :htmlunit
          caps = Selenium::WebDriver::Remote::Capabilities.htmlunit(:javascript_enabled => true)
          @browser.for(:remote, :url => "http://127.0.0.1:4444/wd/hub", :desired_capabilities => caps)
        else
          @browser.for browser_type.to_sym
        end
      when "Watir::Browser"
        if @browser_type == :htmlunit
          caps = Selenium::WebDriver::Remote::Capabilities.htmlunit(:javascript_enabled => true)
          @browser.new(:remote, :url => "http://127.0.0.1:4444/wd/hub", :desired_capabilities => caps)
        else
          @browser.new browser_type.to_sym
        end
      when "Watir::Safari"
        @browser.new
      when "FireWatir::Firefox"
        @browser.new
      when "Watir::IE"
        @browser.new
      else
        @browser.new
      end
    end

    def renew_provider
      self.class.superclass
    end

  end

end

class Provider

  attr_accessor :drb_server_uri, :ring_server_uri

  def initialize(params = {})
    @drb_server_host  = params[:drb_server_host]  || external_interface
    @drb_server_port  = params[:drb_server_port]  || 0
    @ring_server_host = params[:ring_server_host] || external_interface
    @ring_server_port = params[:ring_server_port] || Rinda::Ring_PORT
    @controller_uri   = params[:controller_uri]
    @renewer          = params[:renewer]          || Rinda::SimpleRenewer.new
    @driver           = params[:driver]           || 'webdriver'
    @browser_type     = params[:browser_type]     || 'firefox'

    logfile = params[:logfile] || STDOUT
    @log  = Logger.new(logfile, 'daily')
    @log.level = params[:loglevel] || Logger::INFO
    @log.datetime_format = "%Y-%m-%d %H:%M:%S "
  end

  ##
  # Start providing Watir objects on the ring server
  def start(params = {})
    # create a DRb 'front' object
    watir_provider = Watir::Provider.new(@driver)
    @log.debug("Watir provider is     : #{watir_provider}")
    architecture = Config::CONFIG['arch']
    hostname = ENV['SERVER_NAME'] || %x{hostname}.strip

    # setup the security--remember to call before DRb.start_service()
    DRb.install_acl(ACL.new(@acls))

    # start the DRb Server
    drb_server = DRb.start_service(
      "druby://#{@drb_server_host}:#{@drb_server_port}")

    # obtain DRb Server uri
    @drb_server_uri = drb_server.uri
    @log.info("Provider started on   : #{@drb_server_uri}")

    # create a service tuple
    @tuple = [
                :WatirGrid,
                :WatirProvider,
                watir_provider,
                'A watir provider',
                hostname,
                architecture,
                @driver
    ]

    # locate the Rinda Ring Server via a UDP broadcast
    @log.debug("Broadcast Ring Server : druby://#{@ring_server_host}:#{@ring_server_port}")
    find_ring_server

    # advertise this service on the primary remote tuple space
    @ring_server.write(@tuple, @renewer)

    # log DRb server uri
    @log.info("Provider registered   : #{@controller_uri}")

    # wait for explicit stop via ctrl-c
    DRb.thread.join if __FILE__ == $0
  end

  ##
  # Stop the provider by shutting down the DRb service
  def stop
    DRb.stop_service
    @log.info("Provider stopped on   : #{@drb_server_uri}")
  end

  private

  ##
  # Locate the Rinda Ring Server via a UDP broadcast or direct URI
  def find_ring_server
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
  # Get the external facing interface for this server
  def external_interface
    begin
      UDPSocket.open {|s| s.connect('ping.watirgrid.com', 1); s.addr.last }
    rescue
      '127.0.0.1'
    end
  end
end
