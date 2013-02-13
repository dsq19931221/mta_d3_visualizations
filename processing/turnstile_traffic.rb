require "rubygems"
#require "bundler/setup"
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'json'
require 'zip/zip'
require 'Date'
require 'Time'

def date_to_ms(date, time)
	split_date = date.split('-')
	new_date = "20#{split_date[2]}-#{split_date[0]}-#{split_date[1]}"
	raw_date = "#{new_date} #{time}"
	date_ms = Time.parse(raw_date).to_i * 1000
	date_ms
end


def fetch_data
	uri = 'http://www.mta.info/developers/data/nyct/turnstile/turnstile_120211.txt'
	data = open(uri).read
	data	
end

def write_to_raw_file
	Dir.chdir(File.join(File.dirname(__FILE__), '..', 'data'))
	
	fh = File.open('turnstile_traffic.txt', 'w' )
	fh.write(fetch_data)
	fh.close
end

#write_to_raw_file

def parse_raw
	raw_data = []
	parse_file = '../data/turnstile_traffic.txt'
	
	
	File.open(parse_file, "r") do |infile|
		while (line = infile.gets)
			raw_data << line
		end
	end
	raw_data
end

def extract_gc_locns
	lines = parse_raw
	gc_locns =  ['R236', 'R238','R237','R240','R237B','R241A']
	gc = []
	
	lines.each do |line|
		if gc_locns.include?(line.split(',')[1])
			gc << line
		end
	end
	gc
end


def extract_ts_locns
	lines = parse_raw
	ts_locns =  ['R145', 'A021','R143','R151','R148','R147']
	ts = []
	
	
	lines.each do |line|
		if ts_locns.include?(line.split(',')[1])
			ts << line
		end
	end
	ts
end

def parse_locn_lines(arr)
	time_counts = []
	arr.each do |line|
		arr = line.split(',')
		arr.shift(3)
		
		arr.each_with_index do |str, idx|
			
			if str == 'REGULAR'
				time = arr[idx-1]
				date = arr[idx-2]
				entries = arr[idx+1].to_i
				exits = arr[idx+2] .to_i
				
				ms_date = date_to_ms(arr[idx-2], arr[idx-1])
				
				time_counts << [entries, exits, ms_date]
				
			end
		end
		
	end
	time_counts
end

def make_gc_hash
	grand_central = {}
	puts parse_locn_lines(extract_gc_locns)
end

make_gc_hash