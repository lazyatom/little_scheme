module LittleScheme
  class Evaluator
    class Car
      def apply(env, s_expression)
        list = s_expression.evaluate(env)
        raise if list.empty?
        list.first
      end
    end

    class Cdr
      def apply(env, s_expression)
        list = s_expression.evaluate(env)
        raise if list.empty?
        List.new(*list.rest)
      end
    end

    class IsNull
      def apply(env, s_expression)
        x = s_expression.evaluate(env)
        raise unless x.is_a?(List)
        x.empty? ? True : False
      end
    end

    class IsAtom
      def apply(env, atom)
        x = atom.evaluate(env)
        x.is_a?(Atom) ? True : False
      end
    end

    class IsEq
      def apply(env, atom1, atom2)
        x = atom1.evaluate(env)
        y = atom2.evaluate(env)
        raise unless x.is_a?(Atom) && x.non_numerical? &&
                     y.is_a?(Atom) && y.non_numerical?
        x.symbol == y.symbol ? True : False
      end
    end

    class Quote
      def apply(env, *args)
        List.new
      end
    end

    class Cons
      def apply(env, thing, list)
        x = thing.evaluate(env)
        y = list.evaluate(env)
        List.new(x, *y.array)
      end
    end

    class Lambda
      def apply(env, parameters, s_expression)
        Compiled.new(parameters, s_expression)
      end

      class Compiled
        def initialize(parameters, s_expression)
          @parameter_names = parameters.array.map(&:symbol)
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
          condition, result = condition_expression.array
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

    def evaluate(s_expression, environment)
      environment = {
        :'#t' => LittleScheme::True,
        :'#f' => LittleScheme::False,

        car: Car.new,
        cdr: Cdr.new,
        cons: Cons.new,
        null?: IsNull.new,
        atom?: IsAtom.new,
        eq?: IsEq.new,
        quote: Quote.new,
        lambda: Lambda.new,
        cond: Cond.new,
        :'else' => Else.new,
        :'or' => Or.new
      }.merge(environment)

      s_expression.evaluate(environment)
    end
  end
end
