#require 'dry/monads/result'
#require 'dry/matcher/result_matcher'
#
#module Business
#  class UpdateCourse
#    include Dry::Monads::Result::Mixin
#    include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)
#    Dry::Schema.load_extensions(:monads)
#
#    CourseSchema = Dry::Schema.Params do
#      required(:name).filled(:string)
#    end
#
#    def call(raw_inputs)
#      validate_params(raw_inputs).bind do
#        Success()
#      end
#    end
#
#    private
#
#    def validate_params(raw_inputs)
#      CourseSchema.call(raw_inputs).to_monad
#    end
#  end
#end
