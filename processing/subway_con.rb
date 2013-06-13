require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

zip_file = "../data/google_transit.zip"
extract_dest = "../data/mta_gtfs/"

def fetch_data
	if File.exists?('../data/google_transit.zip') == false

	  open('../data/google_transit.zip', 'wb') do |f|
	  f.print open("http://www.mta.info/developers/data/nyct/subway/google_transit.zip").read
	  end
	end
end

def unzip_file (file, destination)
  Zip::ZipFile.open(file) { |zip_file|
   zip_file.each { |f|
     f_path=File.join(destination, f.name)
     FileUtils.mkdir_p(File.dirname(f_path))
     zip_file.extract(f, f_path) unless File.exist?(f_path)
   }
  }
end

#
#stop_id,stop_code,stop_name,stop_desc,stop_lat,stop_lon,zone_id,stop_url,location_type,parent_station

def parse
end

fetch_data
unzip_file(zip_file, extract_dest)



