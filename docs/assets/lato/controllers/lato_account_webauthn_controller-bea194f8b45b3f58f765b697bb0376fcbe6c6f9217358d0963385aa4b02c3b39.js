import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['credentialInput', 'submit', 'status']
  static values = {
    options: Object,
    errorMessage: String
  }

  async connect() {
    if (!this.hasOptionsValue) return

    try {
      // Converti le options in formato corretto per il browser
      const publicKey = this.preparePublicKeyOptions(this.optionsValue)
      
      // Richiedi la creazione della credential al browser
      const credential = await navigator.credentials.create({ publicKey })
      
      if (!credential) {
        this.showError(this.errorMessageValue)
        return
      }

      // Prepara il payload da inviare al server
      const credentialPayload = this.prepareCredentialPayload(credential)
      
      // Popola il campo hidden con il payload
      this.credentialInputTarget.value = JSON.stringify(credentialPayload)
      
      // Submit automatico del form
      this.submitTarget.click()
    } catch (error) {
      console.error('WebAuthn error:', error)
      this.showError(this.errorMessageValue)
    }
  }

  preparePublicKeyOptions(options) {
    return {
      challenge: Uint8Array.from(atob(options.challenge.replace(/-/g, '+').replace(/_/g, '/')), c => c.charCodeAt(0)),
      rp: options.rp,
      user: {
        id: Uint8Array.from(atob(options.user.id), c => c.charCodeAt(0)),
        name: options.user.name,
        displayName: options.user.displayName
      },
      pubKeyCredParams: options.pubKeyCredParams,
      timeout: options.timeout,
      excludeCredentials: options.excludeCredentials?.map(cred => ({
        id: Uint8Array.from(atob(cred), c => c.charCodeAt(0)),
        type: 'public-key'
      })) || [],
      authenticatorSelection: {
        authenticatorAttachment: 'platform',
        requireResidentKey: false,
        userVerification: 'preferred'
      },
      attestation: 'none'
    }
  }

  prepareCredentialPayload(credential) {
    return {
      id: credential.id,
      rawId: this.arrayBufferToBase64(credential.rawId),
      type: credential.type,
      response: {
        clientDataJSON: this.arrayBufferToBase64(credential.response.clientDataJSON),
        attestationObject: this.arrayBufferToBase64(credential.response.attestationObject)
      }
    }
  }

  arrayBufferToBase64(buffer) {
    const bytes = new Uint8Array(buffer)
    let binary = ''
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i])
    }
    return btoa(binary)
  }

  showError(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.innerHTML = `
        <div class="alert alert-danger">
          <h4 class="alert-heading">${message}</h4>
        </div>
      `
    }
  }
};
