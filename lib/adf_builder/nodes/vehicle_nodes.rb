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

    class Price < Node
      validates_inclusion_of :type, in: %i[quote offer msrp invoice call appraisal asking]
      validates_inclusion_of :delta, in: %i[absolute relative percentage]
      validates_inclusion_of :relativeto, in: %i[msrp invoice]

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

      def method(value)
        add_child(GenericNode.new(:method, {}, value))
      end

      def amount(value, type: :total, limit: :maximum, currency: nil)
        add_child(Amount.new(value, type: type, limit: limit, currency: currency))
      end

      def balance(value, type: :finance, currency: nil)
        add_child(Balance.new(value, type: type, currency: currency))
      end
    end

    class Option < Node
      def initialize
        super
        @tag_name = :option
      end

      def optionname(value)
        add_child(GenericNode.new(:optionname, {}, value))
      end

      def manufacturercode(value)
        add_child(GenericNode.new(:manufacturercode, {}, value))
      end

      def stock(value)
        add_child(GenericNode.new(:stock, {}, value))
      end

      def weighting(value)
        add_child(GenericNode.new(:weighting, {}, value))
      end

      def price(value, **attrs)
        add_child(Price.new(value, **attrs))
      end
    end

    class ColorCombination < Node
      def initialize
        super
        @tag_name = :colorcombination
      end

      def interiorcolor(value)
        add_child(GenericNode.new(:interiorcolor, {}, value))
      end

      def exteriorcolor(value)
        add_child(GenericNode.new(:exteriorcolor, {}, value))
      end

      def preference(value)
        add_child(GenericNode.new(:preference, {}, value))
      end
    end
  end
end
