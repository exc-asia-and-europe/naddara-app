xquery version "3.1";

module namespace naddara-config="http://hra.uni-heidelberg.de/ns/apps/naddara/config";

(: 
    Determine the application root collection from the current module load path.
:)
declare variable $naddara-config:app-root := 
    let $rawPath := system:get-module-load-path()
    let $modulePath :=
        (: strip the xmldb: part :)
        if (starts-with($rawPath, "xmldb:exist://")) then
            if (starts-with($rawPath, "xmldb:exist://embedded-eXist-server")) then
                substring($rawPath, 36)
            else
                substring($rawPath, 15)
        else
            $rawPath
    return
        substring-before($modulePath, "/modules")
;

declare variable $naddara-config:resource-root := "/data/commons/Abou_Naddara/Journals";

declare variable $naddara-config:iiif-server := "http://kjc-sv010.kjc.uni-heidelberg.de:6081/fcgi-bin/iipsrv.fcgi?IIIF=";
declare variable $naddara-config:iiif-server-path := "kjc-sv016/commons/Abou_Naddara/";
