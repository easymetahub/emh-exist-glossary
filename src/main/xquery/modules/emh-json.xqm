xquery version "3.1";
(:
 : Module Name: JSON Utility Library Module
 :
 : Module Version: 1.0
 :
 : Date: May 17, 2019
 :
 : Copyright (c) 2019. EasyMetaHub, LLC
 :
 : Proprietary
 : Extensions: eXist-db
 :
 : XQuery
 : Specification March 2017
 :
 : Module Overview: This module has utility functions for generating JSON from items
 :
 :)
(:~
 : This module has utility functions for generating JSON from items
 :
 : @author Loren Cahlander
 : @since May 17, 2019
 : @version 1.0
 :)
module namespace emhjson="http://easymetahub.com/emh-accelerator/library/json";

import module namespace functx = "http://www.functx.com";

(:~
 : Generates the snippe match string to show the highlighted text for the client.
 :
 : @param $match The match text for a snippet that contains highlighted text
 : @return A string with highlight spans encoded within the string
 :)
declare function emhjson:stringify($match as node()) {
    fn:string-join(
        for $text-or-highlight in $match/node()
        return
        if ($text-or-highlight instance of element()) 
        then
            fn:concat('<span class="highlight">', 
                      $text-or-highlight/text(), 
                      '</span>')
        else
            $text-or-highlight
    )
};

(:~
 : Generate the JSON object for a match within a snippet
 :
 : @param $match The match text for a snippet that contains highlighted text
 : @return the JSON object for a match within a snippet
 :)
declare function emhjson:match($match as node()) {
    map {
      'path' : "" (:functx:path-to-node($match):),
      'text' : fn:serialize($match)
    }
};


(:~
 :
 :
 : @param $values
 : @return
 :)
declare function emhjson:concept-value($values as node()*) {
    switch (fn:count($values))
        case 0 return
            ()
        case 1 return
            xs:string($values)
        default return
            array { $values/text() }
};


(:~
 : The proper format for a facet value in a search is facet:value.  
 : If either the facet or the value contains spaces then they need 
 : to be surrounded by double-quotes.
 :
 : @param $facet-name - the name of the facet
 : @param $value-name - the text of the facet value
 : @return - The proper search value for a facet in a search
 :)
declare function emhjson:facet-text($facet-name as xs:string, $value-name as xs:string) {
    fn:concat(
        if (fn:contains($facet-name, ' '))
        then '"' || $facet-name || '"'
        else $facet-name, 
        ':', 
        if (fn:contains($value-name, ' '))
        then '"' || encode-for-uri($value-name) || '"'
        else encode-for-uri($value-name)
    )
};

