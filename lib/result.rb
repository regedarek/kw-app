# Represents a result of an operation. Use Failure/Success to make it more concise
# Its recommended to use named args:
# result = Failure.new(:invalid, foo: 'bar')
# result.invalid { |foo:| puts foo }
# result = Success.new(foo: 'bar')
# result.success { |foo:| puts foo }
class Result
  attr_reader :name, :args

  def initialize(name, *args)
    @name = name
    @args = args
    @was_called = false

    define_singleton_method(name) do |&block|
      block.call(*@args)
      @was_called = true
    end

    define_singleton_method("#{name}?") do
      true
    end
  end

  def else
    yield unless @was_called
  end

  def else_fail!
    self.else { fail "unhandled Result '#{@name}' with args: #{@args.inspect}" }
  end

  def method_missing(_method_name, *_args, &_block)
    false
  end

  def inspect
    "#{self.class.name}<#{@name}:#{@args.inspect}>"
  end
end
