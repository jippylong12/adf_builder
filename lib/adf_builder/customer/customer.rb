# frozen_string_literal: true

module AdfBuilder
  class Customer
    def initialize(prospect)
      @customer = Ox::Element.new("customer")
      @contact = nil
      @timeframe = nil

      prospect << @customer
    end

    attr_reader :contact, :timeframe

    def add(name, opts = {})
      @contact = Contact.new(@customer, name, opts)
    end

    def add_id(index, value, source = nil, sequence = 1)
      if @prospect.locate("customer").empty?
        false
      else
        Id.new.add(@prospect.customer(index), value, source, sequence)
      end
    end

    # @param descriptin [String] - Description of customer’s timing intention.
    # @param earliest_date [DateTime] - Earliest date customer is interested in. If timeframe tag
    # is present, it is required to specify earliestdate and/or
    # latestdate
    # @param latest_date [DateTime] - Latest date customer is interested in. If timeframe tag
    # is present, it is required to specify earliestdate and/or
    # latestdate
    def add_timeframe(description, earliest_date = nil, latest_date = nil)
      return false if earliest_date.nil? && latest_date.nil?

      return false if earliest_date && (earliest_date.class != DateTime)

      return false if latest_date && (latest_date.class != DateTime)

      @timeframe = Timeframe.new(@customer, description, earliest_date, latest_date) if @timeframe.nil?
    end

    def update_comments(comments)
      return false if comments.class != String

      AdfBuilder::Builder.update_node(@customer, :comments, comments)
    end
  end
end
