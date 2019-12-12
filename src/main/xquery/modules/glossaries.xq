xquery version "3.1";

import module namespace config="http://exist-db.org/apps/emh-glossary/config" at "config.xqm";
import module namespace functx = "http://www.functx.com";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare namespace env = "http://exist-db.org/data/envelope";

declare option output:method "json";
declare option output:media-type "application/json";

array { functx:sort(fn:distinct-values(collection($config:data-root)//env:glossaryName/text())) }
