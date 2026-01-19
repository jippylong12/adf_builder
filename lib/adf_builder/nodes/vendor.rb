# frozen_string_literal: true

module AdfBuilder
  module Nodes
    class Vendor < Node
      def initialize
        super
        @tag_name = :vendor
      end

      def id(value, sequence: nil, source: nil)
        add_child(Id.new(value, sequence: sequence, source: source))
      end

      def vendorname(value)
        remove_children(:vendorname)
        add_child(GenericNode.new(:vendorname, {}, value))
      end

      def url(value)
        remove_children(:url)
        add_child(GenericNode.new(:url, {}, value))
      end

      def contact(primary_contact: false, &block)
        remove_children(:contact)
        contact = Contact.new(primary_contact: primary_contact)
        contact.instance_eval(&block) if block_given?
        add_child(contact)
      end
    end
  end
end
