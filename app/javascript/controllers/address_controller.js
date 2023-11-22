import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    'input',
    'postal_code',
    'latitude',
    'longitude'
  ]
  connect() {
    if(window.google) {
      this.initGoogle();
    }
  }

  initGoogle() {
    this.autocomplete = new google.maps.places.Autocomplete(this.inputTarget, {
      componentRestrictions: { country: ["us"] },
      fields: ["address_components", "geometry"],
      types: ["address"],
    })
    this.autocomplete.addListener('place_changed', this.addressSelected.bind(this))
  }

  addressSelected() {
    const place = this.autocomplete.getPlace();

    // grab lat and long for weather forecast
    this.latitudeTarget.value = place.geometry.location.lat()
    this.longitudeTarget.value = place.geometry.location.lng()

    // grab the zipcode for caching purposes
    for (const component of place.address_components) {
      const componentType = component.types[0];
  
      switch (componentType) {
        case "postal_code": {
          this.postal_codeTarget.value = `${component.long_name}`;
          break;
        }
        case "postal_code_suffix": {
          this.postal_codeTarget.value = `${this.postal_codeTarget.value}-${component.long_name}`;
          break;
        }
     }
    }
  }
}
