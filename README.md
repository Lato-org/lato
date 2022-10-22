# Lato
Basic engine for all Lato projects.

## Installation
Add required dependencies to your application's Gemfile:

```ruby
gem "sassc-rails"

gem "bootstrap
```

Add this line to your application's Gemfile:

```ruby
gem "lato"
```

Create a css file **app/assets/stylesheet/lato.scss** to import bootstrap and override default style:

```scss
@import "bootstrap";
```

And then execute:

```bash
$ bundle
$ rails lato:install:migrations
$ rails db:migrate
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
  btstrap.nav = 'navbar-dark bg-primary'
end
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).