source "https://rubygems.org"

git_source(:github) do |repo_name|
  repo_name = "#{repo_name}/#{repo_name}" unless repo_name.include?("/")
  "https://github.com/#{repo_name}.git"
end

gem "activemerchant"
gem "bootstrap-select-rails"
gem "cancancan"
gem "carrierwave", "1.2.2"
gem "coffee-rails", "~> 4.2"
gem "config"
gem "devise"
gem "faker"
gem "figaro"
gem "geocoder"
gem "gmaps4rails"
gem "i18n-js"
gem "jbuilder", "~> 2.5"
gem "jquery-rails"
gem "kaminari"
gem "mini_magick", "~> 4.8"
gem "money"
gem "mysql2"
gem "public_activity"
gem "puma", "~> 3.7"
gem "rails", "~> 5.1.7"
gem "rails-i18n"
gem "redis", "~> 4.0"
gem "rubocop", "~> 0.54.0", require: false
gem "rufus-scheduler"
gem "sass-rails", "~> 5.0"
gem "search_cop"
gem "uglifier", ">= 1.3.0"

group :development, :test do
  gem "byebug", platforms: %i(mri mingw x64_mingw)
  gem "capybara", ">= 2.15"
  gem "selenium-webdriver"
end

group :development do
  gem "listen", ">= 3.0.5", "< 3.2"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.0.0"
  gem "web-console", ">= 3.3.0"
end

gem "tzinfo-data", platforms: %i(mingw mswin x64_mingw jruby)
