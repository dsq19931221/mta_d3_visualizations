require "rubygems"
#require "bundler/setup"
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'json'
require 'zip/zip'
require 'Date'
#require 'Time'


class Hash
	
  def median_traffic
    avgs_with_time = self.map{ |key,value| [key ,value.inject(0) do |sum,num| (sum + num[:count]) end / value.size] }
  end
  
end


class Array
	
  def sort_arr_hash
    sorted_arr = self.sort_by { |hsh| hsh[:time] }
  end
  
  def ex_low
	  hsh = {}
	  tstiles_grpd = self.group_by { |tstile| tstile[:time] } 
    
	  tstiles_grpd.each do |key, value|
		  if value.count > 6		  
		    hsh["#{key}"] = tstiles_grpd[key]
      end
	  end
    hsh
  end
  
end#Class array

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

def write_json_to_file
	Dir.chdir(File.join(File.dirname(__FILE__), '..', 'data'))
	fh = File.open('turnstile_traffic.json', 'w')
	fh.write(make_json)
	fh.close
end

write_to_raw_file

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
		
		arr.each_with_index do |str, idx|
			
			if str == 'REGULAR'
				locn = arr[0]
				key = arr[2]
				time = arr[idx-1]
				date = arr[idx-2]
				entries = arr[idx+1].to_i
				exits = arr[idx+2] .to_i
				
				ms_date = date_to_ms(arr[idx-2], arr[idx-1])
				
				time_counts << [locn, key, entries, exits, ms_date]
				
			end
		end
		
	end
	time_counts
end

def make_gc_hash
	grand_central = []
	set_key = ''
	arr = parse_locn_lines(extract_gc_locns)
	
	arr.each_index do |i|
	  
	  if set_key == arr[i][1]
	     entries = arr[i][2] - arr[i-1][2]
	     exits = arr[i][3] - arr[i-1][3]
	     grand_central << { :time => arr[i][4],:count => (entries).to_f } 
	  elsif set_key == '' || set_key != arr[i][1]
	     set_key == arr[i][1]
	  end
	     set_key = arr[i][1]
	end
	
	grand_central
end

def make_ts_hash
	times_square = []
	set_key = ''
	arr = parse_locn_lines(extract_ts_locns)
	
	arr.each_index do |i|
	  
	  if set_key == arr[i][1]
	     entries = arr[i][2] - arr[i-1][2]
	     exits = arr[i][3] - arr[i-1][3]
	     times_square << { :time => arr[i][4], :count => (entries).to_f } 
	  elsif set_key == '' || set_key != arr[i][1]
	     set_key == arr[i][1]
	  end
	     set_key = arr[i][1]
	end
	
	times_square 
end

def gc_time_median_hash
  grand_central_a = []
  arr = make_gc_hash.ex_low.median_traffic
  arr.each_index do |i|
    if arr[i][1] < 0 || arr[i][1] == 0
      next
    else 
      grand_central_a << { :time => arr[i][0], :count => arr[i][1] }
    end
  end
  grand_central_a
end 

def ts_time_median_hash
  times_square_a = []
  arr = make_ts_hash.ex_low.median_traffic
  arr.each_index do |i|
    if arr[i][1] < 0 || arr[i][1] == 0
      next
    else 
      times_square_a << { :time => arr[i][0], :count => arr[i][1] }
    end
  end
  times_square_a
end

def make_json
  combined = {}
  combined[:times_square] = ts_time_median_hash.sort_arr_hash
  combined[:grand_central] =  gc_time_median_hash.sort_arr_hash
  combined.to_json
end

write_json_to_file


