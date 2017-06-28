require 'vobject'
require 'vobject/component'

class Vcard < Vobject::Component

  attr_accessor :version

  class << self

    private

    def raise_invalid_parsing
      raise "vCard parse failed"
    end

  end

  def initialize key, cs
    begin
      version_key = cs.first.keys.first
      self.version = cs.first[version_key][:value]
    rescue
      self.class.raise_invalid_parsing
    end

    super
  end

  private

  def name
    :VCARD
  end

  def property_base_class
    version_class.const_get(:Property)
  end

  def component_base_class
    version_class.const_get(:Component)
  end

  def version_class
    Vcard::const_get(:"V#{version.gsub(/\./, "_")}")
  end

end

def require_dir(dir)
  base = File.expand_path('../', __FILE__)
  Dir.glob(File.join(base, dir, "**", "*.rb")).each do |path|
    require path.gsub(/\.rb\Z/, '')
  end
end

require 'vcard/v4_0/component'
require 'vcard/v4_0/property'
require_dir 'vcard/v4_0/component'
require_dir 'vcard/v4_0/property'
