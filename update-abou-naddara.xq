xquery version "3.0";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace vra="http://www.vraweb.org/vracore4.htm";
declare namespace xlink = "http://www.w3.org/1999/xlink";

import module namespace functx = "http://www.functx.com";

declare function local:get-covers($collection-uri as xs:anyURI) {
    let $vra-works := xmldb:xcollection(($collection-uri || "/series_covers", $collection-uri || "/volume_covers"))//vra:work
    for $work in $vra-works
        let $w_uuid := $work/@id/string()
        let $i_uuids := $work/vra:relationSet/vra:relation/@relids/string()
        return
            <cover>
                <work>
                    <vra>{$work}</vra>
                    <title>{$work/vra:titleSet/vra:title/string()}</title>
                    <uuid>{$w_uuid}</uuid>
                </work>
            </cover>
};

let $fs-directory := "/home/samurai/mounts"

let $root := xs:anyURI("/db/data/commons/Naddara/Journals")
let $vra-records-root := xs:anyURI("/db/data/commons/Naddara/Journals")
let $mods := collection("/db/data/commons/Naddara/Journals/")/mods:mods

for $mods-record in $mods
    let $record-name := util:document-name($mods-record)
    let $record-collection := util:collection-name($mods-record)
    let $path-to-folder := $mods-record/mods:location/mods:url[@displayLabel="Path to Folder"]
    let $vra-records-location := $vra-records-root || substring-after($record-collection, $root) || "/" || $path-to-folder
    let $vra-records := xmldb:xcollection(xmldb:encode-uri($vra-records-location))//vra:work
    let $covers := local:get-covers(xmldb:encode-uri($vra-records-location))
    (: first remove the relatedItems for the page numbering   :)
(:    let $log := util:log("INFO", $mods-record/mods:relatedItem[./mods:part/mods:detail/@type = "page number"]):)

    let $remove-page-informations :=
        for $page-information in $mods-record/mods:relatedItem[./mods:part/mods:detail/@type = "page number"]
            return 
                update delete $page-information

    return
        <div>
            <mods-record>
                <uuid>{$mods-record/@ID/string()}</uuid>)
            </mods-record>
            <vra-records>
                <location>{xmldb:encode-uri($vra-records-location)}</location>
                <amount>{count($vra-records)}</amount>
                <plain>
                    {
                        for $record in $vra-records
                        order by xs:string($record/vra:titleSet/vra:title/string())
                            return $record
                    }
                </plain>
            </vra-records>
            <cover>
                {$covers}
            </cover>
            <to-insert>
                {
                    let $vra-records :=
                        for $vra-record at $number in $vra-records 
                        order by xs:string(functx:substring-before-last($vra-record/vra:titleSet/vra:title/string(), "."))
                        return
                            $vra-record
                    return
                        (

                            for $cover at $pos in $covers
(:                            let $page-number := replace(substring-before(substring-after($cover/work/vra/vra:work/vra:titleSet/vra:title[1]/string(), "_"), "_"), '^0*', '' ):)
                            let $page-number := replace(substring-before(substring-after($cover/work/vra//vra:work/vra:titleSet/vra:title[1]/string(), "_"), "_"), '^0*', '' )
                            let $page-number :=
                                if ($page-number = "") then
                                    0
                                else
                                    $page-number
(:                            let $log := util:log("INFO", $cover/work/vra/vra:work/vra:titleSet/vra:title[1]/string()):)
                            let $uuid := $cover/work/uuid/string()
                            
                            return
                                (: insert an relatedItem to the mods record:)
                                update insert
                                    <relatedItem xmlns="http://www.loc.gov/mods/v3" type="constituent" displayLabel="Cover Page" xlink:href="#{$uuid}">
                                        <typeOfResource>still image</typeOfResource>
                                        <identifier type="local">{$cover/work/uuid/string()}</identifier>
                                        <titleInfo>
                                            <title>{$cover/work/vra/vra:work/vra:titleSet/vra:title[1]/string()}</title>
                                        </titleInfo>
                                        <part>
                                            <text type="cover"/>
                                            <detail type="page number">
                                                <number>{$page-number}</number>
                                            </detail>
                                        </part>
                                    </relatedItem>
                                into $mods-record
                            ,
    
                            for $vra-record at $number in $vra-records 
                            let $title := $vra-record/vra:titleSet/vra:title[1]/string()
(:                            let $page-number := substring-before(substring-after($vra-record/vra:titleSet/vra:title[1]/string(), "_"), "_"):)
                            let $page-number := replace(substring-before(functx:substring-after-last($vra-record/vra:titleSet/vra:title[1]/string(), "_"), "."), '^0*', '' )
(:                            let $page-number := replace(substring-before(substring-after($vra-record/vra:titleSet/vra:title[1]/string(), "_"), "_"), '^0*', '' ):)
                            return
                                (
                                    let $remove-former-relations :=
                                        for $former-relation in $vra-record/vra:relationSet/vra:relation[@type="relatedTo" and ./string()="Tamboti MODS record"]
                                        return 
                                            update delete $former-relation
                                    return
                                        (: create relationSet if not existing:)
                                        if (count($vra-record/vra:relationSet) = 0) then
                                            update insert
                                                <relationSet xmlns="http://www.vraweb.org/vracore4.htm" >
                                                    <relation type="relatedTo" href="{$mods-record/@ID/string()}" pref="false">Tamboti MODS record</relation>
                                                </relationSet>
                                            into
                                                $vra-record
                                        else
                                            update insert
                                                <relation xmlns="http://www.vraweb.org/vracore4.htm" type="relatedTo" href="{$mods-record/@ID/string()}" pref="false">Tamboti MODS record</relation>
                                    into
                                        $vra-record/vra:relationSet
                                    ,
                                    
                                    (: insert an relatedItem in the MODS record, pointing to VRA Work:)
                                    update insert
                                        <relatedItem xmlns="http://www.loc.gov/mods/v3" type="constituent" displayLabel="Page" xlink:href="#{$vra-record/@id/string()}">
                                            <typeOfResource>still image</typeOfResource>
                                            <identifier type="local">{$vra-record/@id/string()}</identifier>
                                            <titleInfo>
                                                <title>{$title}</title>
                                            </titleInfo>
                                            <part>
                                                <detail type="page number" order="{$page-number}">
                                                    <number>{$page-number}</number>
                                                </detail>
                                            </part>
                                        </relatedItem>
                                    into $mods-record
                                )
                            )
                }
            </to-insert>
        </div>
        