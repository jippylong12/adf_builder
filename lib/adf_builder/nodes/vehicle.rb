# frozen_string_literal: true

module AdfBuilder
  module Nodes
    class Vehicle < Node
      validates_inclusion_of :status, in: %i[new used]

      def year(value)
        @attributes[:year] = value
      end

      def make(value)
        @attributes[:make] = value
      end

      def model(value)
        @attributes[:model] = value
      end

      def status(value)
        @attributes[:status] = value
      end
    end
  end
end
