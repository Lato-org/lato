import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    this.loadHiddenPreferenceFromCookies()
  }

  /**
   * Functions
   */

  toggle() {
    if (this.isMobile()) {
      document.body.classList.toggle('aside-open')
    } else {
      document.body.classList.toggle('aside-hidden')
      this.updateHiddenPreferenceOnCookies(document.body.classList.contains('aside-hidden'))
    } 
  }

  /**
   * Actions
   */

  onClickToggle(e) {
    e.preventDefault()
    if (this.isMobile()) {
      document.body.classList.toggle('aside-open')
    } else {
      document.body.classList.toggle('aside-hidden')
      this.updateHiddenPreferenceOnCookies(document.body.classList.contains('aside-hidden'))
    }
  }

  /**
   * Helpers
   */

  isMobile() {
    return window.innerWidth <= 1024
  }

  updateHiddenPreferenceOnCookies(hidden) {
    const date = new Date()
    date.setTime(date.getTime() + (365*24*60*60*1000)) // 1 year
    document.cookie = `lato_aside_hidden=${hidden}; expires=${date.toUTCString()}; path=/`
  }

  loadHiddenPreferenceFromCookies() {
    const match = document.cookie.match(new RegExp('(^| )lato_aside_hidden=([^;]+)'))
    if (match) {
      const hidden = match[2] === 'true'
      if (hidden) {
        document.body.classList.add('aside-hidden')
      } else {
        document.body.classList.remove('aside-hidden')
      }
    }
  }
};
