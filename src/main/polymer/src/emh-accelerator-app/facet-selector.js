/*
  Copyright (c) 2018. EasyMetaHub, LLC
 */
import {html, PolymerElement} from '@polymer/polymer/polymer-element.js';
import '@polymer/paper-button/paper-button.js';
import '@polymer/paper-checkbox/paper-checkbox.js';
import '@polymer/iron-collapse/iron-collapse.js';
/**
 * `facet-card`
 * 
 *
 * @customElement
 * @polymer
 * @demo demo/index.html
 */
class FacetSelector extends PolymerElement {
  static get template() {
    return html`
    <style>
      :host {
        display: block;
        padding-left: 5px;
        --paper-checkbox-label: {
        width: 175px;
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
        };
      }
      .counter {
        float:right;
        background: #ddd;
        border-radius: 2px;
      }
      
    </style>
    <template is="dom-repeat" items="{{facet.values}}">
      <div style="width: 90%;">
        <paper-checkbox on-change="checkboxChanged" name="[[facet.name]]:[[item.name]]" checked="{{item.selected}}" title="[[item.name]]">[[item.name]]</paper-checkbox>
        <span class="counter">[[item.count]]</span>
      </div>
    </template>
    <iron-collapse id="contentCollapse" opened="{{expanded}}">
      <template is="dom-repeat" items="{{facet.extvalues}}">
        <div style="width: 90%;">
          <paper-checkbox on-change="checkboxChanged" name="[[facet.name]]:[[item.name]]" checked="{{item.selected}}" title="[[item.name]]">[[item.name]]</paper-checkbox>
          <span class="counter">[[item.count]]</span>
        </div>
      </template>
    </iron-collapse>
    <paper-button on-tap="toggleExpand" id="expandText">more...</paper-button>
    `;
  }
  static get properties() {
    return {
      expanded: {
        type: Boolean,
        value: false,
        notify: true,
        observer: '_expandedChanged'
      },
      facet: { type: Object, notify: true, observer: '_facetChanged' }
    };
  }

    // Fires when an attribute was added, removed, or updated
    _expandedChanged(newVal, oldVal) {
      try {
      
        if (this.facet.extvalues) {
          if(this.expanded) {
            this.$.expandText.innerHTML = "less...";
          }
          else {
            this.$.expandText.innerHTML = "more...";
          }
        }
        else {
          this.$.expandText.innerHTML = "";
        }
      } catch(err) {
      }
    }

    _facetChanged(newVal, oldVal) {
      try {
      
        if (this.facet.extvalues) {
          if(this.expanded) {
            this.$.expandText.innerHTML = "less...";
          }
          else {
            this.$.expandText.innerHTML = "more...";
          }
        }
        else {
          this.$.expandText.innerHTML = "";
        }
      } catch(err) {
      }
    }

    toggleExpand() {
    this.expanded = !this.expanded;
    }

    checkboxChanged(event) {
      if (!this.selectedFacets) this.selectedFacets = [];
      
      if (event.target.checked) {
      this.push('selectedFacets', event.target.name);
      } else {
        // remove selected facet
      }
      this.notifyPath('selectedFacets');
    }

}

window.customElements.define('facet-selector', FacetSelector);
