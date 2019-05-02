/*
  Copyright (c) 2018. EasyMetaHub, LLC

  TODO: Customize for project specifics.

 */
import {PolymerElement, html} from '@polymer/polymer/polymer-element.js';
import {GestureEventListeners} from '@polymer/polymer/lib/mixins/gesture-event-listeners.js';
import '@polymer/paper-card/paper-card.js';
import '@polymer/iron-collapse/iron-collapse.js';
import '@polymer/iron-icons/iron-icons.js';
import '@polymer/paper-icon-button/paper-icon-button.js';
import '@polymer/paper-button/paper-button.js';
import '@vaadin/vaadin-grid/vaadin-grid.js';
import './search-snippet-highlight.js';

/**
 * @customElement
 * @polymer
 */
class ResultItem extends GestureEventListeners(PolymerElement) {
  static get template() {
    return html`
    <style>
      :host {
        display: block;
        }
      paper-card {
        width: 100%;
      }
      .circle {
        display: inline-block;
        height: 24px;
        min-width: 24px;
        border-radius: 50%;
        background: #ddd;
        line-height: 24px;
        font-size: 10px;
        color: #555;
        text-align: center;
        padding-left: 2px;
        padding-right: 2px;
        margin-right: 5px;
      }
      .conceptcard {
        background-color: #fafafa;
        border-radius: 3px;
        padding: 5px;
        font-size: 16px;
      }
      .card-content {
        padding-top: 5px;
        padding-bottom: 5px;
        font-size: 10px;
      }
      paper-button.label {
        padding: 1px;
      }
      .term {
        font-size: 14px;
      }
      expanded-card {
        padding-top: 1px;
        padding-bottom: 1px;
      }
      ul.cptInstanceMetadata {
        list-style: none;
      }
    </style>
      <paper-card>
        <div class="card-content">
          <div>
            <div class="circle">[[item.index]]</div>
            <template is="dom-if" if="[[editable]]">
              <paper-icon-button icon="delete" raised></paper-icon-button>
            </template>
            <span class="term">[[item.concept.term]]</span>
          </div>
          <template is="dom-repeat" items="[[item.snippets]]">
            <search-snippet-highlight snippet="[[item]]"></search-snippet-highlight>
          </template>
          <template is="dom-if" if="[[item.grid]]">
            <vaadin-grid theme="compact row-stripes" items="[[item.grid.rows]]"  height-by-rows>
              <template is="dom-repeat" items="[[item.grid.columns]]" as="column">
                <vaadin-grid-column>
                  <template class="header">[[column]]</template>
                  <template>[[get(column, item)]]</template>
                </vaadin-grid-column>
              </template>
            </vaadin-grid>
          </template>
          <paper-icon-button on-tap="toggleExpand" class="self-end" id="expandButton"></paper-icon-button>
          <paper-button on-tap="toggleExpand" id="expandText">Show details</paper-button>
          <iron-collapse id="contentCollapse" opened="{{expanded}}">
            <div class="conceptcard">
              <template is="dom-if" if="[[item.concept.altlabel]]">
                <h5>AltLabel</h5>
                <p>[[item.concept.altlabel]]</p>
              </template>
              <h5>Definition</h5>
              <template is="dom-repeat" items="[[item.concept.definition]]">
                <p>[[item]]</p>
              </template>
              <h5>Related</h5>
              <template is="dom-repeat" items="[[item.concept.related]]">
                <paper-button class="label" raised>[[item.name]]</paper-button>
              </template>
              <h5>Broader</h5>
              <template is="dom-repeat" items="[[item.concept.broader]]">
                <paper-button class="label" raised>[[item.name]]</paper-button>
              </template>
              <h5>Narrower 
                  <template is="dom-if" if="[[editable]]">
                    <paper-icon-button icon="add" raised></paper-icon-button>
                  </template>
              </h5>
              <template is="dom-repeat" items="[[item.concept.narrower]]">
                <paper-button class="label" raised>[[item.name]]</paper-button>
              </template>
            </div>
          </iron-collapse>
        </div>
      </paper-card>
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
      item: { type: Object, notify: true },
      editable: { type: Boolean, value:false }
    };
  }

    // Fires when the local DOM has been fully prepared
    ready() {
      super.ready();
    //Set initial icon
      if(this.expanded) {
        this.$.expandButton.icon = "icons:expand-less";
        this.$.expandText.innerHTML = "Hide details";
      }
      else {
        this.$.expandButton.icon = "icons:expand-more";
        this.$.expandText.innerHTML = "Show details";
      }
    }
    // Fires when an attribute was added, removed, or updated
    _expandedChanged(newVal, oldVal) {
    
      //If icon is already set no need to animate!
      if((newVal && (this.$.expandButton.icon == "icons:expand-less")) || (!newVal && (this.$.expandButton.icon == "icons:expand-more"))) {
        return;
      }
      
      if(this.expanded) {
        this.$.expandButton.icon = "icons:expand-less";
        this.$.expandText.innerHTML = "Hide details";
      } else {
        this.$.expandButton.icon = "icons:expand-more";
        this.$.expandText.innerHTML = "Show details";
      }
    }
    toggleExpand(e) {
      this.expanded = !this.expanded;
    }

}

window.customElements.define('result-item', ResultItem);
