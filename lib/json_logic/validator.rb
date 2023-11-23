# frozen_string_literal: true

module JsonLogic
  class Validator
    def json_logic_valid?(rules)
      return validate_hash(rules) if rules.is_a?(Hash)
      return validate_array(rules) if rules.is_a?(Array)

      primitive?(rules)
    end

    private

    def operator?(operator)
      operators = JsonLogic::OPERATIONS.keys
      operators.include?(operator)
    end

    def variable?(value)
      return false unless value.is_a?(Hash)

      var = value['var']
      return false unless var

      var.is_a?(String) || var.is_a?(Numeric) || var.nil?
    end

    def primitive?(value)
      value.is_a?(String) || value.is_a?(Numeric) ||
        value.is_a?(TrueClass) || value.is_a?(FalseClass) || value.is_a?(NilClass)
    end

    def validate_hash(hash)
      hash.all? do |operator, value|
        operator?(operator) && json_logic_valid?(value)
      end
    end

    def validate_array(array)
      array.all? do |value|
        json_logic_valid?(value) || variable?(value) || primitive?(value)
      end
    end

    def validate_var(value)
      return false unless value.is_a?(Hash)

      value.key?('var') && value.keys.count == 1
    end
  end
end
