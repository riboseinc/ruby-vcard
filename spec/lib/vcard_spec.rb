require 'spec_helper'

def create_vcard_object
  Vcard.new({
    :name => {
      :family => "Vcard",
      :given  => "Testing"
    },
    :fullname => {
      :value => "Testing Vcard"
    }
  })
end

def count_vcard(vcard)
  length = 0

  vcard.each do |fields|

    [fields].flatten.each do |field|
      length += 1
    end

  end

  length
end

def test_encode_vcard(vcard, version)
  vcard_str = vcard.encode(version)
  decoded_vcard = Vcard.decode(vcard_str, version)

  decoded_vcard.name.family.should == ["Vcard"]
  decoded_vcard.name.given.should == ["Testing"]
  decoded_vcard.fullname.value.should == "Testing Vcard"
end

def test_decode_vcard(vcard_str, version=nil)
  vcard = Vcard.decode(*([vcard_str, version].compact))
  vcard.should be_an_instance_of(Vcard)
end

include Vcard::StructureHelper
Vcard::StructureHelper.define_structural_comparators do
  {
    :eql        => ->(a, b) { a.should eql b },
    :include    => ->(a, b) { a.should include b },
    :be_kind_of => ->(a, b) { a.should be_kind_of b },
    :on_error   => ->(a) {
      raise RSpec::Expectations::ExpectationNotMetError.new a
    }
  }
end

describe Vcard do

  describe '.schema' do
    #
    context 'with a WebUI adaptor' do

      it 'should have a proper structure' do
        #
        should_have_structure(
          Vcard.schema(Vcard::AttributeAdaptor::WebUI),
          {
            email: {
              multi: NilOr[Bool],
              field_type: String,
              type_types: [String],
            },
            impp: {
              multi: NilOr[Bool],
              field_type: String,
              type_types: [String],
              purpose_types: [String],
              scheme_types: [String],
            },
            telephone: {
              multi: NilOr[Bool],
              field_type: String,
              type_types: [String],
              capability_types: [String],
            },
            url: {
              # TODO: BlogFeed, etc.
              multi: NilOr[Bool],
              field_type: String,
            },
            organization: {
              field_type: [
                { name: Symbol, field_type: String },
              ],
            },
            title: {
              multi: NilOr[Bool],
              field_type: String,
            },
            birthday: {
              multi: NilOr[Bool],
              field_type: String,
            },
            address: {
              multi: NilOr[Bool],
              field_type: [
                { name: Symbol, field_type: String },
              ],
              type_types: [String],
            },
            note: {
              field_type: String,
            },
          }
        )
      end
    end

    context 'without adaptor' do

      it 'should have a proper structure' do
        #
        should_have_structure Vcard.schema, {
          :note => {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :type=>{},
            :nonstandard=>{}},
          :address=> {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :label=>{},
            :geo=>{},
            :pobox=>{},
            :extended=>{},
            :street=>{},
            :locality=>{},
            :region=>{},
            :postalcode=>{},
            :country=>{},
            :type=>{:suggested_values=>[String]},
            :delivery=>{:suggested_values=>[String]},
            :nonstandard=>{}},
          :telephone=> {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :scheme=>{},
            :type=>{:suggested_values=>[String]},
            :capability=> {
              :suggested_values=> [String]
            },
            :nonstandard=>{}},
          :other=> {:alt_id=>{}, :group=>{}, :preferred=>{}, :visibility=>{}, :value=>{}},
          :nickname=> {:alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :type=>{},
            :nonstandard=>{}},
          :photo=> {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :type=>{},
            :image_type=>{},
            :scheme=>{},
            :nonstandard=>{}},
          :impp=> {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :purpose=>{:suggested_values=>[String]},
            :type=>{:suggested_values=>[String]},
            :service_type=>{},
            :scheme=> {:suggested_values=> [String]},
            :nonstandard=>{}},
          :kind=>{:alt_id=>{}, :group=>{}, :preferred=>{}, :visibility=>{}, :value=>{}},
          :fullname=> {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :type=>{},
            :nonstandard=>{}},
          :email=> {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :type=>{:suggested_values=>[String]},
            :format=>{},
            :nonstandard=>{}},
          :xname=> {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :xkey=>{},
            :type=>{},
            :nonstandard=>{}},
          :title=> {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :type=>{},
            :nonstandard=>{}},
          :url=> {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :scheme=>{},
            :type=>{:suggested_values=>[String]},
            :nonstandard=>{}},
          :birthday=> {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :year=>{},
            :month=>{},
            :day=>{}},
          :organization=> {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :type=>{},
            :company=>{},
            :department=>{},
            :other=>{},
            :nonstandard=>{}},
          :name=> {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :family=>{},
            :given=>{},
            :additional=>{},
            :prefix=>{},
            :suffix=>{}},
          :socialprofile=> {
            :alt_id=>{},
            :group=>{},
            :preferred=>{},
            :visibility=>{},
            :value=>{},
            :type=>{:suggested_values=>[String]},
            :scheme=> {:suggested_values=> [String]
            },
            :nonstandard=>{}
          }
        }
      end
    end
  end

  describe '#serializable_hash' do
    #
    it 'should not serialize "blank" fields' do
      vcard = Vcard.new({
        :impp => {
          :scheme => 'pqrst',
        },
        :email => [
          {},
          {
            :value => 'abxyz',
          },
          {
            :value => 'acxyz@asdf.com',
          },
          {
            :value => 'bcxyz',
          },
        ]
      })

      vcard.serializable_hash[:impp].should be_nil
      vcard.serializable_hash[:email].length.should == 3
    end

    it 'should return values in the form of Arrays for all fields' do
      vcard = Vcard.new({
        :name => {
          :family => "Vcard",
          :given  => "Testing"
        },
        :fullname => {
          :value => "Testing Vcard"
        },
        :impp => {
          :value => 'abcxyz',
          :scheme => 'pqrst',
        },
        :email => [
          {
            :value => 'abcxy',
          },
          {
            :value => 'abxyz',
          },
          {
            :value => 'acxyz',
          },
          {
            :value => 'bcxyz',
          },
        ]
      })

      vcard.serializable_hash.values.each do |v|
        v.should be_kind_of Array
      end
    end
  end

  describe "encode" do

    describe "Vcard 3.0" do

      before(:each) do
        @version = 30
      end

      it "should encode a vcard object to a valid vcard string" do
        vcard = create_vcard_object
        test_encode_vcard(vcard, @version)
      end

      it "should encode a vcard object without N field decoded from Vcard 4.0" do
        vcard_str = <<-eos
BEGIN:VCARD
VERSION:4.0
FN:Testing Vcard
END:VCARD
eos
        vcard = Vcard.decode(vcard_str)

        encoded = vcard.encode(@version)
        decoded_vcard = Vcard.decode(encoded)

        decoded_vcard.name.given.should == ["Testing"]
        decoded_vcard.name.family.should == ["Vcard"]
        decoded_vcard.fullname.value.should == "Testing Vcard"
      end

    end

    describe "Vcard 4.0" do

      before(:each) do
        @version = 40
      end

      it "should encode a vcard object to a valid vcard string" do
        vcard = create_vcard_object
        test_encode_vcard(vcard, @version)
      end

    end

  end

  describe "decode" do

    describe "Vcard 3.0" do

      before(:each) do
        @version = 30
      end

      it "should decode a vcard string to a vcard object" do
        vcard_str = <<-eos
BEGIN:VCARD
VERSION:3.0
N:Vcard;Testing;;
FN:Testing Vcard
PHOTO;ENCODING=b;TYPE=JPEG:/9j/4AAQSkZJRgABAQAAAQABAAD/4gxYSUNDX1BST0ZJTEUA\r
 AQEAAAxITGlubwIQAABtbnRyUkdCIFhZWiAHzgACAAkABgAxAABhY3NwTVNGVAAAAABJRUMgc1\r
 JHQgAAAAAAAAAAAAAAAQAA9tYAAQAAAADTLUhQICAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA\r
 FABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQAUAFABQB//9k=\r
END:VCARD
eos
        test_decode_vcard(vcard_str, @version)
      end

    end

    describe "Vcard 4.0" do

      before(:each) do
        @version = 40
      end

      it "should decode a vcard string to a vcard object" do
        vcard_str = <<-eos
BEGIN:VCARD
VERSION:4.0
FN:Testing Vcard
END:VCARD
eos
        test_decode_vcard(vcard_str, @version)
      end

    end

    it "should decode a vcard string to a vcard object without specifying the vcard version 1" do
      vcard_str = <<-eos
BEGIN:VCARD
VERSION:3.0
N:Vcard;Testing;;
FN:Testing Vcard
END:VCARD
eos
      test_decode_vcard(vcard_str)
    end

    it "should decode a vcard string to a vcard object without specifying the vcard version 2" do
      vcard_str = <<-eos
BEGIN:VCARD
VERSION:4.0
FN:Testing Vcard
END:VCARD
eos
      test_decode_vcard(vcard_str)
    end

    describe "exported from MS Outlook for Mac" do

      before :all do
        @vcard_str = File.read 'spec/fixtures/ujb.vcf'
      end

      before :each do
        @vcard = Vcard.decode @vcard_str
      end

      it 'is a vcard' do
        test_decode_vcard @vcard_str
      end

      it 'contains the expected number of fields' do
        invis = ::Vcard::Field::INVISIBLE
        @vcard.emails(invis)     .length.should == 1
        @vcard.telephones(invis) .length.should == 2
        @vcard.addresses(invis)  .length.should == 1
      end

    end

    describe "exported from Apple Contacts" do

      before :all do
        @vcard_str = File.read 'spec/fixtures/apple.vcf'
      end

      before :each do
        @vcard = Vcard.decode @vcard_str
      end

      it 'is a vcard' do
        test_decode_vcard @vcard_str
      end

      it 'contains the expected number of fields' do
        invis = ::Vcard::Field::INVISIBLE
        @vcard.emails(invis)     .length.should == 3
        @vcard.urls(invis)       .length.should == 4
        @vcard.impps(invis)      .length.should == 9
        @vcard.addresses(invis)  .length.should == 3
        @vcard.notes(invis)      .length.should == 1
        @vcard.telephones(invis) .length.should == 11
      end

    end

  end

  describe 'Superset' do

    before(:each) do
      @vcard = create_vcard_object
    end

    it "should obtain a field object by field name" do
      @vcard.name.family.should == "Vcard"
      @vcard.name.given.should == "Testing"
      @vcard.fullname.value.should == "Testing Vcard"
    end

    it "should add a field to the vcard for <<" do
      field = Vcard::Field::Birthday.new(
        :year  => 1970,
        :month => 1,
        :day   => 1
      )
      @vcard << field

      @vcard.birthday('invisible').should be_an_instance_of(Vcard::Field::Birthday)
    end

    it "should add 2 fields to the vcard for <<" do
      field1 = Vcard::Field::Note.new(
        :value => 'This is note 1.'
      )
      field2 = Vcard::Field::Note.new(
        :value => 'This is note 2.'
      )
      @vcard << field1 << field2

      @vcard.notes('invisible').should be_an_instance_of(Array)
      @vcard.notes('invisible').length.should == 2

      @vcard.notes('invisible').each do |note|
        note.should be_an_instance_of(Vcard::Field::Note)
      end
    end

    it "should raise exception when try to add non field object to vcard for <<" do
      expect {
        @vcard << {}
      }.to raise_error(Vcard::VcardException)
    end

    it "should not append non meaningful field to vcard" do
      length_before = count_vcard(@vcard)

      version = Vcard::Field::Version.new
      @vcard << version

      length_after = count_vcard(@vcard)

      length_after.should == length_before
    end

    it "should add a field to the vcard for = by a hash" do
      hash  = {
        :year  => 1970,
        :month => 1,
        :day   => 1
      }

      @vcard.birthday = hash
      @vcard.birthday('invisible').should be_an_instance_of(Vcard::Field::Birthday)
    end

    it "should add 2 fields to the vcard for = by an array" do
      ary   = [
        { :value => 'This is note 1.' },
        { :value => 'This is note 2.' }
      ]

      @vcard.note = ary
      @vcard.notes('invisible').should be_an_instance_of(Array)
      @vcard.notes('invisible').length.should == 2

      @vcard.notes('invisible').each do |note|
        note.should be_an_instance_of(Vcard::Field::Note)
      end
    end

    it "should replace the original field" do
      @vcard.fullname = { :value => 'Vcard Gem' }

      @vcard.fullname.should be_an_instance_of(Vcard::Field::Fullname)
      @vcard.fullname.value.should == 'Vcard Gem'
    end

    it "should replace the original field with 2 fields" do
      hash  = { :value => 'This is the original note.' }

      @vcard.note = hash
      @vcard.note('invisible').should be_an_instance_of(Vcard::Field::Note)

      ary = [
        { :value => 'This is note 1.' },
        { :value => 'This is note 2.' }
      ]

      @vcard.note = ary
      @vcard.notes('invisible').should be_an_instance_of(Array)
      @vcard.notes('invisible').length.should == 2

      @vcard.notes('invisible').each do |note|
        note.should be_an_instance_of(Vcard::Field::Note)
      end
    end

    it "should return fields of the given group" do
      org   = {
        :group      => 'career',
        :company    => 'Ribose, Inc.',
        :department => 'Team 2'
      }
      title = {
        :group => 'career',
        :value => 'Software Engineer'
      }
      @vcard.organization = org
      @vcard.title = title

      group = @vcard['career']
      group.should be_an_instance_of(Vcard::Group)
      group.name.should == 'career'

      fields = []
      group.each do |field|
        fields << field
      end

      fields.length.should == 2
      fields.map(&:class).should include(
        Vcard::Field::Organization,
        Vcard::Field::Title
      )
    end

    it "should iterate each field of the vcard" do
      length = 0

      @vcard.each do |field|
        length += 1
        field.should be_a_kind_of(Vcard::Field)
      end

      length.should == 2
    end

    it "should delete fields fulfilling the condition" do
      notes = [
        { :value => 'This is note 1.' },
        { :value => 'This is note 2.' }
      ]

      @vcard.note = notes

      @vcard.notes.should be_an_instance_of(Array)

      @vcard.delete_if do |field|
        field.is_a?(Vcard::Field::Note)
      end

      @vcard.notes.should be_empty

      @vcard.name.should be_an_instance_of(Vcard::Field::Name)
      @vcard.fullname.should be_an_instance_of(Vcard::Field::Fullname)
    end

  end

end
