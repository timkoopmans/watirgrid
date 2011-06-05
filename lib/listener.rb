#!/usr/bin/env ruby
# listener.rb
# Controller Listener (for debugging)

require 'rinda/ring'

class Listener

  def initialize(params = {})
    @controller_uri   = params[:controller_uri]
    logfile = STDOUT
    @log  = Logger.new(logfile, 'daily')
    @log.level = Logger::DEBUG
    @log.datetime_format = "%Y-%m-%d %H:%M:%S "
  end

  def start
    DRb.start_service
    ring_server = DRbObject.new(nil, @controller_uri)
    service = ring_server.read([:WatirGrid, nil, nil, nil, nil, nil, nil, nil])
    observers = []
    observers << ring_server.notify('write',[:WatirGrid, nil, nil, nil, nil, nil, nil, nil], nil)
    observers << ring_server.notify('take', [:WatirGrid, nil, nil, nil, nil, nil, nil, nil], nil)
    observers << ring_server.notify('delete', [:WatirGrid, nil, nil, nil, nil, nil, nil, nil], nil)
    @log.debug("Listener started on   : #{@controller_uri}")
    threads = []
    observers.each do |observer|
      threads << Thread.new do
        observer.each do |event|
          @log.debug(event.inspect)
        end
      end
    end
    # abort all threads on an exception
    Thread.abort_on_exception = true

    # wait for explicit stop via ctrl-c
    DRb.thread.join if __FILE__ == $0
  end
end
