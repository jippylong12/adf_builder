# frozen_string_literal: true

module AdfBuilder
  class DSL
    def self.build(&block)
      root = Nodes::Root.new
      root.instance_eval(&block) if block_given?
      root.validate!
      Serializer.to_xml(root)
    end

    def self.tree(&block)
      root = Nodes::Root.new
      root.instance_eval(&block) if block_given?
      root
    end
  end

  def self.build(&block)
    DSL.build(&block)
  end

  def self.tree(&block)
    DSL.tree(&block)
  end
end
