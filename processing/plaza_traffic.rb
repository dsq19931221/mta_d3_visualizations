require "rubygems"
#require "bundler/setup"
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'json'

def fetch_data
	uri = 'http://www.mta.info/developers/data/bandt/tbta_plaza/PLAZA_DAILY_TRAFFIC_20121126.xml'
	xml = open(uri).read
	xml	
end

def write_to_raw_file
	Dir.chdir(File.join(File.dirname(__FILE__), '..', 'data'))
	
	fh = File.open('daily_plaza_traffic.xml', 'w' )
	fh.write(fetch_data)
	fh.close
end

def write_json_to_file
	Dir.chdir(File.join(File.dirname(__FILE__), '..', 'data'))
	fh = File.open('daily_plaza_traffic_processed.json', 'w')
	fh.write(make_json)
	fh.close
end

def parse_to_ids_avgs
	Dir.chdir(File.join(File.dirname(__FILE__), '..', 'data'))
	
	grpd_traffic = []
	raw_traffic = []
	avgs_with_id = []

	data = Nokogiri::XML(open('daily_plaza_traffic.xml'))
	
	data.css('TransSummary').collect.each do |summary|
		if summary.css('facility').count == 10
			summary.css('facility').each do |facility|
				raw_traffic << { :id => facility["id"], :total_traffic => facility["etc-count"].to_f + facility["cash-count"].to_f }
			end		
		else
			next
		end
		
	end
	
	p grpd_traffic = raw_traffic.group_by {|plaza| plaza[:id]}
	  
	#avgs_with_id = grpd_traffic.map{ |array|  [array[1][0][:id], array[1].inject(0) do |sum, num| (sum + num[:total_traffic]) / num.size end] }
	    
	#avgs_with_id
	  
end

parse_to_ids_avgs

def make_json
  plz_traffic = []
    
  parse_to_ids_avgs.each_index do |i|
    if    parse_to_ids_avgs[i][0] == "1"
      plz_traffic << { :id => parse_to_ids_avgs[i][0], :name => "Robert F. Kennedy Bridge Bronx Plaza", :count => parse_to_ids_avgs[i][1] } 
    elsif parse_to_ids_avgs[i][0] == "2"
      plz_traffic << { :id => parse_to_ids_avgs[i][0], :name => "Robert F. Kennedy Bridge Manhattan Plaza", :count => parse_to_ids_avgs[i][1] }
    elsif parse_to_ids_avgs[i][0] == "3"
      plz_traffic << { :id => parse_to_ids_avgs[i][0], :name => "Bronx-Whitestone Bridge", :count => parse_to_ids_avgs[i][1] }
    elsif parse_to_ids_avgs[i][0] == "4"
      plz_traffic << { :id => parse_to_ids_avgs[i][0], :name => "Henry Hudson Bridge", :count => parse_to_ids_avgs[i][1] }
    elsif parse_to_ids_avgs[i][0] == "5"
      plz_traffic << { :id => parse_to_ids_avgs[i][0], :name => "Marine Parkway-Gil Hodges Memorial Bridge", :count => parse_to_ids_avgs[i][1] }
    elsif parse_to_ids_avgs[i][0] == "6"
      plz_traffic << { :id => parse_to_ids_avgs[i][0], :name => "Cross Bay Veterans Memorial Bridge", :count => parse_to_ids_avgs[i][1] }
    elsif parse_to_ids_avgs[i][0] == "7"
      plz_traffic << { :id => parse_to_ids_avgs[i][0], :name => "Queens Midtown Tunnel", :count => parse_to_ids_avgs[i][1] }
    elsif parse_to_ids_avgs[i][0] == "8"
      plz_traffic << { :id => parse_to_ids_avgs[i][0], :name => "Brooklyn-Battery Tunnel", :count => parse_to_ids_avgs[i][1] }
    elsif parse_to_ids_avgs[i][0] == "9"
      plz_traffic << { :id => parse_to_ids_avgs[i][0], :name => "Throgs Neck Bridge", :count => parse_to_ids_avgs[i][1] }
    elsif parse_to_ids_avgs[i][0] == "11"
      plz_traffic << { :id => parse_to_ids_avgs[i][0], :name => "Verrazano-Narrows Bridge", :count => parse_to_ids_avgs[i][1] }
    end
  end
  
  plz_traffic.to_json

  
end#make_json

#write_to_raw_file
#write_json_to_file