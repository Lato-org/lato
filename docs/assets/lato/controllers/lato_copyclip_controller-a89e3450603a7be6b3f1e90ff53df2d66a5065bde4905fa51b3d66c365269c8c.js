import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'input',
    'button'
  ]

  connect() {
    if (this.hasButtonTarget) {
      this.buttonTargetOriginalHTML = this.buttonTarget.innerHTML
    }

    // Live region created up front: screen readers only announce changes to a region already in the DOM.
    this.statusElement = document.createElement('span')
    this.statusElement.className = 'visually-hidden'
    this.statusElement.setAttribute('role', 'status')
    this.statusElement.setAttribute('aria-live', 'polite')
    this.element.appendChild(this.statusElement)
  }

  disconnect() {
    if (this._copyTimeout) clearTimeout(this._copyTimeout)
    this.statusElement?.remove()
  }

  onButtonClick(e) {
    e.preventDefault()

    this.copy()
  }

  async copy() {
    if (!this.hasInputTarget) return

    // Copy the text inside the text field
    this.inputTarget.select()
    this.inputTarget.setSelectionRange(0, 99999) // For mobile devices

    // Copy the text inside the text field
    try {
      await navigator.clipboard.writeText(this.inputTarget.value)
    } catch (error) {
      console.error(error)
      return
    }

    const copiedText = (this.hasButtonTarget && this.buttonTarget.dataset.copyText) || 'Copied!'
    this.statusElement.textContent = copiedText

    // Manage button state
    if (this._copyTimeout) clearTimeout(this._copyTimeout)
    if (this.hasButtonTarget) this.buttonTarget.textContent = copiedText
    this._copyTimeout = setTimeout(() => {
      if (this.hasButtonTarget) this.buttonTarget.innerHTML = this.buttonTargetOriginalHTML
      this.statusElement.textContent = ''
    }, 2000)
  }
};
