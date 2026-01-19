# frozen_string_literal: true

module AdfBuilder
  class Vendor
    def initialize(prospect)
      @vendor = Ox::Element.new("vendor")
      @contact = nil
      prospect << @vendor
    end

    attr_reader :contact

    def add(name, contact_name, opts = {})
      @vendor << (Ox::Element.new("vendorname") << name)
      @contact = Contact.new(@vendor, contact_name, opts)
    end

    def add_url(url)
      @vendor.remove_children(@vendor.url) if @vendor.locate("url").size.positive?
      @vendor << (Ox::Element.new("url") << url)
    end

    def add_id(index, value, source = nil, sequence = 1)
      if @prospect.locate("vendor").empty?
        false
      else
        Id.new.add(@prospect.vendor(index), value, source, sequence)
      end
    end
  end
end
