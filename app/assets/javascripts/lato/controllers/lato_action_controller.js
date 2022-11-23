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
    this.bsModals = []
    this.usedModals = []

    this.modalTargets.forEach((modalTarget, index) => {
      this.bsModals.push(new bootstrap.Modal(modalTarget))

      modalTarget.addEventListener('show.bs.modal', () => {
        this.usedModals.push(index)
      })
      modalTarget.addEventListener('hide.bs.modal', () => {
        this.usedModals = this.usedModals.filter((i) => i != index)
        this.modalBodyTargets[index].innerHTML = ''
      })
    })
  }

  disconnect() {
    this.bsModals.forEach((bsModal) => {
      bsModal.dispose()
    })
  }

  triggerTargetConnected(element) {
    element.addEventListener('click', (e) => this.openAction(this.loadOptionsFromTriggerElement(element)))
  }

  /**
   * Functions
   */

  openAction(options) {
    const index = this.getFreeModalIndex()

    if (options.turboFrame && options.turboFrame != '_top') {
      this.modalBodyTargets[index].innerHTML = `<turbo-frame id="${options.turboFrame}"></turbo-frame>`

      if (options.actionTitle) {
        this.modalTitleTargets[index].innerHTML = options.actionTitle
      } else {
        this.modalTitleTargets[index].innerHTML = ''
      }

      if (options.actionSize) {
        this.modalDialogTargets[index].classList.add(`modal-${options.actionSize}`)
      } else {
        this.modalDialogTargets[index].classList.remove('modal-lg')
        this.modalDialogTargets[index].classList.remove('modal-xl')
        this.modalDialogTargets[index].classList.remove('modal-sm')
      }

      this.bsModals[index].show()
    }
  }

  loadOptionsFromTriggerElement(element) {
    const options = {}
    options.turboFrame = element.getAttribute('data-turbo-frame')
    options.actionTitle = element.getAttribute('data-action-title')
    options.actionSize = element.getAttribute('data-action-size')
    return options
  }

  getFreeModalIndex() {
    for (let i = 0; i < this.modalTargets.length; i++) {
      if (!this.usedModals.includes(i)) return i
    }
  }

  /**
   * Actions
   */

  onTriggerClick(e) {
    this.openAction(this.loadOptionsFromTriggerElement(e.currentTarget))
  }
}
