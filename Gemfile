source 'https://rubygems.org'

gemspec

gem 'rspec', '>= 3.0.0'

group :test do
  gem 'simplecov', '>= 0.9.0', :require => false
  gem 'coveralls', :require => false
end

group :local_development do
  gem 'transpec'
  gem 'terminal-notifier-guard', require: false if RUBY_PLATFORM.downcase.include?('darwin')
  gem 'guard-rspec', '>= 4.3.1' ,require: false
  gem 'guard-bundler', require: false
  gem 'guard-preek', require: false
  gem 'guard-rubocop', require: false
  gem 'guard-reek', github: 'pericles/guard-reek', require: false
  gem 'pry'
  gem 'appraisal'
end
