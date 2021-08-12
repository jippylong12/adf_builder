module AdfBuilder
  class Provider


    FREE_TEXT_OPTIONAL_TAGS = [:service, :url]

    def initialize(prospect)
      @prospect = prospect
      @provider = nil
      @contact = nil
    end


    def add(name, params={})
      @provider = Ox::Element.new('provider')

      params.merge!({valid_values: AdfBuilder::Contact::VALID_VALUES, valid_parameters: AdfBuilder::Contact::VALID_PARAMETERS})
      AdfBuilder::Builder.update_node(@provider, :name, name,  params)
      @prospect << @provider
    end

    def update_tags_with_free_text(tags)
      tags.each do |key, value|
        if FREE_TEXT_OPTIONAL_TAGS.include? key.to_sym
          AdfBuilder::Builder.update_node(@provider, key, value)
        end
      end
    end

    def add_id(index, value, source=nil, sequence=1)
      if @prospect.locate("provider").empty?
        false
      else
        Id.new.add(@prospect.provider(index), value, source, sequence)
      end
    end
  end
end