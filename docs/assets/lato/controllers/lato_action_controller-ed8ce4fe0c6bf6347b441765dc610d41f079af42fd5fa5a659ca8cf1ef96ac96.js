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
    this.returnFocusElements = []

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
      // Programmatic show() does not restore focus like data-bs-toggle does: give it back to the trigger.
      modalTarget.addEventListener('hidden.bs.modal', () => {
        const element = this.returnFocusElements[index]
        this.returnFocusElements[index] = null
        if (element && element.isConnected) element.focus()
      })
      modalTarget.addEventListener('hide.bs.modal', () => {
        setTimeout(() => {
          this.usedModals = this.usedModals.filter((i) => i != index)
          this.modalBodyTargets[index].replaceChildren()
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
      modalTitleTarget.textContent = ''
    })

    // clean modalBody content
    this.modalBodyTargets.forEach((modalBodyTarget) => {
      modalBodyTarget.replaceChildren()
    })
  }

  triggerTargetConnected(element) {
    element.addEventListener('click', (e) => {
      this.openAction(this.loadOptionsFromTriggerElement(element), e, this._loadConfirmMessage(element))
    })
  }

  triggerSubmitTargetConnected(element) {
    element.addEventListener('submit', (e) => {
      this.openAction(this.loadOptionsFromTriggerElement(element), e, this._loadConfirmMessage(element))
    })
  }

  // NOTE: Dato che turbo-confirm non riesce a co-esistere con lato_action_controller,
  //       rimuoviamo l'attributo data-turbo-confirm dall'elemento e lo gestiamo
  //       manualmente all'interno di openAction.
  _loadConfirmMessage(element) {
    let confirmData = null
    if (element && element.hasAttribute('data-turbo-confirm')) {
      confirmData = element.getAttribute('data-turbo-confirm')
      element.removeAttribute('data-turbo-confirm')
    }
    return confirmData
  }

  /**
   * Functions
   */

  openAction(options, event, confirmMessage = null) {
    // NOTE: Al momento non riusciamo a utilizzare lato_confirm_controller per gestire le conferme
    //       in quanto è asincrono e richiede di annullare l'evento in modo sincrono.
    //       Per questo motivo, per ora, gestiamo le conferme con il classico window.confirm.
    if (confirmMessage) {
      const result = window.confirm(confirmMessage)
      if (!result) {
        event.preventDefault()
        return
      }
    }

    const index = this.getFreeModalIndex()

    if (options.turboFrame && options.turboFrame != '_top') {
      // Build nodes instead of HTML strings: frame id and title come from element attributes.
      const turboFrame = document.createElement('turbo-frame')
      turboFrame.id = options.turboFrame
      turboFrame.setAttribute('aria-busy', 'true')
      turboFrame.addEventListener('turbo:frame-load', () => turboFrame.removeAttribute('aria-busy'), { once: true })
      const placeholder = document.createElement('div')
      placeholder.className = 'placeholder-glow'
      for (let i = 0; i < options.actionRows; i++) {
        const row = document.createElement('span')
        row.className = 'placeholder placeholder-lg col-12'
        placeholder.appendChild(row)
      }
      turboFrame.appendChild(placeholder)
      this.modalBodyTargets[index].replaceChildren(turboFrame)

      this.modalTitleTargets[index].textContent = options.actionTitle || ''

      if (options.actionSize) {
        this.modalDialogTargets[index].classList.remove('modal-md')
        this.modalDialogTargets[index].classList.remove('modal-xl')
        this.modalDialogTargets[index].classList.remove('modal-lg')
        this.modalDialogTargets[index].classList.remove('modal-sm')
        this.modalDialogTargets[index].classList.add(`modal-${options.actionSize}`)
      }

      this.returnFocusElements[index] = document.activeElement
      this.bsModals[index].show()
    }
  }

  loadOptionsFromTriggerElement(element) {
    const options = {}
    options.turboFrame = element.getAttribute('data-turbo-frame')
    options.actionTitle = element.getAttribute('data-action-title')
    options.actionSize = element.getAttribute('data-action-size') || 'md'
    options.actionRows = element.getAttribute('data-action-rows')
    options.actionRows = options.actionRows ? parseInt(options.actionRows) : 4
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
    this.openAction(this.loadOptionsFromTriggerElement(e.currentTarget), e)
  }
};
