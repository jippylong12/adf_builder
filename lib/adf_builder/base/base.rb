# frozen_string_literal: true

module AdfBuilder
  class Base
    # initialize the prospect, id, and requestdate node
    def initialize(doc)
      @doc = doc
      @prospect = Prospect.new(@doc)
    end

    attr_reader :prospect
  end
end
