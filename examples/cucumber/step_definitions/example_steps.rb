$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..', 'lib'))
require 'watirgrid'
require 'rspec/expectations'; 

Given /^I have created and started a Controller$/ do
  controller = Controller.new(
    :loglevel => Logger::ERROR)
  controller.start
end

Then /^I should be able to create and start (\d+) "(.+?)" Providers$/ do |total, browser_type|
  1.upto(total.to_i) do 
    provider = Provider.new(
      :loglevel => Logger::ERROR, :browser_type => browser_type)
    provider.start
  end
end

Given /^I have created and started a Grid with (\d+) Providers$/ do |total|
  @grid = Watir::Grid.new
  @grid.start(:take_all => true)
  @grid.browsers.size.should == total.to_i
end

Then /^I should be able to control the following browsers in parallel:$/ do |table|
  browsers = table.raw.collect {|e| e.to_s.downcase.to_sym}
  threads = []
    @grid.browsers.each_with_index do |browser, index|
      threads << Thread.new do
        b = browser[:object].new_browser(browsers[index])
        b.goto("http://www.google.com")
        b.text_field(:name, 'q').set("watirgrid")
        b.button(:name, "btnI").click
        b.close
      end
    end
    threads.each {|thread| thread.join}
end
