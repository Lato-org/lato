import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  /**
   * Stimulus
   */

  connect() {
    this.tooltip = new bootstrap.Tooltip(this.element)
  }

  disconnect() {
    this.tooltip.dispose()
  }
}
