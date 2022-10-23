# Lato
Basic engine for all Lato projects.

## Installation
Add required dependencies to your application's Gemfile:

```ruby
# Use Sass to process CSS
gem "sassc-rails"

# Use bootstrap as front-end framework
gem "bootstrap"

# Use lato as application panel
gem "lato"
```

Install gem and run required tasks then execute:

```bash
$ bundle
$ rails lato:install:assets
$ rails lato:install:migrations
$ rails db:migrate
```

Mount lato routes on the **config/routes.rb** file:

```ruby
Rails.application.routes.draw do
  mount Lato::Engine => "/lato"

  # ....
end
```

## Customization
Lato can be customized on every part. Customization can be done by N ways:
- Customize the engine configuration;
- Customize layout boostrap classes;

### Customize the engine configuration
Create a **config/initializers/lato_config.rb** file to edit the default configuration:

```ruby
Lato.configure do |config|
  config.application_title = 'Demo app'
end
```

### Customize layout boostrap classes
Create a **config/initializers/lato_boostrap.rb** file to edit the default classes:

```ruby
Lato.bootstrap do |btstrap|
  btstrap.navbar = 'navbar-dark bg-primary'
end
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).