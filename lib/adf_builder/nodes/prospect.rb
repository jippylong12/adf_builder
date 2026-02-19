# frozen_string_literal: true

module AdfBuilder
  module Nodes
    class Prospect < Node
      validates_inclusion_of :status, in: %i[new resend]

      def initialize
        super
        @tag_name = :prospect
        @attributes[:status] = :new
      end

      def validate!
        super
        # DTD: (id*, requestdate, vehicle+, customer, vendor, provider?)
        requestdate_count = @children.count { |c| c.tag_name == :requestdate }
        unless requestdate_count == 1
          raise AdfBuilder::Error, "Prospect must have a requestdate"
        end

        vehicle_count = @children.count { |c| c.is_a?(Vehicle) }
        unless vehicle_count >= 1
          raise AdfBuilder::Error, "Prospect must have at least one vehicle"
        end

        customer_count = @children.count { |c| c.is_a?(Customer) }
        unless customer_count == 1
          raise AdfBuilder::Error, "Prospect must have exactly one customer"
        end

        vendor_count = @children.count { |c| c.is_a?(Vendor) }
        unless vendor_count == 1
          raise AdfBuilder::Error, "Prospect must have exactly one vendor"
        end

        provider_count = @children.count { |c| c.is_a?(Provider) }
        return if provider_count <= 1

        raise AdfBuilder::Error, "Prospect can have at most one provider"
      end

      def request_date(date)
        remove_children(:requestdate)
        add_child(GenericNode.new(:requestdate, {}, date))
      end

      def status(value)
        @attributes[:status] = value
      end

      def id(value, sequence: nil, source: nil)
        add_child(Id.new(value, sequence: sequence, source: source))
      end

      def vehicle(&block)
        vehicle = Vehicle.new
        vehicle.instance_eval(&block) if block_given?
        add_child(vehicle)
      end

      def customer(&block)
        remove_children(:customer)
        customer = Customer.new
        customer.instance_eval(&block) if block_given?
        add_child(customer)
      end

      def vendor(&block)
        remove_children(:vendor)
        vendor = Vendor.new
        vendor.instance_eval(&block) if block_given?
        add_child(vendor)
      end

      def provider(&block)
        remove_children(:provider)
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
