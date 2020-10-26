source 'https://rubygems.org'

gem 'rails', '~> 4.2.6'

gem 'devise', '~> 4.1.1'
gem 'devise-i18n'

gem 'uglifier', '>= 1.3.0'

gem 'jquery-rails'
gem 'twitter-bootstrap-rails'
gem 'font-awesome-rails'
gem 'russian'
gem 'bigdecimal', '~>1.4'

group :development, :test do
  gem 'sqlite3', '~> 1.3', '< 1.4'
  gem 'byebug'
  gem 'rspec-rails', '~>3.4'
  gem 'factory_bot'
  gem 'shoulda-matchers'
end

group :test do
  gem 'capybara', '3.33.0'
  gem 'launchy'
end

group :production do
  # гем, улучшающий вывод логов на Heroku
  # https://devcenter.heroku.com/articles/getting-started-with-rails4#heroku-gems
  gem 'rails_12factor'
  gem 'pg', '~>0.16'
end
