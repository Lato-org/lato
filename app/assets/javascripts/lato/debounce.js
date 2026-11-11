// Delays fn until wait ms have passed without new calls.
export default function debounce (fn, wait) {
  let timeout
  return function (...args) {
    clearTimeout(timeout)
    timeout = setTimeout(() => fn.apply(this, args), wait)
  }
}
