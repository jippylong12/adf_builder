# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe AdfBuilder::Nodes::Customer do
  # Helper to build a valid prospect with custom customer block
  def build_with_customer(&block)
    AdfBuilder.build do
      prospect do
        request_date Time.now
        vehicle do
          year 2024
          make "T"
          model "M"
        end
        customer(&block)
        vendor do
          vendorname "V"
          contact do
            name "V"
            email "v@v.com"
          end
        end
      end
    end
  end

  describe "validation requirements" do
    it "requires contact" do
      expect do
        build_with_customer do
          # No contact
          comments "test"
        end
      end.to raise_error(AdfBuilder::Error, /Missing required Element: contact/)
    end
  end

  describe "id element" do
    it "accepts id with source" do
      xml = build_with_customer do
        id "CID123", source: "CRM"
        contact do
          name "C"
          email "c@c.com"
        end
      end
      doc = Nokogiri::XML(xml)
      id_node = doc.at_xpath("//customer/id")
      expect(id_node.text).to eq("CID123")
      expect(id_node["source"]).to eq("CRM")
    end

    it "requires source for id" do
      expect do
        build_with_customer do
          id "CID123"
          contact do
            name "C"
            email "c@c.com"
          end
        end
      end.to raise_error(ArgumentError, /Source is required/)
    end

    it "allows multiple ids" do
      xml = build_with_customer do
        id "ID1", source: "CRM"
        id "ID2", source: "DMS"
        id "ID3", source: "Web"
        contact do
          name "C"
          email "c@c.com"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//customer/id").size).to eq(3)
    end

    it "accepts optional sequence attribute" do
      xml = build_with_customer do
        id "ID1", source: "CRM", sequence: 1
        contact do
          name "C"
          email "c@c.com"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//customer/id")["sequence"]).to eq("1")
    end
  end

  describe "comments element" do
    it "renders comments" do
      xml = build_with_customer do
        contact do
          name "C"
          email "c@c.com"
        end
        comments "Looking for financing options"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//customer/comments").text).to eq("Looking for financing options")
    end

    it "replaces existing comments" do
      xml = build_with_customer do
        contact do
          name "C"
          email "c@c.com"
        end
        comments "First comment"
        comments "Second comment"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//customer/comments").size).to eq(1)
      expect(doc.at_xpath("//customer/comments").text).to eq("Second comment")
    end
  end

  describe "contact replaces existing" do
    it "only keeps the last contact" do
      xml = build_with_customer do
        contact do
          name "First Contact"
          email "first@test.com"
        end
        contact do
          name "Second Contact"
          email "second@test.com"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//customer/contact").size).to eq(1)
      expect(doc.at_xpath("//customer/contact/name").text).to eq("Second Contact")
    end
  end

  describe "valid complete customer" do
    it "renders all elements" do
      xml = build_with_customer do
        id "CID001", source: "CRM", sequence: 1
        contact do
          name "Jane Doe", part: :full, type: :individual
          email "jane@example.com", preferredcontact: 1
          phone "555-1234", type: :cellphone, time: :evening
          address type: :home do
            street "123 Main St", line: 1
            city "Seattle"
            regioncode "WA"
            postalcode "98101"
            country "US"
          end
        end
        timeframe do
          description "Buying soon"
          earliestdate "2024-02-01"
          latestdate "2024-03-01"
        end
        comments "Interested in financing"
      end

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//customer/id")).not_to be_nil
      expect(doc.at_xpath("//customer/contact")).not_to be_nil
      expect(doc.at_xpath("//customer/timeframe")).not_to be_nil
      expect(doc.at_xpath("//customer/comments")).not_to be_nil
    end
  end
end

RSpec.describe AdfBuilder::Nodes::Contact do
  def build_with_contact(&block)
    AdfBuilder.build do
      prospect do
        request_date Time.now
        vehicle do
          year 2024
          make "T"
          model "M"
        end
        customer do
          contact(&block)
        end
        vendor do
          vendorname "V"
          contact do
            name "V"
            email "v@v.com"
          end
        end
      end
    end
  end

  describe "validation requirements" do
    it "requires name" do
      expect do
        build_with_contact do
          email "test@test.com"
        end
      end.to raise_error(AdfBuilder::Error, /Missing required Element: name/)
    end

    it "requires at least phone or email" do
      expect do
        build_with_contact do
          name "John Doe"
        end
      end.to raise_error(AdfBuilder::Error, /Contact must have at least one Phone or Email/)
    end

    it "valid with phone only" do
      expect do
        build_with_contact do
          name "John"
          phone "555-1234"
        end
      end.not_to raise_error
    end

    it "valid with email only" do
      expect do
        build_with_contact do
          name "John"
          email "john@test.com"
        end
      end.not_to raise_error
    end

    it "valid with both phone and email" do
      expect do
        build_with_contact do
          name "John"
          phone "555-1234"
          email "john@test.com"
        end
      end.not_to raise_error
    end
  end

  describe "phone element" do
    %i[voice fax cellphone pager].each do |type|
      it "accepts type :#{type}" do
        xml = build_with_contact do
          name "J"
          phone "555-1234", type: type
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//contact/phone")["type"]).to eq(type.to_s)
      end
    end

    it "rejects invalid phone type" do
      expect do
        build_with_contact do
          name "J"
          phone "555-1234", type: :work
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for type/)
    end

    %i[morning afternoon evening nopreference day].each do |time|
      it "accepts time :#{time}" do
        xml = build_with_contact do
          name "J"
          phone "555-1234", time: time
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//contact/phone")["time"]).to eq(time.to_s)
      end
    end

    it "rejects invalid phone time" do
      expect do
        build_with_contact do
          name "J"
          phone "555-1234", time: :night
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for time/)
    end

    [0, 1, "0", "1"].each do |pref|
      it "accepts preferredcontact #{pref.inspect}" do
        xml = build_with_contact do
          name "J"
          phone "555-1234", preferredcontact: pref
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//contact/phone")["preferredcontact"]).to eq(pref.to_s)
      end
    end

    it "rejects invalid preferredcontact" do
      expect do
        build_with_contact do
          name "J"
          phone "555-1234", preferredcontact: 2
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for preferredcontact/)
    end

    it "renders phone with all attributes" do
      xml = build_with_contact do
        name "J"
        phone "555-1234", type: :cellphone, time: :evening, preferredcontact: 1
      end
      doc = Nokogiri::XML(xml)
      phone = doc.at_xpath("//contact/phone")
      expect(phone.text).to eq("555-1234")
      expect(phone["type"]).to eq("cellphone")
      expect(phone["time"]).to eq("evening")
      expect(phone["preferredcontact"]).to eq("1")
    end

    it "allows multiple phones" do
      xml = build_with_contact do
        name "J"
        phone "555-1111", type: :voice
        phone "555-2222", type: :cellphone
        phone "555-3333", type: :fax
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//contact/phone").size).to eq(3)
    end
  end

  describe "email element" do
    it "renders email with value" do
      xml = build_with_contact do
        name "J"
        email "test@test.com"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//contact/email").text).to eq("test@test.com")
    end

    [0, 1, "0", "1"].each do |pref|
      it "accepts preferredcontact #{pref.inspect}" do
        xml = build_with_contact do
          name "J"
          email "test@test.com", preferredcontact: pref
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//contact/email")["preferredcontact"]).to eq(pref.to_s)
      end
    end

    it "rejects invalid preferredcontact" do
      expect do
        build_with_contact do
          name "J"
          email "test@test.com", preferredcontact: "yes"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for preferredcontact/)
    end

    it "allows multiple emails" do
      xml = build_with_contact do
        name "J"
        email "personal@test.com"
        email "work@test.com"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//customer/contact/email").size).to eq(2)
    end
  end

  describe "name element" do
    %i[first middle suffix last full].each do |part|
      it "accepts part :#{part}" do
        xml = build_with_contact do
          name "John", part: part
          email "j@j.com"
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//contact/name")["part"]).to eq(part.to_s)
      end
    end

    it "rejects invalid name part" do
      expect do
        build_with_contact do
          name "John", part: :nickname
          email "j@j.com"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for part/)
    end

    %i[individual business].each do |type|
      it "accepts type :#{type}" do
        xml = build_with_contact do
          name "John", type: type
          email "j@j.com"
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//contact/name")["type"]).to eq(type.to_s)
      end
    end

    it "rejects invalid name type" do
      expect do
        build_with_contact do
          name "John", type: :organization
          email "j@j.com"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for type/)
    end

    it "renders name with all attributes" do
      xml = build_with_contact do
        name "John Doe", part: :full, type: :individual
        email "j@j.com"
      end
      doc = Nokogiri::XML(xml)
      name = doc.at_xpath("//contact/name")
      expect(name.text).to eq("John Doe")
      expect(name["part"]).to eq("full")
      expect(name["type"]).to eq("individual")
    end

    it "allows multiple names (first, last, etc.)" do
      xml = build_with_contact do
        name "John", part: :first
        name "Michael", part: :middle
        name "Doe", part: :last
        email "j@j.com"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//customer/contact/name").size).to eq(3)
    end
  end

  describe "primarycontact attribute" do
    it "accepts primarycontact 1 on vendor contact" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
          end
          customer do
            contact do
              name "C"
              email "c@c.com"
            end
          end
          vendor do
            vendorname "V"
            contact primary_contact: 1 do
              name "V"
              email "v@v.com"
            end
          end
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vendor/contact")["primarycontact"]).to eq("1")
    end

    it "accepts primarycontact 0 on vendor contact" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
          end
          customer do
            contact do
              name "C"
              email "c@c.com"
            end
          end
          vendor do
            vendorname "V"
            contact primary_contact: 0 do
              name "V"
              email "v@v.com"
            end
          end
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vendor/contact")["primarycontact"]).to eq("0")
    end
  end

  describe "address in contact" do
    it "renders address within contact" do
      xml = build_with_contact do
        name "J"
        email "j@j.com"
        address type: :home do
          street "123 Main St"
          city "Seattle"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//contact/address")).not_to be_nil
      expect(doc.at_xpath("//contact/address")["type"]).to eq("home")
    end

    it "allows multiple addresses" do
      xml = build_with_contact do
        name "J"
        email "j@j.com"
        address type: :home do
          street "123 Home St"
          city "Seattle"
        end
        address type: :work do
          street "456 Work St"
          city "Bellevue"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//contact/address").size).to eq(2)
    end
  end
end
