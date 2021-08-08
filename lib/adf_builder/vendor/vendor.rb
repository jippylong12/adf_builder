module AdfBuilder
  class Vendor
    def initialize(prospect)
      @vendor = Ox::Element.new('vendor')
      @contact = nil
      prospect << @vendor
    end

    def contact
      @contact
    end

    def add(name, contact_name, opts={})
      @vendor << (Ox::Element.new('vendorname') << name)
      @contact = Contact.new(@vendor, contact_name, opts)
    end

    def add_url(url)
      if @vendor.locate("url").size > 0
        @vendor.remove_children(@vendor.url)
      end
      @vendor << (Ox::Element.new('url') << url)
    end

    def add_id(index, value, source=nil, sequence=1)
      if @prospect.locate("vendor").empty?
        false
      else
        Id.new.add(@prospect.vendor(index), value, source, sequence)
      end
    end

  end
end