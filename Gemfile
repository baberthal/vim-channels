# frozen_string_literal: true

source "https://rubygems.org"

# Specify your gem's dependencies in vim_channels.gemspec
gemspec

gem "rake", "~> 12.0"
gem "rspec", "~> 3.0"

gem "concurrent-ruby", "~> 1.1.7"
gem "concurrent-ruby-ext", "~> 1.1.7", platforms: :mri

group :development, :test do
  gem "rubocop"
  gem "rubocop-rspec"

  gem "guard"
  gem "guard-rspec"

  gem "colorize"
  gem "pry"
  gem "pry-byebug"

  gem "solargraph"

  gem "yard"
end
