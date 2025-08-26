import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.loadHCaptcha()
  }

  loadHCaptcha() {
    if (window.hcaptcha) {
      window.hcaptcha.render(this.element)
    } else {
      const script = document.createElement('script')
      script.src = 'https://js.hcaptcha.com/1/api.js?onload=hcaptchaOnLoad&render=explicit'
      script.async = true
      script.defer = true
      window.hcaptchaOnLoad = () => {
        window.hcaptcha.render(this.element)
      }
      document.head.appendChild(script)
    }
  }
};
