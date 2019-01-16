xquery version "3.0";

import module namespace json="http://www.json.org";

import module namespace request = "http://exist-db.org/xquery/request";
import module namespace session = "http://exist-db.org/xquery/session";
(:import module namespace util = "http://exist-db.org/xquery/util";:)
import module namespace naddara-config="http://hra.uni-heidelberg.de/ns/apps/naddara/config" at "../config.xqm";

import module namespace mods-hra="http://exist-db.org/mods/retrieve" at "modules/retrieve-mods.xql";
import module namespace mods-common = "http://exist-db.org/mods/common" at "/db/apps/tamboti/modules/mods-common.xql";

declare namespace mods="http://www.loc.gov/mods/v3";
declare namespace vra="http://www.vraweb.org/vracore4.htm";
declare namespace xlink="http://www.w3.org/1999/xlink";

declare option exist:serialize "method=json media-type=text/javascript";

declare variable $local:filmstrip-rows := 2;
declare variable $local:magic-width := 68;

declare variable $local:image-exts := ("tif", "tiff", "bmp", "png", "jpg", "jpeg", "svg", "gif");


declare function local:get-images-from-mods($start as xs:int, $end as xs:int){
    let $relations := session:get-attribute("image-relations") 
    return
        for $relation in $relations[position() >= $start and position() <= $end]
        return $relation
            
};

(:declare function local:get-images-from-cache($start as xs:int, $end as xs:int) as element(mods:url)* {:)
(:    let $cached := session:get-attribute("mods:cached") return:)
(:    :)
(:        for $pos in $start to $end:)
(:        let $entry := $cached[$pos] :)
(:        let $image := $entry/mods:location/mods:url[@access="preview"]:)
(:        return:)
(:            $image:)
(:};:)
(::)
declare function local:get-mods-images() as xs:integer {
    let $mods-data := session:get-attribute("mods-data") 
    let $image-relations := $mods-data/mods:relatedItem[@type="constituent" and starts-with(@xlink:href, "#w_")]
    let $store-relations := session:set-attribute("image-relations", $image-relations)
    return
        count($image-relations)
};

(:declare function local:get-cache-image-count() as xs:integer {:)
(:    let $cached := session:get-attribute("mods:cached") return:)
(:        fn:count($cached):)
(:};:)

(:declare function local:get-image-collection-for-collection($image as xs:string) as xs:string {:)
(:    request:get-parameter("collection",()):)
(:};:)

(:declare function local:get-image-collection-for-cached($image as element(mods:url)) as xs:string {:)
(:    util:collection-name($image):)
(:};:)

(:declare function local:get-images-for-mods($modsUUID as xs:string) as xs:string* {:)
(:    :)
(:};:)


declare function local:thumbnails($filmstrip-width as xs:int, $page as xs:int, $fn-images-available) {
(:    let $log := util:log("INFO" ,"local:thumbnails"):)
    let $images := session:get-attribute("image-relations")
    
    let $max-images-per-page := xs:int(fn:floor(($filmstrip-width div $local:magic-width) * $local:filmstrip-rows)),
    $images-available := util:call($fn-images-available),
    $total-pages := xs:int(fn:ceiling($images-available div $max-images-per-page)),
    
    $start := 
        if($page eq 1)then
            1
        else if((($page -1) * $max-images-per-page) lt $images-available)then
            ($page -1) * ($max-images-per-page) + 1
        else
            ($total-pages - 1) * $max-images-per-page
    ,
    
    $end := if($start + ($max-images-per-page -1) lt $images-available)then
				$start + ($max-images-per-page -1)
			else
				$images-available
    
    return
        <json:value>
            <magicWidth json:literal="true">{$local:magic-width}</magicWidth>
            <page json:literal="true">{$page}</page>
            <totalPages json:literal="true">{$total-pages}</totalPages>
            <images>
        {
            
(:            let $log := util:log("INFO" , $fn-images-available):)

            for $image at $i in $images return
        
                if ($image) then
(:                    let $collection-name := util:call($fn-get-image-collection, $image),:)
(:                    $imgLink := fn:concat("images", substring-after($collection-name, "/db"), "/", $image):)
(:                    let $imgLink := local:getImageLink($image, 64):)
                    let $imgLink := local:getIIIFLink($image, 64)
                    return
                        <json:value>
                            <src>{$imgLink}</src>
                            <item json:literal="true">{$start + $i - 1}</item>
                        </json:value>
                else
                    ()
        }
            </images>
        </json:value>
};


(:declare function local:image($item as xs:int) {:)
(:    let $cached := session:get-attribute("mods:cached"):)
(:    return:)
(:        if ($cached[$item]) then:)
(:            let $entry := $cached[$item]:)
(:            let $image := $entry/mods:location/mods:url[@access="preview"]/string():)
(:            let $imgLink := concat("images/", substring-after(util:collection-name($entry), "/db"), "/", $image):)
(:            return:)
(:                <image>:)
(:                    <src>{ $imgLink }</src>:)
(:                    <title>{ string-join(mods-common:get-short-title($entry), " ") }</title>:)
(:                </image>:)
(:        else:)
(:            ():)
(:};:)

declare function local:image($item as xs:int) {

    let $image-relations := session:get-attribute("image-relations")
(:    let $log := util:log("INFO", "getItem"):)

(:        let $imgLink := local:getImageLink($image-relations[$item], ()):)
    let $imgLink := local:getIIIFLink($image-relations[$item], ())
    return
        <image>
            <src>{ $imgLink }</src>
        </image>
};

declare function local:getIIIFLink($mods-related-item, $size as xs:integer?) {
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

declare function local:getImageLink($mods-related-item, $size as xs:integer?) {
    let $size := 
        if (not($size)) then 
            1024
        else
            $size
            
    let $work-uuid := replace($mods-related-item/@xlink:href/string(), '^#*', '')
    let $work := collection($naddara-config:resource-root)//vra:work[@id=$work-uuid]
    let $image-uuid := $work/vra:relationSet/vra:relation[@type="imageIs"][1]/@relids/string()
    
(:    let $log := util:log("INFO", $mods-related-item):)
    return
        "/exist/apps/tamboti/modules/display/image.xql?schema=IIIF&amp;call=/" || $image-uuid || "/full/!" || $size || "," || $size || "/0/default.jpg"
};

let $item := request:get-parameter("item", ())
(:let $collection := request:get-parameter("collection", ()):)
let $modsUUID := 
    if(request:get-parameter("modsUUID", ())) then
        request:get-parameter("modsUUID", ())
    else
        session:get-attribute("mods-uuid")
(:let $log := util:log("INFO", request:get-parameter-names()):)
let $store-uuid := session:set-attribute("mods-uuid", $modsUUID)
let $store-mods := session:set-attribute("mods-data", collection($naddara-config:resource-root)//mods:mods[@ID=$modsUUID])

let $get-images := local:get-mods-images()

return
    if ($item) then
(:        return:)
            local:image(xs:int($item))
    else
        let $fn :=
            if($modsUUID) then
(:                let $log := util:log("INFO", "not cached"):)
                    (
                        local:get-mods-images#0
                    )
            else
                (
(:                    util:log("INFO", "CACHED!"),:)
(:                    local:get-cache-image-count#0,:)
(:                    local:get-images-from-cache#2,:)
(:                    local:get-image-collection-for-cached#1:)
                )

        return
            local:thumbnails(xs:int(request:get-parameter("filmstripWidth", 800)), xs:int(request:get-parameter("page", 1)), $fn[1])