import { Controller } from "@hotwired/stimulus"

// Asks the browser wallet to sign the server nonce, then submits the form with address and signature.
// Empty values are submitted when no wallet is available or the user rejects the request: the server handles the error.
export default class extends Controller {
  static targets = ['nonce', 'address', 'signedNonce', 'submit']

  async connect() {
    const { ethers } = await import('ethers')

    let address = ''
    let signedNonce = ''

    try {
      if (window.ethereum) {
        const provider = new ethers.providers.Web3Provider(window.ethereum)
        await provider.send('eth_requestAccounts', [])
        const signer = provider.getSigner()
        address = await signer.getAddress()
        signedNonce = await signer.signMessage(this.nonceTarget.textContent)
      }
    } catch (error) {
      console.error(error)
    }

    this.addressTarget.value = address
    this.signedNonceTarget.value = signedNonce
    this.submitTarget.click()
  }
};
