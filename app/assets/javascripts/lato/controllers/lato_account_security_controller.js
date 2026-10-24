import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['credential', 'error']
  static values = { challengeUrl: String, webauthn: Boolean }

  connect () {
    this.form = this.element.closest('form')
    this.onSubmit = this.confirm.bind(this)
    this.form.addEventListener('submit', this.onSubmit)
  }

  disconnect () {
    this.form.removeEventListener('submit', this.onSubmit)
  }

  async confirm (event) {
    if (!this.webauthnValue || this.confirmed) return
    event.preventDefault()
    event.stopImmediatePropagation()
    this.errorTarget.textContent = ''
    try {
      const response = await fetch(this.challengeUrlValue, {
        method: 'POST',
        headers: { Accept: 'application/json', 'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content }
      })
      if (!response.ok) throw new Error('Unable to request security key confirmation.')
      const publicKey = await response.json()
      const decode = value => Uint8Array.from(atob(value.replace(/-/g, '+').replace(/_/g, '/')), c => c.charCodeAt(0))
      publicKey.challenge = decode(publicKey.challenge)
      publicKey.allowCredentials = publicKey.allowCredentials.map(credential => ({ ...credential, id: decode(credential.id) }))
      const credential = await navigator.credentials.get({ publicKey })
      const encode = buffer => btoa(String.fromCharCode(...new Uint8Array(buffer)))
      this.credentialTarget.value = JSON.stringify({
        id: credential.id,
        rawId: encode(credential.rawId),
        type: credential.type,
        response: {
          clientDataJSON: encode(credential.response.clientDataJSON),
          authenticatorData: encode(credential.response.authenticatorData),
          signature: encode(credential.response.signature),
          userHandle: credential.response.userHandle ? encode(credential.response.userHandle) : null
        }
      })
      this.confirmed = true
      this.form.requestSubmit(event.submitter)
    } catch (error) {
      this.errorTarget.textContent = 'Security key confirmation failed. Try again.'
    }
  }
}
