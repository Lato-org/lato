source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in lato.gemspec.
gemspec

# LATO DEPENDENCIES

# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Use Kredis as Redis interface [https://github.com/rails/kredis]
# NOTE: Installation -> https://github.com/rails/kredis#installation
gem "kredis"

# Use Sass to process CSS
gem "sassc-rails"

# Use bootstrap as front-end framework
gem "bootstrap"

# / LATO DEPENDENCIES

gem "puma"
gem "sqlite3"
gem "sprockets-rails"
gem "sidekiq"
gem "rails-erd"

group :development do
  # Start debugger with binding.b [https://github.com/ruby/debug]
  gem "debug", ">= 1.0.0"

  # Preview email in browser [https://github.com/ryanb/letter_opener]
  gem "letter_opener"

  # Generate random data [https://github.com/faker-ruby/faker]
  gem "faker"
end

group :test do
  # Move on time to make better tests [https://github.com/travisjeffery/timecop]
  gem "timecop"
end
