module AdfBuilder
  class Prospect
    STATUSES = {
      new: :new,
      resend: :resend
    }

    def initialize(doc)
      @doc = doc
      @doc.adf << Ox::Element.new("prospect")
      @prospect = @doc.adf.prospect
      @prospect[:status] = STATUSES[:new]


      @request_date = RequestDate.new(@prospect)
      @vehicles = Vehicles.new(@prospect)
      @customer = Customer.new(@prospect)
      @vendor = Vendor.new(@prospect)
    end

    def request_date
      @request_date
    end

    def vehicles
      @vehicles
    end

    def customer
      @customer
    end

    def vendor
      @vendor
    end

    # set status to renew
    def set_renew
      @prospect[:status] = STATUSES[:resend]
    end

    def add_id(value, source=nil, sequence=1)
      Id.new.add(@prospect, value, source, sequence)
    end
  end
end