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

    # Common ISO 3166-1 alpha-2 codes
    ISO_3166 = %w[US CA MX GB DE FR GR IT ES JP CN IN BR RU ZA AU NZ KR SE NO FI DK NL BE CH].freeze

    class Phone < Node
      validates_inclusion_of :type, in: %i[phone fax cellphone pager]
      validates_inclusion_of :time, in: %i[morning afternoon evening nopreference day]
      validates_inclusion_of :preferredcontact, in: [0, 1, "0", "1"]

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
      validates_inclusion_of :preferredcontact, in: [0, 1, "0", "1"]

      def initialize(value, preferredcontact: nil)
        super()
        @tag_name = :email
        @value = value
        @attributes[:preferredcontact] = preferredcontact if preferredcontact
      end
    end

    class Name < Node
      validates_inclusion_of :part, in: %i[first middle suffix last full]
      validates_inclusion_of :type, in: %i[individual business]

      def initialize(value, part: nil, type: nil)
        super()
        @tag_name = :name
        @value = value
        @attributes[:part] = part if part
        @attributes[:type] = type if type
      end
    end

    class Address < Node
      validates_inclusion_of :type, in: %i[work home delivery]
      validates_inclusion_of :country, in: ISO_3166

      def initialize(type: nil)
        super()
        @tag_name = :address
        @attributes[:type] = type if type
      end

      def street(value, line: nil)
        # Line validation 1-5
        raise AdfBuilder::Error, "Street line must be 1-5" if line && !line.to_s.match?(/^[1-5]$/)

        node = GenericNode.new(:street, { line: line }.compact, value)
        add_child(node)
      end

      # Simple elements
      %i[apartment city regioncode postalcode country].each do |tag|
        define_method(tag) do |value|
          if tag == :country && !ISO_3166.include?(value.to_s.upcase)
            raise AdfBuilder::Error, "Invalid country code: #{value}"
          end

          add_child(GenericNode.new(tag, {}, value))
        end
      end
    end

    class Contact < Node
      validates_inclusion_of :primarycontact, in: [0, 1, "0", "1"]

      def initialize(primary_contact: nil)
        super()
        @tag_name = :contact
        @attributes[:primarycontact] = primary_contact if primary_contact
      end

      def validate!
        super
        # Custom Validation: Name is required
        raise AdfBuilder::Error, "Contact must have a Name" unless @children.any? { |c| c.tag_name == :name }

        # Custom Validation: At least one Phone OR Email
        return if @children.any? { |c| %i[phone email].include?(c.tag_name) }

        raise AdfBuilder::Error, "Contact must have at least one Phone or Email"
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
