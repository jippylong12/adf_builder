# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe AdfBuilder::Nodes::Prospect do
  # Helper to build a valid minimal prospect
  def valid_prospect_xml(&block)
    AdfBuilder.build do
      prospect do
        request_date Time.now
        vehicle do
          year 2024
          make "Toyota"
          model "Camry"
        end
        customer do
          contact do
            name "John Doe"
            email "john@example.com"
          end
        end
        vendor do
          vendorname "Test Dealer"
          contact do
            name "Sales"
            email "sales@dealer.com"
          end
        end
        instance_eval(&block) if block
      end
    end
  end

  describe "validation requirements" do
    it "requires requestdate" do
      expect do
        AdfBuilder.build do
          prospect do
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
      end.to raise_error(AdfBuilder::Error, /Prospect must have a requestdate/)
    end

    it "requires at least one vehicle" do
      expect do
        AdfBuilder.build do
          prospect do
            request_date Time.now
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
      end.to raise_error(AdfBuilder::Error, /Prospect must have at least one vehicle/)
    end

    it "requires customer" do
      expect do
        AdfBuilder.build do
          prospect do
            request_date Time.now
            vehicle do
              year 2024
              make "T"
              model "M"
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
      end.to raise_error(AdfBuilder::Error, /Prospect must have a customer/)
    end

    it "requires vendor" do
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
                name "C"
                email "c@c.com"
              end
            end
          end
        end
      end.to raise_error(AdfBuilder::Error, /Prospect must have a vendor/)
    end
  end

  describe "optional elements" do
    it "accepts optional provider" do
      xml = valid_prospect_xml do
        provider do
          name "CarPoint"
          service "Classifieds"
        end
      end

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//adf/prospect/provider")).not_to be_nil
      expect(doc.at_xpath("//adf/prospect/provider/name").text).to eq("CarPoint")
    end
  end

  describe "multiple vehicles" do
    it "supports multiple vehicles" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "Toyota"
            model "Camry"
          end
          vehicle do
            year 2023
            make "Honda"
            model "Accord"
          end
          vehicle do
            year 2022
            make "Ford"
            model "F-150"
          end
          customer do
            contact do
              name "John"
              email "j@j.com"
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
      vehicles = doc.xpath("//adf/prospect/vehicle")
      expect(vehicles.size).to eq(3)
      expect(vehicles[0].at_xpath("make").text).to eq("Toyota")
      expect(vehicles[1].at_xpath("make").text).to eq("Honda")
      expect(vehicles[2].at_xpath("make").text).to eq("Ford")
    end
  end

  describe "request_date behavior" do
    it "replaces existing requestdate when called multiple times" do
      first_time = Time.new(2024, 1, 1, 12, 0, 0)
      second_time = Time.new(2024, 6, 15, 18, 30, 0)

      tree = AdfBuilder.tree do
        prospect do
          request_date first_time
          request_date second_time
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

      xml = tree.to_xml
      doc = Nokogiri::XML(xml)
      requestdates = doc.xpath("//adf/prospect/requestdate")
      expect(requestdates.size).to eq(1)
      expect(requestdates.first.text).to include("2024-06-15")
    end

    it "renders requestdate as child element not attribute" do
      xml = valid_prospect_xml
      doc = Nokogiri::XML(xml)

      expect(doc.at_xpath("//adf/prospect/requestdate")).not_to be_nil
      expect(doc.at_xpath("//adf/prospect")["requestdate"]).to be_nil
    end
  end

  describe "helper methods" do
    it "#vehicles returns all Vehicle children" do
      tree = AdfBuilder.tree do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "A"
            model "A"
          end
          vehicle do
            year 2023
            make "B"
            model "B"
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

      prospect = tree.first_prospect
      expect(prospect.vehicles.size).to eq(2)
      expect(prospect.vehicles.all? { |v| v.is_a?(AdfBuilder::Nodes::Vehicle) }).to be true
    end

    it "#customers returns all Customer children" do
      tree = AdfBuilder.tree do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "A"
            model "A"
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

      prospect = tree.first_prospect
      expect(prospect.customers.size).to eq(1)
      expect(prospect.customers.first).to be_a(AdfBuilder::Nodes::Customer)
    end
  end

  describe "valid minimal prospect" do
    it "builds without error" do
      expect { valid_prospect_xml }.not_to raise_error
    end

    it "contains all required elements" do
      xml = valid_prospect_xml
      doc = Nokogiri::XML(xml)

      expect(doc.at_xpath("//adf/prospect/requestdate")).not_to be_nil
      expect(doc.at_xpath("//adf/prospect/vehicle")).not_to be_nil
      expect(doc.at_xpath("//adf/prospect/customer")).not_to be_nil
      expect(doc.at_xpath("//adf/prospect/vendor")).not_to be_nil
    end
  end

  describe "valid complete prospect" do
    it "builds with all sections" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "Rivian"
            model "R1T"
            status :new
            interest :buy
            vin "1ABC2DEF3GHI45678"
            stock "STK123"
            trim "Adventure"
            doors 4
            bodystyle "Pickup"
            condition "excellent"
            odometer 100, status: :original, units: :mi
            finance do
              method "finance"
              amount 5000, type: :downpayment
            end
            option do
              optionname "Off-road Package"
            end
            colorcombination do
              interiorcolor "Black"
              exteriorcolor "Green"
            end
          end
          customer do
            id "CID123", source: "CRM"
            contact do
              name "Jane Doe", part: :full, type: :individual
              phone "555-0199", type: :cellphone, time: :evening
              email "jane@example.com", preferredcontact: 1
              address type: :home do
                street "123 Main St", line: 1
                city "Seattle"
                regioncode "WA"
                postalcode "98101"
                country "US"
              end
            end
            timeframe do
              description "ASAP"
              earliestdate "2024-01-01"
            end
            comments "Looking for a good deal."
          end
          vendor do
            id "VID456", source: "DMS"
            vendorname "Best Dealership"
            url "http://bestdealer.com"
            contact do
              name "Sales Manager"
              phone "555-9999", type: :voice
            end
          end
          provider do
            name "CarPoint", part: :full
            service "Classifieds"
            url "http://carpoint.com"
            email "info@carpoint.com"
            phone "800-555-1234"
            contact primary_contact: 1 do
              name "Support"
              email "support@carpoint.com"
            end
          end
        end
      end

      doc = Nokogiri::XML(xml)
      expect(doc.errors).to be_empty
      expect(doc.at_xpath("//adf/prospect/vehicle/vin").text).to eq("1ABC2DEF3GHI45678")
      expect(doc.at_xpath("//adf/prospect/customer/id")["source"]).to eq("CRM")
      expect(doc.at_xpath("//adf/prospect/vendor/vendorname").text).to eq("Best Dealership")
      expect(doc.at_xpath("//adf/prospect/provider/service").text).to eq("Classifieds")
    end
  end
end
