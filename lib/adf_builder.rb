# frozen_string_literal: true

require 'ox'
require_relative "adf_builder/version"

# CUSTOMER
require_relative 'adf_builder/customer/customer'

# BASE
require_relative 'adf_builder/base/base'
require_relative 'adf_builder/base/prospect'
require_relative 'adf_builder/base/request_date'

# SHARED
require_relative 'adf_builder/shared/id'
require_relative 'adf_builder/shared/contact'

# VEHICLES
require_relative 'adf_builder/vehicles/vehicles'

# VENDER
require_relative 'adf_builder/vendor/vendor'

module AdfBuilder
  class Error < StandardError; end
  class Builder
    def initialize
      @doc = self.init_doc
      @base = Base.new(@doc)
    end

    def prospect
      @base.prospect
    end

    # output the XML
    def to_xml
      Ox.dump(@doc, {})
    end

    # def an example of minimal XML taken from ADF spec file http://adfxml.info/adf_spec.pdf
    def minimal_lead
      prospect = Ox::Element.new("prospect")

      request_date = Ox::Element.new("requestdate")
      request_date << '2000-03-30T15:30:20-08:00'

      vehicle = Ox::Element.new('vehicle')
      year = Ox::Element.new("year")
      year << '1999'

      make = Ox::Element.new("make")
      make << 'Chevrolet'

      model = Ox::Element.new("model")
      model << 'Blazer'

      vehicle << year << make << model

      customer = Ox::Element.new("customer")

      contact = Ox::Element.new("contact")

      name = Ox::Element.new("name")
      name[:part] = 'full'
      name << 'John Doe'

      phone = Ox::Element.new("phone")
      phone << '393-999-3922'

      contact << name << phone
      customer << contact

      vendor = Ox::Element.new("vendor")

      contact = Ox::Element.new("contact")
      name = Ox::Element.new("name")
      name[:part] = 'full'
      name << 'Acura of Bellevue'

      contact << name
      vendor << contact

      prospect << request_date << vehicle << customer << vendor
      @doc.remove_children_by_path("adf/prospect")
      @doc.adf << prospect
      Ox.dump(@doc, {})
    end

    # go back to the initial structure
    def reset_doc
      @doc.adf.prospect.remove_children_by_path("*")
    end

    # all the files will start with this same header
    def init_doc
      doc = Ox::Document.new
      instruct = Ox::Instruct.new('ADF')
      instruct[:version] = '1.0'
      doc << instruct
      doc << Ox::Raw.new("\n")
      instruct = Ox::Instruct.new(:xml)
      instruct[:version] = '1.0'
      doc << instruct
      adf = Ox::Element.new("adf")
      doc << adf
      doc
    end
  end
end
