require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'When taking tuples from the grid' do
  before(:all) do
    controller = Controller.new(
      :ring_server_port => 12351,
      :loglevel => Logger::ERROR)
    controller.start
    1.upto(5) do 
      provider = Provider.new(
        :ring_server_port => 12351, 
        :loglevel => Logger::ERROR, :browser_type => 'safari')
      provider.start
    end
  end

  it 'should start 1st grid and take all tuples' do
    grid1 = Watir::Grid.new(:ring_server_port => 12351)
    grid1.start(:take_all => true)
    grid1.size.should == 5
  
    describe 'Then for subsequent grids' do
      it 'should start 2nd grid and confirm there are no more tuples' do
        grid2 = Watir::Grid.new(:ring_server_port => 12351)
        grid2.start(:take_all => true)
        grid2.size.should == 0
      end
  
      it 'should release the tuples taken by the 1st grid' do
        grid1.release_tuples
      end
  
      it 'should start 3rd grid and confirm there are tuples available' do
        grid3 = Watir::Grid.new(:ring_server_port => 12351)
        grid3.start(:take_all => true)
        grid3.size.should == 5
      end  
    
    end

end
  
end
