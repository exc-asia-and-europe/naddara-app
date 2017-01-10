xquery version "3.0";

module namespace app="http://hra.uni-heidelberg.de/ns/apps/naddara/app";

import module namespace templates="http://exist-db.org/xquery/templates" at "templates.xql";
import module namespace naddara-config="http://hra.uni-heidelberg.de/ns/apps/naddara/config" at "config.xqm";
(:import module namespace ="http://hra.uni-heidelberg.de/ns/mods-hra-framework" at "/apps/tamboti/frameworks/mods-hra/mods-hra.xqm";:)
import module namespace mods-hra="http://exist-db.org/mods/retrieve" at "/apps/tamboti/themes/default/modules/retrieve-mods.xql";

import module namespace mods-common = "http://exist-db.org/mods/common" at "/apps/tamboti/modules/search/mods-common.xql";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace vra="http://www.vraweb.org/vracore4.htm";
declare namespace xlink="http://www.w3.org/1999/xlink";

(:~
 : This function can be called from the HTML templating. It shows which parameters
 : are required for a function to be callable from the templating system. To build 
 : your application, add more functions to this module.
 :)

declare function app:collection($node as node(), $params as element(parameters)?, $model as item()*) {
    let $collection := request:get-parameter("collection", $naddara-config:resource-root)
    let $collection := 
        if ($collection) then 
            $collection 
        else 
            $naddara-config:resource-root
	let $log := util:log("DEBUG", ("##$collection-2): ", xmldb:encode($collection)))
    let $model :=
        xmldb:xcollection(xmldb:encode($collection))//mods:mods
    return
        <div id="results">{ templates:process($node/*, $model) }</div>
};

declare function app:item-list($node as node(), $params as element(parameters)?, $model as item()*) {
    <ul>
    { 
        for $entry in $model
(:        let $year := $entry/mods:relatedItem[@type = "series"]/../mods:titleInfo[not(@type)]/mods:title:)
        let $dateIssued := $entry/mods:relatedItem[@type = "series"]/../mods:originInfo/mods:dateIssued[@encoding="w3cdtf"]/number()
        let $year := 
            if ($dateIssued) then
                $dateIssued
            else
                $entry/mods:relatedItem[@type = "series"]/../mods:titleInfo[not(@type)]/mods:title
        let $issue := xs:integer(app:get-issue($entry))
        order by $year, $issue, $entry/mods:location/mods:url[@displayLabel="Path to Folder"]/string()
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
            { mods-hra:format-list-view($id, $entry, $subcollection) }
            </a>
        else
            mods-hra:format-list-view($id, $entry, $subcollection)
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
    let $parentId := $model[1]/mods:relatedItem[@type="series"][1]/@xlink:href
    let $parentId := substring-after($parentId, '#')
    let $parent := collection($naddara-config:resource-root)//mods:mods[@ID = $parentId]
    let $parent-collection := util:collection-name($parent)
(:    let $log := util:log("INFO", "parent: " || $parent):)
    return
        (:#uuid-34a1979d-ce93-4620-a6b9-7dae7b4ea12c is the id of the document describing the journals as a whole and should not be shown.:)
        if ($parentId and $parentId ne 'uuid-34a1979d-ce93-4620-a6b9-7dae7b4ea12c') 
        then
            let $parent-title := mods-common:get-short-title($parent) 
            return
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

(:declare function app:get-images($collection as xs:string) {:)
(:    for $resource in xmldb:get-child-resources($collection):)
(:    let $path := concat($collection, "/", $resource):)
(:    let $log := util:log("INFO", "path:" || $path):)
(::)
(:(:    let $iiif-resource-id := $naddara-config:iiif-server-path || substring-after($collection, $naddara-config:resource-root || "/") || "/" || $thumb:):)
(::)
(:    let $mimeType := xmldb:get-mime-type($path):)
(:        where $mimeType = ("image/tiff", "image/jpeg"):)
(:        order by number(replace($resource, "^\d+_0*(\d+)_.*$", "$1")) ascending:)
(:        return:)
(:            $resource:)
(:};:)

(:declare function app:get-images($collection as item()) {:)
(:    for $resource in xmldb:get-child-resources($collection):)
(:    let $path := concat($collection, "/", $resource):)
(:(:    let $iiif-resource-id := $naddara-config:iiif-server-path || substring-after($collection, $naddara-config:resource-root || "/") || "/" || $thumb:):)
(::)
(:    let $mimeType := xmldb:get-mime-type($path):)
(:        where $mimeType = ("image/tiff", "image/jpeg"):)
(:        order by number(replace($resource, "^\d+_0*(\d+)_.*$", "$1")) ascending:)
(:        return:)
(:            $resource:)
(:};:)


(:declare function app:get-icon-from-folder($size as xs:int, $collection as xs:string) {:)
(:    let $thumb := app:get-images($collection)[1]:)
(:    (: remove exist-resource-path and concat with iiif-server-path:):)
(:    let $iiif-resource-id := $naddara-config:iiif-server-path || "Journals/" || substring-after($collection, $naddara-config:resource-root || "/") || "/" || $thumb:)
(:    return:)
(:        if ($thumb) then:)
(:            (: construct the IIIF URL :):)
(:            let $url := $naddara-config:iiif-server || $iiif-resource-id || "/full/!" || $size || "," || $size || "/0/default.jpg":)
(:            return:)
(:                <img src="{$url}" title="{$collection}" />:)
(:        else:)
(:            <img src="resources/images/1405369361_Book.png"/>:)
(:};:)
(::)

declare function app:get-icon($size as xs:int, $item as element(mods:mods)) {
    let $relations := root($item)/mods:mods/mods:relatedItem

    let $vra-work-relations := 
        for $work-relation in $relations[starts-with(@xlink:href, "#w_") or starts-with(@xlink:href, "w_")]
        order by $work-relation/mods:part/mods:detail[@type="page number"]/mods:number/number()
        return
            $work-relation
            
    let $page-count :=
         count($relations[@type="constituent" and  @displayLabel="Page"])
(:    let $log := util:log("INFO", $page-count):)

    return
        if (count($vra-work-relations) > 0) then
            <img mods-uuid="{root($item)/mods:mods/@ID/string()}" pages="{$page-count}" src="{app:getIIIFLink($vra-work-relations[1], $size)}" />
            
(:            let $work-uuid := replace($vra-work-relations[1]/@xlink:href/string(), '^#*', ''):)
(:            let $work := collection($naddara-config:resource-root)//vra:work[@id=$work-uuid]:)
(:            let $image-uuid := $work/vra:relationSet/vra:relation[@type="imageIs"][1]/@relids/string():)
(:            :)
(:(:            let $log := util:log("INFO", $image-uuid):):)
(:            return:)
(:                <img mods-uuid="{root($item)/mods:mods/@ID/string()}" pages="{$page-count}" src="/exist/apps/tamboti/modules/display/image.xql?schema=IIIF&amp;call=/{$image-uuid}/full/!{$size},{$size}/0/default.jpg" />:)
        else
            <img mods-uuid="{root($item)/mods:mods/@ID/string()}" pages="{$page-count}" src="resources/images/1405369361_Book.png"/>
};

declare function app:get-issue($entry as element(mods:mods)) {
    let $issue := $entry/mods:relatedItem[@type = "series"]/mods:part/mods:detail[@type = "issue"]/mods:number[not(@lang)]
return
        if ($issue) then
            $issue
        else
            0
};

declare function app:getIIIFLink($mods-related-item, $size as xs:integer?) {
    let $size := 
        if (not($size)) then 
            1024
        else
            $size
    
    let $work-uuid := replace($mods-related-item/@xlink:href/string(), '^#*', '')
    let $work := collection($naddara-config:resource-root)//vra:work[@id=$work-uuid]
    let $image-uuid := $work/vra:relationSet/vra:relation[@type="imageIs"][1]/@relids/string()
    let $image-record := collection($naddara-config:resource-root)//vra:image[@id=$image-uuid]
    let $iiif-id := substring-after($image-record/@href/string(), "://")
    return
        $naddara-config:iiif-server || "/" || $iiif-id || "/full/!" || $size || "," || $size || "/0/default.jpg"
    
};
