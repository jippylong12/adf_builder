# frozen_string_literal: true

module AdfBuilder
  module Nodes
    class Prospect < Node
      def validate!
        super
        # DTD: (id*, requestdate, vehicle+, customer, vendor, provider?)
        unless @children.any? { |c| c.tag_name == :requestdate }
          raise AdfBuilder::Error, "Prospect must have a requestdate"
        end
        unless @children.any? { |c| c.is_a?(Vehicle) }
          raise AdfBuilder::Error, "Prospect must have at least one vehicle"
        end
        raise AdfBuilder::Error, "Prospect must have a customer" unless @children.any? { |c| c.is_a?(Customer) }
        raise AdfBuilder::Error, "Prospect must have a vendor" unless @children.any? { |c| c.is_a?(Vendor) }
      end

      def request_date(date)
        remove_children(:requestdate)
        add_child(GenericNode.new(:requestdate, {}, date))
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

      def vendor(&block)
        vendor = Vendor.new
        vendor.instance_eval(&block) if block_given?
        add_child(vendor)
      end

      def provider(&block)
        provider = Provider.new
        provider.instance_eval(&block) if block_given?
        add_child(provider)
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
