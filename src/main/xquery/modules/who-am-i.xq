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
 : Extensions: eXist-db
 :
 : XQuery
 : Specification March 2017
 :
 : Module Overview: This module handles files being uploaded to the server.
 :
 :)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:media-type "application/json";

let $user:= request:get-attribute("com.easymetahub.user")
let $name := if ($user) then sm:get-account-metadata($user, xs:anyURI('http://axschema.org/namePerson')) else 'Guest'
let $group := if ($user) then sm:get-user-groups($user) else ('guest')
return
    map { "userid" : $user, "name" : $name, "groups" : array { $group } }
