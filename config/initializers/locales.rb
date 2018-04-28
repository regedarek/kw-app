I18n.load_path += Dir[Rails.root.join('lib', 'locales', '**', '*.{rb,yml}')]
I18n.load_path += Dir[Rails.root.join('app', 'components', '**', '*.yml')]
I18n.default_locale = :pl
