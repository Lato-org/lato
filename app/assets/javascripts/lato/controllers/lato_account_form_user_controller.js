import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'emailInput',
    'validateEmailLink'
  ]

  connect() {
    if (this.hasEmailInputTarget) this.emailInputOriginalValue = this.emailInputTarget.value
  }

  onEmailKeyUp(e) {
    if (!this.hasEmailInputTarget || !this.hasValidateEmailLinkTarget) return

    const newEmailInputValue = this.emailInputTarget.value
    if (this.emailInputOriginalValue !== newEmailInputValue) {
      this.validateEmailLinkTarget.classList.add('opacity-50')
      this.validateEmailLinkTarget.style.pointerEvents = 'none'
    } else {
      this.validateEmailLinkTarget.classList.remove('opacity-50')
      this.validateEmailLinkTarget.style.pointerEvents = 'auto'
    }
  } 
}
