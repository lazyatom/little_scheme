# These methods can be redefined if your implementation doesn't
# work in quite the way they imagine
module SchemeMethodHelper
  def car_of(evaluated_scheme)
    raise "not a List!" unless evaluated_scheme.is_a?(List)
    raise "empty List!" if evaluated_scheme.empty?
    evaluated_scheme.first
  end

  def cdr_of(evaluated_scheme)
    raise "not a List!" unless evaluated_scheme.is_a?(List)
    List.new(*evaluated_scheme.rest)
  end

  def cons_of(evaluated_scheme, evaluated_list)
    raise "second argument not a List!" unless evaluated_list.is_a?(List)
    List.new(evaluated_scheme, *elements_in(evaluated_list))
  end

  def is_null?(evaluated_scheme)
    raise "not a List!" unless evaluated_scheme.is_a?(List)
    evaluated_scheme.empty?
  end

  def elements_in(evaluated_scheme)
    raise "not a List!" unless evaluated_scheme.is_a?(List)
    evaluated_scheme.elements
  end
end
