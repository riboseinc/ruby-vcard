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
		   when :SOURCE, :PHOTO, :IMPP, :GEO, :LOGO, :MEMBER, :SOUND, :URL, :FBURL, :CALADRURI, :CALURI, :UID, :TZ
		   when :TEL, :KEY
			   if params[:VALUE] == 'uri'
			   else
                   	parse_err(":MEDIATYPE parameter given for #{prop} with :VALUE of text", ctx) 
			   end
		   when :RELATED
			   if params[:VALUE] == 'text'
                  	parse_err(":MEDIATYPE parameter given for #{prop} with :VALUE of text", ctx) 
			   else
 			   end
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
	   if params and params[:LANGUAGE]
		   case prop
		   when :FN, :N, :NICKNAME, :ADR, :TITLE, :ROLE, :LOGO, :ORG, :NOTE, :SOUND
		   when :BDAY, :ANNIVERSARY
			   # added :ANNIVERSARY per errata
			   if params[:VALUE] == 'text'
			   else
                   		parse_err(":LANGUAGE parameter given for #{prop} with :VALUE of date/time", ctx) 
		           end
		   when :RELATED
			   if params[:VALUE] == 'text'
			   else
                   		parse_err(":LANGUAGE parameter given for #{prop} with :VALUE of uri", ctx) 
		        end
		   else
                   	parse_err(":LANGUAGE parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:VALUE]
		   case prop
		   when :SOURCE, :KIND, :XML, :FN, :N, :NICKNAME, :PHOTO, :GENDER, :ADR, :TEL, :EMAIL, :IMPP, :LANG, :TZ, :GEO, :TITLE, :ROLE, :LOGO, :ORG, :MEMBER, :RELATED, :CATEGORIES, :NOTE, :PRODID, :REV, :SOUND, :URL, :VERSION, :KEY, :FBURL, :CALADRURI, :CALURI, :BDAY, :ANNIVERSARY
		   else
                   	parse_err(":VALUE parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:PREF]
		   case prop
		   when :SOURCE, :FN, :NICKNAME, :PHOTO, :ADR, :TEL, :EMAIL, :IMPP, :LANG, :TZ, :GEO, :TITLE, :ROLE, :LOGO, :ORG, :MEMBER, :RELATED, :CATEGORIES, :NOTE, :SOUND, :URL, :KEY, :FBURL, :CALADRURI, :CALURI
		   else
                   	parse_err(":PREF parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:PID]
		   case prop
		   when :SOURCE, :FN, :NICKNAME, :PHOTO, :ADR, :TEL, :EMAIL, :IMPP, :LANG, :TZ, :GEO, :TITLE, :ROLE, :LOGO, :ORG, :MEMBER, :RELATED, :CATEGORIES, :NOTE, :SOUND, :URL, :KEY, :FBURL, :CALADRURI, :CALURI
		   else
                   	parse_err(":PID parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:SORT_AS]
		   case prop
		   when  :N, :ORG
		   else
                   	parse_err(":SORT_AS parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:ALTID]
		   case prop
		   when :SOURCE, :XML, :FN, :N, :NICKNAME, :PHOTO, :BDAY, :ANNIVERSARY, :ADR, :TEL, :EMAIL, :IMPP, :LANG, :TZ, :GEO, :TITLE, :ROLE, :LOGO, :ORG, :MEMBER, :RELATED, :CATEGORIES, :NOTE, :SOUND, :URL, :KEY, :FBURL, :CALADRURI, :CALURI
		   else
                   	parse_err(":SOURCE parameter given for #{prop}", ctx) 
		   end
	   end
	   if params and params[:LABEL]
		   case prop
		   when :ADR
		   else
                   	parse_err(":LABEL parameter given for #{prop}", ctx) 
		   end
	   end
	   params.each {|p|
		   case p
	 	   when :LANGUAGE, :VALUE, :PREF, :PID, :TYPE, :GEO, :TZ, :SORT_AS, :CALSCALE, :LABEL, :ALTID
		   when /^x/i
			   # xname parameters are always allowed
	 	   else
			   # any-param
			   case prop
			   when :SOURCE, :KIND, :FN, :N, :NICKNAME, :PHOTO, :BDAY, :ANNIVERSARY, :GENDER, :ADR, :TEL, :EMAIL, :IMPP, :LANG, :TZ, :GEO, :TITLE, :ROLE, :LOGO, :ORG, :MEMBER, :RELATED, :CATEGORIES, :NOTE, :PRODID, :REV, :SOUND, :UID, :CLIENTPIDMAP, :URL, :VERSION, :KEY, :FBURL, :CALADRURI, :CALURI
			   else
                   		parse_err("#{p} parameter given for #{prop}", ctx) 
			   end
		   end
	   }
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
