require 'parslet'
require 'little_scheme'

module LittleScheme
  class Parser
    def parse(program)
      ParseResult.new(ParseRules.new.parse(program))
    end
  end

  class ParseResult
    def initialize(tree)
      @tree = tree
    end

    def to_ast
      ParseTransform.new.apply(@tree)
    end

    def s_expressions
      ast = to_ast
      if ast.is_a?(Array)
        ast
      else
        [ast]
      end
    end
  end

  class ParseTransform < Parslet::Transform
    rule(false: simple(:false)) { LittleScheme::False }
    rule(true: simple(:true)) { LittleScheme::True }

    rule(atom: simple(:atom)) { Atom.new(atom.to_str) }
    rule(list: subtree(:list)) { List.new(*list) }
  end

  class ParseRules < Parslet::Parser
    rule(:space)  { match('\s').repeat(1) }
    rule(:space?) { space.maybe }

    rule(:_false) { str('#f').as(:false) }
    rule(:_true) { str('#t').as(:true) }

    rule(:multiplication) { str('*') }
    rule(:addition) { str('+') }
    rule(:exponent) { str('expt') }
    rule(:arithmetic_operation) { multiplication | addition | exponent }

    rule(:atom) { match('[^()\s]').repeat(1).as(:atom) }
    rule(:list) { str('(') >> (s_expression >> space?).repeat(0).as(:list) >> str(')') }
    rule(:s_expression) { _false | _true | atom | list | arithmetic_operation }

    rule(:program) { s_expression >> (space >> s_expression).repeat(0) }

    root(:program)
  end
end
