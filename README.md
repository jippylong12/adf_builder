# AdfBuilder
Hopefully this will help with development in the ADF format. The goal is to intuitively create an update an ADF XML file that can easily be added to an email or saved to a file.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'adf_builder'
```

And then execute:
```shell
$ bundle install
```

Or install it yourself as:
```shell
$ gem install adf_builder
```

## Usage

Quickly create the minimal lead found in the spec document
```ruby
builder = AdfBuilder::Builder.new
builder.minimal_lead
```
Start Building
```ruby
builder = AdfBuilder::Builder.new
builder.to_xml
```


Outputs
```xml
<?ADF version="1.0"?>

<?xml version="1.0"?>
<adf>
  <prospect status="new">
    <requestdate>2021-08-04T15:18:30+04:00</requestdate>
  </prospect>
</adf>
```


Update Requestdate value
```ruby
builder = AdfBuilder::Builder.new
builder.base.prospect.request_date.update_val(Date.new(2021,12,12))
```
Outputs

```xml
<?ADF version="1.0"?>

<?xml version="1.0"?>
<adf>
  <prospect status="new">
    <requestdate>2021-12-12T00:00:00+00:00</requestdate>
  </prospect>
</adf>
```


Add ID tag to Prospect
```ruby
builder = AdfBuilder::Builder.new
builder.base.prospect.add_id('howdy', 'Ag')
```

Outputs
```xml
<?ADF version="1.0"?>

<?xml version="1.0"?>
<adf>
  <prospect status="new">
    <id sequence="1" source="Ag">howdy</id>
    <requestdate>2021-08-04T15:24:16+04:00</requestdate>
  </prospect>
</adf>
```




## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jippylong12/adf_builder. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/jippylong12/adf_builder/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the AdfBuilder project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/jippylong12/adf_builder/blob/master/CODE_OF_CONDUCT.md).
