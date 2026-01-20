## [1.5.0] - 2026-01-19
- **Provider Node Support**:
  - Implemented `Provider` node with support for `name`, `service`, `url`, `email`, `phone`, and `contact`.
  - Enforced `name` presence for `Provider`.
- **Validation Improvements**:
  - `Phone`: Updated allowed types to include `:voice` and removed `:phone` (strictly following spec).
  - `Serializer`: Fixed `primarycontact` being serialized as a child element instead of an attribute.

## [1.4.0] - 2026-01-19
- **Vendor & Customer Validation Improvements**:
  - `Vendor`: Now requires `vendorname` and `contact`.
  - `Customer`: Now requires `contact`.
  - `Contact`: Refactored to use declarative `validates_presence_of :name` (previously manual check).
  - Added comprehensive specs for new presence validations.

## [1.3.1] - 2026-01-19
- **Validation Refinement**: `Address` now strictly enforces 1 to 5 `street` lines.

## [1.3.0] - 2026-01-19
- **Customer & Contact Validations**:
  - `Contact`: Requires Name and at least one Phone or Email.
  - `Address`: Validates Country against ISO 3166-1 alpha-2 codes.
  - `Timeframe`: Validates ISO 8601 dates and requires earliest/latest date if present.
  - `Phone/Email`: Enforces valid types and preference flags.

## [1.2.2] - 2026-01-19
- **Strict Validations**: Added ISO 4217 currency validation for `Price`, `Amount`, and `Balance`.

## [1.2.1] - 2026-01-19
- **Strict Validations**: Added `presence` validation for `Vehicle` (year, make, model required).

## [1.2.0] - 2026-01-19
- **Strict Validations**: Added validation for `Vehicle` condition, `Option` weighting (range), `Finance` method, and required `ID` source.

## [1.1.0] - 2026-01-19
- **Feature Complete**: Implemented all ADF 1.0 nodes and attributes including `Vendor`, `Provider`, and complex `Vehicle` tags (`Finance`, `Option`, `Odometer`, `ColorCombination`, `ImageTag`, `Price`).
- **Singular Field logic**: Methods for singular fields (e.g. `vehicle.year`) now correctly replace existing values instead of appending.
- **Removed Legacy Code**: Cleaned up deprecated legacy implementation directories.

## [1.0.0] - 2026-01-19
- **MAJOR OVERHAUL**: Complete rewrtie of the library architecture.
- **New Block-based DSL**: Intuitive API for building ADF documents (`AdfBuilder.build { vehicle { ... } }`).
- **Validation**: Strict enforcement of ADF enumerations and structure (e.g. `vehicle status: :new`).
- **Editing**: New `AdfBuilder.tree` method for programmatic modifications after construction.
- **Robustness**: Complete rewrite of XML generation using robust heuristics and strict `Ox` serialization.
- **Compatibility**: Verified for Ruby 3.4.x.
- **Features**:
  - Support for multiple vehicles/customers.
  - Support for singular vs multiple item logic.
  - Dynamic support for arbitrary/custom tags (`method_missing`).
  - Automatic handling of XML attributes vs simple elements.

## [0.4.0] - 2026-01-19
- Modernized dependencies
  - Updated `ox` to `~> 2.14.23` for better compatibility
  - Added compatibility for Ruby 3.4.x
  - Updated development dependencies (RSpec, Rubocop, Rake)
- Vehicle Structure - Remaining Optional Tags that are not free text
  - option
  - finance
- Expand Structures for all parameters
  - Customer 
  - Contact
  - Vehicle

## [0.3.0] - 2023-11-28
- Completed Customer - timeframe and comments tags

## [0.2.2] - 2021-11-02
- Fixed bug where ADF and xml tags were flipped

## [0.2.1] - 2021-11-02
- Add comments to the Vehicle nodes

## [0.1.0] - 2021-08-13
- Figured out versioning I think
- Add Price structure to vehicles
- Added JSON file for all 3 code currencies to validate entry
- Color Combinations uses function instead of giving raw array so it's
```ruby
item.color_combination(0) # new
item.color_combinations[0] # old
```

## [0.0.8] - 2021-08-12
- Added all of Provider structure

## [0.0.7] - 2021-08-08
- Much refactoring so that we can reuse functions 
- Added more functionality to the Vehicle structure including all free text, all same level tags with params, and Color Combination and ImageTag


## [0.0.6] - 2021-08-08
- minimal_lead function will remove all previous adf nodes
- Created ability to reset doc

## [0.0.5] - 2021-08-08
- Fixed bug that kept us from using the library

## [0.0.4] - 2021-08-08
- Added Customer, Contact, Vendor basic structure


## [0.0.3] - 2021-08-04
- Added ability to add simple vehicle structures

## [0.0.2] - 2021-08-04

- Can create a prospect and dynamically update params and values for the base and parent level

## [0.0.1] - 2021-08-03

- Initial release
- Can return the minimal XML given from spec doc
