# frozen_string_literal: true

module JsonLogic
  module Trackable
    attr_reader :tracker

    def init_tracker(operator)
      if @tracker.nil?
        @tracker = Rule.new(operator)
      elsif COMPLEX_OPERATORS.include?(operator)
        @tracker = Rule.new(operator, @tracker)
      end
    end

    def commit_rule_result!(var_name, operator, data, rules, result)
      if COMPLEX_OPERATORS.include?(operator)
        # change operand to parent & save result
        @tracker.result = result
        @tracker        = @tracker.parent unless @tracker.parent.nil?
        return result
      end
      @tracker.add_data_point(var_name, operator, rules, data, result)
      result
    end
  end
end
