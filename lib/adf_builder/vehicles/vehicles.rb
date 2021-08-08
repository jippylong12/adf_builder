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

    FREE_TEXT_OPTIONAL_TAGS = [:year, :make, :model, :vin, :stock,
      :trim, :doors, :bodystyle, :transmission, :pricecomments, :comments]

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

    def update_free_text_tags(index, tags)
      if @prospect.vehicle(index).nil?
        return false
      end
      vehicle = @prospect.vehicle(index)
      tags.each do |key, value|
        if FREE_TEXT_OPTIONAL_TAGS.include? key.to_sym
          if vehicle.locate(key.to_s).size > 0
            vehicle.locate(key.to_s).first.replace_text(value)
          else
            vehicle << (Ox::Element.new(key.to_s) << value)
          end
        end
      end
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