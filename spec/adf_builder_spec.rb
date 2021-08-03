# frozen_string_literal: true

RSpec.describe AdfBuilder do
  it "has a version number" do
    builder = AdfBuilder::Builder.new
    builder.base.prospect.set_renew
    puts builder.to_xml
    expect(AdfBuilder::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
