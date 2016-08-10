require 'result'

# Represents a successful operation. Use Failure to represent failures
# Its recommended to use named args:
# result = Success.new(foo: 'bar')
# result.success { |foo:| puts foo }
class Success < Result
  def initialize(*args)
    super(:success, *args)
  end
end
