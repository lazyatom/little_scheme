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
        List.new(x, *y.elements)
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

    class Add1
      def apply(env, number_expression)
        actual_number = number_expression.evaluate(env)
        Atom.new((actual_number.raw_value + 1).to_s)
      end
    end

    class Sub1
      def apply(env, number_expression)
        actual_number = number_expression.evaluate(env)
        value = actual_number.raw_value
        raise if value < 1
        Atom.new((value - 1).to_s)
      end
    end

    class IsZero
      def apply(env, number_expression)
        actual_number = number_expression.evaluate(env)
        actual_number.raw_value == 0 ? True : False
      end
    end

    class IsNumber
      def apply(env, number_expression)
        number_expression.evaluate(env).numerical? ? True : False
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
        :'or' => Or.new,
        :'and' => And.new,
        add1: Add1.new,
        sub1: Sub1.new,
        zero?: IsZero.new,
        number?: IsNumber.new
      }.merge(environment)

      s_expression.evaluate(environment)
    end
  end
end
