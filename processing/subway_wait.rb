require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)


=begin
Necessary files (http://www.mta.info/developers/data/Performance_XML_Data.zip) already downloaded by bus_performance.rb, unless
this script has not previously been run.
=end

def write_to_file(path, file)
	fh = File.open(path, 'w' )
	fh.write(file)
	fh.close
end

def parse
	arr = []
	exclude = ["V Line","S 42 St","W Line","S Fkln","S Rock"]
	
	parse_file = "../data/performance_xml_data/Performance_NYCT.xml"
	indicator_sections = Nokogiri::XML(open(parse_file)).css('INDICATOR').collect
	
	indicator_sections.each do |indicator_section|
		indicator_name = indicator_section.css('INDICATOR_NAME').text

		if indicator_name.include?("Subway Wait Assessment - ") && exclude.include?(indicator_section.css('INDICATOR_NAME').text.split('-') [1].strip) == false 

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

write_to_file("../data/subway_wait.json", parse.to_json)

write_to_file("../data/subway_wait_mean.json", get_mean.to_json)








    

