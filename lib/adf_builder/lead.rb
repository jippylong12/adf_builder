require 'ox'

module AdfBuilder
  class Lead
    def initialize(doc)
      @doc = doc
    end

    def base_xml
      Ox.dump(@doc, {})
    end
  end
end