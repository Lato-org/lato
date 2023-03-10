// Import turbo rails
import "@hotwired/turbo-rails"
// Import bootstrap js
import "bootstrap"
// Import controllers (stimulus rails)
import "controllers"

// Close sidebar before page change with turbo
document.addEventListener("turbo:before-visit", (e) => {
  document.body.classList.remove('aside-open')
})

// Close all boostrap modals before page change with turbo
// NOTE: This is not a good solution, but it seems to work
document.addEventListener("turbo:before-visit", (e) => {
  document.querySelectorAll('.modal').forEach((modal) => {
    modal.classList.remove('show')
  })
})