class List
  attr_reader :elements

  def initialize(*elements)
    @elements = elements
  end

  def ==(other)
    other.elements == elements
  end

  def eql?(other)
    self == other
  end

  def hash
    elements.map(&:hash).hash
  end

  def evaluate(env)
    return self if elements.empty?
    operation, *arguments = elements
    debug evaluating_list: to_s, env: env do
      result = operation.evaluate(env)
      debug applying_list_result: result, with_arguments: arguments
      result.apply(env, *arguments)
    end
  end

  def inspect
    # "<List: (#{@elements.map { |m| m.inspect }.join(' ')})>"
    to_s
  end

  def to_s
    "(#{@elements.join(' ')})"
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
