require 'vcard/v3_0/typegrammars'
require 'vcard/v3_0/grammar'
require 'vcard/v3_0/component'
require 'vcard/v4_0/typegrammars'
require 'vcard/v4_0/grammar'
require 'vcard/v4_0/component'

module Vcard

 class << self

	 def parse3(vcf)
		 return Vcard::V3_0::Component.parse(vcf)
	end
	 def parse4(vcf)
		 return Vcard::V4_0::Component.parse(vcf)
	end
end
end
