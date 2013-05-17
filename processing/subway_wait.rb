require "rubygems"
#require "bundler/setup"
require 'open-uri'
require 'Date'
require 'Time'
#Bundler.require
require 'nokogiri'
require 'mechanize'
require 'json'
require 'zip'

#Bundler.require

=begin
Necessary files (http://www.mta.info/developers/data/Performance_XML_Data.zip) already downloaded by bus_performance.rb, unless
this script has not previously been run.
=end


def parse
	arr = []
	exclude = [ "V", "S 42 St", "Line_W", "S Fkln", "S Rock" ]
	
	parse_file = "../data/performance_xml_data/Performance_NYCT.xml"
	indicator_sections = Nokogiri::XML(open(parse_file)).css('INDICATOR').collect
	
	indicator_sections.each do |indicator_section|
		if indicator_section.css('INDICATOR_NAME').text.include?("Subway Wait Assessment - ") && indicator_section.css('INDICATOR_NAME').text.include?("V") == false && indicator_section.css('INDICATOR_NAME').text.include?("S 42 St") == false && indicator_section.css('INDICATOR_NAME').text.include?("W Line") == false && indicator_section.css('INDICATOR_NAME').text.include?("S Fkln") == false && indicator_section.css('INDICATOR_NAME').text.include?("S Rock") == false
			line_name = indicator_section.css('INDICATOR_NAME').text.split('-') [1].strip
			line_id = line_name.split(' ').reverse.join('_')
			year = indicator_section.css('PERIOD_YEAR').text
			month = indicator_section.css('PERIOD_MONTH').text
			timestamp = Time.parse("#{year}-#{month}-01").to_i * 1000
			if indicator_section.css('MONTHLY_ACTUAL').text == ''|| indicator_section.css('MONTHLY_ACTUAL').text == '.00'
				next
			else
				late_percent = indicator_section.css('MONTHLY_ACTUAL').text
			end
			arr << { :line_id => line_id, :line_name => line_name, :late_percent=> late_percent, :time => timestamp  }
		end
	end
	arr
end


def get_mean
	grpd_arr = parse.group_by { |line| line[:line_id] } 
	grpd_arr.map{ |key, arr| { :line_id => key, :line_name => key.split('_').reverse.join(' '), :mean => arr.inject(0) do |sum,num| (sum + num[:late_percent].to_f) end / arr.size }  }
	
end

File.open("../data/subway_wait.json", 'w') {|f| f.write(parse.to_json) }

File.open("../data/subway_wait_mean.json", 'w') {|f| f.write(get_mean.to_json) }







    

