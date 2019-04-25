/*
  Copyright (c) 2018. EasyMetaHub, LLC
 */
import {html, PolymerElement} from '@polymer/polymer/polymer-element.js';
import '@polymer/app-layout/app-drawer-layout/app-drawer-layout.js';
import '@polymer/app-layout/app-drawer/app-drawer.js';
import '@polymer/app-layout/app-scroll-effects/app-scroll-effects.js';
import '@polymer/app-layout/app-header/app-header.js';
import '@polymer/app-layout/app-header-layout/app-header-layout.js';
import '@polymer/app-layout/app-toolbar/app-toolbar.js';
import '@polymer/app-layout/demo/sample-content.js';
import '@polymer/iron-icons/iron-icons.js';
import '@polymer/iron-icon/iron-icon.js';
import '@polymer/paper-icon-button/paper-icon-button.js';
import '@polymer/paper-button/paper-button.js';
import '@polymer/paper-card/paper-card.js';
import '@polymer/paper-slider/paper-slider.js';
import '@polymer/paper-input/paper-input.js';
import '@polymer/iron-location/iron-location.js';
import '@polymer/iron-location/iron-query-params.js';
import '@polymer/paper-button/paper-button.js';
import '@polymer/paper-dialog/paper-dialog.js';
import '@polymer/paper-dialog-scrollable/paper-dialog-scrollable.js';
import '@polymer/iron-ajax/iron-ajax.js';
import '@vaadin/vaadin-upload/vaadin-upload.js';
import './upload-item.js';
import './result-item.js';
import './facet-card.js';
import 'paper-pagination/paper-pagination.js';
 
/**
 * @customElement
 * @polymer
 */
class EMHAcceleratorApp extends PolymerElement {
  static get template() {
    return html`
      <style is="custom-style">
        :host {
          display: block;
          background-color: lightgrey;
        }
      app-drawer-layout {
        background-color: lightgrey;
      }
      app-toolbar {
        background-color: grey;
        color: #fff;
      }
      app-drawer-layout:not([narrow]) [drawer-toggle] {
        display: none;
      }
        .counter {
          padding: 0px 0px 0px 16px;
        }
        section {
          overflow: scroll;
          height: 100%;
          background-color: lightgrey;
        }
        paper-item {
          cursor: pointer;
        }
        result-item {
          margin: 5px;
        }
        paper-dialog {
          width: 90%;
        }
        paper-card {
          width: 100%;
          font-size: 10px;
          margin: 5px;
        }
        .emhLink {
          color: white;
        }
      </style>
      <iron-location id="sourceLocation" query="{{query}}"></iron-location>
      <iron-query-params id="sourceParams" params-string="{{query}}" params-object="{{params}}"></iron-query-params>
      <iron-ajax auto="true" id="runSearch"
        url="/search"  
        params="[[params]]"
        handle-as="json"
        last-response="{{result}}"></iron-ajax>
      <iron-ajax auto="true"  id="whoAmI"
        url="/modules/who-am-i.xqy"  
        handle-as="json"
        last-response="{{user}}"></iron-ajax>
      <iron-ajax id="loginAction" 
        url="/modules/login.xqy"  
        params="[[loginData]]"
        handle-as="json"
        on-response="_onLoginResponse"></iron-ajax>
      <paper-dialog id="dialog">
        <h2>Upload ZIP(s)</h2>
        <paper-dialog-scrollable>
          <vaadin-upload accept=".zip" target="/upload-all" method="POST" timeout="300000" form-data-name="my-attachment" id="responseDemo" files="{{files}}">
            <iron-icon slot="drop-label-icon" icon="description"></iron-icon>
            <span slot="drop-label">Drop your requests here (ZIP files only)</span>
            <div slot="file-list">
              <h4 id="files">Files</h4>
              <template is="dom-repeat" items="[[files]]" as="file">
                <upload-item item="[[file]]"></upload-item>
              </template>
            </div>
          </vaadin-upload>
        </paper-dialog-scrollable>
        <div class="buttons">
          <paper-button on-click="_closeUpload">Close</paper-button>
        </div>
      </paper-dialog>
      <paper-dialog id="login">
        <h2>Login</h2>
        <paper-input label="username" value="{{loginData.user}}"></paper-input>
        <paper-input label="password" value="{{loginData.password}}" type="password"></paper-input>
        <div class="buttons">
          <paper-button dialog-dismiss>Close</paper-button>
          <paper-button on-click="_attemptUserLogin">Login</paper-button>
        </div>
      </paper-dialog>
      <app-drawer-layout>
        <app-drawer slot="drawer">
          <app-toolbar>
            <div main-title>Facets</div>
            <paper-icon-button icon="file-upload" on-click="_openDialog"></paper-icon-button>
          </app-toolbar>
        <section>
          <template is="dom-repeat" items="{{result.facets}}" as="facet">
            <template is="dom-if" if="{{facet.values}}">
              <facet-card facet="{{facet}}"></facet-card>
            </template>
          </template>
          <div style="margin-bottom:90px;width:100%;"></div>
        </section>
        </app-drawer>
        <app-header-layout>
          <app-header slot="header" reveals effects="waterfall">
          <app-toolbar>
            <paper-icon-button icon="menu" drawer-toggle></paper-icon-button>
            <iron-icon src="icon.png"></iron-icon>
            <div main-title>Accelerator</div>
            <paper-slider title="Page size" pin snaps min="10" max="100" step="10" value="{{params.pagelength}}"></paper-slider>
            <paper-button on-click="_openLoginDialog">[[user.username]]</paper-icon-button>
          </app-toolbar>
          </app-header>
          <paper-card>
            <paper-input id="searchInput" source="{{suggestions}}" value="{{params.q}}" placeholder="Query text">
            </paper-input>
          </paper-card>
          <paper-card>
            <div class="totalcounter">Total Count: [[_formatNumber(result.total)]] of [[_formatNumber(result.available)]]</div>
            <paper-pagination id="paginator" range-size="5" page-size="[[params.pagelength]]" total="[[result.total]]" offset="{{params.start}}"></paper-pagination>
          </paper-card>
        <section>
          <template is="dom-repeat" items="{{result.results}}">
            <result-item item="{{item}}"></result-item>
          </template>
          <!-- DO NOT REMOVE COPYRIGHT NOTICE -->
          <paper-card>Copyright &#169; 2018 EasyMetaHub, LLC. All rights reserved.</paper-card>
          <div style="margin-bottom:200px;height:150px;width:100%;"></div>
        </section>
        </app-header-layout>
      </app-drawer-layout>
    `;
  }
  static get properties() {
    return {
      suggestions: { type: Array, notify: true },
      result: { type: Object, notify: true },
      params: { type: Object, notify: true },
      user: { type: Object, notify: true },
      loginData: { type:Object, value: { }, notify: true }
    };
  }
    static get observers() {
      return [
      'facetChanged(result.facets.*)'
    ]
    } 

    facetChanged(value) {
      if (value.path.endsWith(".selected")) {
        var separator = "~~";
        var pathlength = value.path.length;
        var trimmed = value.path.substr(0, pathlength - 9);
        var item = this.get(trimmed);
        if (typeof item == 'undefined') {
          this.set( 'params.facets', ''  );
          this.notifyPath('params.facets');
          return;
        }
        var params = this.get("params");
        console.log("facet changed " + value);
        if (item.selected) {
          if (params.facets) {
            params.facets += separator + item.value;
          } else {
            params.facets = item.value;
          }
        } else {
          var tArray = params.facets.split(separator);
          var idx = tArray.indexOf(item.value);
          if (idx >= 0) {
            tArray.splice(idx, 1);
          }
          params.facets = tArray.join(separator);
        }
        this.set( 'params.facets', params.facets  );
        this.notifyPath('params.facets');
      }
    }

    ready() {
      super.ready();
      if (!this.params.pagelength) {
        this.params.pagelength = 10;
        this.notifyPath('params.pagelength');
      }
    }

    connectedCallback() {
      super.connectedCallback();
      if (!this.params.pagelength) {
        this.params.pagelength = 10;
        this.notifyPath('params.pagelength');
      }
    }

    _openDialog() {
      var d = this.$.dialog;
      var upload = this.$.responseDemo;

      upload.addEventListener('upload-response', function(event) {
        var results = JSON.parse(event.detail.xhr.response);
        console.log('upload xhr after server response: ', event.detail.xhr);
        
        if (results.errorResponse) {
          event.detail.file.messages = [{'type': 'fatal', 'message': results.errorResponse.message }];
        } else {
          if (results[0].responseFilename) {
            event.detail.file.responseFilename = results[0].responseFilename;
            event.detail.file.location = results[0].location;
            if (results[0].messages.length) {
              event.detail.file.messages = results[0].messages;
            }
          }
        }
      });
      this.$.dialog.open();
    }

    _closeUpload() {
      this.$.runSearch.generateRequest();
      this.$.dialog.close();
    }


    _openLoginDialog() {
      this.$.login.open();
    }

    _attemptUserLogin() {
      var a = this.loginData;
      this.$.loginAction.generateRequest();
    }

    _onLoginResponse(e) {
      var resp = e.detail.response;
      if (resp.status == 'success') {
        this.$.whoAmI.generateRequest();
        this.$.runSearch.generateRequest();
        this.$.login.close();
      } else {
        alert('error');
      }
    }


    _formatNumber(x) {
      if (typeof x == 'undefined') {
        x = 0;
      }
      return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
    }

}

window.customElements.define('emh-accelerator-app', EMHAcceleratorApp);
