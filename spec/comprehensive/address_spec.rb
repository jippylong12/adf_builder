# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe AdfBuilder::Nodes::Address do
  def build_with_address(&block)
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
            name "J"
            email "j@j.com"
            address(&block)
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
  end

  describe "street line requirements" do
    it "requires at least one street line" do
      expect do
        build_with_address do
          city "Seattle"
          country "US"
        end
      end.to raise_error(AdfBuilder::Error, /Address must have at least one street line/)
    end

    it "accepts 1 street line" do
      expect do
        build_with_address do
          street "123 Main St"
        end
      end.not_to raise_error
    end

    it "accepts 5 street lines (maximum)" do
      expect do
        build_with_address do
          street "Line 1", line: 1
          street "Line 2", line: 2
          street "Line 3", line: 3
          street "Line 4", line: 4
          street "Line 5", line: 5
        end
      end.not_to raise_error
    end

    it "rejects more than 5 street lines" do
      expect do
        build_with_address do
          street "Line 1", line: 1
          street "Line 2", line: 2
          street "Line 3", line: 3
          street "Line 4", line: 4
          street "Line 5", line: 5
          street "Line 6", line: 6
        end
      end.to raise_error(AdfBuilder::Error, /Address can have at most 5 street lines/)
    end
  end

  describe "street element" do
    it "renders street with value only" do
      xml = build_with_address do
        street "123 Main Street"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//address/street").text).to eq("123 Main Street")
    end

    it "renders street with line number" do
      xml = build_with_address do
        street "123 Main Street", line: 1
      end
      doc = Nokogiri::XML(xml)
      street = doc.at_xpath("//address/street")
      expect(street.text).to eq("123 Main Street")
      expect(street["line"]).to eq("1")
    end

    it "renders multiple streets with line numbers" do
      xml = build_with_address do
        street "Apartment 4B", line: 1
        street "Building C", line: 2
        street "123 Main Street", line: 3
      end
      doc = Nokogiri::XML(xml)
      streets = doc.xpath("//address/street")
      expect(streets.size).to eq(3)
      expect(streets[0]["line"]).to eq("1")
      expect(streets[2]["line"]).to eq("3")
    end
  end

  describe "type attribute" do
    %i[work home delivery].each do |type|
      it "accepts type :#{type}" do
        xml = build_with_address do
          street "123 Main"
        end
        # Need to build fresh with type parameter
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
                name "J"
                email "j@j.com"
                address type: type do
                  street "123 Main"
                end
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
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//address")["type"]).to eq(type.to_s)
      end
    end

    it "rejects invalid type" do
      expect do
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
                name "J"
                email "j@j.com"
                address type: :office do
                  street "123 Main"
                end
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
      end.to raise_error(AdfBuilder::Error, /Invalid value for type/)
    end
  end

  describe "country validation (ISO 3166-1 alpha-2)" do
    %w[US CA MX GB DE FR JP CN AU NZ].each do |code|
      it "accepts country code #{code}" do
        xml = build_with_address do
          street "123 Main"
          country code
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//address/country").text).to eq(code)
      end
    end

    it "rejects invalid country code" do
      expect do
        build_with_address do
          street "123 Main"
          country "XX"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid country code: XX/)
    end

    it "rejects made-up country code" do
      expect do
        build_with_address do
          street "123 Main"
          country "USA"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid country code/)
    end
  end

  describe "simple elements" do
    it "renders apartment" do
      xml = build_with_address do
        street "123 Main"
        apartment "4B"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//address/apartment").text).to eq("4B")
    end

    it "renders city" do
      xml = build_with_address do
        street "123 Main"
        city "Seattle"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//address/city").text).to eq("Seattle")
    end

    it "renders regioncode" do
      xml = build_with_address do
        street "123 Main"
        regioncode "WA"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//address/regioncode").text).to eq("WA")
    end

    it "renders postalcode" do
      xml = build_with_address do
        street "123 Main"
        postalcode "98101"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//address/postalcode").text).to eq("98101")
    end
  end

  describe "complete address" do
    it "renders all elements" do
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
              name "J"
              email "j@j.com"
              address type: :home do
                street "123 Main St", line: 1
                street "Apt 4B", line: 2
                apartment "4B"
                city "Seattle"
                regioncode "WA"
                postalcode "98101"
                country "US"
              end
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

      doc = Nokogiri::XML(xml)
      addr = doc.at_xpath("//address")
      expect(addr["type"]).to eq("home")
      expect(addr.xpath("street").size).to eq(2)
      expect(addr.at_xpath("city").text).to eq("Seattle")
      expect(addr.at_xpath("regioncode").text).to eq("WA")
      expect(addr.at_xpath("postalcode").text).to eq("98101")
      expect(addr.at_xpath("country").text).to eq("US")
    end
  end

  describe "multiple addresses in contact" do
    it "supports home and work addresses" do
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
              name "J"
              email "j@j.com"
              address type: :home do
                street "123 Home Lane"
                city "Seattle"
              end
              address type: :work do
                street "456 Work Street"
                city "Bellevue"
              end
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

      doc = Nokogiri::XML(xml)
      addresses = doc.xpath("//contact/address")
      expect(addresses.size).to eq(2)
      expect(addresses[0]["type"]).to eq("home")
      expect(addresses[1]["type"]).to eq("work")
    end
  end
end
