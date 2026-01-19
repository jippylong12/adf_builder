# frozen_string_literal: true

module AdfBuilder
  module Validations
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def validates_inclusion_of(attribute, in:)
        @validations ||= []
        @validations << { type: :inclusion, attribute: attribute, in: binding.local_variable_get(:in) }
      end

      def validations
        @validations || []
      end
    end

    def validate!
      self.class.validations.each do |validation|
        value = @attributes[validation[:attribute]]
        next if value.nil? # Allow nil unless presence validation is added

        next unless validation[:type] == :inclusion

        allowed = validation[:in]
        unless allowed.include?(value)
          raise AdfBuilder::Error,
                "Invalid value for #{validation[:attribute]}: #{value}. Allowed: #{allowed.join(", ")}"
        end
      end

      # Recursively validate children
      @children.each(&:validate!)
    end
  end
end
