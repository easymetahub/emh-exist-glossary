/*
  Copyright (c) 2018. EasyMetaHub, LLC

  TODO: Customize for project specifics.

 */
import {PolymerElement, html} from '@polymer/polymer/polymer-element.js';
import '@vaadin/vaadin-grid/vaadin-grid.js';
import '@polymer/iron-icon/iron-icon.js';

/**
 * @customElement
 * @polymer
 */
class UploadItem extends PolymerElement {
  static get template() {
    return html`
    <style is="custom-style">
      :host {
        display: block;
        }
      .card-content {
        width: 100%;
      }
      .term {
        font-size: 14px;
      }
      vaadin-grid {
        overflow: right;
      }

      </style>
      <div class="card-content">
        <span class="term">[[item.filename]]</span>
        <span class="term">[[item.responseFilename]]</span>
        [[item.status]]
        <template is="dom-if" if="[[item.location]]">
          <a href="[[item.location]]" download="[[item.responseFilename]]"><iron-icon class="download" icon="icons:file-download"></iron-icon></a>
        </template>
        <vaadin-grid  theme="compact wrap-cell-content column-borders row-stripes" items="[[item.messages]]"  height-by-rows>
          <vaadin-grid-column flex-grow="1">
            <template class="header">Type</template>
            <template>[[item.type]]</template>
          </vaadin-grid-column>
          <vaadin-grid-column flex-grow="7">
            <template class="header">Message</template>
            <template>[[item.message]]</template>
          </vaadin-grid-column>
        </vaadin-grid>
      </div>
    `;
  }
  static get properties() {
    return {
      item: { type: Object, notify: true }
    };
  }


}

window.customElements.define('upload-item', UploadItem);
