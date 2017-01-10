xquery version "3.0";
import module namespace functx="http://www.functx.com";

let $collection := xmldb:encode-uri('/db/data/commons/Naddara')
let $date := current-dateTime()

let $zip := compression:zip(xs:anyURI($collection || "/Journals"), true())
return
    response:stream-binary($zip, "application/zip", concat(functx:substring-after-last($collection, "/"), "_", $date, ".zip"))