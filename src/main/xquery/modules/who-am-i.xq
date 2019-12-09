xquery version "3.1";
(:
 : Module Name: Who am I Module
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
 : Module Overview: Return the user id, name and groups of the logged in user.
 :
 :)

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";

declare option output:method "json";
declare option output:media-type "application/json";

let $user:= request:get-attribute("com.easymetahub.user")
let $name := if ($user) then sm:get-account-metadata($user, xs:anyURI('http://axschema.org/namePerson')) else 'Guest'
let $group := if ($user) then sm:get-user-groups($user) else ('guest')
return
    map { "username" : $user, "name" : $name, "groups" : array { $group } }
