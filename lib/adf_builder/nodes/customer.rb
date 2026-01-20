# frozen_string_literal: true

module AdfBuilder
  module Nodes
    class Customer < Node
      def initialize
        super
        @tag_name = :customer
      end

      def contact(&block)
        remove_children(:contact)
        contact = Contact.new
        contact.instance_eval(&block) if block_given?
        add_child(contact)
      end

      def id(value, sequence: nil, source: nil)
        # id* is multiple
        add_child(Id.new(value, sequence: sequence, source: source))
      end

      def timeframe(&block)
        remove_children(:timeframe)
        tf = Timeframe.new
        tf.instance_eval(&block) if block_given?
        add_child(tf)
      end

      def comments(value)
        remove_children(:comments)
        add_child(GenericNode.new(:comments, {}, value))
      end
    end

    class Timeframe < Node
      def initialize
        super
        @tag_name = :timeframe
      end

      def validate!
        super
        # If timeframe is present, earliestdate or latestdate is required
        return if @children.any? { |c| %i[earliestdate latestdate].include?(c.tag_name) }

        raise AdfBuilder::Error, "Timeframe must have at least one of earliestdate or latestdate"
      end

      def description(value)
        remove_children(:description)
        add_child(GenericNode.new(:description, {}, value))
      end

      def earliestdate(value)
        validate_iso8601(value)
        remove_children(:earliestdate)
        add_child(GenericNode.new(:earliestdate, {}, value))
      end

      def latestdate(value)
        validate_iso8601(value)
        remove_children(:latestdate)
        add_child(GenericNode.new(:latestdate, {}, value))
      end

      private

      def validate_iso8601(value)
        # Simple ISO 8601 check (YYYY-MM-DDT...)
        # Using a basic regex for now or standard library
        require "date"
        Date.iso8601(value.to_s)
      rescue ArgumentError
        raise AdfBuilder::Error, "Invalid ISO 8601 date: #{value}"
      end
    end
  end
end
