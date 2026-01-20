# frozen_string_literal: true

module AdfBuilder
  module Nodes
    class Vehicle < Node
      validates_inclusion_of :status, in: %i[new used]
      validates_inclusion_of :interest, in: %i[buy lease sell trade-in test-drive]
      validates_presence_of :year, :make, :model

      def initialize
        super
        @tag_name = :vehicle
        @attributes[:status] = :new
        @attributes[:interest] = :buy
      end

      # Simple Text Elements (Singular)
      # Simple Text Elements (Singular)
      %i[year make model vin stock trim doors bodystyle transmission pricecomments comments].each do |tag|
        define_method(tag) do |value|
          remove_children(tag)
          add_child(GenericNode.new(tag, {}, value))
        end
      end

      def condition(value)
        remove_children(:condition)
        add_child(Condition.new(value))
      end

      def interest(value)
        @attributes[:interest] = value
      end

      def status(value)
        @attributes[:status] = value
      end

      # Complex Elements
      def id(value, sequence: nil, source: nil)
        # id* is multiple, so just add
        add_child(Id.new(value, sequence: sequence, source: source))
      end

      def odometer(value, status: nil, units: nil)
        remove_children(:odometer)
        add_child(Odometer.new(value, status: status, units: units))
      end

      def imagetag(value, width: nil, height: nil, alttext: nil)
        remove_children(:imagetag)
        add_child(ImageTag.new(value, width: width, height: height, alttext: alttext))
      end

      def price(value, **attrs)
        remove_children(:price)
        add_child(Price.new(value, **attrs))
      end

      def option(&block)
        # option* is multiple
        opt = Option.new
        opt.instance_eval(&block) if block_given?
        add_child(opt)
      end

      def finance(&block)
        remove_children(:finance)
        fin = Finance.new
        fin.instance_eval(&block) if block_given?
        add_child(fin)
      end

      def colorcombination(&block)
        # colorcombination* is multiple
        cc = ColorCombination.new
        cc.instance_eval(&block) if block_given?
        add_child(cc)
      end
    end
  end
end
