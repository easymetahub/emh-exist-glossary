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

declare variable $request-filename := request:get-uploaded-file-name("my-attachment");

declare option xdmp:mapping "false";

let $log := xdmp:log("Starting an upload!")
(: wrapping updates in invoke-function so transaction results are visible to code below :)
let $json-response :=
                array {
                    if (request:get-uploaded-file-data("my-attachment")) eq 0)
                    then 
                        map {
                            "filename" : "none", 
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
                        return
                            map { 
                                "filename" : $filename, 
                                "messages" : array { custom:process-upload($filename, $file) } 
                            }
                }
            }
return $json-response
