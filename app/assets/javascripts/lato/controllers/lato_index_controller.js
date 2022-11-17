import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'modal',
    'modalBody',
    'action'
  ]

  /**
   * Stimulus
   */

  connect() {
    this.bsModal = new bootstrap.Modal(this.modalTarget)
  }

  disconnect() {
    this.bsModal.dispose()
    this.modalTarget.parentNode.removeChild(this.modalTarget)
  }

  actionTargetConnected(element) {
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

  onActionClick(e) {
    const targetTurboFrame = e.currentTarget.getAttribute('data-turbo-frame')
    this.openAction(targetTurboFrame)
  }
}
