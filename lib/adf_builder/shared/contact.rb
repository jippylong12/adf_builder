module AdfBuilder
  class Contact
    def initialize(parent_node, name)
      @contact = Ox::Element.new('contact') <<
        (Ox::Element.new('name') << name)
      parent_node << @contact
    end

  end
end