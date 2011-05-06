Given /^users navigate to the portal$/ do
  @grid.iterate {|browser| browser.goto "http://gridinit.com/examples/logon.html" }
end

When /^they enter their credentials$/ do
  @grid.iterate do |browser|
    browser.text_field(:name => "email").set "tim@mahenterprize.com"
    browser.text_field(:name => "password").set "mahsecretz"
    browser.button(:type => "submit").click
  end
end

Then /^they should see their account settings$/ do
  @grid.iterate do |browser|
    browser.text.should =~ /Maybe I should get a real Gridinit account/
  end
end

Then /^the response time should be less than (\d+) seconds$/ do |response_time|
  @grid.iterate do |browser|
    browser.performance.summary[:response_time].should < response_time.to_i * 1000
  end
end
