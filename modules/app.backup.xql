xquery version "3.0";

module namespace app="http://exist-db.org/xquery/app";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace config="http://exist-db.org/xquery/apps/config" at "config.xqm";
import module namespace mods="http://www.loc.gov/mods/v3" at "xmldb:exist:///db/library/modules/search/retrieve-mods.xql";

declare namespace xlink="http://www.w3.org/1999/xlink";

(:~
 : This function can be called from the HTML templating. It shows which parameters
 : are required for a function to be callable from the templating system. To build 
 : your application, add more functions to this module.
 :)
declare function app:collection($node as node(), $params as element(parameters)?, $model as item()*) {
    let $collection := request:get-parameter("collection", $config:resource-root)
    let $collection := if ($collection) then $collection else '/db/resources/commons/galleries/Naddara/Journals' (:line added, jens:)
	let $log := util:log("DEBUG", ("##$collection-2): ", $collection))
    let $model :=
        xmldb:xcollection(xmldb:encode($collection))//mods:mods
    return
        <div id="results">{ templates:process($node/*, $model) }</div>
};

declare function app:item-list($node as node(), $params as element(parameters)?, $model as item()*) {
    <ul>
    { 
        for $entry in $model
        let $year := $entry/mods:relatedItem[@type = "series"]/../mods:titleInfo[not(@type)]/mods:title
        let $issue := app:get-issue($entry)
        order by $year, $issue
return 
            templates:process($node/*, $entry)
    }
    </ul>
};

declare function app:short-entry($node as node(), $params as element(parameters)?, $model as item()*) {
    for $entry in $model
    let $child := $entry/mods:location/mods:url/string()
    let $subcollection := xmldb:encode(concat(util:collection-name($entry), "/", $child))
    let $id := $entry/@ID
    return
        if (collection($subcollection)//mods:mods) then
            <a href="?collection={$subcollection}" title="{$subcollection}">
            { mods:format-list-view($id, $entry) }
            </a>
        else
            mods:format-list-view($id, $entry)
};

declare function app:icon($node as node(), $params as element(parameters)?, $model as item()*) {
    app:get-icon(256, $model)
};

declare function app:metadata-link($node as node(), $params as element(parameters)?, $model as item()*) {
    <a class="info" href="modules/metadata.xql?id={$model/@ID}">
        <img src="resources/images/info.png"/>
    </a>
};

declare function app:parent-link($node as node(), $params as element(parameters)?, $model as item()*) {
    let $parentId := $model[1]/mods:relatedItem/@xlink:href
    let $parentId := substring-after($parentId, '#')
    let $parent := collection($config:resource-root)//mods:mods[@ID = $parentId]
    let $parent-collection := util:collection-name($parent)
    let $parent-title := mods:get-short-title($parent) 
    return
        (:#uuid-34a1979d-ce93-4620-a6b9-7dae7b4ea12c is the id of the document describing the journals as a whole and should not be shown.:)
        if ($parentId and $parentId ne 'uuid-34a1979d-ce93-4620-a6b9-7dae7b4ea12c') 
        then
                <div class="nav">
                    <a href="?collection={$parent-collection}">
                        <img src="resources/images/arrowup.png" height="16"/>
                        {$parent-title}
                    </a>
                </div>
        else
                <div class="nav">
                    Journals
                </div>
};

declare function app:get-images($collection as xs:string) {
    for $resource in xmldb:get-child-resources($collection)
    let $path := concat($collection, "/", $resource)
    let $mimeType := xmldb:get-mime-type($path)
    where $mimeType = ("image/tiff", "image/jpeg")
    order by number(replace($resource, "^\d+_0*(\d+)_.*$", "$1")) ascending
    return
        $resource
};

declare function app:get-icon-from-folder($size as xs:int, $collection as xs:string) {
    let $thumb := app:get-images($collection)[1]
    return
        if ($thumb) then
            let $imgLink := concat(substring-after($collection, "/db"), "/", $thumb)
            return
                <img src="images/{$imgLink}?s={$size}" title="{$collection}"/>
        else
             <img src="resources/images/1405369361_Book.png"/>
};

declare function app:get-icon($size as xs:int, $item as element(mods:mods)) {
    let $image := $item/mods:location/mods:url
    return
        if (exists($image)) then
            let $path := concat(util:collection-name($item), "/", xmldb:encode($image))
            return
                if (collection($path)) then
                    app:get-icon-from-folder($size, $path)
                else
                    let $imgLink := concat(substring-after(util:collection-name($item), "/db"), "/", $image)
                    return
                        <img title="{$item/mods:typeOfResource/string()}" src="images/{$imgLink}?s={$size}"/>
        else
            ()
};

declare function app:get-issue($entry as element(mods:mods)) {
    let $issue := $entry/mods:relatedItem[@type = "series"]/mods:part/mods:detail[@type = "issue"]/mods:number[not(@lang)]
return
        if ($issue) then
            $issue
        else
            0
};