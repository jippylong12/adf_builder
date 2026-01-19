# frozen_string_literal: true

module AdfBuilder
  module Nodes
    class Node
      include AdfBuilder::Validations

      attr_reader :children, :attributes, :value, :tag_name

      def initialize
        @children = []
        @attributes = {}
        @value = nil
        @tag_name = nil
      end

      def add_child(node)
        @children << node
      end

      def remove_children(tag_name)
        @children.reject! { |c| c.tag_name == tag_name }
      end

      def to_xml
        Serializer.to_xml(self)
      end

      def method_missing(method_name, *args, &block)
        # Support for dynamic/custom tags
        # usage: custom_tag "value", attr: "val"
        # usage: custom_tag { ... }

        tag_name = method_name
        attributes = args.last.is_a?(Hash) ? args.last : {}
        value = args.first unless args.first == attributes

        # If it's a block, it's a structural node
        if block_given?
          node = GenericNode.new(tag_name, attributes)
          node.instance_eval(&block)
          add_child(node)
        # If it has a value, it's a leaf node/element
        elsif value
          node = GenericNode.new(tag_name, attributes, value)
          add_child(node)
        else
          # Just a tag with attributes? e.g. <flag active="true"/>
          node = GenericNode.new(tag_name, attributes)
          add_child(node)
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        true
      end
    end

    class GenericNode < Node
      def initialize(tag_name, attributes = {}, value = nil)
        super()
        @tag_name = tag_name
        @attributes = attributes
        @value = value
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
