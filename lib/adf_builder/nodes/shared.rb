# frozen_string_literal: true

module AdfBuilder
  module Nodes
    class Id < Node
      def initialize(value, source:, sequence: nil)
        super()
        raise ArgumentError, "Source is required" if source.nil?

        @tag_name = :id
        @value = value
        @attributes[:sequence] = sequence if sequence
        @attributes[:source] = source
      end
    end

    class Phone < Node
      def initialize(value, type: nil, time: nil, preferredcontact: nil)
        super()
        @tag_name = :phone
        @value = value
        @attributes[:type] = type if type
        @attributes[:time] = time if time
        @attributes[:preferredcontact] = preferredcontact if preferredcontact
      end
    end

    class Email < Node
      def initialize(value, preferredcontact: nil)
        super()
        @tag_name = :email
        @value = value
        @attributes[:preferredcontact] = preferredcontact if preferredcontact
      end
    end

    class Name < Node
      def initialize(value, part: nil, type: nil)
        super()
        @tag_name = :name
        @value = value
        @attributes[:part] = part if part
        @attributes[:type] = type if type
      end
    end

    class Address < Node
      def initialize(type: nil)
        super()
        @tag_name = :address
        @attributes[:type] = type if type
      end

      def street(value, line: nil)
        node = GenericNode.new(:street, { line: line }.compact, value)
        add_child(node)
      end

      # Simple elements
      %i[apartment city regioncode postalcode country].each do |tag|
        define_method(tag) do |value|
          add_child(GenericNode.new(tag, {}, value))
        end
      end
    end

    class Contact < Node
      def initialize(primary_contact: false)
        super()
        @tag_name = :contact
        # primary_contact might be useful for logic but not an attribute
      end

      def name(value, part: nil, type: nil)
        add_child(Name.new(value, part: part, type: type))
      end

      def email(value, preferredcontact: nil)
        add_child(Email.new(value, preferredcontact: preferredcontact))
      end

      def phone(value, type: nil, time: nil, preferredcontact: nil)
        add_child(Phone.new(value, type: type, time: time, preferredcontact: preferredcontact))
      end

      def address(type: nil, &block)
        addr = Address.new(type: type)
        addr.instance_eval(&block) if block_given?
        add_child(addr)
      end
    end
  end
end
