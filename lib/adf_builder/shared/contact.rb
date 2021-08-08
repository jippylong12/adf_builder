module AdfBuilder
  class Contact
    VALID_PARAMETERS = {
      name: [:part, :type, :primarycontact],
      email: [:preferredcontact],
      phone: [:type, :time, :preferredcontact]
    }


    PHONE_TYPES = [:phone, :fax, :cellphone, :pager]

    def initialize(parent_node, name, opts={})
      @contact = Ox::Element.new('contact') << (Ox::Element.new('name') << name)
      parent_node << @contact

      opts = whitelabel_opts(opts, :name)

      if opts[:primary_contact]
        @contact[:primarycontact] = opts[:primary_contact].to_s
      end

      opts.each do |k,v|
        @contact.locate("name")[0][k] = v.to_s
      end

    end

    def add_email(email, opts={})
      @contact << (Ox::Element.new('email') << email)
      opts = whitelabel_opts(opts, :phone)

      opts.each do |k,v|
        @contact.email[k] = v.to_s
      end
    end

    def add_phone(phone, opts={})
      @contact << (Ox::Element.new('phone') << phone)
      opts = whitelabel_opts(opts, :phone)

      opts.each do |k,v|
        @contact.phone[k] = v.to_s
      end
    end




    private

    # clear out the opts that don't match valid keys
    def whitelabel_opts(opts, key)
      opts.slice(*VALID_PARAMETERS[key])
    end
  end
end