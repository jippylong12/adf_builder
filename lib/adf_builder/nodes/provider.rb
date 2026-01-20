# frozen_string_literal: true

module AdfBuilder
  module Nodes
    class Provider < Node
      def initialize
        super
        @tag_name = :provider
      end
      validates_presence_of :name

      def id(value, sequence: nil, source: nil)
        add_child(Id.new(value, sequence: sequence, source: source))
      end

      def name(value, part: nil, type: nil)
        remove_children(:name)
        add_child(Name.new(value, part: part, type: type))
      end

      def service(value)
        remove_children(:service)
        add_child(GenericNode.new(:service, {}, value))
      end

      def url(value)
        remove_children(:url)
        add_child(GenericNode.new(:url, {}, value))
      end

      def email(value, preferredcontact: nil)
        remove_children(:email)
        add_child(Email.new(value, preferredcontact: preferredcontact))
      end

      def phone(value, type: nil, time: nil, preferredcontact: nil)
        remove_children(:phone)
        add_child(Phone.new(value, type: type, time: time, preferredcontact: preferredcontact))
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
