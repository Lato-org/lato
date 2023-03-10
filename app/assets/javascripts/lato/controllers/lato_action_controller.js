import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'trigger',
    'triggerSubmit',
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

        // update backdrop z-index in case of multiple opened modals
        setTimeout(() => { // use setTimeout because bsModalBackdropElement is not always ready after 'show.bs.modal' event
          if (this.usedModals.length > 1) {
            for (let i = 0; i < this.usedModals.length; i++) {
              const bsModal = this.bsModals[this.usedModals[i]]
  
              const bsModalElement = bsModal._element
              if (bsModalElement) bsModalElement.style.zIndex = 1055 + i + 1
  
              const bsModalBackdropElement = bsModal._backdrop._element
              if (bsModalBackdropElement) bsModalBackdropElement.style.zIndex = 1055 + i
            }
          }
        }, 1)
      })
      modalTarget.addEventListener('hide.bs.modal', () => {
        setTimeout(() => {
          this.usedModals = this.usedModals.filter((i) => i != index)
          this.modalBodyTargets[index].innerHTML = ''
        }, 500)
      })
    })
  }

  disconnect() {
    // call dispose to all bootstrap modals (clear bootstrap modal)
    this.bsModals.forEach((bsModal) => {
      bsModal.dispose()
    })

    // clean modalTitle content
    this.modalTitleTargets.forEach((modalTitleTarget) => {
      modalTitleTarget.innerHTML = ''
    })

    // clean modalBody content
    this.modalBodyTargets.forEach((modalBodyTarget) => {
      modalBodyTarget.innerHTML = ''
    })
  }

  triggerTargetConnected(element) {
    element.addEventListener('click', (e) => this.openAction(this.loadOptionsFromTriggerElement(element)))
  }

  triggerSubmitTargetConnected(element) {
    element.addEventListener('submit', (e) => this.openAction(this.loadOptionsFromTriggerElement(element)))
  }

  /**
   * Functions
   */

  openAction(options) {
    const index = this.getFreeModalIndex()

    if (options.turboFrame && options.turboFrame != '_top') {
      this.modalBodyTargets[index].innerHTML = `
      <turbo-frame id="${options.turboFrame}">
      <div class="placeholder-glow">
        <span class="placeholder placeholder-lg col-12"></span>
        <span class="placeholder placeholder-lg col-12"></span>
        <span class="placeholder placeholder-lg col-12"></span>
        <span class="placeholder placeholder-lg col-12"></span>
      </div>
      </turbo-frame>
      `

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

  onTriggerRun(e) {
    this.openAction(this.loadOptionsFromTriggerElement(e.currentTarget))
  }
}
