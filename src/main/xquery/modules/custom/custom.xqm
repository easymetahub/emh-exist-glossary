xquery version "3.1";
(:
 : Module Name: Customization Library Module
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
 : Module Overview: This module is where the customization to the accelerator takes place.
 :
 :)
(:~
 : This module is where the customization to the accelerator takes place.
 :
 : TODO: Customize for the project
 :
 : @author Loren Cahlander
 : @since October 25, 2018
 : @version 1.0
 :)
module namespace custom="http://easymetahub.com/emh-accelerator/library/custom";

import module namespace emhjson="http://easymetahub.com/emh-accelerator/library/json" at "../emh-json.xqm";
import module namespace kwic="http://exist-db.org/xquery/kwic";

declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";
declare namespace skos="http://www.w3.org/2008/05/skos#";
declare namespace rdfs="http://www.w3.org/2000/01/rdf-schema#";
declare namespace dc="http://purl.org/dc/elements/1.1/";
declare namespace env = "http://marklogic.com/data-hub/envelope";
declare namespace search = "http://marklogic.com/data-hub/search";

(:~
 : This is the collection that all uploads will be stored in so that the search can find them.
 :)
declare variable $custom:data-collection := "/db/apps/emh-accelerator/data";

(:~
 : Look up the Concept whose rdf:about value equals the $name parameter.
 :
 : @param $name The value that relates to the rdf:about attribute of a skos:Concept
 : @return The skos:prefLabel of a skos:Concept
 :)
declare function custom:prefLabel($name as xs:string)
{
    collection($custom:data-collection)//skos:Concept[@rdf:about = $name]/skos:prefLabel/text()
};

(:~
 : Generates the JSON object for a facet value.
 :
 : @param $facet-value The 'search:facet-value' of the 'search:facet' of the search results.
 : @param $facet-name  The name of the facet from the 'search:facet' element.
 : @param $qtext       The 'search:qtext' of the search results to find the selected facet value(s)
 : @return The JSON object for creating a facet value entry on the client page
 :)
declare function custom:facet-value($facet-name as xs:string, $count as xs:integer, $value-name as xs:string, $qtext as xs:string?)
{
    let $facet-text := emhjson:facet-text($facet-name, $value-name)
    let $display-name :=
        if (fn:starts-with($value-name, "#"))
        then custom:prefLabel($value-name)
        else $value-name
    let $selected := if (fn:string-length($qtext) gt 0)
                    then if ($qtext eq $facet-text)
                     then fn:true()
                     else fn:false()
                     else fn:false()
                     
    return
        if (fn:not($value-name))
        then ()
        else
        map {
            "facet" : $facet-name,
            "value" : $facet-text,
            "name" : $display-name,
            "count" : $count,
            "selected" : $selected 
        }
};

(:~
 : Generates the JSON object for a facet.
 :
 : @param $facet  The 'search:facet' object from the search results.
 : @param $qtext  The 'search:qtext' of the search results to find the selected facet value(s)
 : @return The JSON object for creating a facet entry on the client page
 :)
declare function custom:facet-object($facet as map(*), $facet-name as xs:string, $qtext as xs:string*) 
{
    let $names := 
        for $name in map:keys($facet)
        let $count := map:get($facet, $name)
        order by $count descending, $name ascending
        return $name
        
    let $selected-facet := (
        for $facet in $qtext
        return 
            if (fn:starts-with($facet, $facet-name))
            then $facet
            else (), "")[1]
        
    return
    map {
        "name" : $facet-name,
        "values" : array {
                for $value in fn:subsequence($names, 1, 10)
                return custom:facet-value($facet-name, map:get($facet, $value), $value, $selected-facet)
            },
        "extvalues" : 
            if (fn:count($names) gt 10)
            then
                array {
                    for $value in fn:subsequence($names, 11)
                return custom:facet-value($facet-name, map:get($facet, $value), $value, $selected-facet)
                }
            else ()
    }

};

(:~
 : Generates the JSON object for a result item.
 :
 : @param $result A 'search:result' object from the search results
 : @param $show-snippets A flag for whether to show the snippets.
 : @return The JSON object that represents a result item in the client page
 :)
declare function custom:result-object($result as node(), $index, $show-snippets as xs:boolean)
{
    let $uri := fn:base-uri($result)
    let $concept := $result//skos:Concept
    return
        map {
            'index' : $index,
            'concept' : map {
                            'term' : emhjson:concept-value($concept/skos:prefLabel),
                            'about' : emhjson:concept-value($concept/@rdf:about),
                            'definition' : array { for $definition in $concept/skos:definition return emhjson:concept-value($definition) },
                            'altLabel' : emhjson:concept-value($concept/skos:altLabel),
                            'related' : array { 
                                            for $related in $concept/skos:related 
                                            let $prefLabel := custom:prefLabel($related/@rdf:resource)
                                            return 
                                                map {
                                                    'name' : emhjson:concept-value($prefLabel), 
                                                    'glossary' : emhjson:facet-text('Glossary', $result/env:headers/env:glossaryName),
                                                    'label' : emhjson:facet-text('Preferred Label', $prefLabel[1])
                                                }
                                        },
                            'broader' : array { 
                                            for $broader in $concept/skos:broader
                                            let $prefLabel := custom:prefLabel($broader/@rdf:resource)
                                            return 
                                                map {
                                                    'name' : emhjson:concept-value($prefLabel), 
                                                    'glossary' : emhjson:facet-text('Glossary', $result/env:headers/env:glossaryName),
                                                    'label' : emhjson:facet-text('Preferred Label', $prefLabel[1])
                                                }
                                        },
                            'narrower' : array { 
                                            for $narrower in $concept/skos:narrower
                                            let $prefLabel := custom:prefLabel($narrower/@rdf:resource)
                                            return 
                                                map { 
                                                    'name' : emhjson:concept-value($prefLabel), 
                                                    'glossary' : emhjson:facet-text('Glossary', $result/env:headers/env:glossaryName),
                                                    'label' : emhjson:facet-text('Preferred Label', $prefLabel[1])
                                                }
                                        }
                        },
            'snippets' : array { 
                if ($show-snippets)
                then
                    for $snippet in kwic:summarize($result, <config width="40"/>)
                    return fn:serialize($snippet)
                else ()
            },
(: This is an example of adding a grid of data to the result item.
            'grid' : map {
                        'columns' : array { ('Header', 'Value') },
                        'rows' : array {
                                    map {
                                        'Header' : 'Header One',
                                        'Value' : 'Value One'
                                    },
                                    map {
                                        'Header' : 'Header Two',
                                        'Value' : 'Value Two'
                                    }
                                 }
                     },
:)
            'uri' : $result/@uri/string(),
            'score' : ft:score($result)
        }
};

(:~
 : This function processes the file that was uploaded through the upload dialog.
 :
 :  @param $filename The name of the file that has ben uploaded
 :  @param $file     The file that has been uploaded.
 :  @return An array of JSON objects as { "type": error-type, "message": error-message }
 :)
declare function custom:process-upload($filename as xs:string, $file as node())
as map(*)
{
    let $log := util:log("info", "Processing file: " || $filename)
    let $log2 := util:log("info", "Processing file: " || $file/*/fn:local-name())
    let $glossary := fn:substring-before($filename, ".")
    let $is-glossary := fn:collection($custom:data-collection)//env:headers[env:glossaryName = $glossary]
    return if ($is-glossary)
    then
        map {
            "type" : "error",
            "message" : fn:concat("Glossary ", $glossary, " already exists")
        }
    else
    (:let $mkdir := xmldb:create-collection($custom:data-collection, $glossary):)
    let $nodes :=
        for $node at $index in $file//rdf:RDF/*
        let $id := util:uuid()
        let $envelope :=
            element { "env:envelope" } {
                element { "env:headers" } {
                    element { "env:id" } { $id },
                    element { "env:glossaryName" } { $glossary },
                    element { "env:timestamp" } {  fn:current-dateTime() }
                },
                element { "env:instance" } { $node }
            }
        let $stored :=
            xmldb:store($custom:data-collection, $id || '.xml', $envelope)
        return ()
    return 
        map {
            "type" : "info",
            "message" : fn:concat("File ", $filename, " processed")
        }
};

(:~
 : Returns the search option for the query.
 :
 : @return The search options for the search:search() call in the search module.
 :)
declare function custom:search-options()
as node()
{
  <options xmlns="http://marklogic.com/appservices/search">
  </options>
};

