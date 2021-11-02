# frozen_string_literal: true

RSpec.describe AdfBuilder do
  it "has a version number" do
    expect(AdfBuilder::VERSION).not_to be nil
  end

  it "can add vehicle comment" do
    builder = AdfBuilder::Builder.new
    builder.prospect.vehicles.add(2021, 'Toyota', 'Prius', {
      status: :used,
    })

    builder.prospect.vehicles.add_comments(0, "This is a comment")

    puts builder.to_xml

  end

  it "can add price" do
    builder = AdfBuilder::Builder.new
    builder.prospect.vehicles.add(2021, 'Toyota', 'Prius', {
      status: :used,
    })

    builder.prospect.vehicles.add_price(0,23400, {
      type: 'quote',
      currency: 'blah',
      source: "YES"
    })

    puts builder.to_xml

    builder.prospect.vehicles.price(0).update(3444, {
      currency: 'USD'
    })

    puts builder.to_xml
  end

  it 'can add a provider' do
    builder = AdfBuilder::Builder.new
    provider = builder.prospect.provider
    provider.add('Testing', {part: 'full', type: 'business'})
    provider.update_tags_with_free_text({
                                                           url: 'howdy',
                                                           service: "Nice"
                                                         })
    provider.add_email("test@test.com", {preferredcontact: 0})
    provider.add_phone("+14445556666", {
      type: 'fax',
      time: 'day'
    })
    provider.add_contact("Mr Sir")
    provider.contact.add_phone("+132435523424")
    puts builder.to_xml
  end

  it 'can add color combination' do
    builder = AdfBuilder::Builder.new
    builder.prospect.vehicles.add(2021, 'Toyota', 'Prius', {
      status: :used,
    })
    builder.prospect.vehicles.add_color_combination(0, 'black', 'yellow', 1)
    puts builder.to_xml
    builder.prospect.vehicles.color_combination(0).update_tags(0, {
      preference: 20,
      interiorcolor: 'yellow'
    })
    puts builder.to_xml

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
    builder.prospect.vehicles.update_imagetag(0, 'http://adfxml.info/adf_spec.pdf', {
      width: 400,
      height: 500,
      alttext: 'Howdy'
    })
    puts builder.to_xml
  end
end
