pin "lato/application", to: "lato/application.js"
pin_all_from Lato::Engine.root.join("app/assets/javascripts/lato/controllers"), under: "controllers", to: "lato/controllers"

pin "@rails/activestorage", to: "activestorage.esm.js", preload: true

pin "bootstrap", to: "bootstrap.js", preload: true
pin "local-time", to: "local-time.es2017-esm.js"
pin "lato/debounce", to: "lato/debounce.js"
# Vendored (verified against the cdnjs SRI hash) and loaded on demand by the web3 controller.
pin "ethers", to: "lato/vendor/ethers.esm.min.js", preload: false
