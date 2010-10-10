require 'rubygems'
require '../lib/watirgrid'

grid = Watir::Grid.new(:ring_server_port => 12358, 
:ring_server_host => '192.168.1.102', 
:loglevel => Logger::DEBUG)
grid.start(:read_all => true)

threads = []
grid.browsers.each do |browser|
  threads << Thread.new do 
    b = browser[:object].new_browser
    b.goto("http://google.com.au/")
    b.text_field(:name, 'q').set("performance & test automation specialists")
    sleep 1
    b.button(:name, 'btnI').click
  end
end
threads.each {|thread| thread.join}