require 'json'
require 'httparty'
require_relative 'pin'

API_TOKEN = ''

class OPDB
  include HTTParty
  BASE_URI = 'https://opdb.org/api'

  base_uri BASE_URI

  def self.persist_response(filename, response)
    File.open(filename, 'w') do |f|
      f.write(response)
    end
  end

  def self.import_response(filename)
    file = File.read(filename)
    JSON.parse(file)
  end
end

def filesafe_manufacturer_name(manufacturer_name)
  manufacturer_name.gsub(/[^0-9A-Za-z.\-]/, '_')
end

def pins_by_manufacturer
  pins_by_manufacturer = Hash.new { |h, k| h[k] = [] }

  OPDB.import_response('./export.json').each do |pin_response|
    pin = Pin.new(pin_response)

    next unless pin.valid?
    pins_by_manufacturer[pin.manufacturer_name] << pin
  end

  pins_by_manufacturer
end

pins_by_manufacturer.each do |manufacturer_name, pins|
  filename = "#{filesafe_manufacturer_name(manufacturer_name)}.md"

  File.open(filename,'w') do |f|
    pins.group_by { |pin| pin.md_formatted_type }.each do |type, pins|
      f.write(type)
      f.write("\n")

      pins.sort_by{ |pin| pin.name }.each do |pin|
        f.write(pin.md_formatted_title)
        f.write("\n")
      end
    end

    skribbl_string = pins.map { |pin| pin.skribbl_name }.sort.uniq.join(',')
    f.write('## Skribbl Custom Words')
    f.write("\n")
    f.write(skribbl_string)
  end
end

# response = OPDB.get('/export/groups', query: { api_token: API_TOKEN })
# OPDB.persist_response('./groups.json', response)

# response = OPDB.get('/export', query: { api_token: API_TOKEN })
# OPDB.persist_response('./export.json', response)
