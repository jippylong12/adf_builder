# frozen_string_literal: true

module AdfBuilder
  module Nodes
    class Node
      include AdfBuilder::Validations

      attr_reader :children, :attributes

      def initialize
        @children = []
        @attributes = {}
      end

      def add_child(node)
        @children << node
      end

      def to_xml
        Serializer.to_xml(self)
      end
    end

    class Root < Node
      # The root context of the builder
      def prospect(&block)
        prospect = Prospect.new
        prospect.instance_eval(&block) if block_given?
        add_child(prospect)
      end

      def first_prospect
        @children.find { |c| c.is_a?(Prospect) }
      end
    end
  end
end
