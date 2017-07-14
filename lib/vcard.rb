require "rsec"
require "set"
require "uri"
require "date"
#require "tzinfo"
include Rsec::Helpers
require 'vcard/version'
require 'vobject'
require 'vobject/component'

module Vcard

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
    ianaToken 	= /[a-zA-Z\d\-]+/.r 
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

  def date_noreduc
     date_noreduc	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
	     		#Time.utc(yy, mm, dd)
		} | seq('--', /[0-9]{2}/.r, /[0-9]{2}/.r) {|_, mm, dd|
		} | seq('--', '-', /[0-9]{2}/.r) {|_, _, dd|
		}
     date_noreduc.eof
  end

  def date_complete
     date_complete	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
		}
     date_complete.eof
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

  def time_notrunc
    sign	    = /[+-]/i.r
    utc_offset 	= seq(sign, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?)
    zone	= utc_offset | /Z/i.r
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time_notrunc	= seq(hour, minute, second, zone._?) |
	    	seq(hour, minute, zone._?) |
    		seq(hour, zone._?) 
    time_notrunc.eof
  end

  def time_complete
    sign	    = /[+-]/i.r
    utc_offset 	= seq(sign, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?)
    zone	= utc_offset | /Z/i.r
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time_complete	= seq(hour, minute, second, zone._?) 
    time_complete.eof
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

  def timestamp
     date_complete	= seq(/[0-9]{4}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r) {|yy, mm, dd|
		}
    sign	    = /[+-]/i.r
    utc_offset 	= seq(sign, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?)
    zone	= utc_offset | /Z/i.r
    hour	= /[0-9]{2}/.r
    minute	= /[0-9]{2}/.r
    second	= /[0-9]{2}/.r
    time_complete	= seq(hour, minute, second, zone._?) 
    timestamp 	= seq(date_complete, 'T', time_complete)
    timestamp.eof
  end

  def date_and_or_time
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
    time	= seq(hour, minute, second, zone._?) |
	    	seq(hour, minute, zone._?) |
    		seq(hour, zone._?) |
	    	seq('-', minute, second, zone._?) |
	    	seq('-', minute, zone._?) |
	    	seq('-', '-', second, zone._?) 
    date_and_or_time = date_time | date | seq("T", time)
     date_and_or_time.eof
  end
  
  def utc_offset
    sign	    = /[+-]/i.r
    utc_offset 	= seq(sign, /[0-9]{2}/.r, /[0-9]{2}/.r, /[0-9]{2}/.r._?)
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
	    		{:surname => a, :givenname => b, :additionalname => c, 
				:honprefix => d, :honsuffix => e}
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
	    	}
    address.eof
  end

  def gender
	  gender = seq(/[MFONU]/.r._?, text._?) { |sex, gender|
		  		sex = sex[0] unless sex.empty?
		  		gender = gender[0] unless gender.empty?
		  		{:sex => sex, :gender => gender}
	  		}
	  gender.eof
  end

  def typeparamtel1list
    ianaToken 	= /[a-zA-Z\d\-]+/.r 
    xname 	= seq( '[xX]-', /[a-zA-Z0-9-]+/.r).map(&:join)
    typeparamtel1	= /TEXT/i.r | /VOICE/i.r | /FAX/i.r | /CELL/i.r | /VIDEO/i.r |
	    		/PAGER/i.r | /TEXTPHONE/i.r | ianaToken | xname
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

  def vobjectGrammar

# properties with value cardinality 1
    @cardinality1 = {}
    @cardinality1[:PARAM] = Set.new [:VALUE]
    @cardinality1[:PROP] = Set.new [:KIND, :N, :BDAY, :ANNIVERSARY, :GENDER, :PRODID, :REV, :UID]
    ianaToken 	= /[a-zA-Z\d\-]+/.r 
    utf8_tail 	= /[\u0080-\u00bf]/.r
    utf8_2 	= /[\u00c2-\u00df]/.r  | utf8_tail
    utf8_3 	= /[\u00e0\u00a0-\u00bf\u00e1-\u00ec\u00ed\u0080-\u009f\u00ee-\u00ef]/.r  | 
	          utf8_tail
    utf8_4 	= /[\u00f0\u0090-\u00bf\u00f1-\u00f3\u00f4\u0080-\u008f]/.r | utf8_tail
    nonASCII 	= utf8_2 | utf8_3 | utf8_4
    wsp 	= /[ \t]/.r
    qSafeChar 	= wsp | /[!\u0023-\u007e]/ | nonASCII
    safeChar 	= wsp | /[!\u0023-\u0039\u003c-\u007e]/  | nonASCII
    vChar 	= /[\u0021-\u007e]/.r
    valueChar 	= wsp | vChar | nonASCII
    dQuote 	= /"/.r

    group 	= ianaToken
    vendorid	= /[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]/.r
    xname 	= seq( '[xX]-', /[a-zA-Z0-9-]+/.r).map(&:join)
    		  # different from ical
    linegroup 	= group <<  '.' 
    beginend 	= /BEGIN/i.r | /END/i.r
    name  	= xname | seq( ''.r ^ beginend, ianaToken )[1]
    boolean 	= /TRUE/i.r | /FALSE/i.r



# parameters and parameter types
    propertyname 	= /SOURCE/i.r | /KIND/i.r | /FN/i.r | /NICKNAME/i.r | /NOTE/i.r | /N/i.r |
	    		/PHOTO/i.r | /BDAY/i.r | /ANNIVERSARY/i.r | /GENDER/i.r | /ADR/i.r |
			/TEL/i.r | /EMAIL/i.r | /IMPP/i.r | /LANG/i.r | /TZ/i.r |
			/GEO/i.r | /TITLE/i.r | /ROLE/i.r | /LOGO/i.r | /ORG/i.r |
			/MEMBER/i.r | /RELATED/i.r | /CATEGORIES/i.r | /PRODID/i.r |
			/REV/i.r | /SOUND/i.r | /UID/i.r | /CLIENTPIDMAP/i.r | /URL/i.r |
			/KEY/i.r | /FBURL/i.r | /CALADRURI/i.r | /CALURI/i.r | /XML/i.r
    paramname 		= /LANGUAGE/i.r | /VALUE/i.r | /PREF/i.r | /ALTID/i.r | /PID/i.r |
	    		/TYPE/i.r | /MEDIATYPE/i.r | /CALSCALE/i.r | /SORT-AS/i.r |
			/GEO/i.r | /TZ/i.r | /LABEL/i.r
    otherparamname = xname | seq(''.r ^ paramname, ianaToken)[1]
    pText  	= safeChar.star.map(&:join)
    quotedString = seq(dQuote, qSafeChar.star, dQuote) {|_, qSafe, _| 
	    		qSafe.join('') 
    		}
    paramvalue 	= quotedString.map {|s| s } | pText.map {|s| s.upcase }
    tzidvalue 	= seq("/".r._?, pText).map {|_, val| val}
    
    calscalevalue = /GREGORIAN/i.r | ianaToken | xname
    prefvalue	= /[0-9]{1,2}/i.r | '100'.r
    pidvalue	= /[0-9]+(\.[0-9]+)?/.r
    pidvaluelist	= (pidvalue ^ ','.r).map {|z| [z]} | seq(pidvalue, ",", lazy{pidvaluelist}) {|a, _, b|
	    			[a, b].flatten
	    		}
    typeparamtel1	= /TEXT/i.r | /VOICE/i.r | /FAX/i.r | /CELL/i.r | /VIDEO/i.r |
	    		/PAGER/i.r | /TEXTPHONE/i.r 
    typeparamtel	= typeparamtel1 | ianaToken | xname
    typeparamrelated	= /CONTACT/i.r | /ACQUAINTANCE/i.r | /FRIEND/i.r | /MET/i.r |
	    		/CO-WORKER/i.r | /COLLEAGUE/i.r | /CO-RESIDENT/i.r | /NEIGHBOR/i.r |
			/CHILD/i.r | /PARENT/i.r | /SIBLING/i.r | /SPOUSE/i.r | /KIN/i.r |
			/MUSE/i.r | /CRUSH/i.r | /DATE/i.r | /SWEETHEART/i.r | /ME/i.r |
			/AGENT/i.r | /EMERGENCY/i.r
    typevalue	= /WORK/i.r | /HOME/i.r | typeparamtel1 | typeparamrelated | ianaToken | xname
    typevaluelist = typevalue.map {|t| [t] } | seq(typevalue, ",", lazy{typevaluelist}) {|a, _, b|
	    			[a, b].flatten
			}
    typeparamtel1list = typeparamtel1.map {|t| [t] } | seq(typeparamtel1, ",", lazy{typeparamtel1list}) {|a, _, b|
	    			[a, b].flatten
			}
     geourlvalue = seq('"'.r >> uri << '"'.r) {|s|
	                 	parse_err("geo value not a URI") unless s =~ URI::regexp 
				s
    			}
    tzvalue 	= paramvalue | geourlvalue
    valuetype 	= /TEXT/i.r | /URI/i.r | /TIMESTAMP/i.r | /TIME/i.r | /DATE-TIME/i.r | /DATE/i.r |
	    	/DATE-AND-OR-TIME/i.r | /BOOLEAN/i.r | /INTEGER/i.r | /FLOAT/i.r | /UTC-OFFSET/i.r | 
		/LANGUAGE-TAG/i.r | xname | ianaToken
    mediaattr	= /[!\"#$%&'*+.^A-Z0-9a-z_`i{}|~-]+/.r
    mediavalue	=	mediaattr | quotedString
    mediatail	= seq(';', mediaattr, '=', mediavalue)
    rfc4288regname      = /[A-Za-z0-9!#$&.+^+-]{1,127}/.r
    rfc4288typename     = rfc4288regname
    rfc4288subtypename  = rfc4288regname
    mediavalue	= seq(rfc4288typename, "/", rfc4288subtypename, mediatail.star)
    pvalueList 	= (paramvalue & /[;:]/.r).map {|e| 
	    		[e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
    		} | (seq(paramvalue, ','.r, lazy{pvalueList}) & /[;:]/.r).map {|e, _, list|
			ret = list << e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n") 
			ret
		}
    quotedStringList = (quotedString & /[;:]/.r).map {|e|
                        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
                } | (seq(quotedString, ','.r, lazy{quotedStringList}) & /[;:]/.r).map {|e, _, list|
                         ret = list << e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")
                         ret
                }

    fmttypevalue 	= seq(rfc4288typename, "/", rfc4288subtypename).map(&:join)
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

    param 	= seq(/ALTID/i.r, '=', paramvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
    		} | seq(/LANGUAGE/i.r, '=', rfc5646langvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/PREF/i.r, '=', prefvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
    		} | seq(/TYPE/i.r, '=', typevaluelist) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val.upcase}
		} | seq(/MEDIATYPE/i.r, '=', mediavalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/CALSCALE/i.r, '=', calscalevalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/SORT-AS/i.r, '=', pvalueList) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/TZ/i.r, '=', tzvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/GEO/i.r, '=', geourlvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/VALUE/i.r, '=', valuetype) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(/PID/i.r, '=', pidvaluelist) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
    		} | seq(otherparamname, '=', pvalueList) {|name, _, val|
	    		val = val[0] if val.length == 1
			{name.upcase.gsub(/-/,"_").to_sym => val}
		} | seq(paramname, '=', pvalueList) {|name, _, val|
			parse_err("Violated format of parameter value #{name} = #{val}")
		}

    params	= seq(';'.r >> param ^ ';'.r).map {|e|
			e[0]
    		} | seq(';'.r >> param, lazy{params} ) {|p, ps|
			p.merge(ps) {|key, old, new|
				if @cardinality1[:PARAM].include?(key)
						parse_err("Violated cardinality of parameter #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
			}
		}

    value 	= valueChar.star.map(&:join)
    contentline = seq(linegroup._?, name, params._?, ':', 
		      value, /[\r\n]/) {|group, name, params, _, value, _|
			key =  name.upcase.gsub(/-/,"_").to_sym
			hash = { key => {} }
			hash[key][:value] = typematch(key, params[0], :GENERIC, value)
			hash[key][:group] = group[0]  unless group.empty?
			hash[key][:params] = params[0] unless params.empty?
			# TODO restrictions on params
			hash
		}
        props	= (''.r & beginend).map {|e|
			 	{}   
			} | seq(contentline, lazy{props}) {|c, rest|
			c.merge( rest ) { | key, old, new|
				if @cardinality1[:PROP].include?(key.upcase) and
					!(new.kind_of?(Array) and 
						  	new[0].key?(:params) and new[0][:params].key?(:ALTID) and
					     		old.key?(:params) and old[:params].key?(:ALTID) and 
							old[:params][:ALTID] == new[0][:params][:ALTID]) and
						!(new.kind_of?(Hash) and
						  	old.key?(:params) and old[:params].key?(:ALTID) and 
					     		new.key?(:params) and new[:params].key?(:ALTID) and 
							old[:params][:ALTID] == new[:params][:ALTID])
						parse_err("Violated cardinality of property #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
			}
			}

	calpropname = /VERSION/i.r 
	calprop     = seq(calpropname, ':', value, 	/[\r\n]/) {|key, _, value, _|
	    		key = key.upcase.gsub(/-/,"_").to_sym
	    		hash = { key => {} }
			hash[key][:value] = typematch(key, nil, :VCARD, value)
			hash
	}
    vobject 	= seq(/BEGIN:VCARD[\r\n]/i.r, calprop, props, /END:VCARD[\r\n]/i.r) { |(b, v, rest, e)|
			parse_err("Missing VERSION attribute") unless v.has_key?(:VERSION)
			parse_err("Missing FN attribute") unless rest.has_key?(:FN)
			rest.delete(:END)
	            	hash = { :VCARD => v.merge( rest ) }
		        hash
		}
    vobject.eof 
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

  def parse(vobject)
	@ctx = Rsec::ParseContext.new unfold(vobject), 'source'
	ret = vobjectGrammar._parse @ctx
	if !ret or Rsec::INVALID[ret] 
	      raise @ctx.generate_error 'source'
        end
	Rsec::Fail.reset
	return ret
  end

private

  def unfold(str)
	         str.gsub(/[\n\r]+[ \t]+/, '')
  end


   def parse_err(msg)
	   	  STDERR.puts msg
	          raise @ctx.generate_error 'source'
   end

  end
end
