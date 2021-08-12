module AdfBuilder
  class Contact
    VALID_PARAMETERS = {
      name: [:part, :type, :primarycontact],
      email: [:preferredcontact],
      phone: [:type, :time, :preferredcontact]
    }

    VALID_VALUES = {
      name: {
        part: %w[first middle suffix last full],
        type: %w[individual business],
        primarycontact: %w[0 1]
      },
      email: {
        preferredcontact: %w[0 1],
      },
      phone: {
        preferredcontact: %w[0 1],
        type: %w[phone fax cellphone pager],
        time: %w[morning afternoon evening nopreference day]
      }
    }

    PHONE_TYPES = [:phone, :fax, :cellphone, :pager]

    def initialize(parent_node, name, params={})
      @contact = Ox::Element.new('contact')
      params.merge!({valid_values: VALID_VALUES, valid_parameters: VALID_PARAMETERS})
      AdfBuilder::Builder.update_node(@contact, :name, name,  params)
      parent_node << @contact
    end

    def add_phone(phone, params={})
      params.merge!({valid_values: VALID_VALUES, valid_parameters: VALID_PARAMETERS})
      AdfBuilder::Builder.update_node(@contact, :phone, phone,  params)
    end

    def add_email(email, params={})
      params.merge!({valid_values: VALID_VALUES, valid_parameters: VALID_PARAMETERS})
      AdfBuilder::Builder.update_node(@contact, :email, email,  params)
    end
  end
end