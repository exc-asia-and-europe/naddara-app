xquery version "3.0";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace jquery="http://exist-db.org/xquery/jquery" at "resource:org/exist/xquery/lib/jquery.xql";

declare option exist:serialize "method=html5 media-type=text/html";

(:declare option exist:serialize "method=xml media-type=application/xml";:)

declare variable $modules :=
    <modules>
        <module prefix="config" uri="http://exist-db.org/xquery/apps/config" at="modules/config.xql"/>
        <module prefix="app" uri="http://hra.uni-heidelberg.de/ns/apps/naddara/app" at="app.xqm"/>
    </modules>;


let $content := request:get-data()
(:let $log := util:log("DEBUG", ($content)):)

let $no-cache := if( request:get-parameter( 'resource','something-else') = 'browse.html') then (
                      response:set-header( "Cache-Control",  'no-cache, no-store, max-age=0, must-revalidate' ),
                      response:set-header( "X-Content-Type-Options", 'nosniff' )
                 )else()

return
    jquery:process(
        templates:apply($content, $modules, ())
    )