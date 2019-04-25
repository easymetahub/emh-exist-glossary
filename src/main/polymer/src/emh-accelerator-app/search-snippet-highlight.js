/*
  Copyright (c) 2018. EasyMetaHub, LLC
 */
import {html, LitElement} from '@polymer/lit-element/lit-element.js';

/**
 * `search-snippet-highlight`
 * 
 *
 * @customElement
 * @polymer
 * @demo demo/index.html
 */
class SearchSnippetHighlight extends LitElement {

  static get properties() {
    return {
      snippet: { type: String, notify: true }
    };
  }

  constructor() {
    super();
    this.snippet = 'Hello <span class="highlight">World</span>!';
  }

  render() {
    return html`
      <style>.highlight { background-color: yellow; }</style>
      <div .innerHTML="${this.sanitizeHtml(this.snippet)}"></div>`;
  }

  sanitizeHtml(input) {
    return input; // TODO: actually sanitize input with sanitize-html library
  }

}

window.customElements.define('search-snippet-highlight', SearchSnippetHighlight);
