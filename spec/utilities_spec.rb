require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'WatirGrid' do
  before(:all) do
    controller = Controller.new(
      :ring_server_port => 12351,
      :loglevel => Logger::ERROR)
    controller.start
    1.upto(1) do 
      provider = Provider.new(
        :ring_server_port => 12351, 
        :loglevel => Logger::ERROR, :browser_type => 'safari')
      provider.start
    end
    grid = Watir::Grid.new(:ring_server_port => 12351, 
    :ring_server_host => '127.0.0.1')
    grid.start(:read_all => true)
    @browser = grid.browsers[0]
  end
  
  it 'should get the logged-in user for the remote provider' do
    @browser[:object].get_logged_in_user.should == `whoami`.chomp
  end

  it 'should enumerate any running browsers on the remote provider' do
    @browser[:object].get_running_browsers(['firefox-bin']).size.should == 0
  end

  it 'should be able to start a new firefox browser' do
    @browser[:object].start_firefox_jssh
    sleep 5
    @browser[:object].get_running_browsers(['firefox-bin']).size.should == 1
  end
  
  it 'should be able to kill all firefox browsers' do
    @browser[:object].kill_browser('firefox-bin')
    @browser[:object].get_running_browsers(['firefox-bin']).size.should == 0
  end
  
  it 'should be able to start a new firefox browser specified by path' do
    @browser[:object].start_firefox_jssh
      ("/Applications/Firefox.app/Contents/MacOS/firefox-bin")
    sleep 5
    @browser[:object].get_running_browsers(['firefox-bin']).size.should == 1
  end
  
  it 'should be able to kill all browsers' do
    @browser[:object].kill_all_browsers
    @browser[:object].get_running_browsers.size.should == 0
  end
  
  
  
end