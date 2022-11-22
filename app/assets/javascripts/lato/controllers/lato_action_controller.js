import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'trigger',
    'modal',
    'modalBody',
    'modalTitle',
    'modalDialog'
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
    element.addEventListener('click', (e) => this.openAction(this.loadOptionsFromTriggerElement(element)))
  }

  /**
   * Functions
   */

  openAction(options) {
    if (options.turboFrame && options.turboFrame != '_top') {
      this.modalBodyTarget.innerHTML = `<turbo-frame id="${options.turboFrame}"></turbo-frame>`

      if (options.actionTitle) {
        this.modalTitleTarget.innerHTML = options.actionTitle
      } else {
        this.modalTitleTarget.innerHTML = ''
      }

      if (options.actionSize) {
        this.modalDialogTarget.classList.add(`modal-${options.actionSize}`)
      } else {
        this.modalDialogTarget.classList.remove('modal-lg')
        this.modalDialogTarget.classList.remove('modal-xl')
        this.modalDialogTarget.classList.remove('modal-sm')
      }

      this.bsModal.show()
    }
  }

  loadOptionsFromTriggerElement(element) {
    const options = {}
    options.turboFrame = element.getAttribute('data-turbo-frame')
    options.actionTitle = element.getAttribute('data-action-title')
    options.actionSize = element.getAttribute('data-action-size')
    return options
  }

  /**
   * Actions
   */

  onTriggerClick(e) {
    this.openAction(this.loadOptionsFromTriggerElement(e.currentTarget))
  }
}
