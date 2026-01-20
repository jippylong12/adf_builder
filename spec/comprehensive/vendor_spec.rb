# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe AdfBuilder::Nodes::Vendor do
  def build_with_vendor(&block)
    AdfBuilder.build do
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
        vendor(&block)
      end
    end
  end

  describe "validation requirements" do
    it "requires vendorname" do
      expect do
        build_with_vendor do
          contact do
            name "V"
            email "v@v.com"
          end
        end
      end.to raise_error(AdfBuilder::Error, /Missing required Element: vendorname/)
    end

    it "requires contact" do
      expect do
        build_with_vendor do
          vendorname "Test Dealer"
        end
      end.to raise_error(AdfBuilder::Error, /Missing required Element: contact/)
    end
  end

  describe "vendorname element" do
    it "renders vendorname" do
      xml = build_with_vendor do
        vendorname "Best Auto Sales"
        contact do
          name "V"
          email "v@test.com"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vendor/vendorname").text).to eq("Best Auto Sales")
    end

    it "replaces existing vendorname" do
      xml = build_with_vendor do
        vendorname "First Name"
        vendorname "Second Name"
        contact do
          name "V"
          email "v@test.com"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//vendor/vendorname").size).to eq(1)
      expect(doc.at_xpath("//vendor/vendorname").text).to eq("Second Name")
    end
  end

  describe "id element" do
    it "accepts id with source" do
      xml = build_with_vendor do
        id "VID123", source: "DMS"
        vendorname "V"
        contact do
          name "V"
          email "v@test.com"
        end
      end
      doc = Nokogiri::XML(xml)
      id_node = doc.at_xpath("//vendor/id")
      expect(id_node.text).to eq("VID123")
      expect(id_node["source"]).to eq("DMS")
    end

    it "requires source for id" do
      expect do
        build_with_vendor do
          id "VID123"
          vendorname "V"
          contact do
            name "V"
            email "v@test.com"
          end
        end
      end.to raise_error(ArgumentError, /Source is required/)
    end

    it "allows multiple ids" do
      xml = build_with_vendor do
        id "ID1", source: "DMS"
        id "ID2", source: "CRM"
        vendorname "V"
        contact do
          name "V"
          email "v@test.com"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//vendor/id").size).to eq(2)
    end
  end

  describe "url element" do
    it "renders url" do
      xml = build_with_vendor do
        vendorname "V"
        url "http://example.com"
        contact do
          name "V"
          email "v@test.com"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vendor/url").text).to eq("http://example.com")
    end

    it "replaces existing url" do
      xml = build_with_vendor do
        vendorname "V"
        url "http://first.com"
        url "http://second.com"
        contact do
          name "V"
          email "v@test.com"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//vendor/url").size).to eq(1)
      expect(doc.at_xpath("//vendor/url").text).to eq("http://second.com")
    end
  end

  describe "contact element" do
    it "renders contact structure" do
      xml = build_with_vendor do
        vendorname "V"
        contact do
          name "Sales Manager", part: :full
          phone "555-1234", type: :voice
          email "sales@dealer.com"
        end
      end
      doc = Nokogiri::XML(xml)
      contact = doc.at_xpath("//vendor/contact")
      expect(contact.at_xpath("name").text).to eq("Sales Manager")
      expect(contact.at_xpath("phone").text).to eq("555-1234")
      expect(contact.at_xpath("email").text).to eq("sales@dealer.com")
    end

    it "contact replaces existing" do
      xml = build_with_vendor do
        vendorname "V"
        contact do
          name "First"
          email "first@test.com"
        end
        contact do
          name "Second"
          email "second@test.com"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//vendor/contact").size).to eq(1)
      expect(doc.at_xpath("//vendor/contact/name").text).to eq("Second")
    end
  end

  describe "complete vendor" do
    it "renders all elements" do
      xml = build_with_vendor do
        id "V001", source: "DMS", sequence: 1
        vendorname "Premium Auto Sales"
        url "http://premiumauto.com"
        contact do
          name "John Smith", part: :full
          phone "800-555-1234", type: :voice
          email "info@premiumauto.com", preferredcontact: 1
          address type: :work do
            street "1000 Dealer Row", line: 1
            city "Detroit"
            regioncode "MI"
            postalcode "48201"
            country "US"
          end
        end
      end

      doc = Nokogiri::XML(xml)
      vendor = doc.at_xpath("//vendor")
      expect(vendor.at_xpath("id")).not_to be_nil
      expect(vendor.at_xpath("vendorname").text).to eq("Premium Auto Sales")
      expect(vendor.at_xpath("url").text).to eq("http://premiumauto.com")
      expect(vendor.at_xpath("contact")).not_to be_nil
      expect(vendor.at_xpath("contact/address")).not_to be_nil
    end
  end
end
