module AdfBuilder
  class Vendor
    def initialize(prospect)
      @prospect = prospect
    end

    def add(year, make, model, tags={})
      vehicle = Ox::Element.new('vendor')

      if tags[:interest]
        interest = INTEREST_VALUES[tags[:interest].to_sym]
        tags.delete(:interest)
        vehicle[:interest] = interest
      end

      if tags[:status]
        status = STATUS_VALUES[tags[:status].to_sym]
        tags.delete(:status)
        vehicle[:status] = status
      end


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
      if @prospect.locate("vendor").empty?
        false
      else
        Id.new.add(@prospect.vendor(index), value, source, sequence)
      end
    end

  end
end