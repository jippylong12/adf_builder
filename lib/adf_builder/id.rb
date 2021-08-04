module AdfBuilder
  class Id
    def initialize

    end

    # add id tag to the form
    def add(parent_node, value, source=nil, sequence=1)
      id_node = Ox::Element.new('id')
      id_node << value
      id_node[:source] = sequence

      if source
        id_node[:source] = source
      end

      parent_node << id_node
    end
  end
end