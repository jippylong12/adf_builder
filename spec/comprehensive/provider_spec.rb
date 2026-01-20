# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe AdfBuilder::Nodes::Provider do
  def valid_prospect_base
    proc do
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
        contact do
          name "V"
          email "v@v.com"
        end
      end
    end
  end

  def build_with_provider(&block)
    base = valid_prospect_base
    AdfBuilder.build do
      prospect do
        instance_eval(&base)
        provider(&block)
      end
    end
  end

  describe "validation requirements" do
    it "requires name" do
      expect do
        base = valid_prospect_base
        AdfBuilder.build do
          prospect do
            instance_eval(&base)
            provider do
              service "Classifieds"
            end
          end
        end
      end.to raise_error(AdfBuilder::Error, /Missing required Element: name/)
    end
  end

  describe "name element" do
    it "renders name" do
      xml = build_with_provider do
        name "CarPoint"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//provider/name").text).to eq("CarPoint")
    end

    it "replaces existing name" do
      xml = build_with_provider do
        name "First"
        name "Second"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//provider/name").size).to eq(1)
      expect(doc.at_xpath("//provider/name").text).to eq("Second")
    end

    %i[first middle suffix last full].each do |part|
      it "accepts part :#{part}" do
        xml = build_with_provider do
          name "Provider", part: part
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//provider/name")["part"]).to eq(part.to_s)
      end
    end

    it "rejects invalid part" do
      expect do
        build_with_provider do
          name "Provider", part: :nickname
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for part/)
    end

    %i[individual business].each do |type|
      it "accepts type :#{type}" do
        xml = build_with_provider do
          name "Provider", type: type
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//provider/name")["type"]).to eq(type.to_s)
      end
    end
  end

  describe "service element" do
    it "renders service" do
      xml = build_with_provider do
        name "P"
        service "Used Car Classifieds"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//provider/service").text).to eq("Used Car Classifieds")
    end

    it "replaces existing service" do
      xml = build_with_provider do
        name "P"
        service "First"
        service "Second"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//provider/service").size).to eq(1)
      expect(doc.at_xpath("//provider/service").text).to eq("Second")
    end
  end

  describe "url element" do
    it "renders url" do
      xml = build_with_provider do
        name "P"
        url "http://carpoint.com"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//provider/url").text).to eq("http://carpoint.com")
    end

    it "replaces existing url" do
      xml = build_with_provider do
        name "P"
        url "http://first.com"
        url "http://second.com"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//provider/url").size).to eq(1)
      expect(doc.at_xpath("//provider/url").text).to eq("http://second.com")
    end
  end

  describe "email element" do
    it "renders email" do
      xml = build_with_provider do
        name "P"
        email "info@provider.com"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//provider/email").text).to eq("info@provider.com")
    end

    it "replaces existing email" do
      xml = build_with_provider do
        name "P"
        email "first@test.com"
        email "second@test.com"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//provider/email").size).to eq(1)
      expect(doc.at_xpath("//provider/email").text).to eq("second@test.com")
    end

    it "accepts preferredcontact attribute" do
      xml = build_with_provider do
        name "P"
        email "test@test.com", preferredcontact: 1
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//provider/email")["preferredcontact"]).to eq("1")
    end
  end

  describe "phone element" do
    it "renders phone" do
      xml = build_with_provider do
        name "P"
        phone "800-555-1234"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//provider/phone").text).to eq("800-555-1234")
    end

    it "replaces existing phone" do
      xml = build_with_provider do
        name "P"
        phone "111-1111"
        phone "222-2222"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//provider/phone").size).to eq(1)
      expect(doc.at_xpath("//provider/phone").text).to eq("222-2222")
    end

    it "accepts type, time, and preferredcontact attributes" do
      xml = build_with_provider do
        name "P"
        phone "555-1234", type: :voice, time: :day, preferredcontact: 1
      end
      doc = Nokogiri::XML(xml)
      phone = doc.at_xpath("//provider/phone")
      expect(phone["type"]).to eq("voice")
      expect(phone["time"]).to eq("day")
      expect(phone["preferredcontact"]).to eq("1")
    end
  end

  describe "contact element" do
    it "renders contact" do
      xml = build_with_provider do
        name "P"
        contact do
          name "Support Team"
          email "support@provider.com"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//provider/contact")).not_to be_nil
      expect(doc.at_xpath("//provider/contact/name").text).to eq("Support Team")
    end

    it "replaces existing contact" do
      xml = build_with_provider do
        name "P"
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
      expect(doc.xpath("//provider/contact").size).to eq(1)
      expect(doc.at_xpath("//provider/contact/name").text).to eq("Second")
    end

    it "accepts primary_contact attribute" do
      xml = build_with_provider do
        name "P"
        contact primary_contact: 1 do
          name "Primary"
          email "primary@test.com"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//provider/contact")["primarycontact"]).to eq("1")
    end
  end

  describe "id element" do
    it "accepts id with source" do
      xml = build_with_provider do
        id "PID123", source: "Internal"
        name "P"
      end
      doc = Nokogiri::XML(xml)
      id_node = doc.at_xpath("//provider/id")
      expect(id_node.text).to eq("PID123")
      expect(id_node["source"]).to eq("Internal")
    end

    it "allows multiple ids" do
      xml = build_with_provider do
        id "ID1", source: "System1"
        id "ID2", source: "System2"
        name "P"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//provider/id").size).to eq(2)
    end
  end

  describe "complete provider" do
    it "renders all elements" do
      xml = build_with_provider do
        id "PROV001", source: "LeadProvider"
        name "CarPoint Services", part: :full
        service "Used Car Classifieds"
        url "http://carpoint.msn.com"
        email "carcomm@carpoint.com", preferredcontact: 1
        phone "425-555-1212", type: :voice, time: :day
        contact primary_contact: 1 do
          name "Fred Jones", part: :full
          email "support@carpoint.com"
          phone "425-253-2222", type: :voice
          address do
            street "One Microsoft Way", line: 1
            city "Redmond"
            regioncode "WA"
            postalcode "98052"
            country "US"
          end
        end
      end

      doc = Nokogiri::XML(xml)
      provider = doc.at_xpath("//provider")

      expect(provider.at_xpath("id")).not_to be_nil
      expect(provider.at_xpath("name").text).to eq("CarPoint Services")
      expect(provider.at_xpath("service").text).to eq("Used Car Classifieds")
      expect(provider.at_xpath("url").text).to eq("http://carpoint.msn.com")
      expect(provider.at_xpath("email").text).to eq("carcomm@carpoint.com")
      expect(provider.at_xpath("phone").text).to eq("425-555-1212")
      expect(provider.at_xpath("contact")).not_to be_nil
      expect(provider.at_xpath("contact/address")).not_to be_nil
    end
  end
end
