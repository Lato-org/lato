import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'modalBody'
  ]

  connect() {
    this.modal = new bootstrap.Modal(this.element)
    Turbo.config.forms.confirm = this.customConfirm.bind(this)

    this.element.addEventListener('show.bs.modal', () => {
      this.element.style.zIndex = 2001

      // update backdrop z-index to be sure is always above other modals
      setTimeout(() => { // use setTimeout because bsModalBackdropElement is not always ready after 'show.bs.modal' event
        const bsModalBackdropElement = this.modal._backdrop._element
        if (bsModalBackdropElement) bsModalBackdropElement.style.zIndex = 2000
      }, 1)
    })

    // Any dismissal (backdrop, ESC, close button) must settle the pending confirm, otherwise the form hangs.
    this.element.addEventListener('hidden.bs.modal', () => {
      this.resolveConfirm(false)
      this.modalBodyTarget.textContent = ''
      // Programmatic show() does not restore focus like data-bs-toggle does: give it back to the trigger.
      if (this._returnFocusElement && this._returnFocusElement.isConnected) this._returnFocusElement.focus()
      this._returnFocusElement = null
    })
  }

  disconnect() {
    this.resolveConfirm(false)
    Turbo.config.forms.confirm = window.confirm
  }

  customConfirm(message) {
    this.resolveConfirm(false)
    this._returnFocusElement = document.activeElement
    // textContent: the message comes from data-turbo-confirm and may include user data.
    this.modalBodyTarget.textContent = message
    this.modal.show()

    return new Promise(resolve => { this._resolve = resolve })
  }

  confirmSuccess() {
    this.resolveConfirm(true)
    this.modal.hide()
  }

  confirmCancel() {
    this.resolveConfirm(false)
    this.modal.hide()
  }

  resolveConfirm(result) {
    if (!this._resolve) return

    this._resolve(result)
    this._resolve = null
  }
};
