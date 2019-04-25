/*
  Copyright (c) 2018. EasyMetaHub, LLC
 */
import {html, PolymerElement} from '@polymer/polymer/polymer-element.js';
import '@polymer/paper-card/paper-card.js';
import '@polymer/paper-button/paper-button.js';
import './facet-selector.js'
/**
 * `facet-card`
 * 
 *
 * @customElement
 * @polymer
 * @demo demo/index.html
 */
class FacetCard extends PolymerElement {
  static get template() {
    return html`
    <style>
      :host {
        display: block;
      }
      
      paper-card {
      width: 100%;
      font-size: 10px;
      margin: 5px;
      padding-top: 5px;
      }
      paper-button {
      float:right;
      }
      .title {
        display:block;
        height: 30px;
        margin-left: 20px;
        margin-right: 20px;
      }
      
      .title span {
        font-weight: bold;
        font-size: 15px;
        line-height: 30px;
      }
      
    </style>
    <paper-card class="facet">
      <div class="title">
        <span>[[facet.name]]</span>
      </div>
      <!-- template is="dom-if" if="[[facet.min]]">
        <facet-range facet="{{facet}}"></facet-range>
      </template -->
      <template is="dom-if" if="[[!facet.min]]">
        <facet-selector facet="{{facet}}"></facet-selector>
      </template>   
    </paper-card>
    `;
  }
  static get properties() {
    return {
      facet: { type: Object, notify: true }
    };
  }
}

window.customElements.define('facet-card', FacetCard);
