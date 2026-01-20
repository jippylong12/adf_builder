# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe "XML Output" do
  def valid_minimal_xml
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
      end
    end
  end

  describe "XML structure" do
    it "includes XML declaration" do
      xml = valid_minimal_xml
      expect(xml).to start_with("<?xml version=\"1.0\"")
    end

    it "has root adf element" do
      doc = Nokogiri::XML(valid_minimal_xml)
      expect(doc.root.name).to eq("adf")
    end

    it "has prospect as child of adf" do
      doc = Nokogiri::XML(valid_minimal_xml)
      expect(doc.at_xpath("/adf/prospect")).not_to be_nil
    end

    it "is well-formed XML" do
      doc = Nokogiri::XML(valid_minimal_xml)
      expect(doc.errors).to be_empty
    end
  end

  describe "attribute rendering" do
    it "renders symbol attributes correctly" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            status :used
            interest :lease
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

      doc = Nokogiri::XML(xml)
      vehicle = doc.at_xpath("//vehicle")
      expect(vehicle["status"]).to eq("used")
      expect(vehicle["interest"]).to eq("lease")
    end

    it "renders numeric attributes correctly" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            imagetag "http://test.jpg", width: 800, height: 600
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

      doc = Nokogiri::XML(xml)
      img = doc.at_xpath("//imagetag")
      expect(img["width"]).to eq("800")
      expect(img["height"]).to eq("600")
    end

    it "renders string attributes correctly" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            id "VIN123", source: "DMS"
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

      doc = Nokogiri::XML(xml)
      id = doc.at_xpath("//vehicle/id")
      expect(id["source"]).to eq("DMS")
    end
  end

  describe "special character escaping" do
    it "escapes ampersand (&)" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            comments "Tom & Jerry"
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

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/comments").text).to eq("Tom & Jerry")
    end

    it "escapes less than (<)" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            comments "Price < MSRP"
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

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/comments").text).to eq("Price < MSRP")
    end

    it "escapes greater than (>)" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            comments "MPG > 30"
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

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/comments").text).to eq("MPG > 30")
    end

    it "handles multiple special characters" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            comments "Price < $30k & MPG > 40 <guaranteed>"
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

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/comments").text).to eq("Price < $30k & MPG > 40 <guaranteed>")
    end

    it "handles quotes in attribute values" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            imagetag "http://test.jpg", alttext: 'The "best" car'
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

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//imagetag")["alttext"]).to eq('The "best" car')
    end
  end

  describe "value types" do
    it "renders empty string elements" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            comments ""
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

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/comments").text).to eq("")
    end

    it "renders boolean values as strings" do
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
            contact do
              name "V"
              email "v@v.com"
            end
          end
          custom_flag true
        end
      end

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//prospect/custom_flag").text).to eq("true")
    end

    it "renders numeric values as strings" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            doors 4
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

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/doors").text).to eq("4")
    end
  end

  describe "nested structure preservation" do
    it "maintains nested structure correctly" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            finance do
              method "lease"
              amount 500, type: :monthly
            end
          end
          customer do
            contact do
              name "C"
              email "c@c.com"
              address do
                street "123 Main"
                city "Seattle"
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
      expect(doc.at_xpath("//prospect/vehicle/finance/method")).not_to be_nil
      expect(doc.at_xpath("//prospect/customer/contact/address/street")).not_to be_nil
    end

    it "maintains multiple children order" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "First"
            model "M"
          end
          vehicle do
            year 2024
            make "Second"
            model "M"
          end
          vehicle do
            year 2024
            make "Third"
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

      doc = Nokogiri::XML(xml)
      makes = doc.xpath("//vehicle/make").map(&:text)
      expect(makes).to eq(%w[First Second Third])
    end
  end
end
