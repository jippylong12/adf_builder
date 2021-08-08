module AdfBuilder
  class ColorCombinations

    FREE_TEXT_OPTIONAL_TAGS = [:interiorcolor, :exteriorcolor, :preference]

    def initialize(vehicle)
      @vehicle = vehicle
      @color_combination = nil
    end

    def add(interior_color, exterior_color, preference)
      @color_combination = Ox::Element.new('colorcombination')
      @color_combination <<
        (Ox::Element.new('interiorcolor') << interior_color) <<
        (Ox::Element.new('exteriorcolor') << exterior_color) <<
        (Ox::Element.new('preference') << preference.to_s)
       @vehicle << @color_combination
    end

    def update_tags(index, tags)
      valid, vehicle = AdfBuilder::Builder.valid_child?(@vehicle,'colorcombination', index)
      if valid
        tags.each do |key, value|
          if FREE_TEXT_OPTIONAL_TAGS.include? key.to_sym
            AdfBuilder::Builder.update_node(vehicle, key, value)
          end
        end
      end
    end
  end
end