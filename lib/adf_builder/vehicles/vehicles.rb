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
      valid, vehicle = valid_vehicle?(index)
      if valid
        params.merge!({valid_values: VALID_VALUES, valid_parameters: VALID_PARAMETERS})
        AdfBuilder::Builder.update_node(vehicle, 'odometer', value, params)
      end
    end

    def update_condition(index, value)
      valid, vehicle = valid_vehicle?(index)
      if valid and CONDITIONS.include? value
        AdfBuilder::Builder.update_node(vehicle, 'condition', value)
      end
    end

    def update_imagetag(index, value, params={})
      valid, vehicle = valid_vehicle?(index)
      if valid
        params.merge!({valid_values: VALID_VALUES, valid_parameters: VALID_PARAMETERS})
        AdfBuilder::Builder.update_node(vehicle, 'imagetag', value, params)
      end
    end

    def update_tags_with_free_text(index, tags)
      valid, vehicle = valid_vehicle?(index)
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

    # check to see if we have a vehicle at this index
    def valid_vehicle?(index)
      if @prospect.vehicle(index).nil?
        return false,nil
      else
        return true, @prospect.vehicle(index)
      end
    end
  end
end