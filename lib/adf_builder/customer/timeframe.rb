module AdfBuilder
  class Timeframe
    def initialize(customer, description, earliest_date, latest_date)

      begin
        earliest_date = earliest_date.strftime('%FT%T%:z') if earliest_date
        latest_date = latest_date.strftime('%FT%T%:z') if latest_date
      rescue => e
        return nil
      end

      @timeframe = Ox::Element.new('timeframe')


      @timeframe << (Ox::Element.new('description') << description)
      @timeframe << (Ox::Element.new('earliestdate') << earliest_date) if earliest_date
      @timeframe << (Ox::Element.new('latestdate') << latest_date) if latest_date
      customer << @timeframe
    end

    def update_description(description)
      AdfBuilder::Builder.update_node(@timeframe, :description, description)
    end

    def update_earliest_date(date)
      begin
        date = date.strftime('%FT%T%:z')
      rescue
        return false
      end
      AdfBuilder::Builder.update_node(@timeframe, :earliestdate, date)
    end

    def update_latest_date(date)
      begin
        date = date.strftime('%FT%T%:z')
      rescue
        return false
      end

      AdfBuilder::Builder.update_node(@timeframe, :latestdate, date)
    end
  end
end