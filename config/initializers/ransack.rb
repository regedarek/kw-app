Ransack.configure do |config|
  config.add_predicate 'year_equals',
  arel_predicate: 'gteq',
  formatter: proc { |v| Date.new(v.to_i); },
  validator: proc { |v| v.present? },
  type: :string
end
