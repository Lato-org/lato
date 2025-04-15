import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'update',
    'outputFile'
  ]

  /**
   * Stimulus
   */

  connect() {
    if (this.hasUpdateTarget) {
      this._timeout = setTimeout(() => {
        this.updateTarget.click()
      }, 2000)
    }
  }

  disconnect() {
    if (this._timeout) clearTimeout(this._timeout)
  }

  outputFileTargetConnected(element) {
    element.click()
  }
};
