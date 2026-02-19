# frozen_string_literal: true

module AdfBuilder
  module Nodes
    class Odometer < Node
      validates_inclusion_of :status, in: %i[unknown rolledover replaced original]
      validates_inclusion_of :units, in: %i[km mi]

      def initialize(value, status: nil, units: nil)
        super()
        @tag_name = :odometer
        @value = value
        @attributes[:status] = status if status
        @attributes[:units] = units if units
      end
    end

    class ImageTag < Node
      def initialize(value, width: nil, height: nil, alttext: nil)
        super()
        @tag_name = :imagetag
        @value = value
        @attributes[:width] = width if width
        @attributes[:height] = height if height
        @attributes[:alttext] = alttext if alttext
      end
    end

    class Condition < Node
      VALID_VALUES = %w[excellent good fair poor unknown].freeze

      def initialize(value)
        super()
        @tag_name = :condition
        unless VALID_VALUES.include?(value.to_s.downcase)
          raise AdfBuilder::Error, "Invalid condition: #{value}. Must be one of: #{VALID_VALUES.join(", ")}"
        end

        @value = value
      end
    end

    class Weighting < Node
      def initialize(value)
        super()
        @tag_name = :weighting
        int_val = value.to_i
        unless int_val.between?(-100, 100)
          raise AdfBuilder::Error, "Weighting must be between -100 and 100. Got: #{value}"
        end

        @value = value
      end
    end

    class FinanceMethod < Node
      VALID_VALUES = %w[cash finance lease].freeze

      def initialize(value)
        super()
        @tag_name = :method
        unless VALID_VALUES.include?(value.to_s.downcase)
          raise AdfBuilder::Error, "Invalid finance method: #{value}. Must be one of: #{VALID_VALUES.join(", ")}"
        end

        @value = value
      end
    end

    # Common ISO 4217 codes (Top valid ones per spec/common usage)
    # Keeping it as a constant for reuse.
    # This list can be expanded but covers major currencies.
    ISO_4217 = %w[
      USD EUR GBP JPY AUD CAD CHF CNY SEK NZD
      MXN SGD HKD NOK KRW TRY RUB INR BRL ZAR
      DKK PLN TWD THB IDR HUF CZK ILS CLP PHP
      AED COP SAR MYR RON PEN VND NGN
    ].freeze

    class Price < Node
      validates_inclusion_of :type, in: %i[quote offer msrp invoice call appraisal asking]
      validates_inclusion_of :delta, in: %i[absolute relative percentage]
      validates_inclusion_of :relativeto, in: %i[msrp invoice]
      validates_inclusion_of :currency, in: ISO_4217

      def initialize(value, type: :quote, currency: nil, delta: nil, relativeto: nil, source: nil)
        super()
        @tag_name = :price
        @value = value
        @attributes[:type] = type
        @attributes[:currency] = currency if currency
        @attributes[:delta] = delta if delta
        @attributes[:relativeto] = relativeto if relativeto
        @attributes[:source] = source if source
      end
    end

    class Amount < Node
      validates_inclusion_of :type, in: %i[downpayment monthly total]
      validates_inclusion_of :limit, in: %i[maximum minimum exact]
      validates_inclusion_of :currency, in: ISO_4217

      def initialize(value, type: :total, limit: :maximum, currency: nil)
        super()
        @tag_name = :amount
        @value = value
        @attributes[:type] = type
        @attributes[:limit] = limit
        @attributes[:currency] = currency if currency
      end
    end

    class Balance < Node
      validates_inclusion_of :type, in: %i[finance residual]
      validates_inclusion_of :currency, in: ISO_4217

      def initialize(value, type: :finance, currency: nil)
        super()
        @tag_name = :balance
        @value = value
        @attributes[:type] = type
        @attributes[:currency] = currency if currency
      end
    end

    class Finance < Node
      def initialize
        super
        @tag_name = :finance
      end

      def validate!
        super
        method_count = @children.count { |c| c.tag_name == :method }
        amount_count = @children.count { |c| c.tag_name == :amount }
        balance_count = @children.count { |c| c.tag_name == :balance }

        unless method_count == 1
          raise AdfBuilder::Error, "Finance must have exactly one method"
        end
        unless amount_count >= 1
          raise AdfBuilder::Error, "Finance must have at least one amount"
        end
        return if balance_count <= 1

        raise AdfBuilder::Error, "Finance can have at most one balance"
      end

      def method(value)
        remove_children(:method)
        add_child(FinanceMethod.new(value))
      end

      def amount(value, type: :total, limit: :maximum, currency: nil)
        add_child(Amount.new(value, type: type, limit: limit, currency: currency))
      end

      def balance(value, type: :finance, currency: nil)
        remove_children(:balance)
        add_child(Balance.new(value, type: type, currency: currency))
      end
    end

    class Option < Node
      def initialize
        super
        @tag_name = :option
      end

      def validate!
        super
        optionname_count = @children.count { |c| c.tag_name == :optionname }
        weighting_count = @children.count { |c| c.tag_name == :weighting }
        manufacturercode_count = @children.count { |c| c.tag_name == :manufacturercode }
        stock_count = @children.count { |c| c.tag_name == :stock }
        price_count = @children.count { |c| c.tag_name == :price }

        unless optionname_count == 1
          raise AdfBuilder::Error, "Option must have exactly one optionname"
        end
        unless weighting_count == 1
          raise AdfBuilder::Error, "Option must have exactly one weighting"
        end
        if manufacturercode_count > 1
          raise AdfBuilder::Error, "Option can have at most one manufacturercode"
        end
        if stock_count > 1
          raise AdfBuilder::Error, "Option can have at most one stock"
        end
        return if price_count <= 1

        raise AdfBuilder::Error, "Option can have at most one price"
      end

      def optionname(value)
        remove_children(:optionname)
        add_child(GenericNode.new(:optionname, {}, value))
      end

      def manufacturercode(value)
        remove_children(:manufacturercode)
        add_child(GenericNode.new(:manufacturercode, {}, value))
      end

      def stock(value)
        remove_children(:stock)
        add_child(GenericNode.new(:stock, {}, value))
      end

      def weighting(value)
        remove_children(:weighting)
        add_child(Weighting.new(value))
      end

      def price(value, **attrs)
        remove_children(:price)
        add_child(Price.new(value, **attrs))
      end
    end

    class ColorCombination < Node
      def initialize
        super
        @tag_name = :colorcombination
      end

      def validate!
        super
        interior_count = @children.count { |c| c.tag_name == :interiorcolor }
        exterior_count = @children.count { |c| c.tag_name == :exteriorcolor }
        preference_count = @children.count { |c| c.tag_name == :preference }

        if interior_count.zero? && exterior_count.zero?
          raise AdfBuilder::Error, "ColorCombination must include interiorcolor or exteriorcolor"
        end
        if interior_count > 1
          raise AdfBuilder::Error, "ColorCombination can have at most one interiorcolor"
        end
        if exterior_count > 1
          raise AdfBuilder::Error, "ColorCombination can have at most one exteriorcolor"
        end
        return if preference_count == 1

        raise AdfBuilder::Error, "ColorCombination must have exactly one preference"
      end

      def interiorcolor(value)
        remove_children(:interiorcolor)
        add_child(GenericNode.new(:interiorcolor, {}, value))
      end

      def exteriorcolor(value)
        remove_children(:exteriorcolor)
        add_child(GenericNode.new(:exteriorcolor, {}, value))
      end

      def preference(value)
        remove_children(:preference)
        add_child(GenericNode.new(:preference, {}, value))
      end
    end
  end
end
