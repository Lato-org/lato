import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ['credential']
  static values = {
    options: Object
  }

  async authenticate(event) {
    event.preventDefault()

    if (!this.hasOptionsValue) {
      console.error('WebAuthn options not provided')
      return
    }

    try {
      // Log per debug
      console.log('WebAuthn options:', this.optionsValue)
      
      // Converti le options in formato corretto per il browser
      const publicKey = this.preparePublicKeyOptions(this.optionsValue)
      
      console.log('Prepared publicKey:', publicKey)
      
      // Richiedi l'autenticazione al browser
      const credential = await navigator.credentials.get({ publicKey })
      
      if (!credential) {
        alert('Autenticazione fallita')
        return
      }

      // Prepara il payload da inviare al server
      const credentialPayload = this.prepareCredentialPayload(credential)
      
      // Popola il campo hidden con il payload
      this.credentialTarget.value = JSON.stringify(credentialPayload)
      
      // Submit del form
      this.element.requestSubmit()
    } catch (error) {
      console.error('WebAuthn authentication error:', error)
      alert('Errore durante l\'autenticazione: ' + error.message)
    }
  }

  preparePublicKeyOptions(options) {
    return {
      challenge: this.base64urlToBuffer(options.challenge),
      timeout: options.timeout || 60000,
      rpId: options.rpId || options.rp_id,
      allowCredentials: (options.allowCredentials || options.allow_credentials || []).map(cred => {
        // Se cred è già un oggetto con id, usalo direttamente
        if (typeof cred === 'object' && cred.id) {
          return {
            id: this.base64urlToBuffer(cred.id),
            type: cred.type || 'public-key'
          }
        }
        // Altrimenti, assumiamo che cred sia una stringa base64
        return {
          id: this.base64urlToBuffer(cred),
          type: 'public-key'
        }
      }),
      userVerification: options.userVerification || options.user_verification || 'preferred'
    }
  }

  base64urlToBuffer(base64url) {
    // Converti base64url in base64 standard
    const base64 = base64url.replace(/-/g, '+').replace(/_/g, '/')
    // Aggiungi padding se necessario
    const padded = base64.padEnd(base64.length + (4 - base64.length % 4) % 4, '=')
    // Decodifica e converti in Uint8Array
    const binary = atob(padded)
    const bytes = new Uint8Array(binary.length)
    for (let i = 0; i < binary.length; i++) {
      bytes[i] = binary.charCodeAt(i)
    }
    return bytes
  }

  prepareCredentialPayload(credential) {
    return {
      id: credential.id,
      rawId: this.arrayBufferToBase64url(credential.rawId),
      type: credential.type,
      response: {
        clientDataJSON: this.arrayBufferToBase64url(credential.response.clientDataJSON),
        authenticatorData: this.arrayBufferToBase64url(credential.response.authenticatorData),
        signature: this.arrayBufferToBase64url(credential.response.signature),
        userHandle: credential.response.userHandle ? this.arrayBufferToBase64url(credential.response.userHandle) : null
      }
    }
  }

  arrayBufferToBase64url(buffer) {
    const bytes = new Uint8Array(buffer)
    let binary = ''
    for (let i = 0; i < bytes.byteLength; i++) {
      binary += String.fromCharCode(bytes[i])
    }
    // Converti in base64 standard
    const base64 = btoa(binary)
    // Converti in base64url (rimuovi padding e sostituisci caratteri)
    return base64.replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '')
  }
}
