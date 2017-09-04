#require 'nokogiri'
#require 'rails/all'
#require 'equivalent-xml/rspec_matchers'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each do |path|
  require path
end

#include XMLHelper

#RSpec.configure do |config|
  #config.color_enabled = true
#end

require "rspec/json_expectations"
require "json"


require "vobject"
require "vcard"
