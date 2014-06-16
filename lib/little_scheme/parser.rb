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

    rule(:atom) { match('[^()\s]').repeat(1).as(:atom) }
    rule(:list) { str('(') >> (s_expression >> space?).repeat(0).as(:list) >> str(')') }
    rule(:s_expression) { _false | _true | atom | list }

    root(:s_expression)
  end
end
