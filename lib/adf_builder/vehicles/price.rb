# frozen_string_literal: true

module AdfBuilder
  class Price
    VALID_PARAMETERS = {
      price: %i[type currency delta relativeto source]
    }.freeze

    VALID_VALUES = {
      price: {
        type: %w[quote offer msrp invoice call appraisal asking],
        currency: true,
        delta: %w[absolute relative percentage],
        relativeto: %w[msrp invoice],
        source: true
      }
    }.freeze

    def initialize(parent_node, value, params = {})
      @parent_node = parent_node
      params.merge!({ valid_values: VALID_VALUES, valid_parameters: VALID_PARAMETERS })
      validate_currency(params)
      AdfBuilder::Builder.update_node(@parent_node, :price, value, params)
      @price = @parent_node.price
    end

    def update(value, params = {})
      params.merge!({ valid_values: VALID_VALUES, valid_parameters: VALID_PARAMETERS })
      AdfBuilder::Builder.update_node(@parent_node, :price, value, params)
    end

    def validate_currency(params)
      code = params[:currency]
      return unless code

      json = JSON.parse(File.read("./lib/adf_builder/data/iso-4217-currency-codes.json"))
      codes = json.map { |j| j["Alphabetic_Code"] }.reject(&:nil?)
      return if codes.include? code

      params.delete(:currency)
    end
  end
end
