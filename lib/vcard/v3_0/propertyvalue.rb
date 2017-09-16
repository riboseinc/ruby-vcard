require 'vobject'
require 'vobject/propertyvalue'

module Vcard::V3_0
module PropertyValue

  class Text < Vobject::PropertyValue

   class << self 
  def escape x
	  # temporarily escape \\ as \u007f, which is banned from text
	  x.gsub(/\\/, "\u007f").gsub(/\n/, "\\n").gsub(/,/, "\\,").gsub(/;/, "\\;").gsub(/\u007f/, "\\\\\\\\")
   end

  def listencode x
	if x.kind_of?(Array)
		ret = x.map{|m| Text.escape m}.join(',')
	else
		ret = Text.escape x
	end
	x
  end
   end

    def initialize val
        self.value = val
        self.type = 'text'
    end

    def to_s
	    Text.escape self.value
    end

    def to_hash
      self.value
    end

  end

  class ClassValue < Text
    def initialize val
        self.value = val
        self.type = 'classvalue'
    end

    def to_hash
      self.value
    end

  end

  class Profilevalue < Text
    def initialize val
        self.value = val
        self.type = 'profilevalue'
    end

    def to_hash
      self.value
    end

  end

  class Kindvalue < Text
    def initialize val
        self.value = val
        self.type = 'kindvalue'
    end

    def to_hash
      self.value
    end

  end

  class Ianatoken < Text
    def initialize val
        self.value = val
        self.type = 'ianatoken'
    end

    def to_hash
      self.value
    end

  end

  class Binary < Text
    def initialize val
        self.value = val
        self.type = 'binary'
    end

    def to_hash
      self.value
    end

  end

  class Phonenumber < Text
    def initialize val
        self.value = val
        self.type = 'phonenumber'
    end

    def to_hash
      self.value
    end

  end

  class Uri < Text
    def initialize val
        self.value = val
        self.type = 'uri'
    end

    def to_hash
      self.value
    end

  end

  class Float < Vobject::PropertyValue
    include Comparable
    def <=>(anOther)
	    self.value <=> anOther.value
    end

    def initialize val
        self.value = val
        self.type = 'float'
    end

    def to_s
	    self.value
    end

    def to_hash
      self.value
    end

  end

  class Integer < Vobject::PropertyValue
    include Comparable
    def <=>(anOther)
	    self.value <=> anOther.value
    end

    def initialize val
        self.value = val
        self.type = 'integer'
    end

    def to_s
	self.value.to_s
    end

    def to_hash
      self.value
    end

  end

  class Date < Vobject::PropertyValue
    include Comparable
    def <=>(anOther)
	    self.value <=> anOther.value
    end

    def initialize val
        self.value = val
        self.type = 'date'
    end

    def to_s
	sprintf("%04d%002d-%02d", self.value.year, self.value.month, self.value.day)
    end

    def to_hash
      self.value
    end

  end

  class DateTimeLocal < Vobject::PropertyValue
    include Comparable
    def <=>(anOther)
	    self.value[:time] <=> anOther.value[:time]
    end

    def initialize val
        self.value = val
	# val consists of :time and :zone values. If :zone is empty, floating local time (i.e. system local time) is assumed
        self.type = 'datetimeLocal'
	val[:sec] += (val[:secfrac].to_f / (10 ** val[:secfrac].length)) if !val[:secfrac].nil? and !val[:secfrac].empty?
	if val[:zone].nil? or val[:zone].empty?
		self.value[:time] = ::Time.local(val[:year], val[:month], val[:day], val[:hour], val[:min], val[:sec])
	else
		self.value[:time] = ::Time.utc(val[:year], val[:month], val[:day], val[:hour], val[:min], val[:sec])
	end
	if val[:zone] and val[:zone] != 'Z'
            offset = val[:zone][:hour]*3600 + val[:zone][:min]*60
            offset += val[:zone][:sec] if val[:zone][:sec]
            offset = -offset if val[:sign] == '-'
            self.value[:time] += offset.to_i
        end
    end

    def to_s
	localtime = self.value[:time]
	ret = sprintf("%04d-%02d-%02dT%02d:%02d:%02d", localtime.year, localtime.month, localtime.day,
	       localtime.hour, localtime.min, localtime.sec)
	ret = ret + ",.#{self.value[:secfrac]}" if self.value[:secfrac]
	zone = "Z" if self.value[:zone] and self.value[:zone] == "Z"
	zone = "#{self.value[:zone][:sign]}#{self.value[:zone][:hour]}:#{self.value[:zone][:min]}" if self.value[:zone] and self.value[:zone].kind_of?(Hash)
        ret = ret + zone
	ret
    end


    def to_hash
	    ret = {
		    :year => self.value[:year],
		    :month => self.value[:month],
		    :day => self.value[:day],
		    :hour => self.value[:hour],
		    :min => self.value[:min],
		    :sec => self.value[:sec],
	    }
	    ret[:zone] = self.value[:zone] if self.value[:zone]
	    ret
    end

  end

#  class DateTimeUTC < Vobject::PropertyValue
#    include Comparable
#    def <=>(anOther)
#	    self.value[:time] <=> anOther.value[:time]
#    end
#
#    def initialize val
#        self.value = val
#        self.type = 'datetimeUTC'
#    end
#
#
#    def to_s
#	utc = self.value[:time]
#	sprintf("%04d%02d%02dT%02d%02d%02dZ", utc.year, utc.month, utc.day,
#	       utc.hour, utc.min, utc.sec)
#    end
#
#    def to_hash
#      self.value
#    end
#
#  end
#
#  class Boolean < Vobject::PropertyValue
#
#    def initialize val
#        self.value = val
#        self.type = 'boolean'
#    end
#
#    def to_s
#	    ret = self.value
#    end
#
#    def to_hash
#      self.value
#    end
#
#  end
#
#  class Duration < Vobject::PropertyValue
#
#    def initialize val
#        self.value = val
#        self.type = 'duration'
#    end
#
#    def to_s
#	    ret = "P"
#	    ret = self.value[:sign] + ret if self.value[:sign]
#	    ret = ret + "#{self.value[:weeks]}D" if self.value[:weeks]
#	    ret = ret + "#{self.value[:days]}D" if self.value[:days]
#	    ret = ret + "T" if self.value[:hours] or self.value[:minutes] or self.value[:seconds]
#	    ret = ret + "#{self.value[:hours]}H" if self.value[:hours]
#	    ret = ret + "#{self.value[:minutes]}M" if self.value[:minutes]
#	    ret = ret + "#{self.value[:seconds]}S" if self.value[:seconds]
#	    ret
#    end
#
#    def to_hash
#      self.value
#    end
#
#  end
#
  class Time < Vobject::PropertyValue

    def initialize val
        self.value = val
        self.type = 'time'
    end

    def to_s
        ret = "#{self.value[:hour]}:#{self.value[:min]}:#{self.value[:sec]}"
	ret = ret + ".#{self.value[:secfrac]}" if self.value[:secfrac]
	zone = ""
	zone = "Z" if self.value[:zone] and self.value[:zone] == "Z"
	zone = "#{self.value[:zone][:sign]}#{self.value[:zone][:hour]}:#{self.value[:zone][:min]}" if self.value[:zone] and self.value[:zone].kind_of?(Hash)
        ret = ret + zone
    	ret
    end

    def to_hash
      self.value
    end

  end

  class Utcoffset < Vobject::PropertyValue

    def initialize val
        self.value = val
        self.type = 'utcoffset'
    end

    def to_s
	    ret = "#{self.value[:sign]}#{self.value[:hr]}#{self.value[:min]}"
	    #ret += self.value[:sec] if self.value[:sec]
	    ret
    end

    def to_hash
      self.value
    end

  end

  class Geovalue < Vobject::PropertyValue

    def initialize val
        self.value = val
        self.type = 'geovalue'
    end

    def to_s
	    ret = "#{self.value[:lat]};#{self.value[:long]}"
    ret
   end

    def to_hash
      self.value
    end

  end

  class Version < Vobject::PropertyValue

    def initialize val
        self.value = val
        self.type = 'version'
    end

    def to_s
      self.value
    end

    def to_hash
      	self.value
    end

  end

  class Org < Vobject::PropertyValue
    def initialize val
        self.value = val
        self.type = 'org'
    end

    def to_s
      self.value.map{|m| Text.escape m}.join(';')
    end

    def to_hash
      	self.value
    end

  end

  class Fivepartname < Vobject::PropertyValue
    def initialize val
        self.value = val
        self.type = 'fivepartname'
    end

    def to_s
      ret = Text.listencode self.value[:surname]
      ret += ";#{Text.listencode self.value[:givenname]}" if self.value[:givenname]
      ret += ";#{Text.listencode self.value[:middlename]}" if self.value[:middlename]
      ret += ";#{Text.listencode self.value[:honprefix]}" if self.value[:honprefix]
      ret += ";#{Text.listencode self.value[:honsuffix]}" if self.value[:honsuffix]
      ret
    end

    def to_hash
      	self.value
    end

  end

  class Address < Vobject::PropertyValue
    def initialize val
        self.value = val
        self.type = 'address'
    end

    def to_s
      ret = Text.listencode self.value[:pobox]
      ret += ";#{Text.listencode self.value[:ext]}" 
      ret += ";#{Text.listencode self.value[:street]}" 
      ret += ";#{Text.listencode self.value[:locality]}" 
      ret += ";#{Text.listencode self.value[:region]}"
      ret += ";#{Text.listencode self.value[:code]}"
      ret += ";#{Text.listencode self.value[:country]}"
      ret
    end

    def to_hash
      	self.value
    end

  end

  class Textlist < Vobject::PropertyValue
    def initialize val
        self.value = val
        self.type = 'textlist'
    end

    def to_s
      self.value.map{|m| Text.escape m}.join(',')
    end

    def to_hash
      	self.value
    end

  end

  class Agent < Vobject::PropertyValue
    def initialize val
        self.value = val
        self.type = 'agent'
    end

    def to_hash
	    ret = {}
	    self.value.each{|k, v| 
		ret[k] = {}
		v.each{|k1, v1|
			ret[k][k1] = {}
			v1.each {|k2, v2|
				ret[k][k1][k2] = v2.to_hash
			}
		}
	    }
	    ret
    end

    def to_s
	ret = Vobject::Component.new(self.value).to_s
	ret.gsub(/\n/,"\\n")
    end

  end

#  class Periodlist < Vobject::PropertyValue
#    def initialize val
#        self.value = val
#        self.type = 'periodlist'
#    end
#
#    def to_s
#      self.value.map{|m| 
#	      ret = m[:start].to_s + "/"
#	      ret += m[:end].to_s if m.has_key? :end
#	      ret += m[:duration].to_s if m.has_key? :duration
#	      ret
#      }.join(',')
#    end
#
#    def to_hash
#      	self.value.map {|m| m.each {|k, v| m[k] = v.to_hash }}
#    end
#
#  end
#
#  class Datelist < Vobject::PropertyValue
#    def initialize val
#        self.value = val
#        self.type = 'datelist'
#    end
#
#    def to_s
#      self.value.map{|m| m.to_s}.join(',')
#    end
#
#    def to_hash
#      	self.value.map{|m| m.to_hash}
#    end
#
#  end
#
#  class Datetimelist < Vobject::PropertyValue
#    def initialize val
#        self.value = val
#        self.type = 'datetimelist'
#    end
#
#    def to_s
#      self.value.map{|m| m.to_s}.join(',')
#    end
#
#    def to_hash
#      	self.value.map{|m| m.to_hash}
#    end
#
#  end
#
#  class Datetimeutclist < Vobject::PropertyValue
#    def initialize val
#        self.value = val
#        self.type = 'datetimeutclist'
#    end
#
#    def to_s
#      self.value.map{|m| m.to_s}.join(',')
#    end
#
#    def to_hash
#      	self.value.map{|m| m.to_hash}
#    end
#
#  end
#
#  class Requeststatusvalue < Vobject::PropertyValue
#    def initialize val
#        self.value = val
#        self.type = 'requeststatusvalue'
#    end
#
#    def to_s
#	    ret = "#{self.value[:statcode]};#{self.value[:statdesc]}"
#	    ret += ";#{self.value[:extdata]}" if self.value[:extdata]
#	    ret
#    end
#    
#    def to_hash
#	    self.value
#    end
#
#  end
#
#  class Recur < Vobject::PropertyValue
#    def initialize val
#        self.value = val
#        self.type = 'recur'
#    end
#
#    def to_s
#	    ret = []
#	    self.value.each {|k, v| 
#		ret << "#{k.to_s.upcase}=#{valencode(k,v)}"
#	    }
#	    ret.join(';')
#    end
#
#    def to_hash
#	    ret = {}
#	    self.value.each{|k, v|
#		    if v.respond_to?(:to_hash)
#		    	ret[k] = v.to_hash
#		    else
#			ret[k] = v
#		    end
#	    }
#	    ret
#    end
#
#    private
#
#    def valencode(k, v) 
#	case k
#	when :bysetpos, :byyearday
#		return v.map{|x| 
#			ret = x[:ordyrday]
#			ret = x[:sign] + ret if x[:sign]
#			ret
#		}.join(',')
#	when :byweekno
#		return v.map{|x| 
#			ret = x[:ordwk]
#			ret = x[:sign] + ret if x[:sign]
#			ret
#		}.join(',')
#	when :bymonthday
#		return v.map{|x| 
#			ret = x[:ordmoday]
#			ret = x[:sign] + ret if x[:sign]
#			ret
#		}.join(',')
#	when :byday
#		return v.map{|x| 
#			ret = x[:weekday]
#			ret = x[:ordwk] + ret if x[:ordwk]
#			ret = x[:sign] + ret if x[:sign]
#			ret
#		}.join(',')
#	when :bymonth, :byhour, :byminute, :bysecond
#		return v.join(',')
#	when :enddate
#		return v.to_s
#	else
#		return v
#	end
#    end

  end

end