module AdfBuilder
  class Customer
    def initialize(prospect)
      @customer = Ox::Element.new('customer')
      @contact = nil

      prospect << @customer
    end

    def contact
      @contact
    end

    def add(name, opts={})
      @contact = Contact.new(@customer, name, opts)
    end

    def add_id(index, value, source=nil, sequence=1)
      if @prospect.locate("customer").empty?
        false
      else
        Id.new.add(@prospect.customer(index), value, source, sequence)
      end
    end

  end
end