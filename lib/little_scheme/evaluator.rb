module LittleScheme
  class Evaluator
    class Operation
      def initialize(name = nil, &block)
        @name = name
        @block = block
      end

      def apply(env, *arguments)
        evaluated_arguments = arguments.map { |a| a.evaluate(env) }
        @block.call(*evaluated_arguments)
      end

      def to_s
        "operation/#{@name}"
      end
      alias :inspect :to_s
    end

    class BooleanOperation < Operation
      def apply(env, *arguments)
        super(env, *arguments) ? True : False
      end
    end

    class Define
      def apply(env, name, s_expression)
        debug applying_define: name, s_expression: s_expression do
          env[name.symbol] = s_expression.evaluate(env)
        end
      end
    end

    class Lambda
      def apply(env, parameters, s_expression)
        debug applying_lambda: parameters, s_expression: s_expression, env: env do
          Compiled.new(parameters, s_expression, env)
        end
      end

      def to_s
        "Lambda"
      end
      alias :inspect :to_s

      class Compiled
        def initialize(parameters, s_expression, original_env)
          @parameter_names = parameters.elements.map(&:symbol)
          @s_expression = s_expression
          @original_env = original_env
        end

        def apply(env, *arguments)
          debug applying_compiled_lambda: @s_expression, parameter_names: @parameter_names, env: env do
            debug message: 'evaluating compiled lambda arguments: ', arguments: arguments
            evaluated_arguments = arguments.map { |a| a.evaluate(env) }
            debug parameter_names: @parameter_names, evaluated_arguments: evaluated_arguments
            argument_environment = Hash[@parameter_names.zip(evaluated_arguments)]
            argument_environment.delete_if { |_,v| v.nil? }
            debug original_env: true, env: @original_env
            local_env = env.merge(@original_env).merge(argument_environment)
            debug evaluating_s_expression: @s_expression, env: local_env
            r = @s_expression.evaluate(local_env)
            debug result: r
            r
          end
        end

        def to_s
          "(lambda/compiled (#{@parameter_names.join(' ')}) #{@s_expression})"
        end
        alias :inspect :to_s
      end
    end

    class Cond
      def apply(env, *conditions)
        debug cond_conditions: conditions.count
        conditions.each do |condition_expression|
          condition, result = condition_expression.elements
          evaluated = debug evaluating_condition: condition, result: result do
            condition.evaluate(env)
          end
          if evaluated == True || evaluated.is_a?(Else)
            return debug evaluating_cond_result: result do
              evaluated_result = result.evaluate(env)
            end
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

    class Quote
      def apply(env, thing)
        thing
      end
    end

    def default_environment
      {
        car:   Operation.new(:car)  { |list| list.empty? ? raise("car error on #{list}") : list.first },
        cdr:   Operation.new(:cdr)  { |list| list.empty? ? raise("cdr error on #{list}") : List.new(*list.rest) },
        cons:  Operation.new(:cons) { |thing, list| List.new(thing, *list.elements) },
        null?:   BooleanOperation.new(:null?) { |list| list.is_a?(List) ? list.empty? : raise("null? error on #{list}") },
        atom?:   BooleanOperation.new(:atom?) { |atom| atom.is_a?(Atom) },
        zero?:   BooleanOperation.new(:zero?) { |atom| atom.raw_value == 0 },
        number?: BooleanOperation.new(:number?) { |atom| atom.numerical? },
        eq?:     BooleanOperation.new(:eq?) do |atom1, atom2|
          raise("eq? error on [#{atom1}] vs [#{atom2}]") unless atom1.is_a?(Atom) && atom1.non_numerical? &&
                       atom2.is_a?(Atom) && atom2.non_numerical?
          atom1.symbol == atom2.symbol
        end,
        quote: Quote.new,
        add1: Operation.new(:add1) { |atom| Atom.new(atom.raw_value + 1) },
        sub1: Operation.new(:sub1) { |atom| atom.raw_value < 1 ? raise("sub1 error on #{atom}") : Atom.new(atom.raw_value - 1) },

        :'#t' => LittleScheme::True,
        :'#f' => LittleScheme::False,

        define: Define.new,
        lambda: Lambda.new,
        cond: Cond.new,
        else: Else.new,
        or: Or.new,
        and: And.new
      }
    end

    class EvaluationResult < Struct.new(:result, :environment); end

    def evaluate(s_expression, environment)
      environment = default_environment.merge(environment)

      result = s_expression.evaluate(environment)
      EvaluationResult.new(result, environment)
    end
  end
end
