module AdfBuilder
  class Vehicles
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

    def add(year, make, model, tags={})
      vehicle = Ox::Element.new('vehicle')

      if tags[:interest]
        interest = INTEREST_VALUES[tags[:interest].to_sym]
        tags.delete(:interest)
      else
        interest = INTEREST_VALUES[:buy]
      end

      if tags[:status]
        status = STATUS_VALUES[tags[:status].to_sym]
        tags.delete(:status)
      else
        status = STATUS_VALUES[:new]
      end

      vehicle[:interest] = interest
      vehicle[:status] = status

      vehicle << (Ox::Element.new('year') << year.to_s)
      vehicle << (Ox::Element.new('make') << make)
      vehicle << (Ox::Element.new('model') << model)

      tags.each do |key, value|
        if FREE_TEXT_OPTIONAL_TAGS.include? key.to_sym
          vehicle << (Ox::Element.new(key.to_s) << value)
        end
      end

      @prospect << vehicle
    end

    def add_id(index, value, source=nil, sequence=1)
      if @prospect.locate("vehicle").empty? or @prospect.vehicle(index).nil?
        false
      else
        Id.new.add(@prospect.vehicle(index), value, source, sequence)
      end
    end

  end
end