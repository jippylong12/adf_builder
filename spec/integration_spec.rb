# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe "Integration: Full Lead" do
  it "generates XML with multiple vehicles and complex customer info" do
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

        # Multiple Vehicles
        vehicle do
          year 2020
          make "Ford"
          model "Mustang"
        end

        vehicle do
          year 2022
          make "Tesla"
          model "Model Y"
        end

        customer do
          contact do
            name "John Doe", part: "full"
            email "john@example.com"
            phone "555-1234", type: "cellphone"
          end
        end
      end
    end

    doc = Nokogiri::XML(xml)

    # Check vehicles
    vehicles = doc.xpath("//adf/prospect/vehicle")
    expect(vehicles.size).to eq(2)
    expect(vehicles[0].at_xpath("make").text).to eq("Ford")
    expect(vehicles[1].at_xpath("make").text).to eq("Tesla")

    # Check Customer Contact
    name_node = doc.at_xpath("//adf/prospect/customer/contact/name")
    expect(name_node.text).to eq("John Doe")
    expect(name_node["part"]).to eq("full")

    phone_node = doc.at_xpath("//adf/prospect/customer/contact/phone")
    expect(phone_node.text).to eq("555-1234")
    expect(phone_node["type"]).to eq("cellphone")
  end
end
