
module AdfBuilder
  class Lead
    STATUSES = {
      new: :new,
      resend: :resend
    }

    # initialize the prospect, id, and requestdate node
    def initialize(doc)
      @doc = doc
      @doc.adf << Ox::Element.new("prospect")
      @prospect = @doc.adf.prospect
      @prospect[:status] = STATUSES[:new]
    end

    # set status to renew
    def prospect_renew
      @prospect[:status] = STATUSES[:resend]
    end

  end
end