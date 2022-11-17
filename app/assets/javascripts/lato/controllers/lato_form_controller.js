import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'submit',
    'input'
  ]

  /**
   * Stimulus
   */

  connect() {
    this.originalFormData = this.loadFormData()
    this.disableSubmit()
  }

  /**
   * Functions
   */

  disableSubmit() {
    if (!this.hasSubmitTarget) return
    this.submitTarget.setAttribute('disabled', true)
  }

  enableSubmit() {
    if (!this.hasSubmitTarget) return
    this.submitTarget.removeAttribute('disabled')
  }

  loadFormData() {
    const formData = {}

    this.inputTargets.forEach((input) => {
      if (input.type == 'checkbox') {
        formData[input.name] = input.checked
      } else {
        formData[input.name] = input.value
      }
    })

    return formData
  }

  /**
   * Actions
   */

  onInputChange(e) {
    e.target.classList.remove('is-invalid')

    const formData = this.loadFormData()
    if (JSON.stringify(formData) != JSON.stringify(this.originalFormData)) {
      this.enableSubmit()
    } else {
      this.disableSubmit()
    }
  }
}
