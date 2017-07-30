require "rsec"
require "set"
require "uri"
require "date"
#require "tzinfo"
include Rsec::Helpers
require 'vcard/version'
require 'vobject'

module Vcard::V4_0
	class Paramcheck

 class << self

   def paramcheck(prop, params, ctx) 
           if params and params[:TYPE]
		   case prop
		   when :FN, :NICKNAME, :PHOTO, :ADR, :TEL, :EMAIL, :IMPP, :LANG, :TZ, :GEO, :TITLE, :ROLE, :LOGO, :ORG, :RELATED, :CATEGORIES, :NOTE, :SOUND, :URL, :KEY, :FBURL, :CALADRURI, :CALURI
		   else
                   	parse_err(":TYPE parameter given for #{prop}", ctx) 
		   end
           end
	   if params and params[:MEDIATYPE]
		   case prop
		   when :SOURCE, :PHOTO, :IMPP, :GEO, :LOGO, :MEMBER, :SOUND, :URL, :FBURL, :CALADRURI, :CALURI, :TEL, :RELATED, :UID, :KEY, :TZ
		   else
                   	parse_err(":MEDIATYPE parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:CALSCALE]
		   case prop
		   when :BDAY, :ANNIVERSARY
		   else
                   	parse_err(":CALSCALE parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:GEO]
		   case prop
		   when :ADR
		   else
                   	parse_err(":GEO parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:TZ]
		   case prop
		   when :ADR
		   else
                   	parse_err(":TZ parameter given for #{prop}", ctx) 
		   end
	   end
           case prop
	           when :SOURCE, :PHOTO, :IMPP, :GEO, :LOGO, :MEMBER, :SOUND, :URL, :FBURL, :CALADRURI, :CALURI
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val != "uri"
	                   }
	           when :LANG
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val != "language-tag"
	                   }
	           when :REV
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val != "timestamp"
	                   }
	           when :KIND, :XML, :FN, :N, :NICKNAME, :GENDER, :ADR, :EMAIL, :TITLE, :ROLE, :ORG, :CATEGORIES, :NOTE, :PRODID, :VERSION
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val != "text"
	                   }
	           when :BDAY, :ANNIVERSARY
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val != "date-and-or-time" and val != "text"
	                   }
	           when :TEL, :RELATED, :UID, :KEY
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val != "uri" and val != "text"
	                   }
	           when :TZ
	                   params.each {|key, val|
	                           parse_err("illegal value #{val} given for parameter #{key} of #{prop}", ctx) if key == :VALUE and val != "uri" and val != "text" and val != "utc-offset"
	                   }
		   else
		  end
    end


private


   def parse_err(msg, ctx)
	          raise ctx.generate_error 'source'
   end

  end
end
end
