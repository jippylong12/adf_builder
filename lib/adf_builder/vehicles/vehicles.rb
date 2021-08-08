module AdfBuilder
  class Vehicles
    VALID_PARAMETERS = {
      vehicle: [:interest, :status],
      odometer: [:status, :units],
      imagetag: [:width, :height, :alttext],
    }

    INTEREST_VALUES = {
      buy: 'buy',
      lease: 'lease',
      sell: 'sell',
      trade_in: 'trade-in',
      test_drive: 'test-drive'
    }

    STATUS_VALUES = {
      new: 'new',
      used: 'used'
    }

    FREE_TEXT_OPTIONAL_TAGS = {
      vin: :vin,
      stock: :stock,
      trim: :trim,
      doors: :doors,
      bodystyle: :bodystyle,
      transmission: :transmission,
      pricecomments: :pricecomments,
      comments: :comments
    }

    def initialize(prospect)
      @prospect = prospect
    end

    def add(year, make, model, params={})
      vehicle = Ox::Element.new('vehicle')
      params = whitelabel_opts(params, :vehicle)
      if params[:interest]
        interest = INTEREST_VALUES[params[:interest].to_sym]
        vehicle[:interest] = interest
      end

      if params[:status]
        status = STATUS_VALUES[params[:status].to_sym]
        vehicle[:status] = status
      end


      vehicle << (Ox::Element.new('year') << year.to_s)
      vehicle << (Ox::Element.new('make') << make)
      vehicle << (Ox::Element.new('model') << model)

      @prospect << vehicle
    end

    def add_id(index, value, source=nil, sequence=1)
      if @prospect.locate("vehicle").empty? or @prospect.vehicle(index).nil?
        false
      else
        Id.new.add(@prospect.vehicle(index), value, source, sequence)
      end
    end


    # clear out the opts that don't match valid keys
    def whitelabel_opts(opts, key)
      opts.slice(*VALID_PARAMETERS[key])
    end
  end
end