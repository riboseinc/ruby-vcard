require "vobject/property"

class Vcard::V4_0::Property::Tel < Vcard::V4_0::Property

  private

  def name
    :TEL
  end

  def parse_uri_value value
    URI(value)
  end

end
