module AdfBuilder
  class Prospect
    STATUSES = {
      new: :new,
      resend: :resend
    }

    def initialize(doc)
      @doc = doc
      @doc.adf << Ox::Element.new("prospect")
      @prospect = @doc.adf.prospect
      @prospect[:status] = STATUSES[:new]
    end

    # set status to renew
    def set_renew
      @prospect[:status] = STATUSES[:resend]
    end
  end
end