import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

window.initGooglePlaces = () => {
  //emit event so we know when to connect controller
  const event = new CustomEvent("google-loaded", { bubbles: true, cancelable: true })
  window.dispatchEvent(event)
}

export { application }
