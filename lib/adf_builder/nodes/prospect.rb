# frozen_string_literal: true

module AdfBuilder
  module Nodes
    class Prospect < Node
      def request_date(date)
        @attributes[:requestdate] = date
      end

      def vehicle(&block)
        vehicle = Vehicle.new
        vehicle.instance_eval(&block) if block_given?
        add_child(vehicle)
      end

      def customer(&block)
        customer = Customer.new
        customer.instance_eval(&block) if block_given?
        add_child(customer)
      end

      # Helpers for Editing
      def vehicles
        @children.select { |c| c.is_a?(Vehicle) }
      end

      def customers
        @children.select { |c| c.is_a?(Customer) }
      end
    end
  end
end
