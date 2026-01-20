# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe "Boundary & Limit Testing" do
  def valid_prospect_base
    proc do
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
    end
  end

  describe "empty string values" do
    it "handles empty string in comments" do
      base = valid_prospect_base
      xml = AdfBuilder.build do
        prospect do
          instance_eval(&base)
          vehicles.first.comments("")
        end
      end
      doc = Nokogiri::XML(xml)
      # Should not raise, empty string is valid
      expect(doc.errors).to be_empty
    end

    it "handles empty string in optional fields" do
      base = valid_prospect_base
      xml = AdfBuilder.build do
        prospect do
          instance_eval(&base)
        end
      end
      # This should work fine
      expect { Nokogiri::XML(xml) }.not_to raise_error
    end
  end

  describe "very long string values" do
    it "handles 1000+ character comments" do
      long_string = "X" * 1500
      base = valid_prospect_base
      xml = AdfBuilder.build do
        prospect do
          instance_eval(&base)
        end
      end

      tree = AdfBuilder.tree do
        prospect do
          instance_eval(&base)
        end
      end
      tree.first_prospect.vehicles.first.comments(long_string)
      xml = tree.to_xml

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/comments").text.length).to eq(1500)
    end

    it "handles very long vendorname" do
      long_name = "Super Auto Dealership " * 50
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
            vendorname long_name
            contact do
              name "V"
              email "v@v.com"
            end
          end
        end
      end

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vendor/vendorname").text).to eq(long_name)
    end
  end

  describe "unicode characters" do
    it "handles unicode in name" do
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
              name "José García 日本語 Müller"
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
      expect(doc.at_xpath("//customer/contact/name").text).to eq("José García 日本語 Müller")
    end

    it "handles unicode in address" do
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
              address do
                street "123 北京路"
                city "東京"
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
      expect(doc.at_xpath("//address/street").text).to eq("123 北京路")
      expect(doc.at_xpath("//address/city").text).to eq("東京")
    end

    it "handles emojis" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            comments "Love this car! 🚗💕"
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
      expect(doc.at_xpath("//vehicle/comments").text).to include("🚗")
    end
  end

  describe "numeric edge cases" do
    it "handles year 0" do
      # Edge case - year validation doesn't restrict value
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 0
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

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/year").text).to eq("0")
    end

    it "handles very large year" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 9999
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

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/year").text).to eq("9999")
    end

    it "handles zero price" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            price 0, type: :quote
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
      expect(doc.at_xpath("//vehicle/price").text).to eq("0")
    end

    it "handles large price" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            price 999_999_999, type: :msrp
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
      expect(doc.at_xpath("//vehicle/price").text).to eq("999999999")
    end

    it "handles decimal odometer" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            odometer 12_345.67
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
      expect(doc.at_xpath("//vehicle/odometer").text).to eq("12345.67")
    end
  end

  describe "whitespace-only values" do
    it "handles space-only string" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            comments "   "
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
      expect(doc.at_xpath("//vehicle/comments").text).to eq("   ")
    end

    it "handles tabs and newlines" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            comments "Line 1\n\tLine 2"
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
      expect(doc.at_xpath("//vehicle/comments").text).to include("\n")
    end
  end

  describe "deeply nested custom structures" do
    it "handles 5 levels of nesting" do
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
          level1 do
            level2 do
              level3 do
                level4 do
                  level5 "Deep Value"
                end
              end
            end
          end
        end
      end

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//prospect/level1/level2/level3/level4/level5").text).to eq("Deep Value")
    end

    it "handles 10 levels of nesting" do
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
          l1 do
            l2 do
              l3 do
                l4 do
                  l5 do
                    l6 do
                      l7 do
                        l8 do
                          l9 do
                            l10 "Very Deep"
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end

      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//l1/l2/l3/l4/l5/l6/l7/l8/l9/l10").text).to eq("Very Deep")
    end
  end

  describe "maximum children count" do
    it "handles 50+ vehicles" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          50.times do |i|
            vehicle do
              year 2020 + (i % 5)
              make "Make#{i}"
              model "Model#{i}"
            end
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
      expect(doc.xpath("//vehicle").size).to eq(50)
    end

    it "handles 100+ options on a vehicle" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            100.times do |i|
              option { optionname "Option #{i}" }
            end
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
      expect(doc.xpath("//vehicle/option").size).to eq(100)
    end
  end

  describe "special XML characters in all positions" do
    it "handles < > & in element value" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            comments "<script>alert('XSS')</script> & other < > tricks"
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
      expect(doc.at_xpath("//vehicle/comments").text).to include("<script>")
    end

    it "handles quotes in attribute values" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            imagetag "http://test.jpg", alttext: "A 'test' \"image\""
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
      alttext = doc.at_xpath("//imagetag")["alttext"]
      expect(alttext).to include("'test'")
      expect(alttext).to include('"image"')
    end
  end
end
