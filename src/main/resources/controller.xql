xquery version "3.1";

import module namespace login="http://exist-db.org/xquery/login" at "resource:org/exist/xquery/modules/persistentlogin/login.xql";

declare variable $exist:path external;
declare variable $exist:resource external;
declare variable $exist:controller external;
declare variable $exist:prefix external;
declare variable $exist:root external;

let $user := login:set-user("com.easymetahub.glossary", (), false())
return
    if ($exist:path eq '') 
    then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <redirect url="{request:get-uri()}/"/>
        </dispatch>
    else if ($exist:path eq "/") 
    then
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <redirect url="{request:get-uri()}/index.html"/>
        </dispatch>
    else if (contains($exist:path, "modules/")) 
    then 
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <cache-control cache="no"/>
        </dispatch>
    else
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <cache-control cache="yes"/>
        </dispatch>
