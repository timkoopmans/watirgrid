require 'rubygems'
require 'sinatra'
require 'haml'

get '/load/:browser_id/:browser_object_id' do
  params[:browser_object_id]
end

get '/' do
   haml :example
end

post '/' do
   "Congratulations #{params[:username]}, you hit the button!"
end

__END__

@@ layout
%html
  = yield

@@ example
%style{:type=>"text/css"}
  :plain
    input {
      border-bottom-style: inset;
      border-bottom-width: 2px;
      border-left-style: inset;
      border-left-width: 2px;
      border-right-style: inset;
      border-right-width: 2px;
      border-top-style: inset;
      border-top-width: 2px;
      font-family: arial, sans-serif;
      font-size: 30px;
      font-style: normal;
      font-variant: normal;
      font-weight: normal;
      height: 40px;
      width: 200px;
    }
%form{:action=>'/', :method=>'POST'}
  %input{:name=>'username', :value=>'username'}
  %button{:id=>'go', :type=>'submit'} GO



