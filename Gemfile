source 'https://rubygems.org'

gem 'rails', '4.1.0'
gem 'sass-rails', '~> 4.0.3'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.0.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'quiet_assets'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'spring', group: :development
gem 'sqlite3', :group => [:test, :development, :staging]

group :test, :development do
  gem 'webrick'
  gem "rspec-rails"
  gem 'capybara'
  gem "guard-rspec"
  gem "guard-spring"
  gem 'rb-inotify'
  gem 'brakeman', :require => false
  gem 'mina', :require => false
  gem "email_spec"
  gem "timecop"
  gem 'simplecov', :require => false
  gem "database_cleaner"
  gem "rails_best_practices", :require => false
end

