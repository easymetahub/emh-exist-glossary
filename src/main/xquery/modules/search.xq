xquery version "3.1";
(:
 : Module Name: Search Module
 :
 : Module Version: 1.0
 :
 : Date: 10/25/2018
 :
 : Copyright (c) 2018. EasyMetaHub, LLC
 :
 : Proprietary
 : Extensions: MarkLogic
 :
 : XQuery
 : Specification March 2017
 :
 : Module Overview: This module handles the search from the server.
 :
 :)
(:~
 : This module handles the search the server.
 :
 : @author Loren Cahlander
 : @since October 25, 2018
 : @version 1.0
 :)
import module namespace emhjson="http://easymetahub.com/emh-accelerator/library/json" at "emh-json.xqm";
import module namespace custom="http://easymetahub.com/emh-accelerator/library/custom" at "custom/custom.xqm";

declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos="http://www.w3.org/2008/05/skos#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace search = "http://marklogic.com/data-hub/search";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace env = "http://marklogic.com/data-hub/envelope";

declare option output:method "json";
declare option output:media-type "application/json";

(:~
 : This method allows for the odering of facets showing the selected snippets first
 :
 : @param $facets          The facets from the search result
 : @param $return-selected The flag to determine if the facet should be returned if the facet has a selected value.
 : @param $qtext           The 'search:qtext' of the search results to find the selected facet value(s)
 :)
declare function local:facets-by-selection($facets as node()*, $return-selected as xs:boolean, $qtext as xs:string)
{
    for $facet in $facets[search:facet-value]
    let $selected := 
        for $value in $facet/search:facet-value
        return if (fn:contains($qtext, emhjson:facet-text($facet/@name/string(), $value/@name/string()))) then $value else ()
    return
        if (fn:not($selected))
        then 
            if ($return-selected) then () else $facet
        else
            if ($return-selected) then $facet else ()
};

let $q := if (fn:string-length(request:get-parameter('q', "")) gt 0) then request:get-parameter('q', "") else ()
let $debug := if (fn:string-length(request:get-parameter('debug', "")) gt 0) then fn:true() else fn:false()

let $total-count := fn:count(fn:collection($custom:data-collection)//skos:Concept)

let $start := xs:positiveInteger(request:get-parameter('start', '1'))
let $page-length := xs:positiveInteger(request:get-parameter('pagelength', '10'))
let $facets-param := fn:tokenize(request:get-parameter('facets', ()), "~~")
let $end := $start + $page-length - 1


let $search-count := 
    if (fn:string-length($q) gt 0 or fn:count($facets-param) gt 0)
    then fn:count(collection("/db/apps/emh-accelerator/data")//env:envelope[ft:query(., $q, map { "facets" : map:merge(
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

        
    )})])
    else fn:count(collection("/db/apps/emh-accelerator/data")//env:envelope[env:instance/skos:Concept])
let $search-results := 
    if (fn:string-length($q) gt 0 or fn:count($facets-param) gt 0)
    then fn:subsequence(collection("/db/apps/emh-accelerator/data")//env:envelope[ft:query(., $q, map { "facets" : map:merge(
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
    )
        
    })], $start, $start + $page-length -1)
    else fn:subsequence(collection("/db/apps/emh-accelerator/data")//env:envelope[env:instance/skos:Concept], $start, $start + $page-length - 1)


let $facet-names := 
    for $name in ("Broader", "Narrower", "Related", "Glossary", '"Preferred Label"', '"Alternate Label"')
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
    let $facet := ft:facets(head($search-results), $facet-name, ())
    return 
        if (fn:exists($facet) and fn:count(map:keys($facet)) gt 0) 
        then custom:facet-object($facet, $facet-name, $facets-param) 
        else ()


let $unselected-facets := 
    for $facet-name in $unselected-facet-names
    let $facet := ft:facets(head($search-results), $facet-name, ())
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
