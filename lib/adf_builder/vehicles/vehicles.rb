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

      update_params(vehicle, :vehicle, params)

      vehicle << (Ox::Element.new('year') << year.to_s)
      vehicle << (Ox::Element.new('make') << make)
      vehicle << (Ox::Element.new('model') << model)

      @prospect << vehicle
    end

    def update_odometer(index, value, params={})
      valid, vehicle = valid_vehicle?(index)
      if valid
        update_node(vehicle, 'odometer', value, params)
      end
    end

    def update_condition(index, value)
      valid, vehicle = valid_vehicle?(index)
      if valid and CONDITIONS.include? value
        update_node(vehicle, 'condition', value)
      end
    end

    def update_imagetag(index, value, params={})
      valid, vehicle = valid_vehicle?(index)
      if valid
        update_node(vehicle, 'imagetag', value, params)
      end
    end

    def update_tags_with_free_text(index, tags)
      valid, vehicle = valid_vehicle?(index)
      if valid
        tags.each do |key, value|
          if FREE_TEXT_OPTIONAL_TAGS.include? key.to_sym
            update_node(vehicle, key, value)
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
    def whitelabel_params(opts, key)
      opts.slice(*VALID_PARAMETERS[key])
    end

    # check to see if we have a vehicle at this index
    def valid_vehicle?(index)
      if @prospect.vehicle(index).nil?
        return false,nil
      else
        return true, @prospect.vehicle(index)
      end
    end

    # we will either create a new node with the value or replace the one if it is available
    def update_node(vehicle, key, value, params={})
      key = key.to_s
      value = value.to_s
      if vehicle.locate(key).size > 0
        node = vehicle.locate(key).first
        node.replace_text(value)
      else
        node = (Ox::Element.new(key) << value)
        vehicle << node
      end

      update_params(node, key, params)
    end

    # update the params by first checking if they are valid params and then checking if the values are valid if necessary
    def update_params(node, key, params)
      key = key.to_sym
      _params = whitelabel_params(params, key)
      _params.each do |k,v|
        node[k] = v if VALID_VALUES[key][k] == true or VALID_VALUES[key][k].include? v.to_s
      end
    end
  end
end