# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Error Cases" do
  describe "error message quality" do
    it "includes field name in error message" do
      expect do
        AdfBuilder.build do
          prospect do
            request_date Time.now
            vehicle do
              year 2024
              make "T"
              model "M"
              status :invalid
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
      end.to raise_error(AdfBuilder::Error, /status/)
    end

    it "includes invalid value in error message" do
      expect do
        AdfBuilder.build do
          prospect do
            request_date Time.now
            vehicle do
              year 2024
              make "T"
              model "M"
              status :broken
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
      end.to raise_error(AdfBuilder::Error, /broken/)
    end

    it "includes allowed values in error message for inclusion validation" do
      expect do
        AdfBuilder.build do
          prospect do
            request_date Time.now
            vehicle do
              year 2024
              make "T"
              model "M"
              status :broken
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
      end.to raise_error(AdfBuilder::Error, /new.*used|used.*new/i)
    end
  end

  describe "nested validation errors" do
    it "surfaces error from nested vehicle" do
      expect do
        AdfBuilder.build do
          prospect do
            request_date Time.now
            vehicle do
              year 2024
              make "T"
              model "M"
              odometer 100, status: :bad
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
      end.to raise_error(AdfBuilder::Error, /Invalid value for status/)
    end

    it "surfaces error from deeply nested contact" do
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
                name "C", part: :invalid_part
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
      end.to raise_error(AdfBuilder::Error, /Invalid value for part/)
    end

    it "surfaces error from address validation" do
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
                address do
                  street "123 Main"
                  country "INVALID"
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
      end.to raise_error(AdfBuilder::Error, /Invalid country code/)
    end
  end

  describe "multiple validation failures" do
    it "raises first error encountered" do
      # When multiple things are wrong, we get the first one
      expect do
        AdfBuilder.build do
          prospect do
            request_date Time.now
            vehicle do
              year 2024
              make "T"
              model "M"
              status :bad
              interest :worse
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
      end.to raise_error(AdfBuilder::Error)
    end
  end

  describe "presence validation errors" do
    it "indicates missing required element" do
      expect do
        AdfBuilder.build do
          prospect do
            request_date Time.now
            vehicle do
              year 2024
              # Missing make and model
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
      end.to raise_error(AdfBuilder::Error, /Missing required Element: make/)
    end

    it "indicates missing contact in customer" do
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
              comments "No contact here"
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
      end.to raise_error(AdfBuilder::Error, /Missing required Element: contact/)
    end
  end

  describe "argument errors" do
    it "raises ArgumentError for id without source" do
      expect do
        AdfBuilder.build do
          prospect do
            request_date Time.now
            vehicle do
              year 2024
              make "T"
              model "M"
              id "12345"
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
      end.to raise_error(ArgumentError, /Source is required/)
    end
  end

  describe "range errors" do
    it "reports weighting out of range with helpful message" do
      expect do
        AdfBuilder.build do
          prospect do
            request_date Time.now
            vehicle do
              year 2024
              make "T"
              model "M"
              option { weighting 200 }
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
      end.to raise_error(AdfBuilder::Error, /Weighting must be between -100 and 100.*200/)
    end
  end

  describe "date format errors" do
    it "provides helpful message for invalid date" do
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
              timeframe do
                earliestdate "tomorrow"
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
      end.to raise_error(AdfBuilder::Error, /Invalid ISO 8601 date.*tomorrow/)
    end
  end

  describe "error type preservation" do
    it "raises AdfBuilder::Error for validation failures" do
      expect do
        AdfBuilder.build do
          prospect do
            # Missing everything
          end
        end
      end.to raise_error(AdfBuilder::Error)
    end

    it "raises ArgumentError for invalid arguments" do
      expect do
        AdfBuilder::Nodes::Id.new("test", source: nil)
      end.to raise_error(ArgumentError)
    end
  end

  describe "nil value handling" do
    it "handles nil in optional field gracefully" do
      # Nil values are generally ignored or treated as missing
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            comments nil
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

      # Should not crash with nil
      expect(xml).to include("<adf>")
    end
  end
end
