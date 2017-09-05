require "rspec/json_expectations"
require 'spec_helper'
require 'json'
require 'rsec'

# Some examples taken from https://github.com/mozilla-comm/ical.js/

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

end
