source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.0.0'

gem 'rails', '~> 6.1.4', '>= 6.1.4.1'
gem 'pg', '~> 1.1'
gem 'puma', '~> 5.0'
gem 'webpacker', '~> 5.0'
gem 'slim-rails', '~> 3.3.0'

group :development, :test do
  gem 'pry-byebug', platforms: [:mri, :mingw, :x64_mingw]
  gem 'rspec-rails', '~> 5.0.0'
  gem 'factory_bot_rails', '~> 6.2.0'
  gem 'database_cleaner-active_record', '~> 2.0.1'
end

group :development do
  gem 'listen', '~> 3.3'
end
