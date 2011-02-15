#!/usr/bin/env ruby 
# remote.rb
# Rinda Ring Provider

require 'rinda/ring'
require 'rinda/tuplespace'
require 'logger'
require 'drb/acl'
require 'uuid'
require 'selenium/server'
include Selenium
@server = Selenium::Server.new(File.expand_path(File.dirname(__FILE__)) + '/selenium-server-standalone-2.0b1.jar', :background => true)
@server.start  

module Watir
  class Provider

    include DRbUndumped # all objects will be proxied, not copied

    attr_reader :browser

    def initialize(browser = nil)
      browser = (browser || 'tmp').downcase.to_sym 
      case browser
				when :webdriver_remote
					require 'watir-webdriver'
          @browser = Watir::Browser
      end    
    end
  
    def new_browser(webdriver_browser_type = nil)
      if webdriver_browser_type == :htmlunit 
        capabilities = WebDriver::Remote::Capabilities.htmlunit(:javascript_enabled => true)
        @browser.new(:remote, :url => "http://127.0.0.1:4444/wd/hub", :desired_capabilities => capabilities)
      end
    end
  
  end
end
