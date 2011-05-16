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
  # to determine which browser type is supported by the
  # remote DRb process. This returns the DRb front object.
  class Provider

    include DRbUndumped # all objects will be proxied, not copied
    attr_reader :browser

    def initialize(browser = nil)
      browser = (browser || 'tmp').downcase.to_sym
      case browser
        when :safari, :safariwatir
          require 'safariwatir'
          @browser = Watir::Safari
        when :firefox, :firewatir
          require 'firewatir'
          @browser = FireWatir::Firefox
        when :ie, :watir
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
        when :zombie
          require 'watir-zombie'
          @browser = Watir::Zombie
        when :selenium
          require 'selenium-webdriver'
          @browser = Selenium::WebDriver
      end
    end

    def new_browser(webdriver_browser_type = :firefox)
      case @browser.inspect
      when "Selenium::WebDriver"
        if webdriver_browser_type == :htmlunit
          caps = Selenium::WebDriver::Remote::Capabilities.htmlunit(:javascript_enabled => true)
          @browser.for(:remote, :url => "http://127.0.0.1:4444/wd/hub", :desired_capabilities => caps)
        else
          @browser.for webdriver_browser_type
        end
      when "Watir::Browser"
        if webdriver_browser_type == :htmlunit
          caps = Selenium::WebDriver::Remote::Capabilities.htmlunit(:javascript_enabled => true)
          @browser.new(:remote, :url => "http://127.0.0.1:4444/wd/hub", :desired_capabilities => caps)
        else
          @browser.new webdriver_browser_type
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

    ##
    # Get a list of running browsers (optionally specified by browser)
    # 'iexplore','firefox','firefox-bin','chrome','safari','opera'
    def get_running_browsers(browser=nil)
      browsers = browser || \
        ['iexplore','firefox','firefox-bin','chrome','safari','opera']
      case Config::CONFIG['arch']
      when /mswin/
        %x[tasklist].split(/\s+/).collect { |x| x[/\w+/]} \
          & browsers.collect { |x| x.downcase }
      when /linux|darwin/
        %x[ps -A | grep -v ruby].split(/\/|\s+/).collect { |x| x.downcase} \
          & browsers
      end
    end

    def get_running_processes
      %x[ps -A | grep -v ruby].split(/\/|\s+/).collect.uniq
    end

    ##
    # Kill any browser running
    def kill_all_browsers
      case Config::CONFIG['arch']
      when /mswin/
        browsers = ['iexplore.exe', 'firefox.exe', 'chrome.exe']
        browsers.each { |browser| %x[taskkill /F /IM #{browser}] }
      when /linux/
        browsers = ['firefox', 'chrome', 'opera']
        browsers.each { |browser| %x[killall -r #{browser}] }
      when /darwin/
        browsers = ['firefox-bin', 'Chrome', 'Safari']
        browsers.each { |browser| %x[pkill -9 #{browser}] }
      end
    end

    ##
    # Kill all browsers specified by browser name
    # Windows: 'iexplore.exe', 'firefox.exe', 'chrome.exe'
    # Linux: 'firefox', 'chrome', 'opera'
    # OSX: 'firefox-bin', 'Chrome', 'Safari'
    def kill_browser(browser)
      case Config::CONFIG['arch']
      when /mswin/
        %x[taskkill /F /IM #{browser}]
      when /linux/
        %x[killall -r #{browser}]
      when /darwin/
        %x[killall -m #{browser}]
      end
    end

    ##
    # Start firefox (with an optional bin path) using the -jssh extension
    def start_firefox_jssh(path=nil)
      case Config::CONFIG['arch']
      when /mswin/
        bin = path || "C:/Program Files/Mozilla Firefox/firefox.exe"
      when /linux/
        bin = path || "/usr/bin/firefox"
      when /darwin/
        bin = path || "/Applications/Firefox.app/Contents/MacOS/firefox-bin"
      end
      # fork off and die!
      Thread.new {system(bin, "about:blank", "-jssh")}
    end

    ##
    # Get the logged-in user
    def get_logged_in_user
      %x[whoami].chomp
    end

    ##
    # Grep for a process (Linux/OSX-with-port only)
    def process_grep(pattern)
      %x[pgrep -l #{pattern}].split(/\n/)
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

    @renewer = params[:renewer] || Rinda::SimpleRenewer.new
    @browser_type = params[:browser_type] || nil

    logfile = params[:logfile] || STDOUT
    @log  = Logger.new(logfile, 'daily')
    @log.level = params[:loglevel] || Logger::INFO
    @log.datetime_format = "%Y-%m-%d %H:%M:%S "

  end

  ##
  # Start providing watir objects on the ring server
  def start
    # create a DRb 'front' object
    watir_provider = Watir::Provider.new(@browser_type)
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
                @browser_type
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
