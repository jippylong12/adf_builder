# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe AdfBuilder::Nodes::Vehicle do
  # Helper to build prospect with vehicle block
  def build_with_vehicle(&block)
    AdfBuilder.build do
      prospect do
        request_date Time.now
        vehicle(&block)
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
  end

  describe "required fields" do
    it "requires year" do
      expect do
        build_with_vehicle do
          make "Toyota"
          model "Camry"
        end
      end.to raise_error(AdfBuilder::Error, /Missing required Element: year/)
    end

    it "requires make" do
      expect do
        build_with_vehicle do
          year 2024
          model "Camry"
        end
      end.to raise_error(AdfBuilder::Error, /Missing required Element: make/)
    end

    it "requires model" do
      expect do
        build_with_vehicle do
          year 2024
          make "Toyota"
        end
      end.to raise_error(AdfBuilder::Error, /Missing required Element: model/)
    end
  end

  describe "default values" do
    it "defaults status to :new" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle")["status"]).to eq("new")
    end

    it "defaults interest to :buy" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle")["interest"]).to eq("buy")
    end
  end

  describe "status attribute" do
    it "accepts :new" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        status :new
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle")["status"]).to eq("new")
    end

    it "accepts :used" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        status :used
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle")["status"]).to eq("used")
    end

    it "rejects invalid status" do
      expect do
        build_with_vehicle do
          year 2024
          make "T"
          model "M"
          status :broken
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for status: broken/)
    end

    it "rejects unknown status value" do
      expect do
        build_with_vehicle do
          year 2024
          make "T"
          model "M"
          status :certified
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for status/)
    end
  end

  describe "interest attribute" do
    %i[buy lease sell trade-in test-drive].each do |interest|
      it "accepts :#{interest}" do
        xml = build_with_vehicle do
          year 2024
          make "T"
          model "M"
          interest interest
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//vehicle")["interest"]).to eq(interest.to_s)
      end
    end

    it "rejects invalid interest" do
      expect do
        build_with_vehicle do
          year 2024
          make "T"
          model "M"
          interest :rent
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for interest/)
    end
  end

  describe "simple text elements" do
    %i[vin stock trim doors bodystyle transmission pricecomments comments].each do |tag|
      it "supports #{tag}" do
        value = "test_#{tag}_value"
        xml = build_with_vehicle do
          year 2024
          make "T"
          model "M"
          send(tag, value)
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//vehicle/#{tag}").text).to eq(value)
      end
    end

    it "replaces existing value for singular elements" do
      xml = build_with_vehicle do
        year 2020
        year 2024
        make "T"
        model "M"
      end
      doc = Nokogiri::XML(xml)
      years = doc.xpath("//vehicle/year")
      expect(years.size).to eq(1)
      expect(years.first.text).to eq("2024")
    end
  end

  describe "condition element" do
    %w[excellent good fair poor unknown].each do |cond|
      it "accepts '#{cond}'" do
        xml = build_with_vehicle do
          year 2024
          make "T"
          model "M"
          condition cond
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//vehicle/condition").text).to eq(cond)
      end
    end

    it "rejects invalid condition" do
      expect do
        build_with_vehicle do
          year 2024
          make "T"
          model "M"
          condition "terrible"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid condition/)
    end

    it "rejects arbitrary condition value" do
      expect do
        build_with_vehicle do
          year 2024
          make "T"
          model "M"
          condition "mint"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid condition/)
    end
  end

  describe "id element" do
    it "requires source attribute" do
      expect do
        build_with_vehicle do
          year 2024
          make "T"
          model "M"
          id "12345"
        end
      end.to raise_error(ArgumentError, /Source is required/)
    end

    it "accepts id with source" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        id "12345", source: "DMS"
      end
      doc = Nokogiri::XML(xml)
      id_node = doc.at_xpath("//vehicle/id")
      expect(id_node.text).to eq("12345")
      expect(id_node["source"]).to eq("DMS")
    end

    it "accepts optional sequence attribute" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        id "12345", source: "DMS", sequence: 1
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/id")["sequence"]).to eq("1")
    end

    it "allows multiple ids" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        id "ID1", source: "DMS"
        id "ID2", source: "CRM"
        id "ID3", source: "Web"
      end
      doc = Nokogiri::XML(xml)
      ids = doc.xpath("//vehicle/id")
      expect(ids.size).to eq(3)
    end
  end

  describe "odometer element" do
    it "renders with value only" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        odometer 50_000
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/odometer").text).to eq("50000")
    end

    it "renders with all attributes" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        odometer 50_000, status: :original, units: :mi
      end
      doc = Nokogiri::XML(xml)
      odo = doc.at_xpath("//vehicle/odometer")
      expect(odo.text).to eq("50000")
      expect(odo["status"]).to eq("original")
      expect(odo["units"]).to eq("mi")
    end

    %i[unknown rolledover replaced original].each do |status|
      it "accepts status :#{status}" do
        xml = build_with_vehicle do
          year 2024
          make "T"
          model "M"
          odometer 100, status: status
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//vehicle/odometer")["status"]).to eq(status.to_s)
      end
    end

    it "rejects invalid odometer status" do
      expect do
        build_with_vehicle do
          year 2024
          make "T"
          model "M"
          odometer 100, status: :broken
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for status/)
    end

    %i[km mi].each do |unit|
      it "accepts units :#{unit}" do
        xml = build_with_vehicle do
          year 2024
          make "T"
          model "M"
          odometer 100, units: unit
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//vehicle/odometer")["units"]).to eq(unit.to_s)
      end
    end

    it "rejects invalid odometer units" do
      expect do
        build_with_vehicle do
          year 2024
          make "T"
          model "M"
          odometer 100, units: :yards
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for units/)
    end

    it "replaces existing odometer" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        odometer 10_000
        odometer 50_000, status: :original
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//vehicle/odometer").size).to eq(1)
      expect(doc.at_xpath("//vehicle/odometer").text).to eq("50000")
    end
  end

  describe "imagetag element" do
    it "renders with URL only" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        imagetag "http://example.com/car.jpg"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/imagetag").text).to eq("http://example.com/car.jpg")
    end

    it "renders with all attributes" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        imagetag "http://example.com/car.jpg", width: 800, height: 600, alttext: "Front View"
      end
      doc = Nokogiri::XML(xml)
      img = doc.at_xpath("//vehicle/imagetag")
      expect(img.text).to eq("http://example.com/car.jpg")
      expect(img["width"]).to eq("800")
      expect(img["height"]).to eq("600")
      expect(img["alttext"]).to eq("Front View")
    end

    it "replaces existing imagetag" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        imagetag "http://old.jpg"
        imagetag "http://new.jpg"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//vehicle/imagetag").size).to eq(1)
      expect(doc.at_xpath("//vehicle/imagetag").text).to eq("http://new.jpg")
    end

    it "handles special characters in URL" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        imagetag "http://example.com/car.jpg?size=large&format=jpg"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/imagetag").text).to include("size=large")
    end
  end

  describe "price element" do
    %i[quote offer msrp invoice call appraisal asking].each do |type|
      it "accepts type :#{type}" do
        xml = build_with_vehicle do
          year 2024
          make "T"
          model "M"
          price 25_000, type: type
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//vehicle/price")["type"]).to eq(type.to_s)
      end
    end

    it "rejects invalid type" do
      expect do
        build_with_vehicle do
          year 2024
          make "T"
          model "M"
          price 25_000, type: :clearance
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for type/)
    end

    %i[absolute relative percentage].each do |delta|
      it "accepts delta :#{delta}" do
        xml = build_with_vehicle do
          year 2024
          make "T"
          model "M"
          price 1000, delta: delta
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//vehicle/price")["delta"]).to eq(delta.to_s)
      end
    end

    %i[msrp invoice].each do |rel|
      it "accepts relativeto :#{rel}" do
        xml = build_with_vehicle do
          year 2024
          make "T"
          model "M"
          price 1000, relativeto: rel
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//vehicle/price")["relativeto"]).to eq(rel.to_s)
      end
    end

    it "validates currency against ISO 4217" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        price 25_000, currency: "USD"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/price")["currency"]).to eq("USD")
    end

    it "rejects invalid currency" do
      expect do
        build_with_vehicle do
          year 2024
          make "T"
          model "M"
          price 25_000, currency: "XYZ"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for currency/)
    end

    it "renders with all attributes" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        price 25_000, type: :msrp, currency: "USD", delta: :absolute, source: "DMS"
      end
      doc = Nokogiri::XML(xml)
      p = doc.at_xpath("//vehicle/price")
      expect(p.text).to eq("25000")
      expect(p["type"]).to eq("msrp")
      expect(p["currency"]).to eq("USD")
      expect(p["delta"]).to eq("absolute")
      expect(p["source"]).to eq("DMS")
    end
  end

  describe "option element" do
    it "renders optionname" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        option do
          optionname "Sunroof"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/option/optionname").text).to eq("Sunroof")
    end

    it "renders manufacturercode" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        option do
          manufacturercode "ABC123"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/option/manufacturercode").text).to eq("ABC123")
    end

    it "renders stock" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        option do
          stock "STK001"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/option/stock").text).to eq("STK001")
    end

    it "accepts weighting in valid range (-100 to 100)" do
      [-100, -50, 0, 50, 100].each do |w|
        xml = build_with_vehicle do
          year 2024
          make "T"
          model "M"
          option { weighting w }
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//vehicle/option/weighting").text).to eq(w.to_s)
      end
    end

    it "rejects weighting below -100" do
      expect do
        build_with_vehicle do
          year 2024
          make "T"
          model "M"
          option { weighting(-101) }
        end
      end.to raise_error(AdfBuilder::Error, /Weighting must be between -100 and 100/)
    end

    it "rejects weighting above 100" do
      expect do
        build_with_vehicle do
          year 2024
          make "T"
          model "M"
          option { weighting 101 }
        end
      end.to raise_error(AdfBuilder::Error, /Weighting must be between -100 and 100/)
    end

    it "renders option with price" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        option do
          optionname "Premium Audio"
          price 1500, type: :msrp, currency: "USD"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/option/price").text).to eq("1500")
      expect(doc.at_xpath("//vehicle/option/price")["type"]).to eq("msrp")
    end

    it "allows multiple options" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        option { optionname "Option A" }
        option { optionname "Option B" }
        option { optionname "Option C" }
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//vehicle/option").size).to eq(3)
    end
  end

  describe "colorcombination element" do
    it "renders interiorcolor" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        colorcombination do
          interiorcolor "Black"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/colorcombination/interiorcolor").text).to eq("Black")
    end

    it "renders exteriorcolor" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        colorcombination do
          exteriorcolor "Red"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/colorcombination/exteriorcolor").text).to eq("Red")
    end

    it "renders preference" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        colorcombination do
          preference 1
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//vehicle/colorcombination/preference").text).to eq("1")
    end

    it "renders complete colorcombination" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        colorcombination do
          interiorcolor "Tan"
          exteriorcolor "Blue"
          preference 2
        end
      end
      doc = Nokogiri::XML(xml)
      cc = doc.at_xpath("//vehicle/colorcombination")
      expect(cc.at_xpath("interiorcolor").text).to eq("Tan")
      expect(cc.at_xpath("exteriorcolor").text).to eq("Blue")
      expect(cc.at_xpath("preference").text).to eq("2")
    end

    it "allows multiple colorcombinations" do
      xml = build_with_vehicle do
        year 2024
        make "T"
        model "M"
        colorcombination do
          interiorcolor "Black"
          exteriorcolor "White"
        end
        colorcombination do
          interiorcolor "Beige"
          exteriorcolor "Silver"
        end
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//vehicle/colorcombination").size).to eq(2)
    end
  end

  describe "multiple vehicles in prospect" do
    it "maintains separate vehicle configurations" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "Toyota"
            model "Camry"
            status :new
          end
          vehicle do
            year 2020
            make "Honda"
            model "Civic"
            status :used
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
      vehicles = doc.xpath("//vehicle")
      expect(vehicles[0]["status"]).to eq("new")
      expect(vehicles[1]["status"]).to eq("used")
    end
  end
end
