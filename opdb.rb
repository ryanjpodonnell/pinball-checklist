require 'json'
require 'httparty'

API_TOKEN = ''
BASE_URI = 'https://opdb.org/api'

class OPDB
  include HTTParty
  base_uri BASE_URI
end

def get_resource(route, options)
  OPDB.get(route, query: options)
end

def persist_response(filename, response)
  File.open(filename, 'w') do |f|
    f.write(response)
  end
end

def import_resource(filename)
  file = File.read(filename)
  JSON.parse(file)
end

def manufacture_year(pin)
  manufacture_date = Date.parse(pin['manufacture_date'])
  manufacture_date.year
end

def formatted_title(pin)
  "- [ ] #{pin['name']} (#{manufacture_year(pin)})"
end

def manufacturer_name(pin)
  pin['manufacturer']['name']
end

def filesafe_manufacturer_name(manufacturer_name)
  manufacturer_name.gsub(/[^0-9A-Za-z.\-]/, '_')
end

def pins_by_manufacturer
  pins_by_manufacturer = Hash.new { |h, k| h[k] = [] }

  import_resource('export.json').each do |pin|
    next unless pin['is_machine'] == true && pin['physical_machine'] == 1
    pins_by_manufacturer[manufacturer_name(pin)] << formatted_title(pin)
  end

  pins_by_manufacturer
end

pins_by_manufacturer.each do |manufacturer_name, formatted_pin_titles|
  filename = filesafe_manufacturer_name(manufacturer_name)

  File.open("pinballs/#{filename}.md",'w') do |f|
    formatted_pin_titles.sort.each do |formatted_pin_title|
      f.write(formatted_pin_title)
      f.write("\n")
    end
  end
end

# response = get_resource('/export/groups', api_token: API_TOKEN)
# persist_response('groups.json', response)
