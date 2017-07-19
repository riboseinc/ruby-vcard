require "rsec"
require "set"
require "uri"
require "date"
#require "tzinfo"
include Rsec::Helpers
require 'vcard/version'
require 'vobject'

module Vcard::V3_0
	class Typegrammars

 class << self

  # property value types, each defining their own parser

    def binary
           binary  = seq(/[a-zA-Z0-9+\/]*/.r, /={0,2}/.r) {|b, q|
                   ( (b.length + q.length) % 4 == 0 ) ? b + q : {:error => 'Malformed binary coding'}
                   }
            binary.eof
    end

  def phoneNumber 
	  # This is on the lax side; there should be up to 15 digits
	  phoneNumber = /[0-9() +-]+/.r
	  phoneNumber.eof
  end

    def geovalue
	        float           = prim(:double)
		    # TODO confirm that Rsec can do signs!
		geovalue    = seq(float, ';', float) {|a, _, b|
		              ( a <= 180.0 and a >= -180.0 and b <= 180 and b > -180 ) ? {:lat => a, :long => b} :
		                                       {:error => 'Latitude/Longitude outside of range -180..180'}
		                                             }
	                                                  geovalue.eof
    end
		

  def classvalue  
    classvalue 	= /PUBLIC/i.r | /PRIVATE/i.r | /CONFIDENTIAL/i.r | ianaToken | xname
    classvalue.eof
  end
  
  def integer  
    integer 	= prim(:int32)
    integer.eof
  end
  
  def float
    float 	    = prim(:double)
    float.eof
  end

  def ianaToken
    ianaToken 	= /[a-zA-Z\d\-]+/.r 
    ianaToken.eof
  end 

  def versionvalue
     versionvalue = '3.0'.r 
     versionvalue.eof
  end

  def profilevalue
     profilevalue = /VCARD/i.r
     profilevalue.eof
  end

  def uri
	uri         = /\S+/.r.map {|s|
	                  	parse_err("invalid URI: #{s}") unless s =~ URI::regexp 
	                  	s
			 }
	uri.eof
  end

  def text
    text	= /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e:"\u0080-\u00bf\u00c2-\u00df\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]|\\[;,\\nN])*/.r
    text.eof
  end

  def textlist
    text	= /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e:"\u0080-\u00bf\u00c2-\u00df\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]|\\[;,\\nN])*/.r
    textlist	= text.map {|t| [t]} | 
	    	seq(text, ',', lazy{textlist}) { |a, b| [a, b].flatten }
    textlist.eof
  end

  def date
     date	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
	     		#Time.utc(yy, mm, dd)
	     	} | /[0-9]{4}/.r {|yy|
			#Time.utc(yy, 0, 0) 
		} | seq(/[0-9]{4}/.r, "-", /[0-9]{2}/.r) {|yy, _, mm|
			#Time.utc(yy, mm, 0)
		} | seq('--', /[0-9]{2}/.r) {|_, mm|

		} | seq('--', /[0-9]{2}/.r, /[0-9]{2}/.r) {|_, mm, dd|
		} | seq('--', '-', /[0-9]{2}/.r) {|_, _, dd|
		}
     date.eof
  end

  def time	
    sign	    = /[+-]/i.r
    utc_offset 	= seq(sign, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?)
    zone	= utc_offset | /Z/i.r
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time	= seq(hour, minute, second, zone._?) |
	    	seq(hour, minute, zone._?) |
    		seq(hour, zone._?) |
	    	seq('-', minute, second, zone._?) |
	    	seq('-', minute, zone._?) |
	    	seq('-', '-', second, zone._?) 
    time.eof
  end

  def date_time
    sign	    = /[+-]/i.r
    utc_offset 	= seq(sign, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?)
    zone	= utc_offset | /Z/i.r
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time_notrunc	= seq(hour, minute, second, zone._?) |
	    	seq(hour, minute, zone._?) |
    		seq(hour, zone._?) 
     date_noreduc	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
	     		#Time.utc(yy, mm, dd)
		} | seq('--', /[0-9]{2}/.r, /[0-9]{2}/.r) {|_, mm, dd|
		} | seq('--', '-', /[0-9]{2}/.r) {|_, _, dd|
		}
     date_time	= seq(date_noreduc, 'T', time_notrunc) {
	     	}
     date_time.eof
  end

  def utc_offset
    sign	    = /[+-]/i.r
    utc_offset 	= seq(sign, /[0-9]{2}/.r, ':', /[0-9]{2}/.r)
    utc_offset.eof
  end

  def kindvalue
    ianaToken 	= /[a-zA-Z\d\-]+/.r 
    xname 	= seq( '[xX]-', /[a-zA-Z0-9-]+/.r).map(&:join)
	  kindvalue = /individual/i.r | /group/i.r | /org/i.r | /location/i.r |
		  	ianaToken | xname
	  kindvlaue.eof
  end

  def fivepartname
    text	= /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e:"\u0080-\u00bf\u00c2-\u00df\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]|\\[;,\\nN])*/.r
    component	= text.map {|t| [t] }| 
	    	seq(text, ',', lazy{component}) {|a, _, b|
	    		[a, b].flatten
		}
    fivepartname = seq(component, ';', component, ';', component, ';', 
		       component, ';', component) {|a, _, b, _, c, _, d, _, e|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		e = e[0] if e.length == 1
	    		{:surname => a, :givenname => b, :middlename => c, :honprefix => d, :honsuffix => e}
	    	} | seq(component, ';', component, ';', component, ';', component) {|a, _, b, _, c, _, d|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		{:surname => a, :givenname => b, :middlename => c, :honprefix => d, :honsuffix => ''}
	    	} | seq(component, ';', component, ';', component) {|a, _, b, _, c|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		{:surname => a, :givenname => b, :middlename => c, :honprefix => '', :honsuffix => ''}
	    	} | seq(component, ';', component) {|a, _, b|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		{:surname => a, :givenname => b, :middlename => '', :honprefix => '', :honsuffix => ''}
	    	} | component {|a|
	    		a = a[0] if a.length == 1
	    		{:surname => '', :givenname => b, :middlename => '', :honprefix => '', :honsuffix => ''}
	    	} 
    fivepartname.eof
  end

  def address
    text	= /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e:"\u0080-\u00bf\u00c2-\u00df\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]|\\[;,\\nN])*/.r
    component	= text.map {|t| [t] }| 
	    	seq(text, ',', lazy{component}) {|a, _, b|
	    		[a, b].flatten
		}
    address = seq(component, ';', component, ';', component, ';', component, ';', 
		       component, ';', component, ';', component) {|a, _, b, _, c, _, d, _, e, _, f, _, g|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		e = e[0] if e.length == 1
	    		f = f[0] if f.length == 1
	    		g = g[0] if g.length == 1
	    		{:pobox => a, :ext => b, :street => c, 
				:locality => d, :region => e, :code => f, :country => g}
	    	} | seq(component, ';', component, ';', component, ';', component, ';', 
		       component, ';', component) {|a, _, b, _, c, _, d, _, e, _, f|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		e = e[0] if e.length == 1
	    		f = f[0] if f.length == 1
	    		{:pobox => a, :ext => b, :street => c, 
				:locality => d, :region => e, :code => f, :country => ''}
	    	} | seq(component, ';', component, ';', component, ';', component, ';', 
		       component) {|a, _, b, _, c, _, d, _, e|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		e = e[0] if e.length == 1
	    		{:pobox => a, :ext => b, :street => c, 
				:locality => d, :region => e, :code => '', :country => ''}
	    	} | seq(component, ';', component, ';', component, ';', component) {|a, _, b, _, c, _, d|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		{:pobox => a, :ext => b, :street => c, 
				:locality => d, :region => '', :code => '', :country => ''}
	    	} | seq(component, ';', component, ';', component) {|a, _, b, _, c|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		{:pobox => a, :ext => b, :street => c, 
				:locality => '', :region => '', :code => '', :country => ''}
	    	} | seq(component, ';', component) {|a, _, b|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		{:pobox => a, :ext => b, :street => '', 
				:locality => '', :region => '', :code => '', :country => ''}
	    	} | component {|a|
	    		a = a[0] if a.length == 1
	    		{:pobox => a, :ext => '', :street => '', 
				:locality => '', :region => '', :code => '', :country => ''}
	    	} 
    address.eof
  end


  # Enforce type restrictions on values of particular properties.
  # If successful, return typed interpretation of string
  def typematch(key, params, component, value)
    ctx1 = Rsec::ParseContext.new value, 'source'
    case key
     when :VERSION
	    ret = versionvalue._parse ctx1
     when :SOURCE, :URL
	    ret = uri._parse ctx1
     when :NAME, :FN, :NICKNAME, :LABEL, :EMAIL, :MAILER, :TITLE, :ROLE, :NOTE, :PRODID, :SORT_STRING, :UID
	    ret = text._parse ctx1
     when :CLASS
	    ret = classvalue._parse ctx1
     when :ORG, :CATEGORIES
	    ret = textlist._parse ctx1
     when :PROFILE
	    ret = profilevalue._parse ctx1
     when :N
	    ret = fivepartname._parse ctx1
     when :PHOTO, :LOGO, :SOUND
	     if params and params[:VALUE] == 'uri'
		     ret = uri._parse ctx1
	     else
		     ret = binary._parse ctx1
	     end
     when :KEY
	     if params and params[:ENCODING] == 'b'
		     ret = binary._parse ctx1
	     else
		     ret = text._parse ctx1
	     end
     when :BDAY
	     if params and params[:VALUE] == 'date-time'
		     ret = date_time._parse ctx1
	     else
		     ret = date._parse ctx1
	     end
     when :REV
	     if params and params[:VALUE] == 'date'
		     ret = date._parse ctx1
	     else
		     ret = date_time._parse ctx1
	     end
     when :ADR
	    ret = address._parse ctx1
    when :TEL
	    ret = phoneNumber._parse ctx1
    when :TZ
	    ret = utc_offset._parse ctx1
    when :GEO
	    ret = geovalue._parse ctx1
    when :AGENT
	    if params and params[:VALUE] == 'uri'
	    	ret = uri._parse ctx1
	    else
		ret = vcard._parse ctx1
	    end
    else
	    ret = value
    end
    if ret.kind_of?(Hash) and ret[:error]
	STDERR.puts "#{ret[:error]} for property #{key}, value #{value}"
        raise ctx1.generate_error 'source'
    end
    if Rsec::INVALID[ret] 
	STDERR.puts "Type mismatch for property #{key}, value #{value}"
        raise ctx1.generate_error 'source'
    end
    return ret
  end

  def paramcheck(prop, params) 
	if params and params[:TYPE]
		parse_err("multiple values for :TYPE parameter of #{prop}") if params[:TYPE].kind_of?(Array) and prop != :EMAIL and prop != :ADR and prop != :TEL
	end
	case prop
	when :NAME, :PROFILE, :TZ, :GEO, :PRODID, :UID, :URL, :VERSION, :CLASS
		parse_err("illegal parameters #{params} given for #{prop}") unless params.empty?
	when :SOURCE
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}") unless key == :VALUE or key == :CONTEXT or key =~ /^x/i
			parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val != "uri"
			parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :CONTEXT and val != "word"
		}
	when :FN, :N, :NICKNAME, :MAILER, :TITLE, :ROLE, :ORG, :CATEGORIES, :NOTE, :SORT_STRING
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}") unless key == :VALUE or key == :LANGUAGE or key =~ /^x/i
			parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val != "ptext"
		}
	when :TEL
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}") unless key == :TYPE
		}
		# we do not check the values of the :TEL :TYPE parameter, because they include ianaToken
	when :EMAIL
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}") unless key == :TYPE
		}
		# we do not check the values of the first :EMAIL :TYPE parameter, because they include ianaToken
		if params[:TYPE].length > 1
			parse_err("illegal second parameter #{params[:TYPE][1]} given for #{prop}") unless params[:TYPE][1] == 'PREF'
		end
	when :ADR, :LABEL
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}") unless key == :VALUE or key == :LANGUAGE or key =~ /^x/i or key == :TYPE
			parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val != "ptext"
		}
		# we do not check the values of the :ADR :TYPE parameter, because they include ianaToken
	when :KEY
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}") unless key == :TYPE or key == :ENCODING
		}
		# we do not check the values of the :KEY :TYPE parameter, because they include ianaToken
	when :PHOTO, :LOGO, :SOUND
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}") unless key == :VALUE or key == :TYPE or key == :ENCODING
		}
		parse_err("illegal value #{params[:VALUE]} of :VALUE given for #{prop}") if params[:VALUE] and params[:VALUE] != "binary" and params[:VALUE] != "uri"
		parse_err("illegal value #{params[:ENCODING]} of :ENCODING given for #{prop}") if params[:ENCODING] and (params[:ENCODING] != "b" or params[:VALUE] == "uri")
		parse_err("mandatory parameter of :ENCODING missing for #{prop}") if !params.key(:ENCODING) and (!params.key?(:VALUE) or params[:VALUE] == "binary")
		# TODO restriction of :TYPE to image types registered with IANA
		# TODO restriction of :TYPE to sound types registered with IANA
	when :BDAY, :REV
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}") unless key == :VALUE 
		}
		parse_err("illegal value #{params[:VALUE]} of :VALUE given for #{prop}") if params[:VALUE] and params[:VALUE] != "date" and params[:VALUE] != "date-time"
	when :AGENT
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}") unless key == :VALUE 
		}
		parse_err("illegal value #{params[:VALUE]} of :VALUE given for #{prop}") if params[:VALUE] and params[:VALUE] != "uri"
	else
		params.each {|key, val|
			parse_err("illegal parameter #{key} given for #{prop}") unless key == :VALUE or key == :LANGUAGE or key =~ /^x/i
			parse_err("illegal value #{val} given for parameter #{key} of #{prop}") if key == :VALUE and val != "ptext"
		}
	end
  end

private


   def parse_err(msg)
	   	  STDERR.puts msg
	          raise @ctx.generate_error 'source'
   end

  end
end
end
