# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe AdfBuilder::DSL do
  describe ".build" do
    it "builds a valid ADF XML document" do
      xml_output = AdfBuilder.build do
        prospect do
          vehicle do
            year 2021
            make "Ford"
            model "F-150"
            status :new
          end
        end
      end

      # Parse with Nokogiri
      doc = Nokogiri::XML(xml_output)

      # Verify Structure
      expect(doc.xpath("//adf/prospect/vehicle").size).to eq(1)

      vehicle = doc.xpath("//adf/prospect/vehicle").first
      expect(vehicle).not_to be_nil

      # Check child elements (year, make, model)
      expect(vehicle.at_xpath("year").text).to eq("2021")
      expect(vehicle.at_xpath("make").text).to eq("Ford")
      expect(vehicle.at_xpath("model").text).to eq("F-150")

      # Check attributes (status)
      # AdfBuilder::Serializer logic: 'status' should be an attribute
      expect(vehicle["status"]).to eq("new")
    end
  end
end
