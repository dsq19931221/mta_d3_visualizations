require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

def fetch_service_status
	uri = 'http://www.mta.info/status/serviceStatus.txt'
	xml = open(uri).read
	xml	
end

def write_to_raw_file
	fh = File.open('../data/service_status_raw.xml', 'w' )
	fh.write(fetch_service_status)
	fh.close
end

def parse_status
	statuses = []
	
	data = Nokogiri::XML(open('../data/service_status_raw.xml'))
	
	data.xpath('//subway/line').collect.each do |subway|
		statuses << { :status => subway.css('/status').text, :name => subway.css('/name').text }
	end
	
	statuses.to_json
end

def write_json_to_file
	fh = File.open('../data/service_status_processed.json', 'w')
	fh.write(parse_status)
	fh.close
end

write_to_raw_file
write_json_to_file


