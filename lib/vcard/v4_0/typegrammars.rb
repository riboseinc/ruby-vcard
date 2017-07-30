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
	                  	parse_err("invalid URI: #{s}") unless s =~ URI::regexp 
	                  	s
			 }
	uri.eof
  end

  def clientpidmap
	uri         = /\S+/.r.map {|s|
	                  	parse_err("invalid URI: #{s}") unless s =~ URI::regexp 
				s
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
    utc_offset 	= seq(C::SIGN, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?) {|s, h, m, z|
                    h = {:sign => s, :hour => h, :min => m}
                    h[:sec] = z[0] unless s.empty?
                    h
                }
    zone	= utc_offset.map {|u| {:zone => u } } | 
                    /Z/i.r.map {|z| {:zone => 'Z'} }
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time	= seq(hour, minute, second, zone._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq(hour, minute, zone._?) {|h, m, z|
                h = {:hour => h, :min => m}
                h[:zone] = z[0] unless z.empty?
                h
            } |	seq(hour, zone._?) {|h, z|
                h = {:hour => h}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq('-', minute, second, zone._?) {|m, s, z|
                h = {:min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq('-', minute, zone._?) {|m, z|
                h = {:min => m}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq('-', '-', second, zone._?) {|s, z|
                h = {:sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            }
    time.eof
  end

  def time_notrunc
    utc_offset 	= seq(C::SIGN, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?) {
                    h = {:sign => s, :hour => h, :min => m}
                    h[:sec] = s[0] unless s.empty?
                    h
            }
    zone	= utc_offset.map {|u| {:zone => u } } | 
                    /Z/i.r.map {|z| {:zone => 'Z'} }
    time_notrunc	= seq(hour, minute, second, zone._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq(hour, minute, zone._?) {|h, m, z|
                h = {:hour => h, :min => m}
                h[:zone] = z[0] unless z.empty?
                h
	    	} | seq(hour, zone._?) {|h, z|
                h = {:hour => h}
                h[:zone] = z[0] unless z.empty?
                h
	    	}
	time_notrunc.eof
  end

  def time_complete
    utc_offset 	= seq(C::SIGN, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?) {
                    h = {:sign => s, :hour => h, :min => m}
                    h[:sec] = s[0] unless s.empty?
                    h
            }
    zone	= utc_offset.map {|u| {:zone => u } } | 
                    /Z/i.r.map {|z| {:zone => 'Z'} }
    time_complete	= seq(hour, minute, second, zone._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } 
	time_complete.eof
  end

 def date_time
    utc_offset 	= seq(C::SIGN, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?) {
                    h = {:sign => s, :hour => h, :min => m}
                    h[:sec] = s[0] unless s.empty?
                    h
            }
    zone	= utc_offset.map {|u| {:zone => u } } | 
                    /Z/i.r.map {|z| {:zone => 'Z'} }
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time_notrunc	= seq(hour, minute, second, zone._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq(hour, minute, zone._?) {|h, m, z|
                h = {:hour => h, :min => m}
                h[:zone] = z[0] unless z.empty?
                h
	    	} | seq(hour, zone._?) {|h, z|
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
    utc_offset 	= seq(C::SIGN, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?) {
                    h = {:sign => s, :hour => h, :min => m}
                    h[:sec] = s[0] unless s.empty?
                    h
            }
    zone	= utc_offset.map {|u| {:zone => u } } | 
                    /Z/i.r.map {|z| {:zone => 'Z'} }
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time_complete	= seq(hour, minute, second, zone._?) {|h, m, s, z|
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
    utc_offset 	= seq(C::SIGN, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?) {
                    h = {:sign => s, :hour => h, :min => m}
                    h[:sec] = s[0] unless s.empty?
                    h
            }
    zone	= utc_offset.map {|u| {:zone => u } } | 
                    /Z/i.r.map {|z| {:zone => 'Z'} }
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time_notrunc	= seq(hour, minute, second, zone._?) {|h, m, s, z|
                    h = {:hour => h, :min => m, :sec => s}
                    h[:zone] = z[0] unless z.empty?
                    h
            } | seq(hour, minute, zone._?) {|h, m, z|
                    h = {:hour => h, :min => m}
                    h[:zone] = z[0] unless z.empty?
                    h
            } | seq(hour, zone._?) {
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
    time	= seq(hour, minute, second, zone._?) {|h, m, s, z|
                h = {:hour => h, :min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq(hour, minute, zone._?) {|h, m, z|
                h = {:hour => h, :min => m}
                h[:zone] = z[0] unless z.empty?
                h
            } |	seq(hour, zone._?) {|h, z|
                h = {:hour => h}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq('-', minute, second, zone._?) {|m, s, z|
                h = {:min => m, :sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq('-', minute, zone._?) {|m, z|
                h = {:min => m}
                h[:zone] = z[0] unless z.empty?
                h
            } | seq('-', '-', second, zone._?) {|s, z|
                h = {:sec => s}
                h[:zone] = z[0] unless z.empty?
                h
            }
    date_and_or_time = date_time | date | seq("T", time).map {|_, t| t }
     date_and_or_time.eof
  end
  
  def utc_offset
    utc_offset 	= seq(C::SIGN, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?) {
                    h = {:sign => s, :hour => h, :min => m}
                    h[:sec] = s[0] unless s.empty?
                    h
            }
  end

  def kindvalue
	  kindvalue = /individual/i.r | /group/i.r | /org/i.r | /location/i.r |
		  	C::IANATOKEN | C::XNAME
	  kindvlaue.eof
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

  def rfc5646langvalue
    rfc5646irregular	= /en-GB-oed/i.r | /i-ami/i.r | /i-bnn/i.r | /i-default/i.r | /i-enochian/i.r |
	    			/i-hak/i.r | /i-klingon/i.r | /i-lux/i.r | /i-mingo/i.r |
				/i-navajo/i.r | /i-pwn/i.r | /i-tao/i.r  | /i-tay/i.r |
				/i-tsu/i.r | /sgn-BE-FR/i.r | /sgn-BE-NL/i.r | /sgn-CH-DE/i.r
    rfc5646regular	= /art-lojban/i.r | /cel-gaulish/i.r | /no-bok/i.r | /no-nyn/i.r |
	    			/zh-guoyu/i.r | /zh-hakka/i.r | /zh-min/i.r | /zh-min-nan/i.r |
				/zh-xiang/i.r
    rfc5646grandfathered	= rfc5646irregular | rfc5646regular
    rfc5646privateuse1	= seq('-', /[0-9A-Za-z]{1,8}/.r)
    rfc5646privateuse	= seq('x', rfc5646privateuse1 * (1..-1))
    rfc5646extension1	= seq('-', /[0-9A-Za-z]{2,8}/.r)
    rfc5646extension	= seq('-', /[0-9][A-WY-Za-wy-z]/.r, rfc5646extension1 * (1..-1))
    rfc5646variant	= seq('-', /[A-Za-z]{5,8}/.r) | seq('-', /[0-9][A-Za-z0-9]{3}/)
    rfc5646region	= seq('-', /[A-Za-z]{2}/.r) | seq('-', /[0-9]{3}/)
    rfc5646script	= seq('-', /[A-Za-z]{4}/.r)
    rfc5646extlang	= seq(/[A-Za-z]{3}/.r, /[A-Za-z]{3}/.r._?, /[A-Za-z]{3}/.r._?)
    rfc5646language	= seq(/[A-Za-z]{2,3}/.r , rfc5646extlang._?) | /[A-Za-z]{4}/.r | /[A-Za-z]{5,8}/.r
    rfc5646langtag	= seq(rfc5646language, rfc5646script._?, rfc5646region._?,
			      rfc5646variant.star, rfc5646extension.star, rfc5646privateuse._? ) {|a, b, c, d, e, f|
	    			[a, b, c, d, e, f].flatten.join('')
    			}
    rfc5646langvalue 	= rfc5646langtag | rfc5646privateuse | rfc5646grandfathered
    rfc5646langvalue.eof
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
	    ret = text._parse ctx1
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
		    ret = text._parse ctx1
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
		    ret = text._parse ctx1
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
	    ret = rfc5646langvalue._parse ctx1
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


   def parse_err(msg)
	   	  STDERR.puts msg
	          raise @ctx.generate_error 'source'
   end

  end
end
end
