xquery version "3.1";
(:
 : Module Name: Search Module
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
 : Module Overview: This module handles the search from the server.
 :
 :)
(:~
 : This module handles the search of the server.
 :
 : @author Loren Cahlander
 : @since May 17, 2019
 : @version 1.0
 :)
import module namespace emhjson="http://easymetahub.com/emh-glossary/library/json" at "emh-json.xqm";
import module namespace custom="http://easymetahub.com/emh-glossary/library/custom" at "custom/custom.xqm";
import module namespace config="http://exist-db.org/apps/emh-glossary/config" at "config.xqm";

declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace skosxl="http://www.w3.org/2008/05/skos#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace env = "http://exist-db.org/data/envelope";

declare option output:method "json";
declare option output:media-type "application/json";

let $q := if (fn:string-length(request:get-parameter('q', "")) gt 0) then request:get-parameter('q', "") else ()
let $debug := if (fn:string-length(request:get-parameter('debug', "")) gt 0) then fn:true() else fn:false()

let $total-count := fn:count(fn:collection($config:data-root)//skosxl:Concept)

let $start := xs:positiveInteger(request:get-parameter('start', '1'))
let $page-length := xs:positiveInteger(request:get-parameter('pagelength', '10'))
let $facets-param := fn:tokenize(request:get-parameter('facets', ()), "~~")
let $end := $start + $page-length - 1

let $facets-map := 
    map { "facets" : map:merge(
        for $facet in $facets-param
        let $facet-name := fn:substring-before($facet, ":")
        let $trimmed-facet-name := 
                if (fn:starts-with($facet-name, '"'))
                then (fn:substring(fn:substring($facet-name, 1, fn:string-length($facet-name) - 1), 2))
                else $facet-name
        let $facet-value := fn:substring-after($facet, ":")
        let $trimmed-facet-value := 
                if (fn:starts-with($facet-value, '"'))
                then (fn:substring(fn:substring($facet-value, 1, fn:string-length($facet-value) - 1), 2))
                else $facet-value
        return map { $trimmed-facet-name : xmldb:decode($trimmed-facet-value) }

        
    )}

let $query-results := 
    if (fn:string-length($q) gt 0 or fn:count($facets-param) gt 0)
    then collection($config:data-root)//env:envelope[ft:query(., $q, $facets-map)]
    else collection($config:data-root)//env:envelope[env:instance/skosxl:Concept]

let $query-results2 := 
    if (fn:count($query-results) = 0)
    then
        if (fn:string-length($q) gt 0)
        then collection($config:data-root)//env:envelope[ft:query(., $q || "*", $facets-map)]
        else ()
    else $query-results

let $search-count := fn:count($query-results2)
let $search-results := $query-results2[$start le position() and position() le $end]


let $facet-names := 
    for $name in custom:search-options()
    order by $name
    return $name

let $selected-facet-names := fn:distinct-values(
    for $name in $facet-names
    return 
        for $facet-param in $facets-param
        return 
            if (fn:starts-with($facet-param, $name || ":"))
            then $name
            else ()
            )

let $unselected-facet-names := $facet-names[not(.=$selected-facet-names)]

let $selected-facets := 
    for $facet-name in $selected-facet-names
    let $facet := if ($search-count gt 0) then ft:facets($search-results, $facet-name, ()) else ()
    return 
        if (fn:exists($facet) and fn:count(map:keys($facet)) gt 0) 
        then custom:facet-object($facet, $facet-name, $facets-param) 
        else ()


let $unselected-facets := 
    for $facet-name in $unselected-facet-names
    let $facet := if ($search-count gt 0) then ft:facets($search-results, $facet-name, ()) else ()
    return 
        if (fn:exists($facet) and fn:count(map:keys($facet)) gt 0) 
        then custom:facet-object($facet, $facet-name, $facets-param) 
        else ()

let $results := 
    for $result at $index in $search-results
    return
        custom:result-object($result, $index + $start - 1, if ($q) then fn:true() else fn:false())

        
return
    if ($debug)
    then $search-results
    else
        map {
            "total" : $search-count,
            "available" : $total-count,
            "facets" : array { ($selected-facets, $unselected-facets) },
            "results" : array { $results }
        }
