// Import turbo rails
import '@hotwired/turbo-rails'
// Import bootstrap js
import 'bootstrap'
// Import controllers (stimulus rails)
import 'controllers'
// Import local time js
import LocalTime from 'local-time'

/**
 * Setup local time to update time elements on page load and after turbo morph or frame render
 */

LocalTime.start()

document.addEventListener('turbo:morph', () => {
  LocalTime.run()
})

document.addEventListener('turbo:frame-render', () => {
  LocalTime.run()
})

/**
 * Include service worker
 */

if (navigator.serviceWorker) {
  navigator.serviceWorker
    .register('/service-worker.js', { scope: '/' })
    .then(() => navigator.serviceWorker.ready)
    .then((registration) => {
      const event = new window.CustomEvent('service-worker:ready', { detail: registration })
      document.dispatchEvent(event)
    })
    .then(() => window.console.log('[App]', 'Service worker registered! -> listen to \'service-worker:ready\' document event to get registration object'))
}

/**
 * Fix form inside turbo-frame tag with redirect
 * https://github.com/hotwired/turbo-rails/issues/440
 */

document.addEventListener('turbo:frame-missing', event => {
  event.preventDefault()
  event.detail.visit(event.detail.response)
})

/**
 * Manage page caching clean
 */

document.addEventListener('turbo:before-cache', (e) => {
  e.preventDefault()

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

  // close sidebar submenus
  document.querySelectorAll('aside .nav-item .collapse.show').forEach((el) => {
    if (el.querySelector('.nav-link.active')) return // keep open if contains active link
    el.classList.remove('show')
  })

  // close nav menu (for mobile)
  document.querySelector('.navbar-toggler').classList.add('collapsed')
  document.querySelector('.navbar-collapse').classList.remove('show')

  e.detail?.resume()
})
