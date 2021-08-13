## [Unreleased]
- Vehicle Structure - Remaining Optional Tags that are not free text
  - option
  - finance
- Expand Structures for all parameters
  - Customer 
  - Contact
  - Vehicle

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
