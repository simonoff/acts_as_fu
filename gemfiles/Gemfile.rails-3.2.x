source "https://rubygems.org"

gemspec :path => '..'

gem 'rails', '~> 3.2.6'
gem 'sqlite3'

group :development do
  gem 'rake'
  gem 'rspec', '~> 2'
end