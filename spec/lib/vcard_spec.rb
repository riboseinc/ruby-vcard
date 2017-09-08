require "rspec/json_expectations"
require 'spec_helper'
require 'json'
require 'rsec'

# Some examples taken from https://github.com/mozilla-comm/ical.js/ , https://github.com/mangstadt/ez-vcard/

describe Vcard do

  it 'should parse VCF properly' do
      ics = File.read "spec/examples/example1.vcf"
      vobj_json = Vcard.new('4.0').parse(ics).to_json
      exp_json = JSON.load(File.read "spec/examples/example1.json")
      expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse VCF properly' do
      ics = File.read "spec/examples/example2.vcf"
      vobj_json = Vcard.new('4.0').parse(ics).to_json
      exp_json = JSON.load(File.read "spec/examples/example2.json")
      expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse VCF with binary photo properly' do
      ics = File.read "spec/examples/example3.vcf"
      vobj_json = Vcard.new('3.0').parse(ics).to_json
      exp_json = JSON.load(File.read "spec/examples/example3.json")
      expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse VCF properly' do
      ics = File.read "spec/examples/example4.vcf"
      vobj_json = Vcard.new('3.0').parse(ics).to_json
      exp_json = JSON.load(File.read "spec/examples/example4.json")
      expect(vobj_json).to include_json(exp_json)
  end

  it 'should parse VCF from Apple' do
      ics = File.read "spec/examples/apple.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/apple.json")
      expect(vobj_json).to include_json(exp_json)
  end

  it 'should reject TYPE on iana-token property' do
      ics = File.read "spec/examples/apple1.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
  end 

  it 'should reject URL without http prefix per RFC 1738' do
      ics = File.read "spec/examples/apple2.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
  end 

  it 'should reject type parameters on URL' do
      ics = File.read "spec/examples/apple3.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
  end 

  it 'should reject X-parameters on IMPP' do
      ics = File.read "spec/examples/apple4.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
  end 

  it 'should process VCF from Apple' do
      ics = File.read "spec/examples/ujb.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/ujb.json")
      expect(vobj_json).to include_json(exp_json)
  end

  it 'should reject CHARSET parameter' do
      ics = File.read "spec/examples/ujb1.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
  end

  it 'should reject TYPE parameter on X-property' do
      ics = File.read "spec/examples/ujb2.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
  end

  it 'should reject VCF with FN but no N' do
      ics = File.read "spec/examples/example51.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
  end

  it 'should reject VCF with FN but no N' do
      ics = File.read "spec/examples/example61.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
  end

  it 'should process VCF from Apple' do
      ics = File.read "spec/examples/example5.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/example5.json")
      expect(vobj_json).to include_json(exp_json)
  end

  it 'should process VCF from Apple' do
      ics = File.read "spec/examples/example6.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/example6.json")
      expect(vobj_json).to include_json(exp_json)
  end

    it 'should process VCF v4' do
      ics = File.read "spec/examples/vcard4.vcf"
      vobj_json = Vcard.new('4.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/vcard4.json")
      expect(vobj_json).to include_json(exp_json)
    end

    it 'should process VCF v4' do
      ics = File.read "spec/examples/vcard4author.vcf"
      vobj_json = Vcard.new('4.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/vcard4author.json")
      expect(vobj_json).to include_json(exp_json)
    end

    it 'should process VCF v3' do
      ics = File.read "spec/examples/vcard3.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/vcard3.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should process VCF v3' do
      ics = File.read "spec/examples/bubba.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/bubba.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should process VCF v4' do
      ics = File.read "spec/examples/bubba4.vcf"
      vobj_json = Vcard.new('4.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/bubba4.json")
      expect(vobj_json).to include_json(exp_json)
    end
  it 'should reject VCF4 with LABEL property' do
      ics = File.read "spec/examples/example61.vcf"
      expect { Vcard.new('4.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
  end

    it 'should reject TYPE param on X-name property' do
      ics = File.read "spec/examples/John_Doe_EVOLUTION.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
    end
    it 'should process EVOLUTION VCF v3' do
      ics = File.read "spec/examples/John_Doe_EVOLUTION.1.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/John_Doe_EVOLUTION.1.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should reject unescaped comma in FN property, v3' do
      ics = File.read "spec/examples/John_Doe_GMAIL.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
    end
    it 'should reject escaped colon in URI property, v3' do
      ics = File.read "spec/examples/John_Doe_GMAIL.1.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
    end
    it 'should process GMAIL VCF v3' do
      ics = File.read "spec/examples/John_Doe_GMAIL.2.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/John_Doe_GMAIL.3.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should process IPHONE VCF v3' do
      ics = File.read "spec/examples/John_Doe_IPHONE.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r+\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/John_Doe_IPHONE.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should reject double quotation mark in NOTE value, unescaped' do
      ics = File.read "spec/examples/John_Doe_LOTUS_NOTES.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
    end
    it 'should reject TZ value without sign and double digit hour' do
      ics = File.read "spec/examples/John_Doe_LOTUS_NOTES.1.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
    end
    it 'should reject SOURCE value which is not URI' do
      ics = File.read "spec/examples/John_Doe_LOTUS_NOTES.2.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
    end
    it 'should process LOTUS VCF v3' do
      ics = File.read "spec/examples/John_Doe_LOTUS_NOTES.3.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/John_Doe_LOTUS_NOTES.3.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should reject BASE64 parameter VCF v3' do
      ics = File.read "spec/examples/John_Doe_MAC_ADDRESS_BOOK.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
    end
    it 'should process MAC ADDRRESS BOOK VCF v3' do
      ics = File.read "spec/examples/John_Doe_MAC_ADDRESS_BOOK.1.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r+\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/John_Doe_MAC_ADDRESS_BOOK.1.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should process VCF v4' do
      ics = File.read "spec/examples/fullcontact.vcf"
      vobj_json = Vcard.new('4.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/fullcontact.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should process GMAIL VCF v3' do
      ics = File.read "spec/examples/gmail-single.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/gmail-single.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should process GMAIL VCF v3' do
      ics = File.read "spec/examples/gmail-single2.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/gmail-single2.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should reject obsolete CHARSET parameter VCF v3' do
      ics = File.read "spec/examples/thunderbird-MoreFunctionsForAddressBook-extension.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
    end
    it 'should process THUNDERBIRD VCF v3' do
      ics = File.read "spec/examples/thunderbird-MoreFunctionsForAddressBook-extension.1.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/thunderbird-MoreFunctionsForAddressBook-extension.1.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should reject mispositioned VERSION property, v3' do
      ics = File.read "spec/examples/stenerson.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
    end
    it 'should process VCF v3' do
      ics = File.read "spec/examples/stenerson.1.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/stenerson.1.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should process RFC2739 additions to VCF v3' do
      ics = File.read "spec/examples/rfc2739.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/rfc2739.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should process VCF v4' do
      ics = File.read "spec/examples/trafalgar.vcf"
      vobj_json = Vcard.new('4.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/trafalgar.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should process VCF v4 additions from RFC 6474' do
      ics = File.read "spec/examples/rfc6474.1.vcf"
      vobj_json = Vcard.new('4.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/rfc6474.1.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should process VCF v4 additions from RFC 6474' do
      ics = File.read "spec/examples/rfc6474.2.vcf"
      vobj_json = Vcard.new('4.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/rfc6474.2.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should process VCF v4 additions from RFC 6474' do
      ics = File.read "spec/examples/rfc6474.3.vcf"
      vobj_json = Vcard.new('4.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/rfc6474.3.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should process VCF v4 additions from RFC 6715' do
      ics = File.read "spec/examples/rfc6715.1.vcf"
      vobj_json = Vcard.new('4.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/rfc6715.1.json")
      expect(vobj_json).to include_json(exp_json)
    end
    it 'should process VCF v4 additions from RFC 6473' do
      ics = File.read "spec/examples/rfc6473.vcf"
      vobj_json = Vcard.new('4.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/rfc6473.json")
      expect(vobj_json).to include_json(exp_json)
    end

end
