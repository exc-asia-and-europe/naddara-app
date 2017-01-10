xquery version "3.0";
declare namespace mods="http://www.loc.gov/mods/v3";

let $log := util:log("INFO", xmldb:get-current-user())

let $model :=
    xmldb:xcollection("/resources/commons/Abou_Naddara")//mods:mods

return $model