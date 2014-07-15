$debug_level = 0
$debug = ENV['DEBUG'] #|| true

def debug_print(level, thing)
  return unless $debug
  data = thing.is_a?(Hash) ? thing.inspect : thing
  indent = "\t" * level
  puts "#{indent}#{thing}"
end

def debug_environment_ignore_keys
  LittleScheme::Evaluator.new.default_environment.keys
end

def debug(values={}, &block)
  if $debug
    if values[:env]
      values[:env] = values[:env].dup.delete_if { |k,v| debug_environment_ignore_keys.include?(k) || v.is_a?(LittleScheme::Evaluator::Lambda::Compiled) }
    end
    if block_given?
      debug_print $debug_level, values
      $debug_level += 1
      result = yield
      $debug_level -= 1
      debug_print $debug_level, ">>> #{result.inspect}"
      result
    else
      debug_print $debug_level, values
    end
  else
    yield if block_given?
  end
end
