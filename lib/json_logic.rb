# frozen_string_literal: true

require 'active_support/all'

require_relative 'json_logic/version'
require_relative 'json_logic/operations'
require_relative 'json_logic/rule'
require_relative 'json_logic/concerns/trackable'
require_relative 'json_logic/evaluator'
require_relative 'json_logic/validator'

module JsonLogic
  class Error < StandardError; end
end
