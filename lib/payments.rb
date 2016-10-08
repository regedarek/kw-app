Dir[Rails.root.join('lib', 'payments', '**', '*.rb')].each { |file| require file }
