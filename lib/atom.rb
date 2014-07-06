class Atom
  attr_reader :symbol

  def initialize(symbol)
    @symbol = symbol.to_s.to_sym
  end

  def ==(other)
    other.symbol == symbol
  end

  def eql?(other)
    self == other
  end

  def hash
    @symbol.hash
  end

  def evaluate(env)
    env.fetch(symbol, self)
  end

  def inspect
    "<Atom: #{@symbol}>"
  end

  def name
    symbol.to_s
  end
  alias :to_s :name

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
