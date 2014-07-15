require 'support/helpers/evaluate_helper'
require 'support/helpers/parse_helper'

module DefineHelper
  include EvaluateHelper
  include ParseHelper

  def self.extended(base)
    base.class_eval do
      let(:definitions) { {} }
    end
  end

  def define(name, s_expression)
    before(:each) do
      definitions[name] = evaluate_s_expression(parse_s_expression(s_expression), definitions)
    end
  end

  def evaluate(string, environment = {})
    before(:each) do
      evaluation_environment = definitions.merge(Hash[environment.map { |name, string| [name, parse_s_expression(string)] }])
      new_environment = evaluate_program(parse_s_expression(string), evaluation_environment).environment
      definitions.merge!(new_environment)
    end
  end
end
