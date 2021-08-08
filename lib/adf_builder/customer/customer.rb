module AdfBuilder
  class Customer
    def initialize(prospect)
      @customer = Ox::Element.new('customer')
      @contact = nil

      prospect << @customer
    end

    def add(name)
      @contact = Contact.new(@customer, name)
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