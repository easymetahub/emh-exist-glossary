xquery version "3.1";

(:~
 : This action returns the information about the currently logged in user.
 :
 : @author Loren Cahlander
 :)

import module namespace sm = "http://exist-db.org/xquery/securitymanager";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare namespace map= "http://www.w3.org/2005/xpath-functions/map";

declare option output:method "json";
declare option output:media-type "application/json";

let $names := map {
	"http://axschema.org/contact/email": "email",
	"http://axschema.org/pref/language": "language",
	"http://exist-db.org/security/description": "description",
	"http://axschema.org/contact/country/home": "country",
	"http://axschema.org/namePerson": "name",
	"http://axschema.org/namePerson/first": "firstname",
	"http://axschema.org/namePerson/friendly": "friendly",
	"http://axschema.org/namePerson/last": "lastname",
	"http://axschema.org/pref/timezone": "timezone"
}

let $id := sm:id()
let $base := ($id//sm:effective, $id//sm:real)[1]
let $tuser := request:get-parameter("user", ())

let $user := $base/sm:username/text()
let $groups := $base//sm:group/text()
let $properties := 
	for $key in sm:get-account-metadata-keys()
	return if (fn:exists(sm:get-account-metadata($user, $key))) then map { map:get($names, $key) : sm:get-account-metadata($user, $key) } else ()
return map:merge((
    if ($tuser and ($tuser ne $user)) then map { "error" : fn:true() } else (),
    map {
        "id" : $user, 
        "groups" : array { 
        	for $group in  $groups
        	let $name-map := map { "id" : $group } 
        	let $properties := 
        		for $key in sm:get-group-metadata-keys()
        		return if (fn:exists(sm:get-group-metadata($group, $key))) then map { map:get($names, $key) : sm:get-group-metadata($group, $key) } else ()
        	return  map:merge(($name-map, $properties))
		}        
    },
    $properties))
