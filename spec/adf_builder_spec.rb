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
    builder.prospect.vehicles.update_tags_with_free_text(0, {
      bodystyle: 'howdy',
      year: '2000'
    })
    builder.prospect.vehicles.update_odometer(0, 9000, {
      units: 'km'
    })
    builder.prospect.vehicles.update_condition(0, 'ffff')
    puts builder.to_xml
  end
end
