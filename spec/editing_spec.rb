# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe "Editing Workflow" do
  it "allows modifying the tree after construction" do
    # 1. Build the tree (not XML string)
    tree = AdfBuilder.tree do
      prospect do
        request_date Time.now
        vehicle do
          year 2020
          make "Ford"
          status :new
        end
      end
    end

    # 2. Modify the tree
    prospect = tree.children.first
    vehicle = prospect.vehicles.first

    # Change year
    vehicle.year(2025)

    # Add a new vehicle
    prospect.vehicle do
      year 2023
      make "Tesla"
    end

    # 3. Generate XML
    xml = tree.to_xml
    doc = Nokogiri::XML(xml)

    # Verify modifications
    vehicles = doc.xpath("//adf/prospect/vehicle")
    expect(vehicles.size).to eq(2)

    # Check updated year
    expect(vehicles[0].at_xpath("year").text).to eq("2025")

    # Check new vehicle
    expect(vehicles[1].at_xpath("make").text).to eq("Tesla")
  end
end
