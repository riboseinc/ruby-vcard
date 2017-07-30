require "rsec"
require "set"
require "uri"
require "date"
#require "tzinfo"
include Rsec::Helpers
require 'vcard/version'
require 'vobject'

module Vcard::V4_0
	class Typegrammars

 class << self

  # property value types, each defining their own parser

  def integer  
    integer 	= prim(:int32)
    integer.eof
  end
  
  def float
    float 	    = prim(:double)
    float.eof
  end

  def ianaToken
    ianaToken 	= C::IANATOKEN
    ianaToken.eof
  end 

  def versionvalue
     versionvalue = '4.0'.r 
     versionvalue.eof
  end

  def uri
	uri         = /\S+/.r.map {|s|
	                  	s =~ URI::regexp ? s : {:error => 'Invalid URI'}
			 }
	uri.eof
  end

  def clientpidmap
	uri         = /\S+/.r.map {|s|
	                  	s =~ URI::regexp ? s : {:error => 'Invalid URI'}
			 }
	clientpidmap = seq(/[0-9]/.r, ';', uri) {|a, _, b|
		{:pid => a, :uri => b}
	}
	clientpidmap.eof
  end

  def textT
    textT	= C::TEXT
    textT.eof
  end

  def textlist
    textlist	= 
	    	seq(C::TEXT, ',', lazy{textlist}) { |a, b| [a, b].flatten } |
	    	C::TEXT.map {|t| [t]} 
    textlist.eof
  end

  def dateT
     dateT	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
		    {:year => yy, :month => mm, :day => dd}
        } | /[0-9]{4}/.r {|yy|
			{:year => yy }
		} | seq(/[0-9]{4}/.r, "-", /[0-9]{2}/.r) {|yy, _, dd|
			{:year => yy, :day => dd }
		} | seq('--', /[0-9]{2}/.r) {|_, mm|
            {:month => mm}
		} | seq('--', /[0-9]{2}/.r, /[0-9]{2}/.r) {|_, mm, dd|
		    {:month => mm, :day => dd}
		} | seq('--', '-', /[0-9]{2}/.r) {|_, _, dd|
		    {:day => dd}
		}
     dateT.eof
  end

  def date_noreduc
     date_noreduc	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
	     		{:year => yy, :month => mm, :day => dd}
		} | seq('--', /[0-9]{2}/.r, /[0-9]{2}/.r) {|_, mm, dd|
		        {:month => mm, :day => dd}
		} | seq('--', '-', /[0-9]{2}/.r) {|_, _, dd|
		        {:day => dd}
		}
     date_noreduc.eof
  end

  def date_complete
     date_complete	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
            {:year => yy, :month => mm, :day => dd}
		}
     date_complete.eof
  end

  def timeT	
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq(hour, minute, C::ZONE._?) {|h, m, z|
                h = {:hour => h, :min => m}
                h[:zone] = z[0] unless z.empty?
                h
            } |	seq(hour, C::ZONE._?) {|h, z|
                h = {:hour => h}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq('-', minute, second, C::ZONE._?) {|m, s, z|
                h = {:min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq('-', minute, C::ZONE._?) {|m, z|
                h = {:min => m}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq('-', '-', second, C::ZONE._?) {|s, z|
                h = {:sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            }
    time.eof
  end

  def time_notrunc
    time_notrunc	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq(hour, minute, C::ZONE._?) {|h, m, z|
                h = {:hour => h, :min => m}
                h[:zone] = z[0] unless z.empty?
                h
	    	} | seq(hour, C::ZONE._?) {|h, z|
                h = {:hour => h}
                h[:zone] = z[0] unless z.empty?
                h
	    	}
	time_notrunc.eof
  end

  def time_complete
    time_complete	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } 
	time_complete.eof
  end

 def date_time
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time_notrunc	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq(hour, minute, C::ZONE._?) {|h, m, z|
                h = {:hour => h, :min => m}
                h[:zone] = z[0] unless z.empty?
                h
	    	} | seq(hour, C::ZONE._?) {|h, z|
                h = {:hour => h}
                h[:zone] = z[0] unless z.empty?
                h
	    	}
     date_noreduc	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
            {:year => yy, :month => mm, :day => dd}
        } |
		seq('--', /[0-9]{2}/.r, /[0-9]{2}/.r) {|_, mm, dd|
		    {:month => mm, :date => dd}
		} | seq('--', '-', /[0-9]{2}/.r) {|_, _, dd|
		    {:date => dd}
		}
     date_time	= seq(date_noreduc, 'T', time_notrunc) {|d, _, t|
                d.merge t
	     	}
     date_time.eof
  end

  def timestamp
    date_complete	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
            {:year => yy, :month => mm, :day => dd}
		}
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time_complete	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
    }
    timestamp 	= seq(date_complete, 'T', time_complete)  {|d, _, t|
                d.merge t
	     	}
    timestamp.eof
  end

  def date_and_or_time
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time_notrunc	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                    h = {:hour => h, :min => m, :sec => s}
                    h[:zone] = z[0] unless z.empty?
                    h
            } | seq(hour, minute, C::ZONE._?) {|h, m, z|
                    h = {:hour => h, :min => m}
                    h[:zone] = z[0] unless z.empty?
                    h
            } | seq(hour, C::ZONE._?) {
                    h = {:hour => h}
                    h[:zone] = z[0] unless z.empty?
                    h
            }
     date_noreduc	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
	     		 {:year => yy, :month => mm, :day => dd}
		} | seq('--', /[0-9]{2}/.r, /[0-9]{2}/.r) {|_, mm, dd|
		         {:month => mm, :day => dd}
		} | seq('--', '-', /[0-9]{2}/.r) {|_, _, dd|
		         {:day => dd}
		}
     date_time	= seq(date_noreduc, 'T', time_notrunc) {|d, _, t|
                d.merge t
	     	}
     date	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
                {:year => yy, :month => mm, :day => dd}
	     	} | /[0-9]{4}/.r {|yy|
                {:year => yy}
		} | seq(/[0-9]{4}/.r, "-", /[0-9]{2}/.r) {|yy, _, dd|
                {:year => yy, :day => dd}
		} | seq('--', /[0-9]{2}/.r) {|_, mm|
                {:month => mm}
		} | seq('--', /[0-9]{2}/.r, /[0-9]{2}/.r) {|_, mm, dd|
                {:month => mm, :day => dd}
		} | seq('--', '-', /[0-9]{2}/.r) {|_, _, dd|
                {:day => dd}
		}
    time	= seq(hour, minute, second, C::ZONE._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq(hour, minute, C::ZONE._?) {|h, m, z|
                h = {:hour => h, :min => m}
                h[:zone] = z[0] unless z.empty?
                h
            } |	seq(hour, C::ZONE._?) {|h, z|
                h = {:hour => h}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq('-', minute, second, C::ZONE._?) {|m, s, z|
                h = {:min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq('-', minute, C::ZONE._?) {|m, z|
                h = {:min => m}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq('-', '-', second, C::ZONE._?) {|s, z|
                h = {:sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            }
    date_and_or_time = date_time | date | seq("T", time).map {|_, t| t }
     date_and_or_time.eof
  end
  
  def utc_offset
    utc_offset 	= C::UTC_OFFSET
    utc_offset.eof
  end

  def kindvalue
	  kindvalue = /individual/i.r | /group/i.r | /org/i.r | /location/i.r |
		  	C::IANATOKEN | C::XNAME
	  kindvalue.eof
  end

  def fivepartname
    text	= /([ \t\u0021\u0023-\u002b\u002d-\u0039\u003c-\u005b\u005d-\u007e:"\u0080-\u00bf\u00c2-\u00df\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]|\\[;,\\nN])*/.r
    component	=  
	    	seq(C::TEXT, ',', lazy{component}) {|a, _, b|
	    		[a, b].flatten
		} | C::TEXT.map {|t| [t] }
    fivepartname = seq(component, ';', component, ';', component, ';', 
		       component, ';', component) {|a, _, b, _, c, _, d, _, e|
	    		a = a[0] if a.length == 1
	    		b = b[0] if b.length == 1
	    		c = c[0] if c.length == 1
	    		d = d[0] if d.length == 1
	    		e = e[0] if e.length == 1
	    		{:surname => a, :givenname => b, :additionalname => c, 
				:honprefix => d, :honsuffix => e}
	    	}
    fivepartname.eof
  end

  def address
    component	=  
	    	seq(C::TEXT, ',', lazy{component}) {|a, _, b|
	    		[a, b].flatten
		} | C::TEXT.map {|t| [t] }
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
	    	}
    address.eof
  end

  def gender
	  gender = seq(/[MFONU]/.r._?, C::TEXT._?) { |sex, gender|
		  		sex = sex[0] unless sex.empty?
		  		gender = gender[0] unless gender.empty?
		  		{:sex => sex, :gender => gender}
	  		}
	  gender.eof
  end

  def typeparamtel1list
    typeparamtel1	= /TEXT/i.r | /VOICE/i.r | /FAX/i.r | /CELL/i.r | /VIDEO/i.r |
	    		/PAGER/i.r | /TEXTPHONE/i.r | C::IANATOKEN | C::XNAME
    typeparamtel1list = typeparamtel1.map {|t| [t] } | seq(typeparamtel1, ",", lazy{typeparamtel1list}) {|a, _, b|
	    			[a, b].flatten
			}
    typeparamtel1list.eof
  end

  def typerelatedlist
      typeparamrelated    = /CONTACT/i.r | /ACQUAINTANCE/i.r | /FRIEND/i.r | /MET/i.r |
                              /CO-WORKER/i.r | /COLLEAGUE/i.r | /CO-RESIDENT/i.r | /NEIGHBOR/i.r |
                              /CHILD/i.r | /PARENT/i.r | /SIBLING/i.r | /SPOUSE/i.r | /KIN/i.r |
                              /MUSE/i.r | /CRUSH/i.r | /DATE/i.r | /SWEETHEART/i.r | /ME/i.r |
                              /AGENT/i.r | /EMERGENCY/i.r
      typerelatedlist	= typeparamrelated {|t| [t] } | seq(typeparamrelated, ';', lazy{typerelatedlist}) {|a, _, b|
	      			[a, b].flatten
			}
      typerelatedlist.eof
  end

  # Enforce type restrictions on values of particular properties.
  # If successful, return typed interpretation of string
  def typematch(key, params, component, value)
    ctx1 = Rsec::ParseContext.new value, 'source'
    case key
     when :VERSION
	    ret = versionvalue._parse ctx1
     when :SOURCE, :PHOTO, :IMPP, :GEO, :LOGO, :MEMBER, :SOUND, :URL, :FBURL, :CALADRURI, :CALURI
	    ret = uri._parse ctx1
     when :KIND
	    ret = kindvalue._parse ctx1
     when :XML, :FN, :EMAIL, :TITLE, :ROLE, :NOTE
	    ret = textT._parse ctx1
     when :NICKNAME, :ORG, :CATEGORIES
	    ret = textlist._parse ctx1
     when :N
	    ret = fivepartname._parse ctx1
     when :ADR
	    ret = address._parse ctx1
    when :BDAY, :ANNIVERSARY
	    if params and params[:VALUE] == 'text'
		    if params[:CALSCALE]
		        STDERR.puts "Specified CALSCALE within property #{key} as text"
		        raise ctx1.generate_error 'source'
		    end
		    ret = textT._parse ctx1
	    else
		    if params[:CALSCALE] and /^T/ =~ value
		        STDERR.puts "Specified CALSCALE within property #{key} as time"
		        raise ctx1.generate_error 'source'
		    end
		    ret = date_and_or_time._parse ctx1
	    end
    when :TEL
	    if params and params[:TYPE]
		    ret1 = typeparamtel1list.parse params[:type]
		    if ret1 or Rsec::INVALID[ret1]
		        STDERR.puts "Specified illegal TYPE parameter within property #{key}"
	      		raise @ctx.generate_error 'source'
		    end
	    end
	    if params and params[:VALUE] == 'uri'
		    ret = uri._parse ctx1
	    else
		    ret = textT._parse ctx1
	    end
     when :RELATED
	    if params and params[:TYPE]
		    ret1 = typerelatedlist.parse params[:type]
		    if ret1 or Rsec::INVALID[ret1]
		        STDERR.puts "Specified illegal TYPE parameter within property #{key}"
	      		raise @ctx.generate_error 'source'
		    end
	    end
	    if params and params[:VALUE] == 'uri'
		    ret = uri._parse ctx1
	    else
		    ret = text._parse ctx1
	    end
     when :UID, :KEY
	    if params and params[:VALUE] == 'text'
		    ret = text._parse ctx1
	    else
		    ret = uri._parse ctx1
	    end
     when :GENDER
	    ret = gender._parse ctx1
     when :LANG
	    ret = C::RFC5646LANGVALUE._parse ctx1
     when :TZ
	     if params and params[:VALUE] == 'uri'
	    	ret = uri._parse ctx1
	     elsif params and params[:VALUE] == 'utc_offset'
	    	ret = utc_offset._parse ctx1
	     else
	    	ret = text._parse ctx1
	     end
      when :REV
	      ret = timestamp._parse ctx1
     when :CLIENTPIDMAP
	     if params and params[:PID]
		        STDERR.puts "Specified PID parameter in CLIENTPIDMAP property"
	      		raise @ctx.generate_error 'source'
	     end
	     ret = clientpidmap._parse ctx1
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



private


   def parse_err(msg, ctx)
	          raise ctx.report_error msg, 'source'
   end

  end
end
end
