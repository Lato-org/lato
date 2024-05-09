// Import turbo rails
import "@hotwired/turbo-rails"
// Import bootstrap js
import "bootstrap"
// Import controllers (stimulus rails)
import "controllers"

/**
 * Include service worker
 */

if (navigator.serviceWorker) {
  navigator.serviceWorker.register("/service-worker.js", { scope: "/" })
  .then(() => navigator.serviceWorker.ready)
  .then((registration) => {
    const event = new CustomEvent("service-worker:ready", { detail: registration })
    document.dispatchEvent(event)
  })
  .then(() => console.log("[App]", "Service worker registered! -> listen to 'service-worker:ready' document event to get the registration object"))
}

/**
 * Fix form inside turbo-frame tag with redirect
 * https://github.com/hotwired/turbo-rails/issues/440
 */

document.addEventListener("turbo:frame-missing", event => {
  event.preventDefault()
  event.detail.visit(event.detail.response)
})

/**
 * Manage page transitions
 */

const PAGE_TRANSITION_TIME = 50

document.addEventListener('DOMContentLoaded', () => {
  // add is-loaded class
  document.body.classList.add('is-loaded')
})

document.addEventListener('turbo:load', () => {
  setTimeout(() => {
    // add is-loaded class
    document.body.classList.add('is-loaded')
  }, PAGE_TRANSITION_TIME)
})

document.addEventListener('turbo:before-cache', (e) => {
  console.log('turbo:before-cache')

  e.preventDefault()

  // remove is-loaded class
  document.body.classList.remove('is-loaded')

  // hide aside menu (for mobile)
  document.body.classList.remove('aside-open')

  // hide modals and make body scrollable
  document.querySelectorAll('.modal.show').forEach((el) => {
    el.classList.remove('show')
    el.style.display = 'none'
  })
  document.querySelectorAll('.modal-backdrop').forEach((el) => {
    el.remove()
  })
  document.body.classList.remove('modal-open')
  document.body.style.paddingRight = ''
  document.body.style.overflow = ''

  setTimeout(() => {
    e.detail.resume()
  }, PAGE_TRANSITION_TIME)
})
