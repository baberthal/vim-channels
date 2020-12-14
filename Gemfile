# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in vim_channels.gemspec
gemspec

gem "rake", "~> 12.0"
gem "rspec", "~> 3.0"

gem "concurrent-ruby", "~> 1.1.7"
gem "concurrent-ruby-ext", "~> 1.1.7", platforms: :mri

gem "eventmachine"

group :development, :test do
  gem "rubocop"
  gem "rubocop-rspec"

  gem "guard"
  gem "guard-rspec"
  gem "guard-yard"

  gem "colorize"
  gem "pry"
  gem "pry-byebug"

  gem "simplecov", require: false

  gem "solargraph"

  gem "yard"
end
