module AdfBuilder
  class Lead
    # initialize the prospect, id, and requestdate node
    def initialize(doc)
      @doc = doc
      @prospect = Prospect.new(@doc)
    end

    def prospect
      @prospect
    end


  end
end