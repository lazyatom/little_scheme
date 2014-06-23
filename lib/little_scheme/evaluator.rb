module LittleScheme
  class Evaluator
    class Operation
      def initialize(&block)
        @block = block
      end

      def apply(env, *arguments)
        evaluated_arguments = arguments.map { |a| a.evaluate(env) }
        @block.call(*evaluated_arguments)
      end
    end

    class BooleanOperation < Operation
      def apply(env, *arguments)
        super(env, *arguments) ? True : False
      end
    end

    class Lambda
      def apply(env, parameters, s_expression)
        Compiled.new(parameters, s_expression)
      end

      class Compiled
        def initialize(parameters, s_expression)
          @parameter_names = parameters.elements.map(&:symbol)
          @s_expression = s_expression
        end

        def apply(env, *arguments)
          evaluated_arguments = arguments.map { |a| a.evaluate(env) }
          local_env = env.merge(Hash[@parameter_names.zip(evaluated_arguments)])
          @s_expression.evaluate(local_env)
        end
      end
    end

    class Cond
      def apply(env, *conditions)
        conditions.each do |condition_expression|
          condition, result = condition_expression.elements
          evaluated = condition.evaluate(env)
          if evaluated == True || evaluated.is_a?(Else)
            return result.evaluate(env)
          end
        end
      end
    end

    class Else
      def apply(env, result)
        result.evaluate(env)
      end
    end

    class Or
      def apply(env, *conditions)
        conditions.each do |condition_expression|
          evaluated = condition_expression.evaluate(env)
          if evaluated == True
            return True
          end
        end
        return False
      end
    end

    class And
      def apply(env, *conditions)
        conditions.all? do |condition_expression|
          condition_expression.evaluate(env) == True
        end ? True : False
      end
    end

    def evaluate(s_expression, environment)
      operations = {
        car: Operation.new do |list|
          raise if list.empty?
          list.first
        end,
        cdr: Operation.new do |list|
          raise if list.empty?
          List.new(*list.rest)
        end,
        cons: Operation.new do |thing, list|
          List.new(thing, *list.elements)
        end,
        null?: BooleanOperation.new do |list|
          raise unless list.is_a?(List)
          list.empty?
        end,
        atom?: BooleanOperation.new do |atom|
          atom.is_a?(Atom)
        end,
        eq?: BooleanOperation.new do |atom1, atom2|
          raise unless atom1.is_a?(Atom) && atom1.non_numerical? &&
                       atom2.is_a?(Atom) && atom2.non_numerical?
          atom1.symbol == atom2.symbol
        end,
        quote: Operation.new do
          List.new
        end,
        add1: Operation.new do |atom|
          Atom.new((atom.raw_value + 1).to_s)
        end,
        sub1: Operation.new do |atom|
          value = atom.raw_value
          raise if value < 1
          Atom.new((value - 1).to_s)
        end,
        zero?: BooleanOperation.new do |atom|
          atom.raw_value == 0
        end,
        number?: BooleanOperation.new do |atom|
          atom.numerical?
        end
      }

      environment = {
        :'#t' => LittleScheme::True,
        :'#f' => LittleScheme::False,

        lambda: Lambda.new,
        cond: Cond.new,
        else: Else.new,
        or: Or.new,
        and: And.new
      }.merge(operations).merge(environment)

      s_expression.evaluate(environment)
    end
  end
end
