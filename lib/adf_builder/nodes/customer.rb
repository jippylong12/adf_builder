# frozen_string_literal: true

module AdfBuilder
  module Nodes
    class Customer < Node
      def contact(&block)
        contact = Contact.new
        contact.instance_eval(&block) if block_given?
        add_child(contact)
      end
    end

    class Contact < Node
      def name(value, part: nil, type: nil)
        name_node = Name.new(value, part: part, type: type)
        add_child(name_node)
      end

      def email(value)
        add_child(SimpleElement.new(:email, value))
      end

      def phone(value, type: nil)
        phone_node = Phone.new(value, type: type)
        add_child(phone_node)
      end
    end

    class Name < Node
      def initialize(value, part: nil, type: nil)
        super()
        @value = value
        @attributes[:part] = part if part
        @attributes[:type] = type if type
      end
      attr_reader :value
    end

    class Phone < Node
      def initialize(value, type: nil)
        super()
        @value = value
        @attributes[:type] = type if type
      end
      attr_reader :value
    end

    # Simple Helper for tags like <email>foo</email>
    class SimpleElement < Node
      def initialize(tag_name, value)
        super()
        @tag_name = tag_name
        @value = value
      end
      attr_reader :value, :tag_name
    end
  end
end
