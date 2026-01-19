# frozen_string_literal: true

module AdfBuilder
  class RequestDate
    WITH_SYMBOLS = "%FT%T%:z"
    WITHOUT_SYMBOLS = "%Y%m%dT%H%M%S%z"

    def initialize(prospect_node)
      @request_date_node = Ox::Element.new("requestdate")
      @request_date_node << DateTime.now.strftime("%FT%T%:z")
      prospect_node << @request_date_node
    end

    def update_val(datetime_value, format = 1)
      if format == 1
        @request_date_node.replace_text(datetime_value.strftime(WITH_SYMBOLS))
      elsif format == 2
        @request_date_node.replace_text(datetime_value.strftime(WITHOUT_SYMBOLS))
      end
    end
  end
end
