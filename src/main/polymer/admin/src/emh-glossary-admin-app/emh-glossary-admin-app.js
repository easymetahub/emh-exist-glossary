import {html, PolymerElement} from '@polymer/polymer/polymer-element.js';
import '@polymer/app-layout/app-drawer-layout/app-drawer-layout.js';
import '@polymer/app-layout/app-drawer/app-drawer.js';
import '@polymer/app-layout/app-header-layout/app-header-layout.js';
import '@polymer/app-layout/app-header/app-header.js';
import '@polymer/app-layout/app-scroll-effects/app-scroll-effects.js';
import '@polymer/app-layout/app-toolbar/app-toolbar.js';
import '@polymer/iron-ajax/iron-ajax.js';
import '@polymer/iron-icon/iron-icon.js';
import '@polymer/iron-icons/iron-icons.js';
import '@polymer/iron-location/iron-location.js';
import '@polymer/iron-location/iron-query-params.js';
import '@polymer/paper-button/paper-button.js';
import '@polymer/paper-card/paper-card.js';
import '@polymer/paper-dialog/paper-dialog.js';
import '@polymer/paper-icon-button/paper-icon-button.js';
import '@polymer/paper-input/paper-input.js';
import '@vaadin/vaadin-grid/vaadin-grid.js';
import '@vaadin/vaadin-upload/vaadin-upload.js';
import './upload-item.js';

/**
 * @customElement
 * @polymer
 */
class EmhGlossaryAdminApp extends PolymerElement {

  /**
   *
   * @returns {HTMLTemplateElement}
   */
  static get template() {
    return html`
      <style>
        :host {
          display: block;
          background-color: lightgrey;
          --app-drawer-width: 400px;
        }
        app-drawer-layout {
          background-color: lightgrey;
        }
        app-drawer-layout:not([narrow]) [drawer-toggle] {
          display: none;
        }
        section {
          background-color: lightgrey;
          height: 100%;
          overflow: auto;
        }
        paper-card {
          width: 95%;
          font-size: 10px;
          margin: 5px;
        }
        #userdata {
          width: 80%;
        }
        #username {
          color: white;
        }
        app-toolbar {
          background-color: grey;
          color: #fff;
        }
      </style>
      <iron-location id="sourceLocation" query="{{query}}" hash="{{hash}}"></iron-location>
      <iron-query-params id="sourceParams" params-string="{{query}}" params-object="{{params}}"></iron-query-params>
      <iron-ajax id="getGlossaries"
        url="../modules/glossaries.xq"
        handle-as="json"
        last-response="{{glossaries}}" auto></iron-ajax>
      <iron-ajax id="deleteGlossary"
        url="../modules/delete.xq"
        handle-as="json"
        on-response="_onDeleteResponse"></iron-ajax>
      <iron-ajax auto="true"  id="whoAmI"
        url="../modules/who-am-i.xq"
        handle-as="json"
        on-response="handleUserData"></iron-ajax>
      <iron-ajax id="logoutAction" 
        url="../modules/who-am-i.xq"  
        handle-as="json"
        on-response="_onLogoutResponse"></iron-ajax>
      <paper-dialog id="userdata">
        <h2>Groups</h2>
        <vaadin-grid  theme="compact wrap-cell-content column-borders row-stripes" items="[[user.groups]]"  height-by-rows>
          <vaadin-grid-column flex-grow="1">
            <template class="header">ID</template>
            <template>[[item.id]]</template>
          </vaadin-grid-column>
          <vaadin-grid-column flex-grow="7">
            <template class="header">Description</template>
            <template>[[item.description]]</template>
          </vaadin-grid-column>
        </vaadin-grid>
      </paper-dialog>
      <app-drawer-layout fullbleed>
        <app-drawer slot="drawer">
          <app-toolbar>
            <div main-title>Drawer</div>
          </app-toolbar>
          <section>
            <div style="margin-bottom:90px;width:100%;"></div>
          </section>
        </app-drawer>
        <app-header-layout has-scrolling-region>
          <app-header slot="header" fixed effects="waterfall">
          <app-toolbar>
            <paper-icon-button icon="menu" drawer-toggle></paper-icon-button>
            <paper-icon-button icon="chevron-left" on-click="_goHome"></paper-icon-button>
            <div main-title>Administration</div>
            <paper-button disabled>Hello [[user.name]]</paper-button>
          </app-toolbar>
          </app-header>
            <section>
              <paper-card>
                <vaadin-grid  theme="compact wrap-cell-content column-borders row-stripes" items="[[glossaries]]"  height-by-rows>
                  <vaadin-grid-column>
                    <template class="header">ID</template>
                    <template>[[item]]</template>
                  </vaadin-grid-column>
                  <vaadin-grid-column width="14em">
                    <template>
                      <paper-icon-button icon="delete" on-tap="_deleteGlossary" glossary="[[item]]"></paper-icon-button>
                    </template>
                  </vaadin-grid-column>
                </vaadin-grid>
              </paper-card>
              <paper-card>
                <h2>Upload RDF(s)</h2>
                <vaadin-upload accept=".rdf" target="../modules/upload.xq" method="POST" timeout="300000" form-data-name="my-attachment" id="responseDemo" files="{{files}}">
                  <iron-icon slot="drop-label-icon" icon="description"></iron-icon>
                  <span slot="drop-label">Drop your requests here (RDF files only)</span>
                  <div slot="file-list">
                    <h4 id="files">Files</h4>
                    <template is="dom-repeat" items="[[files]]" as="file">
                      <upload-item item="[[file]]"></upload-item>
                    </template>
                  </div>
                </vaadin-upload>
              </paper-card>
            </section>
        </app-header-layout>
      </app-drawer-layout>
    `;
  }

  /**
   *
   * @returns {{params: {type: *, notify: boolean}, user: {type: *, notify: boolean}, logindata: {type: *, value: {password: string, user: string}, notify: boolean}}}
   */
  static get properties() {
    return {
      params: { type: Object, notify: true },
      glossaries: { type: Array, notify: true },
      user: { type: Object, notify: true },
      logindata: { type: Object, notify: true, value: { user: '', password: '' } }
    };
  }

  connectedCallback() {
    super.connectedCallback();
    let upload = this.$.responseDemo;

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

  }

  _goHome() {
    window.location = "../index.html";
  }


  _deleteGlossary(e) {
    let g = e.currentTarget.glossary;
    this.$.deleteGlossary.params = { 'glossary' : g };
    this.$.deleteGlossary.generateRequest();
  }

  /**
   *
   * @param e
   * @private
   */
  _onDeleteResponse(e) {
    this.$.getGlossaries.generateRequest();
  }

  /**
   *
   * @private
   */
  _attemptUserLogout() {
    this.$.logoutAction.params = { 'logout' : true };
    this.$.logoutAction.generateRequest();
  }

  /**
   *
   * @param e
   * @private
   */
  _onLogoutResponse(e) {
    let resp = e.detail.response;
    this.user = resp;
  }

  /**
   *
   * @param a
   * @returns {boolean}
   * @private
   */
  _isLoggedIn(a) {
    return (a != 'guest');
  }

  /**
   *
   * @param request
   */
  handleUserData(request){
    var myResponse = request.detail.response;
    console.log(myResponse);
    this.user = myResponse;
  }
}


window.customElements.define('emh-glossary-admin-app', EmhGlossaryAdminApp);
