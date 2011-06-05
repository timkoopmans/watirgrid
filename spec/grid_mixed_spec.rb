require File.expand_path(File.dirname(__FILE__) + '/spec_helper')
require 'childprocess'

describe 'Using the Grid with different Drivers AND Browser Types' do
  before(:all) do
    @controller = ChildProcess.build("~/.rvm/gems/ruby-1.8.7-p334/bin/controller -h 127.0.0.1").start
    sleep 1
    @provider1  = ChildProcess.build("~/.rvm/gems/ruby-1.8.7-p334/bin/provider -h 127.0.0.1 -p 8001 -d safariwatir").start
    sleep 1
    @provider2  = ChildProcess.build("~/.rvm/gems/ruby-1.8.7-p334/bin/provider -h 127.0.0.1 -p 8002 -d webdriver -b firefox").start
    sleep 2
  end

  after(:all) do
    @controller.stop if @controller.alive?
    @provider1.stop  if @provider1.alive?
    @provider2.stop  if @provider2.alive?
  end

  it 'should control a grid' do
    Watir::Grid.control(:controller_uri => 'druby://127.0.0.1:11235') do |browser, index|
      p "I am browser index #{index}"
      browser.goto "http://google.com"
      p browser.title
      browser.close
    end
  end

  it 'should iterate over a grid' do
    grid = Watir::Grid.new(:controller_uri => 'druby://127.0.0.1:11235')
    grid.start(:initiate => true)
    grid.iterate do |browser|
      browser.goto "http://google.com"
      browser.close
    end
  end
end
