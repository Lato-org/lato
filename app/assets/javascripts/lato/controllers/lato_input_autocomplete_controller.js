import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    path: String
  }

  /**
   * Stimulus
   */

  connect() {
    this.element.addEventListener('keyup', (e) => {
      this.search(e)
    })
  }
}
