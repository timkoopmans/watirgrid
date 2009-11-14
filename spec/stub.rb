require 'rubygems'
require 'sinatra'

get '/load/:browser_id/:browser_object_id' do
  params[:browser_object_id]
end

