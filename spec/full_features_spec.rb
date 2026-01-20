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
            phone "555-0199", type: :cellphone, time: :evening, preferredcontact: 1
            email "jane@example.com", preferredcontact: 1
            address type: :home do
              street "123 Maplestreet", line: 1
              city "Spokane"
              regioncode "WA"
              postalcode "98002"
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
          vendorname "Best Dealership"
          url "http://bestdealer.com"
          contact do
            name "Sales Manager"
            phone "555-9999", type: :phone
          end
        end

        provider do
          name "CarPoint", part: :full
          service "Used Car Classifieds"
          url "http://carpoint.msn.com"
          email "carcomm@carpoint.com"
          phone "425-555-1212"
          contact primary_contact: 1 do
            name "Fred Jones", part: :full
            email "support@carpoint.com"
            phone "425-253-2222", type: :voice, time: :day
            address do
              street "One Microsoft Way", line: 1
              city "Redmond"
              regioncode "WA"
              postalcode "98052"
              country "US"
            end
          end
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
    expect(xml).to include('<street line="1">123 Maplestreet</street>')
    expect(xml).to include("<timeframe>")
    expect(xml).to include("<description>ASAP</description>")
    expect(xml).to include("<comments>Looking for a good deal.</comments>")

    # Vendor/Provider checks
    expect(xml).to include("<vendor>")
    expect(xml).to include("<vendorname>Best Dealership</vendorname>")
    expect(xml).to include("<provider>")
    expect(xml).to include('<name part="full">CarPoint</name>')
    expect(xml).to include("<service>Used Car Classifieds</service>")
    expect(xml).to include("<url>http://carpoint.msn.com</url>")
    expect(xml).to include("<email>carcomm@carpoint.com</email>")
    expect(xml).to include("<phone>425-555-1212</phone>")
    # Check Provider Contact
    expect(xml).to include("<contact primarycontact=\"1\">")
    expect(xml).to include('<name part="full">Fred Jones</name>')
    expect(xml).to include("<email>support@carpoint.com</email>")
    expect(xml).to include('<phone type="voice" time="day">425-253-2222</phone>')
    expect(xml).to include("<address>")
    expect(xml).to include('<street line="1">One Microsoft Way</street>')
    expect(xml).to include("<city>Redmond</city>")
    expect(xml).to include("<country>US</country>")
  end

  it "validates enums strictly" do
    expect do
      AdfBuilder.build do
        prospect do
          vehicle do
            year 2021
            make "Toyota"
            model "Camry"
            status :broken # Invalid
          end
        end
      end
    end.to raise_error(AdfBuilder::Error, /Invalid value for status/)

    expect do
      AdfBuilder.build do
        prospect do
          vehicle do
            year 2021
            make "Toyota"
            model "Camry"
            finance do
              amount 100, type: :invalid_type
            end
          end
        end
      end
    end.to raise_error(AdfBuilder::Error, /Invalid value for type/)

    # Condition Validation
    expect do
      AdfBuilder.build do
        prospect do
          vehicle do
            year 2021
            make "T"
            model "C"
            condition "terrible"
          end
        end
      end
    end.to raise_error(AdfBuilder::Error, /Invalid condition/)

    # Option Weighting Validation
    expect do
      AdfBuilder.build do
        prospect do
          vehicle do
            year 2021
            make "T"
            model "C"
            option { weighting 150 }
          end
        end
      end
    end.to raise_error(AdfBuilder::Error, /Weighting must be between -100 and 100/)

    # Finance Method Validation
    expect do
      AdfBuilder.build do
        prospect do
          vehicle do
            year 2021
            make "T"
            model "C"
            finance { method "steal" }
          end
        end
      end
    end.to raise_error(AdfBuilder::Error, /Invalid finance method/)

    # ID Source Requirement
    expect do
      AdfBuilder.build do
        prospect do
          vehicle do
            year 2021
            make "T"
            model "C"
            id "123"
          end
        end
      end
    end.to raise_error(ArgumentError, /Source is required/)

    # Required Vehicle Fields (Year, Make, Model)
    expect do
      AdfBuilder.build do
        prospect do
          vehicle do
            year 2024
            # Missing Make and Model
          end
        end
      end
    end.to raise_error(AdfBuilder::Error, /Missing required Element: make/)

    # Currency Validation (Price)
    expect do
      AdfBuilder.build do
        prospect do
          vehicle do
            year 2024
            make "T"
            model "C"
            price 100, currency: "XYZ"
          end
        end
      end
    end.to raise_error(AdfBuilder::Error, /Invalid value for currency: XYZ/)

    # Currency Validation (Amount)
    expect do
      AdfBuilder.build do
        prospect do
          vehicle do
            year 2024
            make "T"
            model "C"
            finance { amount 100, currency: "LOL" }
          end
        end
      end
    end.to raise_error(AdfBuilder::Error, /Invalid value for currency: LOL/)

    # Contact Validation (Name Required)
    expect do
      AdfBuilder.build do
        prospect { vendor { vendorname "Bob's Cars" } }
      end
    end.to raise_error(AdfBuilder::Error, /Missing required Element: contact/)

    # Provider Validation (Name Required)
    expect do
      AdfBuilder.build do
        prospect { provider { service "Listings" } }
      end
    end.to raise_error(AdfBuilder::Error, /Missing required Element: name/)

    # Contact Validation (Name Required)
    expect do
      AdfBuilder.build do
        prospect { customer { contact { email "foo@bar.com" } } }
      end
    end.to raise_error(AdfBuilder::Error, /Missing required Element: name/)

    # Contact Validation (Phone or Email Required)
    expect do
      AdfBuilder.build do
        prospect { customer { contact { name "John" } } }
      end
    end.to raise_error(AdfBuilder::Error, /Contact must have at least one Phone or Email/)

    # Address Country Validation
    expect do
      AdfBuilder.build do
        prospect do
          customer do
            contact do
              name "John"
              email "a@b.c"
              address do
                street "Main"
                country "XX"
              end
            end
          end
        end
      end
    end.to raise_error(AdfBuilder::Error, /Invalid country code: XX/)

    # Valid Country Code
    AdfBuilder.build do
      prospect do
        customer do
          contact do
            name "John"
            email "a@b.c"
            address do
              street "Main"
              country "US"
            end
          end
        end
      end
    end

    # Timeframe Validation (Dates)
    expect do
      AdfBuilder.build do
        prospect { customer { timeframe { earliestdate "not-a-date" } } }
      end
    end.to raise_error(AdfBuilder::Error, /Invalid ISO 8601 date/)

    # Timeframe Validation (Requirement)
    expect do
      AdfBuilder.build do
        prospect do
          customer do
            contact do
              name "J"
              email "e"
            end
            timeframe { description "browsing" }
          end
        end
      end
    end.to raise_error(AdfBuilder::Error, /Timeframe must have at least one of earliestdate or latestdate/)
  end
end
