xquery version "3.1";
(:
 : Module Name: File Upload Module
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
 : Module Overview: This module handles files being uploaded to the server.
 :
 :)
(:~
 : This module handles files being uploaded to the server.
 :
 : @author Loren Cahlander
 : @since October 25, 2018
 : @version 1.0
 :)
import module namespace custom="http://easymetahub.com/emh-accelerator/library/custom" at "custom/custom.xqm";

declare namespace error="http://marklogic.com/xdmp/error";
declare namespace skos="http://www.w3.org/2004/02/skos/core#";
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:media-type "application/json";

declare variable $request-filename := request:get-uploaded-file-name("my-attachment");

let $log := util:log("info", "Starting an upload!")
(: wrapping updates in invoke-function so transaction results are visible to code below :)
let $json-response :=
                array {
                    if (fn:count($request-filename) eq 0)
                    then 
                        map {
                            "responseFilename" : "none", 
                            "messages" : 
                                array { 
                                    map { 
                                        "type" : "error", 
                                        "message" : "There are no files to process!" 
                                    } 
                                } 
                        }
                    else
                        for $file at $pos in request:get-uploaded-file-data("my-attachment")
                        let $filename := $request-filename[$pos]
                        let $file-string := util:binary-to-string($file)
                        return
                            map { 
                                "responseFilename" : $filename, 
                                "messages" : array {(
                                    map {
                                        "type" : "info", 
                                        "message" : "Processing file " || $filename 
                                    },
                                    try {
                                        custom:process-upload($filename, fn:parse-xml($file-string) ) 
                                    } catch * {
                                        map { 
                                            "type" : "error", 
                                            "message" : $err:description 
                                        } 
                                    }
                                )} 
                            }
                }

return $json-response
