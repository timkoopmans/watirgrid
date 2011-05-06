Given /^users navigate to the portal$/ do
  @browser.goto "http://localhost:4567/examples/logon.html"
end

When /^they enter their credentials$/ do
  @browser.text_field(:name => "email").set "tim@mahenterprize.com"
  @browser.text_field(:name => "password").set "mahsecretz"
  @browser.button(:type => "submit").click
end

Then /^they should see their account settings$/ do
  @browser.text.should =~ /Maybe I should get a real Gridinit account/
end

When /^they enter a direct url$/ do
  @browser.goto "http://localhost:4567/"
end
