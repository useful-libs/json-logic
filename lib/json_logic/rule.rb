# frozen_string_literal: true

module JsonLogic
  class DataPoint
    attr_accessor :name, :operation, :expected, :current, :result

    def initialize(name, operation, expected, current, result)
      @name = name
      @operation = operation
      @expected = expected
      @current = current
      @result = result
    end

    def report
      "DATA: '#{name}' data:#{current || 'None'} #{operation} expected:#{expected_args},  RESULT = #{result}"
    end

    private

    def expected_args
      @expected.length == 3 ? [@expected.first, @expected.last] : @expected.last
    end
  end

  class Rule
    attr_accessor :name, :reasons, :result, :parent, :deep_level

    def initialize(name, parent = nil)
      @name = name
      @result = false
      @parent = parent
      @reasons = []
      @deep_level = 0
      return if @parent.nil?

      @deep_level = @parent.deep_level + 1
      @parent.reasons << self
    end

    def add_data_point(var_name, operator, rules, data, result)
      @result = result
      current_data = data.is_a?(Hash) ? data[var_name] : data
      @reasons << DataPoint.new(var_name, operator, rules[operator], current_data, result)
    end

    def report
      report = "LOGIC: '#{name}', RESULT = #{result}\n"
      report + reasons.map do |rule|
        "#{Array.new(deep_level + 1, "\t").join} #{rule.report}"
      end.join("\n")
    end
  end
end
