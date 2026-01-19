# frozen_string_literal: true

RSpec.describe AdfBuilder::Timeframe do
  it "adds timeframe" do
    builder = AdfBuilder::Builder.new
    builder.prospect.customer.add("Test Name", {
                                    part: "full",
                                    type: "individual"
                                  })
    builder.prospect.customer.add_timeframe("howdy", DateTime.now, DateTime.now + 10)

    puts builder.to_xml
    expect(builder.prospect.customer.timeframe).not_to be nil
  end

  it "adds comments" do
    builder = AdfBuilder::Builder.new
    builder.prospect.customer.add("Test Name", {
                                    part: "full",
                                    type: "individual"
                                  })

    builder.prospect.customer.update_comments("howdy")
    puts builder.to_xml
  end
end
