class List
  attr_reader :array

  def initialize(*array)
    @array = array
  end

  def ==(other)
    other.array == array
  end

  def evaluate(env)
    return self if array.empty?
    operation, *arguments = array
    result = operation.evaluate(env)
    result.apply(env, *arguments)
  end

  def inspect
    "<List: (#{@array.map { |m| m.inspect }.join(' ')})>"
  end

  def apply(env)
    self
  end

  def empty?
    array.empty?
  end

  def first
    array.first
  end

  def rest
    array[1..-1]
  end

  def all?(&block)
    array.all?(&block)
  end
end
