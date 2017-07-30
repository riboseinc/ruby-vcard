require "rsec"
require "set"
require "uri"
require "date"
#require "tzinfo"
include Rsec::Helpers
require 'vcard/version'
require 'vobject'
require 'vobject/component'
require_relative "../../c"
require_relative "../../error"

module Vcard::V4_0
	class Grammar

 class << self

  def vobjectGrammar

# properties with value cardinality 1
    @cardinality1 = {}
    @cardinality1[:PARAM] = Set.new [:VALUE]
    @cardinality1[:PROP] = Set.new [:KIND, :N, :BDAY, :ANNIVERSARY, :GENDER, :PRODID, :REV, :UID]
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

    group 	= C::IANATOKEN
    linegroup 	= group <<  '.' 
    beginend 	= /BEGIN/i.r | /END/i.r



# parameters and parameter types
    paramname 		= /LANGUAGE/i.r | /VALUE/i.r | /PREF/i.r | /ALTID/i.r | /PID/i.r |
	    		/TYPE/i.r | /MEDIATYPE/i.r | /CALSCALE/i.r | /SORT-AS/i.r |
			/GEO/i.r | /TZ/i.r | /LABEL/i.r
    otherparamname = C::NAME ^ paramname
    paramvalue 	= C::QUOTEDSTRING.map {|s| s } | C::PTEXT.map {|s| s.upcase }
    tzidvalue 	= seq("/".r._?, pText).map {|_, val| val}    
    calscalevalue = /GREGORIAN/i.r | C::IANATOKEN | C::XNAME
    prefvalue	= /[0-9]{1,2}/i.r | '100'.r
    pidvalue	= /[0-9]+(\.[0-9]+)?/.r
    pidvaluelist	=  seq(pidvalue, ",", lazy{pidvaluelist}) {|a, _, b|
	    			[a, b].flatten
	    		} | (pidvalue ^ ','.r).map {|z| [z]}
    typeparamtel1	= /TEXT/i.r | /VOICE/i.r | /FAX/i.r | /CELL/i.r | /VIDEO/i.r |
	    		/PAGER/i.r | /TEXTPHONE/i.r 
    typeparamtel	= typeparamtel1 | C::IANATOKEN | C::XNAME
    typeparamrelated	= /CONTACT/i.r | /ACQUAINTANCE/i.r | /FRIEND/i.r | /MET/i.r |
	    		/CO-WORKER/i.r | /COLLEAGUE/i.r | /CO-RESIDENT/i.r | /NEIGHBOR/i.r |
			/CHILD/i.r | /PARENT/i.r | /SIBLING/i.r | /SPOUSE/i.r | /KIN/i.r |
			/MUSE/i.r | /CRUSH/i.r | /DATE/i.r | /SWEETHEART/i.r | /ME/i.r |
			/AGENT/i.r | /EMERGENCY/i.r
    typevalue	= /WORK/i.r | /HOME/i.r | typeparamtel1 | typeparamrelated | C::IANATOKEN | C::XNAME
    typevaluelist =  seq(typevalue, ",", lazy{typevaluelist}) {|a, _, b|
	    			[a, b].flatten
			} | typevalue.map {|t| [t] }
    typeparamtel1list =  seq(typeparamtel1, ",", lazy{typeparamtel1list}) {|a, _, b|
	    			[a, b].flatten
			} | typeparamtel1.map {|t| [t] }
    geourlvalue = seq('"'.r >> C::TEXT << '"'.r) {|s|
	                 	parse_err("geo value not a URI") unless s =~ URI::regexp 
				s
    			}
    tzvalue 	= paramvalue | geourlvalue
    valuetype 	= /TEXT/i.r | /URI/i.r | /TIMESTAMP/i.r | /TIME/i.r | /DATE-TIME/i.r | /DATE/i.r |
	    	/DATE-AND-OR-TIME/i.r | /BOOLEAN/i.r | /INTEGER/i.r | /FLOAT/i.r | /UTC-OFFSET/i.r | 
		/LANGUAGE-TAG/i.r | C::IANATOKEN | C::XNAME
    mediaattr	= /[!\"#$%&'*+.^A-Z0-9a-z_`i{}|~-]+/.r
    mediavalue	=	mediaattr | C::QUOTEDSTRING
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
    quotedStringList =  (seq(C::QUOTEDSTRING, ','.r, lazy{quotedStringList}) & /[;:]/.r).map {|e, _, list|
                         ret = list << e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")
                         ret
                } | (C::QUOTEDSTRING & /[;:]/.r).map {|e|
                        [e.sub(Regexp.new("^\"(.+)\"$"), '\1').gsub(/\\n/, "\n")]
                }

    fmttypevalue 	= seq(rfc4288typename, "/", rfc4288subtypename).map(&:join)

    param 	= seq(/ALTID/i.r, '=', paramvalue) {|name, _, val|
			{name.upcase.gsub(/-/,"_").to_sym => val}
    		} | seq(/LANGUAGE/i.r, '=', C::RFC5646LANGVALUE) {|name, _, val|
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

    params	=  seq(';'.r >> param, lazy{params} ) {|p, ps|
			p.merge(ps) {|key, old, new|
				if @cardinality1[:PARAM].include?(key)
						parse_err("Violated cardinality of parameter #{key}")
				end
				[old,  new].flatten
				# deal with duplicate properties
			}
		} | seq(';'.r >> param ^ ';'.r).map {|e|
			e[0]
    		}

    value 	= valueChar.star.map(&:join)
    contentline = seq(linegroup._?, name, params._?, ':', 
		      value, /[\r\n]/) {|group, name, params, _, value, _|
			key =  name.upcase.gsub(/-/,"_").to_sym
			hash = { key => {} }
			Vcard::V4_0::Paramcheck.paramcheck(key, params.empty?  ? {} : params[0], @ctx)
			hash[key][:value] = Vcard::V4_0::Typegrammars.typematch(key, params[0], :GENERIC, value)
			hash[key][:group] = group[0]  unless group.empty?
			hash[key][:params] = params[0] unless params.empty?
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
			hash[key][:value] = Vcard::V4_0::Typegrammars.typematch(key, nil, :VCARD, value)
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
end
