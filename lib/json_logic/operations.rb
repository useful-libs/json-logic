# frozen_string_literal: true

module JsonLogic
  OPERATIONS = {
    '==' => ->(a, b) { a == b },
    '!=' => ->(a, b) { a != b },
    '>' => ->(a, b) { to_comparable(a) > to_comparable(b) },
    '>=' => ->(a, b) { to_comparable(a) >= to_comparable(b) },
    '<' => ->(a, b) { to_comparable(a) < to_comparable(b) },
    '<=' => lambda do |a, b, c = nil|
      return to_comparable(a) <= to_comparable(b) if c.nil?

      to_comparable(b).between?(to_comparable(a), to_comparable(c))
    end,
    '!' => ->(a) { json_logic_falsey(a) },
    '!!' => ->(a) { json_logic_truthy(a) },
    '%' => ->(a, b) { a % b },
    'and' => ->(*args) { args.reduce(true) { |total, arg| total && arg } },
    'or' => ->(*args) { args.reduce(false) { |total, arg| total || arg } },
    '?:' => ->(a, b, c) { json_logic_truthy(a) ? b : c },
    'if' => lambda do |*args|
      (0...args.length - 1).step(2) do |i|
        return args[i + 1] if json_logic_truthy(args[i])
      end

      args.length.odd? ? args[-1] : nil
    end,
    'log' => ->(a) { puts a },
    'in' => ->(a, b) { b.respond_to?(:include?) ? b.include?(a) : false },
    'cat' => ->(*args) { args.map(&:to_s).join },
    '+' => ->(*args) { args.sum(&:to_f) },
    '*' => ->(*args) { args.reduce(1) { |total, arg| total * arg.to_f } },
    '-' => ->(*args) { args.length == 1 ? -args[0].to_f : args[0].to_f - args[1].to_f },
    '/' => ->(a, b) { a.to_f / b },
    'min' => ->(*args) { args.map { |arg| to_comparable(arg) }.min },
    'max' => ->(*args) { args.map { |arg| to_comparable(arg) }.max },
    'merge' => ->(*args) { args.flat_map { |arg| arg.is_a?(Array) ? arg.to_a : arg } },
    'count' => ->(*args) { args.count { |a| a } }
  }.freeze

  private

  COMPARATORS = {
    NilClass => ->(_) { 0 },
    FalseClass => ->(_) { 0 },
    TrueClass => ->(_) { 1 },
    Array => ->(arr) { arr.map { |item| to_comparable(item) } },
    Hash => ->(hash) { hash.transform_values { |item| to_comparable(item) } },
    Numeric => ->(num) { num.to_f }
  }.freeze

  def to_comparable(value)
    comparator = COMPARATORS[value.class] || ->(val) { val }
    comparator.call(value)
  end

  def json_logic_falsey(value)
    case value
    when NilClass, FalseClass, TrueClass
      !value
    when Numeric
      value.zero?
    when String, Array, Hash
      value.empty?
    else
      false
    end
  end

  def json_logic_truthy(value)
    !json_logic_falsey(value)
  end

  module_function :to_comparable, :json_logic_falsey, :json_logic_truthy
end
