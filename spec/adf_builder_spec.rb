# frozen_string_literal: true

RSpec.describe AdfBuilder do
  it "has a version number" do
    expect(AdfBuilder::VERSION).not_to be nil
  end

  it "can build a vehicle" do
    builder = AdfBuilder::Builder.new
    builder.prospect.vehicles.add(2021, 'Toyota', 'Prius', {
      status: :used,
    })
    builder.prospect.vehicles.update_free_text_tags(0, {
      bodystyle: 'howdy',
      year: '2000'
    })
    puts builder.to_xml
  end
end
