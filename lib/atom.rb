class Atom
  attr_reader :symbol

  def initialize(symbol)
    @symbol = symbol.to_sym
  end

  def ==(other)
    other.symbol == symbol
  end

  def evaluate(env)
    if numerical?
      self
    else
      env.fetch(symbol)
    end
  end

  def inspect
    "<Atom: #{@symbol}>"
  end

  def raw_value
    if numerical?
      numerical_value
    else
      symbol
    end
  end

  def numerical?
    symbol.to_s =~ /^\d+$/
  end

  def numerical_value
    symbol.to_s.to_i
  end

  def non_numerical?
    !numerical?
  end
end
