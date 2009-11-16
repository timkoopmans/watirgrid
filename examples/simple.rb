require 'rubygems'
require '../lib/watirgrid'

browsers = Watir::Grid.new(:ring_server_port => 12358, :loglevel => Logger::DEBUG)
browsers.start(:quantity => 1, :read_all => true, :browser_type => 'ie')
browsers.each do |browser, browser_id, hostname, arch, type|
  browser.goto("http://www.google.com")
  browser.text_field(:name, 'q').set("watirgrid")
  browser.button(:name, "btnI").click
end