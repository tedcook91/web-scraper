require_relative '../lib/scraper.rb'

describe 'Date parser' do
  it 'converts a string formatted as mm/dd/yyyy into a date object' do
    str_date = "12/24/2018"
    expect(date_parser(str_date).class).to eq(Date)
    expect(date_parser(str_date).month).to eq(12)
  end
end
