import {html, PolymerElement} from '@polymer/polymer/polymer-element.js';

/**
 * @customElement
 * @polymer
 */
class EmhGlossaryAdminApp extends PolymerElement {
  static get template() {
    return html`
      <style>
        :host {
          display: block;
        }
      </style>
      <h2>Hello [[prop1]]!</h2>
    `;
  }
  static get properties() {
    return {
      prop1: {
        type: String,
        value: 'emh-glossary-admin-app'
      }
    };
  }
}

window.customElements.define('emh-glossary-admin-app', EmhGlossaryAdminApp);
