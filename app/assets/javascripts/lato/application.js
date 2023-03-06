// Import turbo rails
import "@hotwired/turbo-rails"
// Import bootstrap js
import "bootstrap"
// Import controllers (stimulus rails)
import "controllers"

// Close sidebar before page change with turbo
document.addEventListener("turbo:before-visit", () => {
  document.body.classList.remove('aside-open')
})
