require 'dry/matcher/either_matcher'

module EitherMatcher
  def either(*args, &block)
    Dry::Matcher::EitherMatcher.call(*args, &block)
  end
end
