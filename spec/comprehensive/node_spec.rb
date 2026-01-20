# frozen_string_literal: true

require "spec_helper"
require "nokogiri"

RSpec.describe AdfBuilder::Nodes::Node do
  describe "initialization" do
    it "initializes with empty children array" do
      node = AdfBuilder::Nodes::Node.new
      expect(node.children).to eq([])
    end

    it "initializes with empty attributes hash" do
      node = AdfBuilder::Nodes::Node.new
      expect(node.attributes).to eq({})
    end

    it "initializes with nil value" do
      node = AdfBuilder::Nodes::Node.new
      expect(node.value).to be_nil
    end

    it "initializes with nil tag_name" do
      node = AdfBuilder::Nodes::Node.new
      expect(node.tag_name).to be_nil
    end
  end

  describe "#add_child" do
    it "adds a child node to children array" do
      parent = AdfBuilder::Nodes::Node.new
      child = AdfBuilder::Nodes::GenericNode.new(:test, {}, "value")

      parent.add_child(child)

      expect(parent.children).to include(child)
      expect(parent.children.size).to eq(1)
    end

    it "maintains order of multiple children" do
      parent = AdfBuilder::Nodes::Node.new
      child1 = AdfBuilder::Nodes::GenericNode.new(:first, {}, "1")
      child2 = AdfBuilder::Nodes::GenericNode.new(:second, {}, "2")
      child3 = AdfBuilder::Nodes::GenericNode.new(:third, {}, "3")

      parent.add_child(child1)
      parent.add_child(child2)
      parent.add_child(child3)

      expect(parent.children.map(&:tag_name)).to eq(%i[first second third])
    end
  end

  describe "#remove_children" do
    it "removes all children with matching tag_name" do
      parent = AdfBuilder::Nodes::Node.new
      child1 = AdfBuilder::Nodes::GenericNode.new(:remove_me, {}, "1")
      child2 = AdfBuilder::Nodes::GenericNode.new(:keep_me, {}, "2")
      child3 = AdfBuilder::Nodes::GenericNode.new(:remove_me, {}, "3")

      parent.add_child(child1)
      parent.add_child(child2)
      parent.add_child(child3)

      parent.remove_children(:remove_me)

      expect(parent.children.size).to eq(1)
      expect(parent.children.first.tag_name).to eq(:keep_me)
    end

    it "does nothing when no matching children exist" do
      parent = AdfBuilder::Nodes::Node.new
      child = AdfBuilder::Nodes::GenericNode.new(:existing, {}, "value")
      parent.add_child(child)

      parent.remove_children(:nonexistent)

      expect(parent.children.size).to eq(1)
    end
  end

  describe "method_missing (dynamic tag support)" do
    let(:node) { AdfBuilder::Nodes::Node.new }

    it "creates GenericNode for unknown tag with value" do
      node.custom_tag "my value"

      expect(node.children.size).to eq(1)
      child = node.children.first
      expect(child.tag_name).to eq(:custom_tag)
      expect(child.value).to eq("my value")
    end

    it "creates GenericNode for unknown tag with value and attributes" do
      node.custom_tag "my value", type: "special", id: 123

      child = node.children.first
      expect(child.tag_name).to eq(:custom_tag)
      expect(child.value).to eq("my value")
      expect(child.attributes[:type]).to eq("special")
      expect(child.attributes[:id]).to eq(123)
    end

    it "creates GenericNode for unknown tag with block (nested structure)" do
      node.parent_tag do
        child_tag "child value"
      end

      parent = node.children.first
      expect(parent.tag_name).to eq(:parent_tag)
      expect(parent.children.size).to eq(1)
      expect(parent.children.first.tag_name).to eq(:child_tag)
      expect(parent.children.first.value).to eq("child value")
    end

    it "creates empty GenericNode for tag with attributes only" do
      node.empty_tag type: "marker"

      child = node.children.first
      expect(child.tag_name).to eq(:empty_tag)
      expect(child.value).to be_nil
      expect(child.attributes[:type]).to eq("marker")
    end
  end

  describe "#respond_to_missing?" do
    it "returns true for any method name" do
      node = AdfBuilder::Nodes::Node.new
      expect(node.respond_to?(:any_random_method)).to be true
      expect(node.respond_to?(:another_method)).to be true
    end
  end
end

RSpec.describe AdfBuilder::Nodes::GenericNode do
  describe "initialization" do
    it "sets tag_name from constructor" do
      node = AdfBuilder::Nodes::GenericNode.new(:my_tag, {}, "value")
      expect(node.tag_name).to eq(:my_tag)
    end

    it "sets attributes from constructor" do
      node = AdfBuilder::Nodes::GenericNode.new(:tag, { foo: "bar", num: 42 }, nil)
      expect(node.attributes[:foo]).to eq("bar")
      expect(node.attributes[:num]).to eq(42)
    end

    it "sets value from constructor" do
      node = AdfBuilder::Nodes::GenericNode.new(:tag, {}, "my value")
      expect(node.value).to eq("my value")
    end

    it "handles nil value" do
      node = AdfBuilder::Nodes::GenericNode.new(:tag, {})
      expect(node.value).to be_nil
    end
  end
end

RSpec.describe AdfBuilder::Nodes::Root do
  describe "#prospect" do
    it "creates and adds a Prospect child" do
      root = AdfBuilder::Nodes::Root.new
      root.prospect do
        # Empty for now
      end

      expect(root.children.size).to eq(1)
      expect(root.children.first).to be_a(AdfBuilder::Nodes::Prospect)
    end

    it "supports multiple prospects" do
      root = AdfBuilder::Nodes::Root.new
      root.prospect {}
      root.prospect {}

      expect(root.children.size).to eq(2)
    end
  end

  describe "#first_prospect" do
    it "returns the first Prospect child" do
      root = AdfBuilder::Nodes::Root.new
      root.prospect {}
      root.prospect {}

      expect(root.first_prospect).to be_a(AdfBuilder::Nodes::Prospect)
      expect(root.first_prospect).to eq(root.children.first)
    end

    it "returns nil when no prospects exist" do
      root = AdfBuilder::Nodes::Root.new
      expect(root.first_prospect).to be_nil
    end
  end
end
