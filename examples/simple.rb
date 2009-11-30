require 'rubygems'
require '../lib/watirgrid'

browsers = Watir::Grid.new(:ring_server_port => 12358, 
:ring_server_host => '192.168.1.122', :loglevel => Logger::DEBUG)
@browsers = browsers.start(:quantity => 2, :read_all => true)

threads = []
@browsers.each do |browser|
  threads << Thread.new do 
    b = browser[:object].new_browser
    b.goto("http://www.google.com")
    b.text_field(:name, 'q').set("watirgrid")
    b.button(:name, "btnI").click
  end
end
threads.each {|thread| thread.join}