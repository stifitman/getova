require 'nokogiri'

a = Nokogiri::HTML(open(ARGV.first))
a.css('.GridItem a[href]').each do |v|
  puts v.attribute('href')
end
