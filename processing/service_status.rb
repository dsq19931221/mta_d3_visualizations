require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'json'

#File structure
#JS-js
#data/xml, json, etc.
#viz/html
#processing/rb

def fetch_service_status
	uri = 'http://www.mta.info/status/serviceStatus.txt'
	xml = open(uri).read
	xml	
end

def write_to_raw_file
	Dir.chdir(File.join(File.dirname(__FILE__), '..', 'data'))
	
	fh = File.open('service_status_raw.xml', 'w' )
	fh.write(fetch_service_status)
	fh.close
end

def parse_status
	Dir.chdir(File.join(File.dirname(__FILE__), '..', 'data'))
	statuses = []
	
	data = Nokogiri::XML(open('service_status_raw.xml'))
	
	data.xpath('//subway/line').collect.each do |subway|
		statuses << { :status => subway.css('/status').text, :name => subway.css('/name').text }
	end
	
	statuses.to_json
end

def write_json_to_file
	Dir.chdir(File.join(File.dirname(__FILE__), '..', 'data'))
	fh = File.open('service_status_processed.json', 'w')
	fh.write(parse_status)
	fh.close
end


write_to_raw_file
write_json_to_file


