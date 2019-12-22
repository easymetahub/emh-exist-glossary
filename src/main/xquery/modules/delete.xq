xquery version "3.1";

(:~
 : This action deletes an existing glossary.
 :
 : @custom:query-param glossary The glossary to be deleted.
 :
 : @author Loren Cahlander
 :)

import module namespace config="http://exist-db.org/apps/emh-glossary/config" at "config.xqm";
import module namespace sm = "http://exist-db.org/xquery/securitymanager";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace map= "http://www.w3.org/2005/xpath-functions/map";

declare option output:method "json";
declare option output:media-type "application/json";


let $id := sm:id()
let $base := ($id//sm:effective, $id//sm:real)[1]

let $allowed := fn:exists($base//sm:group[. = "emh"])
let $glossary := if (fn:string-length(request:get-parameter('glossary', "")) gt 0) 
				 then request:get-parameter('glossary', "") 
				 else ()
let $deleted := if ($allowed)
				 then xmldb:remove($config:data-root || "/" || $glossary)
				 else ()
return map { "success" : fn:true() }
