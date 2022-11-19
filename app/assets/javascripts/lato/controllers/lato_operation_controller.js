import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'update'
  ]

  /**
   * Stimulus
   */

  connect() {
    if (this.hasUpdateTarget) {
      setTimeout(() => {
        this.updateTarget.click()
      }, 2000)
    }
  }
}