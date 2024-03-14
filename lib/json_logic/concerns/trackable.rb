# frozen_string_literal: true

module JsonLogic
  module Trackable
    COMPLEX_OPERATORS = %w[and or if ! !! ?:].freeze

    attr_reader :tracker

    def init_tracker(operator)
      if @tracker.nil?
        @tracker = Rule.new(operator)
      elsif COMPLEX_OPERATORS.include?(operator)
        @tracker = Rule.new(operator, @tracker)
      end
    end

    def commit_rule_result!(operator, data, rules, result)
      if COMPLEX_OPERATORS.include?(operator)
        # change operand to parent & save result
        @tracker.result = result
        @tracker        = @tracker.parent unless @tracker.parent.nil?
        return result
      end
      var_name = get_var_name(operator, rules)
      @tracker.add_data_point(var_name, operator, rules, data, result)
      result
    end

    private

    # This method retrieves the variable name from a hash of rules based on the given operator.
    #   { "<=" : [ 25, { "var": "age" }, 75] }
    #   { "<=" : [ { "var" : "age" }, 20 ] }
    #
    # @param operator [String] The operator for which to retrieve the variable name.
    # @param rules [Hash] A hash containing rule data.
    # @return [String, nil] The variable name if found, otherwise nil.

    def get_var_name(operator, rules)
      args = rules[operator]
      index = COMPLEX_OPERATORS.exclude?(operator) && args.length == 3 ? 1 : 0
      args.dig(index, 'var')
    rescue TypeError
      nil
    end
  end
end
