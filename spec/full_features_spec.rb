# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Full Features Verification" do
  it "builds a complete ADF document with all new nodes" do
    xml = AdfBuilder.build do
      prospect do
        request_date Time.now

        vehicle do
          year 2024
          make "Rivian"
          model "R1T"
          status :new
          interest :buy

          # Complex nodes
          odometer 100, status: :original, units: :mi

          finance do
            method "finance"
            amount 5000, type: :downpayment, limit: :maximum
            balance 50_000, type: :finance
          end

          option do
            optionname "Off-road Package"
            price 2000, type: :msrp, currency: "USD"
          end

          colorcombination do
            interiorcolor "Black"
            exteriorcolor "Green"
            preference 1
          end

          imagetag "http://example.com/image.jpg", width: 800, height: 600, alttext: "Front View"
        end

        customer do
          contact do
            name "Jane Doe", part: :full, type: :individual
            phone "555-0199", type: :cell, time: :evening, preferredcontact: 1
            email "jane@example.com", preferredcontact: 1
            address type: :home do
              street "123 Main St", line: 1
              city "Austin"
              regioncode "TX"
              postalcode "78701"
              country "USA"
            end
          end

          timeframe do
            description "ASAP"
            earliestdate "2024-01-01"
          end

          comments "Looking for a good deal."
        end

        vendor do
          vendorname "Best Dealership"
          url "http://bestdealer.com"
          contact do
            name "Sales Manager"
            phone "555-9999", type: :work
          end
        end

        provider do
          name "Lead Source Provider"
          service "Lead Gen"
          email "leads@provider.com"
        end
      end
    end

    # Basic inclusions check
    expect(xml).to include("<adf>")
    expect(xml).to include("<prospect>")

    # Vehicle checks
    expect(xml).to include("<vehicle status=\"new\" interest=\"buy\">")
    expect(xml).to include("<make>Rivian</make>")
    expect(xml).to include("<odometer status=\"original\" units=\"mi\">100</odometer>")
    expect(xml).to include("<finance>")
    expect(xml).to include("<amount type=\"downpayment\" limit=\"maximum\">5000</amount>")
    expect(xml).to include("<option>")
    expect(xml).to include("<optionname>Off-road Package</optionname>")
    expect(xml).to include("<imagetag width=\"800\" height=\"600\" alttext=\"Front View\">http://example.com/image.jpg</imagetag>")

    # Customer checks
    expect(xml).to include("<customer>")
    expect(xml).to include("<contact>")
    expect(xml).to include("<name part=\"full\" type=\"individual\">Jane Doe</name>")
    expect(xml).to include("<address type=\"home\">")
    expect(xml).to include("<street line=\"1\">123 Main St</street>")
    expect(xml).to include("<timeframe>")
    expect(xml).to include("<description>ASAP</description>")
    expect(xml).to include("<comments>Looking for a good deal.</comments>")

    # Vendor/Provider checks
    expect(xml).to include("<vendor>")
    expect(xml).to include("<vendorname>Best Dealership</vendorname>")
    expect(xml).to include("<provider>")
    expect(xml).to include("<service>Lead Gen</service>")
  end

  it "validates enums strictly" do
    expect do
      AdfBuilder.build do
        prospect do
          vehicle do
            status :broken # Invalid
          end
        end
      end
    end.to raise_error(AdfBuilder::Error, /Invalid value for status/)

    expect do
      AdfBuilder.build do
        prospect do
          vehicle do
            finance do
              amount 100, type: :invalid_type
            end
          end
        end
      end
    end.to raise_error(AdfBuilder::Error, /Invalid value for type/)
  end
end
