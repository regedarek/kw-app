require 'result'

# Represents a failed operation. Use Success to represent success
# Its recommended to use named args:
# result = Failure.new(:invalid, foo: 'bar')
# result.invalid { |foo:| puts foo }
class Failure < Result
  def failure?
    true
  end

  def failure
    yield if failure?
  end
end

# Kernel method to allow Failure(...) syntax
module Kernel
  def Failure(*args)
    ::Failure.new(*args)
  end
end
