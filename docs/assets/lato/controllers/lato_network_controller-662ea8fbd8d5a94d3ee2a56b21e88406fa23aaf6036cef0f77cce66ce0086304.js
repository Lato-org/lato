import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'online',
    'offline'
  ]

  /**
   * Stimulus
   */

  connect() {
    window.addEventListener('online', this.onNetworkOnline.bind(this))
    window.addEventListener('offline', this.onNetworkOffline.bind(this))

    if (!navigator.onLine) {
      this.onNetworkOffline()
    }
  }

  disconnect() {
    window.removeEventListener('online', this.onNetworkOnline.bind(this))
    window.removeEventListener('offline', this.onNetworkOffline.bind(this))
    if (this.timeout) clearTimeout(this.timeout)
  }

  /**
   * Events
   */

  onNetworkOnline() {
    this.element.classList.remove('d-none')
    this.onlineTarget.classList.remove('d-none')
    this.offlineTarget.classList.add('d-none')

    if (this.timeout) clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.classList.add('d-none')
    }, 5000)
  }

  onNetworkOffline() {
    this.element.classList.remove('d-none')
    this.onlineTarget.classList.add('d-none')
    this.offlineTarget.classList.remove('d-none')

    if (this.timeout) clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.classList.add('d-none')
    }, 5000)
  }
};
