class Atom
  attr_reader :symbol

  def initialize(symbol)
    @symbol = symbol.to_sym
  end

  def ==(other)
    other.symbol == symbol
  end

  def evaluate(env)
    env.fetch(symbol)
  end

  def inspect
    "<Atom: #{@symbol}>"
  end

  def non_numerical?
    symbol.to_s =~ /^[^\d]/
  end
end
