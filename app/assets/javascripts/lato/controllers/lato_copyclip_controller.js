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
  }

  onButtonClick(e) {
    e.preventDefault()

    this.copy()
  }

  copy() {
    if (!this.hasInputTarget) return

    // Copy the text inside the text field
    this.inputTarget.select()
    this.inputTarget.setSelectionRange(0, 99999) // For mobile devices

    // Copy the text inside the text field
    navigator.clipboard.writeText(this.inputTarget.value)

    // Manage button state
    if (this.hasButtonTarget) {
      this.buttonTarget.innerHTML = this.buttonTarget.dataset.copyText || 'Copied!'
      
      if (this._copyTimeout) clearTimeout(this._copyTimeout)
      this._copyTimeout = setTimeout(() => {
        this.buttonTarget.innerHTML = this.buttonTargetOriginalHTML
      }, 2000)
    }
  }
}
