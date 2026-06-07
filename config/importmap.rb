pin "lato/application", to: "lato/application.js"
pin_all_from Lato::Engine.root.join("app/assets/javascripts/lato/controllers"), under: "controllers", to: "lato/controllers"

pin "@rails/activestorage", to: "activestorage.esm.js", preload: true

pin "bootstrap", to: "bootstrap.js", preload: true
# pin "@popperjs/core", to: "popper.js", preload: true
pin "local-time", to: "https://ga.jspm.io/npm:local-time@3.0.3/app/assets/javascripts/local-time.es2017-esm.js"
pin "lodash", to: "https://ga.jspm.io/npm:lodash@4.17.21/lodash.js"
