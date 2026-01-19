# frozen_string_literal: true

require "ox"
require "json"

require_relative "adf_builder/version"
require_relative "adf_builder/validations"

# Nodes
require_relative "adf_builder/nodes/node"
require_relative "adf_builder/nodes/prospect"
require_relative "adf_builder/nodes/shared"
require_relative "adf_builder/nodes/vehicle"
require_relative "adf_builder/nodes/vehicle_nodes"
require_relative "adf_builder/nodes/customer"
require_relative "adf_builder/nodes/vendor"
require_relative "adf_builder/nodes/provider"

# Core
require_relative "adf_builder/serializer"
require_relative "adf_builder/dsl"

module AdfBuilder
  class Error < StandardError; end
end
