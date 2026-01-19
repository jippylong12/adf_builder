# frozen_string_literal: true

module AdfBuilder
  class ColorCombinations
    FREE_TEXT_OPTIONAL_TAGS = %i[interiorcolor exteriorcolor preference].freeze

    def initialize(vehicle)
      @vehicle = vehicle
      @color_combination = nil
    end

    def add(interior_color, exterior_color, preference)
      @color_combination = Ox::Element.new("colorcombination")
      @color_combination <<
        (Ox::Element.new("interiorcolor") << interior_color) <<
        (Ox::Element.new("exteriorcolor") << exterior_color) <<
        (Ox::Element.new("preference") << preference.to_s)
      @vehicle << @color_combination
    end

    def update_tags(index, tags)
      valid, vehicle = AdfBuilder::Builder.valid_child?(@vehicle, "colorcombination", index)
      return unless valid

      tags.each do |key, value|
        AdfBuilder::Builder.update_node(vehicle, key, value) if FREE_TEXT_OPTIONAL_TAGS.include? key.to_sym
      end
    end
  end
end
