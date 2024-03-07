# frozen_string_literal: true

module JsonLogic
  class Evaluator
    include Trackable

    def apply(rules, data = {})
      return rules unless rules.is_a?(Hash)

      operator = rules.keys[0]
      init_tracker(operator)

      values = operator == 'map' ? [] : Array(rules[operator]).map { |rule| apply(rule, data) }

      operators(operator, values, rules, data)
    end

    def operators(operator, values, rules, data)
      case operator
      when 'var' then get_var_value(data, *values)
      when 'missing' then missing(data, *values)
      when 'missing_some' then missing_some(data, *values)
      when 'map' then json_logic_map(data, *rules[operator])
      else
        raise("Unrecognized operation #{operator}") unless OPERATIONS.key?(operator)

        execute_operation(operator, rules, data, *values)
      end
    end

    # This method traverses `rules` (expected as a nested data structure
    # composed of Hash and Array objects) to extract values associated
    # with the key 'var'.
    #
    # It's a recursive method that digs into the structure to find 'var'.
    #
    # If `rules` is a Hash, it iterates through each key-value pair:
    # - If the key is 'var', it appends the value to `vars`.
    # - If the key is not 'var', it recurses into the value (if it's an Array or Hash).
    #
    # If `rules` is an Array, it iterates through each element,
    # which should be a Hash or Array, and recurses through it.
    #
    # `vars`, is an optional accumulator Array to hold collected variables.
    # It starts as an empty array if not provided.
    #
    # @param rules [Hash, Array] a data structure composed of nested Hashes
    # and arrays that we want to extract values from.
    #
    # @param vars [Array] an optional accumulator array to hold collected variables.
    #
    # @return [Array] an array of extracted variable values.

    def extract_vars(rules, vars = [])
      if rules.is_a?(Hash)
        rules.each do |key, value|
          key == 'var' ? vars << value : extract_vars(value, vars)
        end
        return vars
      end

      rules.each { |rule| extract_vars(rule, vars) } and return vars if rules.is_a?(Array)

      vars
    end

    # This method recursively searches through the `rules` data structure
    # (composed of nested Hashes and Arrays) to find all values associated
    # with a specified variable name.
    #
    # If `rules` is an Array:
    # - It checks if the first element of the Array has the specified variable.
    #   If so, it adds the second element of the Array (presumed to be the value
    #   of the variable) to `values`.
    # - If not, it recurses through each element of the Array.
    #
    # If `rules` is a Hash, it recurses through each value in the Hash.
    #
    # `values` is an optional accumulator Array used to collect the found variable values.
    #
    # @param rules [Hash, Array] a data structure composed of nested Hashes and
    # Arrays to be searched through.
    #
    # @param var_name [String, Symbol] the name of the variable we want to find the values for.
    #
    # @param values [Array] an optional accumulator array to collect found values.
    #
    # @return [Array] an array of all values associated with the specified variable in `rules`.

    def fetch_var_values(rules, var_name, values = [])
      if rules.is_a?(Array)
        return values << rules[1] if rule_has_var?(rules.first, var_name)

        rules.each { |rule| fetch_var_values(rule, var_name, values) }
        return values
      end

      if rules.is_a?(Hash)
        rules.each_value { |rule| fetch_var_values(rule, var_name, values) }
        return values
      end

      values
    end

    private

    def rule_has_var?(rule, var_name)
      rule.is_a?(Hash) && rule.key?('var') && rule['var'] == var_name
    end

    def json_logic_map(data, items_rule, map_rule)
      items = apply(items_rule, data)

      Array(items).map { |item| apply(map_rule, item) }
    end

    def execute_operation(operator, rules, data, *)
      result = OPERATIONS[operator].call(*)
      var_name = get_var_name(operator, rules)

      commit_rule_result!(var_name, operator, data, rules, result)
    end

    # This method retrieves the value of a variable with a given name from the data structure.
    #
    # @param data [Hash] The data structure to search for the variable value.
    # @param var_name [String] The name of the variable to retrieve.
    # @return [String, Numeric, nil] The value of the variable if found, otherwise nil.

    def get_var_value(data, var_name, default_value = nil)
      var_name.to_s.split('.').each do |key|
        data = data[key]
      rescue TypeError
        data = data[key.to_i]
      end
      data.nil? ? default_value : data
    end

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

    def missing(data, *args)
      args.select { |arg| get_var_value(data, arg).nil? }
    end

    def missing_some(data, min_required, args)
      return [] if min_required < 1

      missed_args, present_args = args.partition { |arg| get_var_value(data, arg).nil? }
      present_args.length >= min_required ? [] : missed_args
    end
  end
end
