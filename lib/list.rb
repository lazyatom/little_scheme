class List
  attr_reader :elements

  def initialize(*elements)
    @elements = elements
  end

  def ==(other)
    other.elements == elements
  end

  def evaluate(env)
    return self if elements.empty?
    operation, *arguments = elements
    result = operation.evaluate(env)
    result.apply(env, *arguments)
  end

  def inspect
    "<List: (#{@elements.map { |m| m.inspect }.join(' ')})>"
  end

  def empty?
    elements.empty?
  end

  def first
    elements.first
  end

  def rest
    elements[1..-1]
  end

  def all?(&block)
    elements.all?(&block)
  end
end
