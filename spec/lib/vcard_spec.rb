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

  it 'should process RFC6868 caret parameters' do
      ics = File.read "spec/examples/ujb.vcf"
      vobj_json = Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n")).to_json
      exp_json = JSON.load(File.read "spec/examples/ujb.json")
      expect(vobj_json).to include_json(exp_json)
  end

  it 'should reject CHARSET parameter' do
      ics = File.read "spec/examples/ujb1.vcf"
      expect { Vcard.new('3.0').parse(ics.gsub(/\r\n?/,"\n"))}.to raise_error(Rsec::SyntaxError)
  end


end
