class Pin
  TYPE_MAPPING = {
    'em' => 'Electro-mechanical',
    'me' => 'Mechanical',
    'ss' => 'Solid State Electronic',
  }

  def initialize(pin_response)
    @pin_response = pin_response
  end

  def name
    @pin_response['name']
  end

  def skribbl_name
    name.split('(')[0].strip
  end

  def manufacture_year
    Date.parse(@pin_response['manufacture_date']).year
  end

  def manufacturer_name
    @pin_response['manufacturer']['name']
  end

  def type
    type_key = @pin_response['type']
    TYPE_MAPPING[type_key]
  end

  def md_formatted_title
    "- [ ] #{name} (#{manufacture_year})"
  end

  def md_formatted_type
    "## #{type}"
  end

  def valid?
    is_machine && physical_machine
  end

  private

  def is_machine
    @pin_response['is_machine']
  end

  def physical_machine
    @pin_response['physical_machine']
  end
end
