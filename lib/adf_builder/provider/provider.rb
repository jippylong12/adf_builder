# frozen_string_literal: true

module AdfBuilder
  class Provider
    FREE_TEXT_OPTIONAL_TAGS = %i[service url].freeze

    def initialize(prospect)
      @prospect = prospect
      @provider = nil
      @contact = nil
    end

    attr_reader :contact

    def add(name, params = {})
      @provider = Ox::Element.new("provider")
      params.merge!({ valid_values: AdfBuilder::Contact::VALID_VALUES,
                      valid_parameters: AdfBuilder::Contact::VALID_PARAMETERS })
      AdfBuilder::Builder.update_node(@provider, :name, name, params)
      @prospect << @provider
    end

    def add_contact(name, opts = {})
      @contact = Contact.new(@provider, name, opts)
    end

    def add_phone(phone, params = {})
      params.merge!({ valid_values: AdfBuilder::Contact::VALID_VALUES,
                      valid_parameters: AdfBuilder::Contact::VALID_PARAMETERS })
      AdfBuilder::Builder.update_node(@provider, :phone, phone, params)
    end

    def add_email(email, params = {})
      params.merge!({ valid_values: AdfBuilder::Contact::VALID_VALUES,
                      valid_parameters: AdfBuilder::Contact::VALID_PARAMETERS })
      AdfBuilder::Builder.update_node(@provider, :email, email, params)
    end

    def update_tags_with_free_text(tags)
      tags.each do |key, value|
        AdfBuilder::Builder.update_node(@provider, key, value) if FREE_TEXT_OPTIONAL_TAGS.include? key.to_sym
      end
    end

    def add_id(index, value, source = nil, sequence = 1)
      if @prospect.locate("provider").empty?
        false
      else
        Id.new.add(@prospect.provider(index), value, source, sequence)
      end
    end
  end
end
