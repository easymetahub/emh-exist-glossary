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

let $q := if (fn:string-length(request:get-parameter('q')) gt 0) then request:get-parameter('q') else ()
let $debug := if (fn:string-length(request:get-parameter('debug')) gt 0) then fn:true() else fn:false()

let $total-count := fn:count(fn:collection($custom:data-collection)//skos:Concept)

let $start := xs:positiveInteger(request:get-parameter('start', '1'))
let $page-length := xs:positiveInteger(request:get-parameter('pagelength', '10'))
let $facets-param := fn:tokenize(request:get-parameter('facets', ()), "~~")
let $end := $start + $page-length - 1


(: If there isn't a search string, then return all possible results :)
let $search-input :=
    fn:string-join(
        (
            ($q, "*")[1],
            $facets-param
        ), 
        " "
    )

let $search-results := search:search($search-input, custom:search-options(), $start, $page-length) 

let $qtext := $search-results/search:qtext/text()

let $selected-facets := 
    for $facet in local:facets-by-selection($search-results/search:facet, fn:true(), $qtext)
    return custom:facet-object($facet, $qtext)

let $unselected-facets := 
    for $facet in local:facets-by-selection($search-results/search:facet, fn:false(), $qtext)
    return custom:facet-object($facet, $qtext)


let $results := 
    for $result in $search-results//search:result
    return
        custom:result-object($result, if ($q) then fn:true() else fn:false())

        
return
    if ($debug)
    then $search-results
    else
        map {
            "total" : $search-results/@total/number(),
            "available" : $total-count,
            "facets" : array { ($selected-facets, $unselected-facets) },
            "results" : array { $results }
        }
