require "vcard/v4_0/property"

module Vcard::V4_0

class Component < Vobject::Component

  class << self

    private

    def raise_invalid_parsing
      raise "vCard parse failed"
    end

  end

  private

  def property_base_class
    version_class.const_get(:Property)
  end

  def component_base_class
    version_class.const_get(:Component)
  end

  def version_class
    Vcard::V4_0
  end

end

end
