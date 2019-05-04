import {PolymerElement, html} from '@polymer/polymer/polymer-element.js';
import '@polymer/paper-button/paper-button.js';

/**
 * @customElement
 * @polymer
 */
class ResultItemButton extends PolymerElement {
  static get template() {
    return html`
    <style>
    paper-button {
      padding-top: 4px;
      padding-bottom: 3px;
    }
    </style>
    <paper-button raised on-click="selectLink">[[item.name]]</paper-button>
    `;
  }
  static get properties() {
    return {
      item: { type: Object, notify: true },
      params: { type: Object, notify: true }
    };
  }

  selectLink() {
    var separator = "~~";
    var tArray = [this.item.glossary, this.item.label];
    this.set('params', { facets: tArray.join(separator) });
    this.notifyPath('params');
  }
}

window.customElements.define('result-item-button', ResultItemButton);
