require 'rubygems'
require 'safariwatir'

@browser = Watir::Safari.new

@browser.goto("http://google.com.au/")
@browser.text_field(:name, 'q').set("performance & test automation specialists")
sleep 1
@browser.button(:name, 'btnI').click