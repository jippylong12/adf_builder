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

      def validates_presence_of(*attributes)
        @validations ||= []
        attributes.each do |attr|
          @validations << { type: :presence, attribute: attr }
        end
      end

      def validations
        @validations || []
      end
    end

    def validate!
      self.class.validations.each do |validation|
        if validation[:type] == :inclusion
          value = @attributes[validation[:attribute]]
          next if value.nil?

          allowed = validation[:in]
          unless allowed.include?(value)
            raise AdfBuilder::Error,
                  "Invalid value for #{validation[:attribute]}: #{value}. Allowed: #{allowed.join(", ")}"
          end
        elsif validation[:type] == :presence
          # Check children for a node with tag_name == attribute
          target_tag = validation[:attribute]
          found = @children.any? { |c| c.tag_name == target_tag }
          unless found
            raise AdfBuilder::Error, "Missing required Element: #{target_tag} in #{tag_name || self.class.name}"
          end
        end
      end

      # Recursively validate children
      @children.each(&:validate!)
    end
  end
end
