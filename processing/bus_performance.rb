require "rubygems"
#require "bundler/setup"
require 'nokogiri'
require 'mechanize'
require 'open-uri'
require 'json'
require 'zip/zip'

zip_file = "../data/Performance_XML_Data.zip"
extract_dest = "../data/performance_xml_data/"

def fetch_data
	if File.exists?('../data/Performance_XML_Data.zip') == false

	  open('../data/Performance_XML_Data.zip', 'wb') do |f|
	  f.print open("http://www.mta.info/developers/data/Performance_XML_Data.zip").read
	  end
	end
end

def write_json_to_file
	Dir.chdir(File.join(File.dirname(__FILE__), '..', 'data'))
	fh = File.open('bus_performance.json', 'w')
	fh.write(parse)
	fh.close
end

#This method thanks to Mark Needham. 
#http://www.markhneedham.com/blog/2008/10/02/ruby-unzipping-a-file-using-rubyzip/
def unzip_file (file, destination)
  Zip::ZipFile.open(file) { |zip_file|
   zip_file.each { |f|
     f_path=File.join(destination, f.name)
     FileUtils.mkdir_p(File.dirname(f_path))
     zip_file.extract(f, f_path) unless File.exist?(f_path)
   }
  }
end

#fetch_data
#unzip_file(zip_file, extract_dest)

def parse
  parse_file = '../data/performance_xml_data/Performance_MTABUS.xml'
  bus_perf_arr_hshs = [] 
  mean_dist= [] 
  coll_inj = [] 
  cust_acc = []
  indicator_sections = Nokogiri::XML(open(parse_file)).css('INDICATOR').collect
  
  data_points = {
		:mean_dist => 'Mean Distance Between Failures - MTA Bus',
		:coll_inj => 'Collisions with Injury Rate - MTA Bus',
		:cust_acc => 'Customer Accident Injury Rate - MTA Bus'
		 }
		  
  indicator_sections.each do |indicator_section|
	   indicator_name = indicator_section.css('INDICATOR_NAME').text
	   if indicator_name == data_points[:mean_dist]
		   mean_dist << indicator_section.css('MONTHLY_ACTUAL').text
	   elsif indicator_name == data_points[:coll_inj]
	     coll_inj << indicator_section.css('MONTHLY_ACTUAL').text
	   elsif indicator_name == data_points[:cust_acc]
	     cust_acc << indicator_section.css('MONTHLY_ACTUAL').text 
	   end
	   
  end
  
  [mean_dist,coll_inj,cust_acc].transpose.each{|x,y,z|
    
    if x.empty? || y.empty? || z.empty?
      next
    elsif x == ".00" || y == ".00" || z == ".00"
      next
    end
    
    bus_perf_arr_hshs << { :dist_between_fail => x, :collisions_with_injury => y, :customer_accident_rate => z  }
   }
     
  bus_perf_arr_hshs
end#def

def write_json_to_file
	Dir.chdir(File.join(File.dirname(__FILE__), '..', 'data'))
	fh = File.open('bus_performance.json', 'w')
	fh.write(parse)
	fh.close
end

write_json_to_file