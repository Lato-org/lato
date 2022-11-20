import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'trigger',
    'modal',
    'modalBody'
  ]

  /**
   * Stimulus
   */

  connect() {
    this.bsModal = new bootstrap.Modal(this.modalTarget)
  }

  disconnect() {
    this.bsModal.dispose()
  }

  triggerTargetConnected(element) {
    element.addEventListener('click', (e) => this.openAction(element.getAttribute('data-turbo-frame')))
  }

  /**
   * Functions
   */

  openAction(turboFrame) {
    if (turboFrame && turboFrame != '_top') {
      this.modalBodyTarget.innerHTML = `<turbo-frame id="${turboFrame}"></turbo-frame>`
      this.bsModal.show()
    }
  }

  /**
   * Actions
   */

  onTriggerClick(e) {
    const targetTurboFrame = e.currentTarget.getAttribute('data-turbo-frame')
    this.openAction(targetTurboFrame)
  }
}
