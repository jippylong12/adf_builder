# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe "Edge Cases & Dynamic Support" do
  describe "Non-standard/Custom Tags" do
    it "supports arbitrary tags via method_missing" do
      xml = AdfBuilder.build do
        prospect do
          vendor do
            vendorname "V"
            contact do
              name "C"
              email "c@test.com"
            end
          end
          customer do
            contact do
              name "C"
              email "e"
            end
          end
          vehicle do
            year 2000
            make "M"
            model "M"
          end

          # Standard
          request_date Time.now

          # Custom/Non-standard
          custom_tag "Custom Value"

          # Custom with attributes
          flag true, type: "urgent"

          # Custom structural
          meta_data do
            source "Google"
            campaign_id 12_345
          end
        end
      end

      doc = Nokogiri::XML(xml)

      # Verify custom_tag
      expect(doc.at_xpath("//adf/prospect/custom_tag").text).to eq("Custom Value")

      # Verify flag with attributes
      flag = doc.at_xpath("//adf/prospect/flag")
      expect(flag.text).to eq("true")
      expect(flag["type"]).to eq("urgent")

      # Verify nested custom structure
      expect(doc.at_xpath("//adf/prospect/meta_data/source").text).to eq("Google")
      expect(doc.at_xpath("//adf/prospect/meta_data/campaign_id").text).to eq("12345")
    end
  end

  describe "Special Characters" do
    it "escapes special characters in values" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vendor do
            vendorname "V"
            contact do
              name "C"
              email "c@test.com"
            end
          end
          customer do
            contact do
              name "C"
              email "e"
            end
          end
          vehicle do
            year 2021
            make "Toyota"
            model "Camry"
            comments "This & That < Other >"
          end
        end
      end

      doc = Nokogiri::XML(xml)
      comments = doc.at_xpath("//adf/prospect/vehicle/comments").text
      expect(comments).to eq("This & That < Other >")
    end
  end

  describe "Deep Nesting" do
    it "handles deep nesting of standard and non-standard tags" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vendor do
            vendorname "V"
            contact do
              name "C"
              email "c@test.com"
            end
          end
          customer do
            contact do
              name "C"
              email "e"
            end
          end
          vehicle do
            year 2000
            make "M"
            model "M"
          end
          level_1 do
            level_2 do
              level_3 "Deep Value"
            end
          end
        end
      end

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//adf/prospect/level_1/level_2/level_3").text).to eq("Deep Value")
    end
  end
end
