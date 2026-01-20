# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe AdfBuilder::Nodes::Timeframe do
  def build_with_timeframe(&block)
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
            name "J"
            email "j@j.com"
          end
          timeframe(&block)
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
  end

  describe "date requirements" do
    it "requires earliestdate or latestdate" do
      expect do
        build_with_timeframe do
          description "Soon"
        end
      end.to raise_error(AdfBuilder::Error, /Timeframe must have at least one of earliestdate or latestdate/)
    end

    it "valid with earliestdate only" do
      expect do
        build_with_timeframe do
          earliestdate "2024-01-01"
        end
      end.not_to raise_error
    end

    it "valid with latestdate only" do
      expect do
        build_with_timeframe do
          latestdate "2024-12-31"
        end
      end.not_to raise_error
    end

    it "valid with both dates" do
      expect do
        build_with_timeframe do
          earliestdate "2024-01-01"
          latestdate "2024-12-31"
        end
      end.not_to raise_error
    end
  end

  describe "description element" do
    it "renders description" do
      xml = build_with_timeframe do
        description "Looking to buy within 3 months"
        earliestdate "2024-01-01"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//timeframe/description").text).to eq("Looking to buy within 3 months")
    end

    it "replaces existing description" do
      xml = build_with_timeframe do
        description "First"
        description "Second"
        earliestdate "2024-01-01"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//timeframe/description").size).to eq(1)
      expect(doc.at_xpath("//timeframe/description").text).to eq("Second")
    end
  end

  describe "ISO 8601 date validation" do
    it "accepts standard ISO 8601 date (YYYY-MM-DD)" do
      xml = build_with_timeframe do
        earliestdate "2024-06-15"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//timeframe/earliestdate").text).to eq("2024-06-15")
    end

    it "accepts ISO 8601 with time component" do
      xml = build_with_timeframe do
        earliestdate "2024-06-15T14:30:00"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//timeframe/earliestdate").text).to include("2024-06-15")
    end

    it "accepts ISO 8601 with timezone" do
      xml = build_with_timeframe do
        earliestdate "2024-06-15T14:30:00Z"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//timeframe/earliestdate").text).to include("2024-06-15")
    end

    it "rejects invalid date format" do
      expect do
        build_with_timeframe do
          earliestdate "not-a-date"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid ISO 8601 date/)
    end

    it "rejects MM/DD/YYYY format" do
      expect do
        build_with_timeframe do
          earliestdate "06/15/2024"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid ISO 8601 date/)
    end

    it "rejects DD-MM-YYYY format" do
      expect do
        build_with_timeframe do
          earliestdate "15-06-2024"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid ISO 8601 date/)
    end

    it "rejects empty string" do
      expect do
        build_with_timeframe do
          earliestdate ""
        end
      end.to raise_error(AdfBuilder::Error, /Invalid ISO 8601 date/)
    end

    it "validates latestdate as well" do
      expect do
        build_with_timeframe do
          latestdate "invalid"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid ISO 8601 date/)
    end
  end

  describe "earliestdate element" do
    it "renders earliestdate" do
      xml = build_with_timeframe do
        earliestdate "2024-03-01"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//timeframe/earliestdate").text).to eq("2024-03-01")
    end

    it "replaces existing earliestdate" do
      xml = build_with_timeframe do
        earliestdate "2024-01-01"
        earliestdate "2024-06-01"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//timeframe/earliestdate").size).to eq(1)
      expect(doc.at_xpath("//timeframe/earliestdate").text).to eq("2024-06-01")
    end
  end

  describe "latestdate element" do
    it "renders latestdate" do
      xml = build_with_timeframe do
        latestdate "2024-12-31"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//timeframe/latestdate").text).to eq("2024-12-31")
    end

    it "replaces existing latestdate" do
      xml = build_with_timeframe do
        latestdate "2024-06-30"
        latestdate "2024-12-31"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//timeframe/latestdate").size).to eq(1)
      expect(doc.at_xpath("//timeframe/latestdate").text).to eq("2024-12-31")
    end
  end

  describe "complete timeframe" do
    it "renders all elements" do
      xml = build_with_timeframe do
        description "Summer purchase"
        earliestdate "2024-06-01"
        latestdate "2024-08-31"
      end

      doc = Nokogiri::XML(xml)
      tf = doc.at_xpath("//timeframe")
      expect(tf.at_xpath("description").text).to eq("Summer purchase")
      expect(tf.at_xpath("earliestdate").text).to eq("2024-06-01")
      expect(tf.at_xpath("latestdate").text).to eq("2024-08-31")
    end
  end
end
