xquery version "3.0";

import module namespace naddara-config="http://hra.uni-heidelberg.de/ns/apps/naddara/config" at "config.xqm";
import module namespace mods-hra="http://exist-db.org/mods/retrieve" at "modules/retrieve-mods.xql";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare option exist:serialize "media-type=text/html method=html5";

let $id := request:get-parameter("id", ())
let $entry := collection($naddara-config:resource-root)//mods:mods[@ID = $id]
return
    mods-hra:format-detail-view($id, $entry, util:collection-name($entry))