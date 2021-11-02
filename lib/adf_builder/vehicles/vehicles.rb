module AdfBuilder
  class Vehicles
    VALID_PARAMETERS = {
      vehicle: [:interest, :status],
      odometer: [:status, :units],
      imagetag: [:width, :height, :alttext],
    }

    VALID_VALUES = {
      vehicle: {
        interest: %w[buy lease sell trade-in test-drive],
        status: %w[new used]
      },
      odometer: {
        status: %w[unknown rolledover replaced original],
        units: %w[km mi]
      },
      imagetag: {
        width: true,
        height: true,
        alttext: true
      }
    }

    FREE_TEXT_OPTIONAL_TAGS = [:year, :make, :model, :vin, :stock,
      :trim, :doors, :bodystyle, :transmission, :pricecomments, :comments]

    CONDITIONS = %w[excellent good fair poor unknown]

    def initialize(prospect)
      @prospect = prospect
      @color_combinations = []
      @prices = []
    end

    def add_color_combination(v_index, interior_color, exterior_color, preference)
      valid, vehicle = AdfBuilder::Builder.valid_child?(@prospect,'vehicle', v_index)
      if valid
        cc = ColorCombinations.new(vehicle)
        cc.add(interior_color, exterior_color, preference)
        @color_combinations.push(cc)
      end
    end

    def color_combination(index)
      @color_combinations[index]
    end

    def price(index)
      @prices[index]
    end

    def add(year, make, model, params={})
      vehicle = Ox::Element.new('vehicle')

      params.merge!({valid_values: VALID_VALUES, valid_parameters: VALID_PARAMETERS})
      AdfBuilder::Builder.update_params(vehicle, :vehicle, params)

      vehicle << (Ox::Element.new('year') << year.to_s)
      vehicle << (Ox::Element.new('make') << make)
      vehicle << (Ox::Element.new('model') << model)

      @prospect << vehicle
    end

    def update_odometer(index, value, params={})
      valid, vehicle = AdfBuilder::Builder.valid_child?(@prospect,'vehicle', index)
      if valid
        params.merge!({valid_values: VALID_VALUES, valid_parameters: VALID_PARAMETERS})
        AdfBuilder::Builder.update_node(vehicle, 'odometer', value, params)
      end
    end

    def update_condition(index, value)
      valid, vehicle = AdfBuilder::Builder.valid_child?(@prospect,'vehicle', index)
      if valid and CONDITIONS.include? value
        AdfBuilder::Builder.update_node(vehicle, 'condition', value)
      end
    end

    def update_imagetag(index, value, params={})
      valid, vehicle = AdfBuilder::Builder.valid_child?(@prospect,'vehicle', index)
      if valid
        params.merge!({valid_values: VALID_VALUES, valid_parameters: VALID_PARAMETERS})
        AdfBuilder::Builder.update_node(vehicle, 'imagetag', value, params)
      end
    end

    def update_tags_with_free_text(index, tags)
      valid, vehicle = AdfBuilder::Builder.valid_child?(@prospect,'vehicle', index)
      if valid
        tags.each do |key, value|
          if FREE_TEXT_OPTIONAL_TAGS.include? key.to_sym
            AdfBuilder::Builder.update_node(vehicle, key, value)
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

    def add_price(index, value, params={})
      valid, vehicle = AdfBuilder::Builder.valid_child?(@prospect,'vehicle', index)
      if valid
        price = Price.new(vehicle, value, params)
        @prices.push(price)
      end
    end

    def add_comments(index, value)
      valid, vehicle = AdfBuilder::Builder.valid_child?(@prospect,'vehicle', index)
      if valid
        AdfBuilder::Builder.update_node(vehicle, 'comments', value)
      end
    end
  end
end