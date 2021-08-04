# frozen_string_literal: true

RSpec.describe AdfBuilder do
  it "has a version number" do
    builder = AdfBuilder::Builder.new
    builder.base.prospect.vehicles.add(2021, 'hyuu', 'ffff')
    builder.base.prospect.vehicles.add(2044, '234', 'ffff')
    puts builder.to_xml
    expect(AdfBuilder::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
