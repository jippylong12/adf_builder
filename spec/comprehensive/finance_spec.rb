# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe AdfBuilder::Nodes::Finance do
  def build_with_finance(&block)
    AdfBuilder.build do
      prospect do
        request_date Time.now
        vehicle do
          year 2024
          make "T"
          model "M"
          finance(&block)
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
  end

  describe "method element" do
    %w[cash finance lease].each do |method|
      it "accepts method '#{method}'" do
        xml = build_with_finance do
          method method
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//finance/method").text).to eq(method)
      end
    end

    it "rejects invalid method" do
      expect do
        build_with_finance do
          method "steal"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid finance method/)
    end

    it "rejects arbitrary method value" do
      expect do
        build_with_finance do
          method "rent"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid finance method/)
    end

    it "replaces existing method" do
      xml = build_with_finance do
        method "cash"
        method "lease"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//finance/method").size).to eq(1)
      expect(doc.at_xpath("//finance/method").text).to eq("lease")
    end
  end

  describe "amount element" do
    %i[downpayment monthly total].each do |type|
      it "accepts type :#{type}" do
        xml = build_with_finance do
          amount 5000, type: type
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//finance/amount")["type"]).to eq(type.to_s)
      end
    end

    it "rejects invalid amount type" do
      expect do
        build_with_finance do
          amount 5000, type: :weekly
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for type/)
    end

    %i[maximum minimum exact].each do |limit|
      it "accepts limit :#{limit}" do
        xml = build_with_finance do
          amount 5000, limit: limit
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//finance/amount")["limit"]).to eq(limit.to_s)
      end
    end

    it "rejects invalid limit" do
      expect do
        build_with_finance do
          amount 5000, limit: :approximate
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for limit/)
    end

    it "validates currency against ISO 4217" do
      %w[USD EUR GBP JPY CAD AUD].each do |currency|
        xml = build_with_finance do
          amount 5000, currency: currency
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//finance/amount")["currency"]).to eq(currency)
      end
    end

    it "rejects invalid currency" do
      expect do
        build_with_finance do
          amount 5000, currency: "FAKE"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for currency/)
    end

    it "renders amount with all attributes" do
      xml = build_with_finance do
        amount 5000, type: :downpayment, limit: :maximum, currency: "USD"
      end
      doc = Nokogiri::XML(xml)
      amt = doc.at_xpath("//finance/amount")
      expect(amt.text).to eq("5000")
      expect(amt["type"]).to eq("downpayment")
      expect(amt["limit"]).to eq("maximum")
      expect(amt["currency"]).to eq("USD")
    end

    it "allows multiple amounts" do
      xml = build_with_finance do
        amount 5000, type: :downpayment
        amount 400, type: :monthly
        amount 30_000, type: :total
      end
      doc = Nokogiri::XML(xml)
      expect(doc.xpath("//finance/amount").size).to eq(3)
    end
  end

  describe "balance element" do
    %i[finance residual].each do |type|
      it "accepts type :#{type}" do
        xml = build_with_finance do
          balance 25_000, type: type
        end
        doc = Nokogiri::XML(xml)
        expect(doc.at_xpath("//finance/balance")["type"]).to eq(type.to_s)
      end
    end

    it "rejects invalid balance type" do
      expect do
        build_with_finance do
          balance 25_000, type: :total
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for type/)
    end

    it "validates currency against ISO 4217" do
      xml = build_with_finance do
        balance 25_000, currency: "EUR"
      end
      doc = Nokogiri::XML(xml)
      expect(doc.at_xpath("//finance/balance")["currency"]).to eq("EUR")
    end

    it "rejects invalid currency" do
      expect do
        build_with_finance do
          balance 25_000, currency: "LOL"
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for currency/)
    end

    it "renders balance with all attributes" do
      xml = build_with_finance do
        balance 25_000, type: :finance, currency: "USD"
      end
      doc = Nokogiri::XML(xml)
      bal = doc.at_xpath("//finance/balance")
      expect(bal.text).to eq("25000")
      expect(bal["type"]).to eq("finance")
      expect(bal["currency"]).to eq("USD")
    end
  end

  describe "complete finance block" do
    it "renders all elements" do
      xml = build_with_finance do
        method "finance"
        amount 5000, type: :downpayment, limit: :exact, currency: "USD"
        amount 450, type: :monthly, limit: :maximum
        balance 30_000, type: :finance
      end

      doc = Nokogiri::XML(xml)
      fin = doc.at_xpath("//finance")
      expect(fin.at_xpath("method").text).to eq("finance")
      expect(fin.xpath("amount").size).to eq(2)
      expect(fin.at_xpath("balance").text).to eq("30000")
    end

    it "finance replaces existing when called multiple times" do
      xml = AdfBuilder.build do
        prospect do
          request_date Time.now
          vehicle do
            year 2024
            make "T"
            model "M"
            finance do
              method "cash"
            end
            finance do
              method "lease"
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
      expect(doc.xpath("//vehicle/finance").size).to eq(1)
      expect(doc.at_xpath("//vehicle/finance/method").text).to eq("lease")
    end
  end
end
