# frozen_string_literal: true

require "spec_helper"

RSpec.describe AdfBuilder::Validations do
  describe "Validation Enforcement" do
    it "raises error when vehicle status is invalid" do
      expect do
        AdfBuilder.build do
          prospect do
            vehicle do
              status :broken # Invalid
            end
          end
        end
      end.to raise_error(AdfBuilder::Error, /Invalid value for status: broken/)
    end

    it "passes when vehicle status is valid" do
      expect do
        AdfBuilder.build do
          prospect do
            vehicle do
              status :new
            end
          end
        end
      end.not_to raise_error
    end
  end
end
