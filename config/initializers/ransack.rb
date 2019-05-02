
module Arel
  module Predications
    def contains(other)
      Nodes::Equality.new(Nodes.build_quoted(other, self), Nodes::NamedFunction.new('ANY', [self]))
    end
  end
end

Ransack.configure do |config|
  config.add_predicate :contains_array, arel_predicate: :contains
  config.add_predicate 'year_equals',
  arel_predicate: 'gteq',
  formatter: proc { |v| Date.new(v.to_i); },
  validator: proc { |v| v.present? },
  type: :string
end
