# AdfBuilder

A Ruby gem for creating valid **Auto-lead Data Format (ADF)** XML documents intuitively. 

Version **1.0** introduces a new declarative DSL, strict validation, and a robust architecture.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'adf_builder'
```

And then execute:
```shell
$ bundle install
```

## Usage

### The DSL (New in v1.0)

Version 1.0 uses a block-based DSL to structure your ADF document. This aligns the visual structure of your Ruby code with the resulting XML hierarchy.

```ruby
xml = AdfBuilder.build do
  prospect do
    # Singular attributes (last call wins)
    request_date Time.now
    
    # Multiple items: Calling 'vehicle' multiple times adds multiple vehicles
    vehicle do
      year 2021
      make 'Ford'
      model 'F-150'
      status :new   # Validated attribute
    end
    
    vehicle do
      year 2023
      make 'Tesla'
      model 'Cybertruck'
      status :used
    end
    
    customer do
      contact do
        name 'John Doe', part: 'full'
        email 'john@example.com'
        phone '555-1234', type: 'cell'
      end
    end
    
    vendor do
       # vendor implementation...
    end
  end
end

puts xml
```

### Outputs

```xml
<?xml version="1.0"?>
<?ADF version="1.0"?>
<adf>
  <prospect>
    <requestdate>2026-01-19 16:40:00 -0600</requestdate>
    <vehicle status="new">
      <year>2021</year>
      <make>Ford</make>
      <model>F-150</model>
    </vehicle>
    <vehicle status="used">
      <year>2023</year>
      <make>Tesla</make>
      <model>Cybertruck</model>
    </vehicle>
    <customer>
      <contact>
        <name part="full">John Doe</name>
        <email>john@example.com</email>
        <phone type="cell">555-1234</phone>
      </contact>
    </customer>
  </prospect>
</adf>
```

### Multiple vs Singular Items

- **Singular Attributes**: Methods that take a value (e.g., `year 2021`, `request_date Time.now`) set an attribute on the current node. Calling them multiple times overwrites the value.
- **Multiple Nodes**: Methods that take a block (e.g., `vehicle { ... }`) create a new child node and append it. You can call them as many times as needed to add multiple items.

### Advanced: Editing & Programmatic Access

If you need to edit the data after building it (or build it progressively), use `AdfBuilder.tree`. This returns the object tree instead of the XML string.

```ruby
# 1. Build the tree
tree = AdfBuilder.tree do
  prospect do
    vehicle do
      year 2020
      make 'Ford'
      status :new
    end
  end
end

# 2. Modify the tree programmatically
# Access helpers: .prospect, .vehicles, .customers
prospect = tree.children.first
vehicle = prospect.vehicles.first

vehicle.year(2025) # Update existing value
vehicle.status(:used)

# Add a new vehicle dynamically
prospect.vehicle do
  year 2023
  make 'Tesla'
  status :new
end

# 3. Serialize to XML
puts tree.to_xml
```

### Validation

The library now enforces ADF standards. Invalid enum values will raise an error.

```ruby
# Raises AdfBuilder::Error: Invalid value for status: broken
AdfBuilder.build do
  prospect do
    vehicle do
      status :broken 
    end
  end
end
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jippylong12/adf_builder.
