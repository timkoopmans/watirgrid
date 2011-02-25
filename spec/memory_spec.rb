require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'ruby-prof'
RubyProf.measure_mode = RubyProf::MEMORY
# requires a GC patch to rubies http://patshaughnessy.net/2010/9/28/ruby187gc-patch

def total_memory_kilobytes(result)
  total = 0
  result.threads.each do |thread_id, methods|
    total += methods.sort.last.total_time if methods.sort.last.total_time < 2*1024*1024
  end
  p total
  #printer = RubyProf::FlatPrinter.new(result)
  #printer.print(STDOUT, 0)
  total
end

describe 'Profile memory of grid elements' do

  it 'Footprint of single contoller should be less than 100KB' do
    result = RubyProf.profile do
      controller = Controller.new(:loglevel => Logger::ERROR)
      controller.start
      controller.drb_server_uri.should =~ /druby/
    end
      total_memory_kilobytes(result).should < 100
  end

  it 'Footprint of single provider with controller should be less than 400KB' do
    result = RubyProf.profile do
      provider = Provider.new(:loglevel => Logger::ERROR)
      provider.start
    end
    total_memory_kilobytes(result).should < 400
  end

  it 'Footprint of 10 providers with controller should be less than 2MB' do
    result = RubyProf.profile do
      1.upto(10) do
        provider = Provider.new(:loglevel => Logger::ERROR)
        provider.start
      end
    end
    total_memory_kilobytes(result).should < 2*1024
  end

  it 'Footprint of 100 providers with controller should be less than 20MB' do
    result = RubyProf.profile do
      1.upto(100) do
        provider = Provider.new(:loglevel => Logger::ERROR)
        provider.start
      end
    end
    total_memory_kilobytes(result).should < 20*1024
  end
end
