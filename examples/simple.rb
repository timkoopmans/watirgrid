require 'rubygems'
require '../lib/watirgrid'

grid = Watir::Grid.new(:ring_server_port => 12358, 
:ring_server_host => '192.168.1.103', :loglevel => Logger::DEBUG)
grid.start(:quantity => 2, :read_all => true)

threads = []
grid.browsers.each do |browser|
  threads << Thread.new do 
    b = browser[:object].new_browser
    b.goto("http://www.dphoto.com")
    # b.text_field(:name, 'q').set("watirgrid")
    # b.button(:name, "btnI").click
  end
end
threads.each {|thread| thread.join}