require 'dry/matcher/result_matcher'

module EitherMatcher
  def either(*args, &block)
    Dry::Matcher::ResultMatcher.call(*args, &block)
  end
end
