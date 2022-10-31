# Lato
Basic engine for all Lato projects.

## Installation
Add required dependencies to your application's Gemfile:

```ruby
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails" # NOTE: Probably already installed in default rails 7 project

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails" # NOTE: Probably already installed in default rails 7 project

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails" # NOTE: Probably already installed in default rails 7 project

# Use Kredis as Redis interface [https://github.com/rails/kredis]
# NOTE: Installation -> https://github.com/rails/kredis#installation
gem "kredis"

# Use Sass to process CSS
gem "sassc-rails"

# Use lato as application panel
gem "lato"
```

Install gem and run required tasks:

```bash
$ bundle
$ rails lato:install:application
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

Import Lato Scss on **app/assets/stylesheets/application.scss** file:
```scss
@import 'lato/application';

// ....
```

Import Lato Js on **app/javascript/application.js** file:
```js
import "lato/application";

// ....
```

Setup italian locale to the application (currently Lato works with IT locale) on the **config/application.rb** file:

```ruby
module MyApplication
  class Application < Rails::Application
    config.i18n.available_locales = [:it]
    config.i18n.default_locale = :it

    # ...
  end
end

```

## Customization
Lato can be customized on every part. Customization can be done by N ways:
- Customize the engine configuration;
- Customize layout boostrap classes;
- Customize view content partials;

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

### Customize view content partials
Override lato content partials on main application and edit it's HTML.
Content partials are specific partial files with this format **partial-name_content** created to helps to override lato pages content without override a full page.
For example, to customize the navbar brand, create a partial file in **app/views/layouts/lato/_navbar-brand_content.html.erb** and add your custom code:

```html
<img src="./logo.jpg" class="custom-logo" alt="My custom logo">
```

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## To do
- Account plans
