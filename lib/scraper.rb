require 'Nokogiri'
require 'pry'
require 'json'
require 'date'
require 'selenium-webdriver'
require 'dotenv/load'



def date_parser date
  Date.strptime(date, "%m/%d/%Y")
end

driver = Selenium::WebDriver.for :chrome
driver.navigate.to "https://www.dominionenergy.com/sign-in"
wait = Selenium::WebDriver::Wait.new(:timeout => 10)

begin

element = driver.find_element(id:'user')
element.send_keys ENV['USERNAME']
element = driver.find_element(id: 'password')
element.send_keys ENV['PASSWORD']
button = driver.find_element(id: 'SignIn')
binding.pry
button.click


#brings us to the page where we scrape kwh usage, bill amount $, service end date (get service start from math)
link = driver.find_element(id: 'AnalyzeEnergyUsage_liId')
link.click

#running wait.until here allows page to hang until needed data is loaded
  wait.until {driver.find_element(link_text: 'View Past Usage')}

  parse_page = Nokogiri::HTML(driver.page_source)

  usage = parse_page.css('.tbl-td-center')[2].text.strip
  bill_amount = parse_page.css('.tbl-td')[2].text.strip
  service_end_string = parse_page.css('.tbl-td-center')[0].text.strip
  service_end = date_parser service_end_string

#subtracting # of days in billing period
  service_start = service_end - ((parse_page.css('.tbl-td-center')[1].text).to_i)

#have to go to a different page (requires two clicks) to get the bill due date
  link = wait.until{driver.find_element(id: 'Billing_liId')}
  link.click

  link = wait.until {driver.find_element(link_text: 'Billing History & more')}
  link.click

#parsing page again to get new elements
  parse_page = Nokogiri::HTML(driver.page_source)

  due_date = parse_page.css('tr').css('td').css('.tbl-td').css('.tbl-td-alt-color')[1].text.strip
ensure
  driver.quit
end
  due_date_formatted = date_parser due_date

# customer friendly view for dates
  service_start_customer = service_start.strftime('%m/%d/%Y')
  service_end_customer = service_end.strftime('%m/%d/%Y')
  due_date_customer = due_date_formatted.strftime('%m/%d/%Y')

puts "Energy usage (kWh): #{usage}"
puts "Bill amount: #{bill_amount}"
puts "Service start date: #{service_start_customer}"
puts "Service end date: #{service_end_customer}"
puts "Bill due: #{due_date_customer}"
