# frozen_string_literal: true

RSpec.describe AdfBuilder do
  it "has a version number" do
    builder = AdfBuilder::Builder.new
    builder.prospect.vehicles.add(2021, 'Toyota', 'Prius', {
      vin: 'XXXXXXXXXX',
      comments: "howdy"
    })
    builder.prospect.vendor.add('marcus', 'test')
    builder.prospect.customer.add('marcus')
    puts builder.to_xml
    expect(AdfBuilder::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
