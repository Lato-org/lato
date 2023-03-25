pin "lato/application", to: "lato/application.js"
pin_all_from Lato::Engine.root.join("app/assets/javascripts/lato/controllers"), under: "controllers", to: "lato/controllers"

pin "bootstrap", to: "bootstrap.js", preload: true
# pin "@popperjs/core", to: "popper.js", preload: true
pin "lodash", to: "https://ga.jspm.io/npm:lodash@4.17.21/lodash.js"
