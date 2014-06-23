require 'atom'
require 'list'
require 'support/helpers/parse_helper'

module SyntaxMatchers
  include ParseHelper
  extend RSpec::Matchers::DSL

  matcher :be_an_atom do
    match do |string|
      s_expression = parse_s_expression(string)
      s_expression.is_a?(Atom)
    end
  end

  matcher :be_a_list do
    match do |string|
      s_expression = parse_s_expression(string)
      s_expression.is_a?(List)
    end
  end

  matcher :be_an_s_expression do
    match do |string|
      begin
        raise unless parse_s_expression(string)
        true
      rescue
        false
      end
    end
  end

  matcher :contain_the_s_expressions do |*expected|
    match do |string|
      elements_in(parse_s_expression(string)) == expected.map(&method(:parse_s_expression))
    end
  end

  matcher :be_a_number do
    match do |string|
      s_expression = parse_s_expression(string)
      s_expression.number? == Atom::TRUE
    end
  end

  matcher :be_a_tup do
    match do |string|
      s_expression = parse_s_expression(string)
      elements_in(s_expression).all? { |s_expression| s_expression.is_a?(Atom) && is_a_number?(s_expression) }
    end
  end

  matcher :be_an_arithmetic_expression do
    def arithmetic_expression?(s_expressions)
      if s_expressions.length == 1 && is_an_atom?(s_expressions.first)
        true
      elsif s_expressions.length >= 3
        first, op, *rest = s_expressions
        arithmetic_expression?([first]) && arithmetic_expression?(rest) && is_an_atom?(op) && %w(+ * expt).include?(op.name)
      end
    end

    match do |string|
      s_expressions = parse_program(string).s_expressions
      arithmetic_expression?(s_expressions)
    end
  end
end
