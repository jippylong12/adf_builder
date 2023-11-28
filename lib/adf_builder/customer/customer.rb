module AdfBuilder
  class Customer
    def initialize(prospect)
      @customer = Ox::Element.new('customer')
      @contact = nil
      @timeframe = nil

      prospect << @customer
    end

    def contact
      @contact
    end

    def timeframe
      @timeframe
    end
    def add(name, opts={})
      @contact = Contact.new(@customer, name, opts)
    end

    def add_id(index, value, source=nil, sequence=1)
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
    def add_timeframe(description, earliest_date=nil, latest_date=nil)
      if earliest_date.nil? and latest_date.nil?
        return false
      end

      if earliest_date and earliest_date.class != DateTime
        return false
      end

      if latest_date and latest_date.class != DateTime
        return false
      end

      @timeframe = Timeframe.new(@customer, description, earliest_date, latest_date) if @timeframe.nil?
    end

    def update_comments(comments)
      return false if comments.class != String
      AdfBuilder::Builder.update_node(@customer, :comments, comments)
    end
  end
end