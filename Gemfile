#ruby-gemset=tehcrawdox
ruby '2.3.1'

source 'https://rubygems.org'

gem 'bundler', '>= 1.8.4'

source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap'
  gem 'rails-assets-angular'
  gem 'rails-assets-leaflet'
end

# Use Postgres as the database for Active Record
gem 'pg'
# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.5'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'


# Use jquery as the JavaScript library
gem 'jquery-rails'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Para trabalhar com textos
gem 'nokogiri'

# Para gerar os conteineres DLC
gem 'dlc', '~> 1.1', '>= 1.1.3'

# Para corrigir o erro de routa com os controllers do angular
gem 'sprockets', '2.12.3'

gem 'angular-rails-templates'

# Para o rake
gem 'rest-client', '~> 1.8.0'

# Gem para o crawler de páginas
gem 'mechanize'

gem 'passenger'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  gem 'rails-assets-angular-mocks'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end
