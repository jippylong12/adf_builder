# frozen_string_literal: true

require "ox"

module AdfBuilder
  class Serializer
    class << self
      def to_xml(root_node)
        new(root_node).to_xml
      end
    end

    def initialize(root_node)
      @root_node = root_node
    end

    def to_xml
      # Validate the entire tree before serializing to ensure data integrity
      @root_node.validate!

      doc = Ox::Document.new(version: "1.0")

      # XML Instruction
      instruct = Ox::Instruct.new(:xml)
      instruct[:version] = "1.0"
      doc << instruct

      # ADF Instruction
      adf_instruct = Ox::Instruct.new("ADF")
      adf_instruct[:version] = "1.0"
      doc << adf_instruct

      # ADF Root Element
      adf = Ox::Element.new("adf")
      doc << adf

      @root_node.children.each do |child|
        serialize_node(child, adf)
      end

      Ox.dump(doc)
    end

    private

    def serialize_node(node, parent_element)
      # Determine element name using tag_name to avoid conflict with DSL methods like 'name'
      # Safest check: Does it have the instance variable set?
      element_name = if node.instance_variable_defined?(:@tag_name) && node.instance_variable_get(:@tag_name)
                       node.instance_variable_get(:@tag_name).to_s
                     else
                       node.class.name.split("::").last.downcase
                     end

      # puts "DEBUG: Serializing #{node.class} as <#{element_name}>"

      element = Ox::Element.new(element_name)

      # Add attributes (XML attributes) or Simple Child Elements
      node.attributes.each do |key, value|
        if attribute?(key)
          element[key] = value.to_s
        else
          # It's a simple child element
          child_el = Ox::Element.new(key.to_s)
          child_el << value.to_s
          element << child_el
        end
      end

      # Add Node-level Text Content (e.g. <name>John</name>)
      element << node.value.to_s if node.respond_to?(:value) && node.value

      # Recursively add children nodes
      node.children.each do |child|
        serialize_node(child, element)
      end

      parent_element << element
    end

    def attribute?(key)
      %i[
        part type status sequence source id valid preferredcontact time
        interest units width height alttext limit currency delta relativeto line
      ].include?(key)
    end
  end
end
