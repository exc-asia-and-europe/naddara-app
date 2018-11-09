(:~
 : A set of helper functions to access the application context from
 : within a module.
 :)
module namespace naddara-config="http://hra.uni-heidelberg.de/ns/apps/naddara/config";

declare namespace repo="http://exist-db.org/xquery/repo";
declare namespace expath="http://expath.org/ns/pkg";

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

declare variable $naddara-config:resource-root := "/resources/commons/Abou_Naddara/Journals";

declare variable $naddara-config:iiif-server := "http://kjc-sv010.kjc.uni-heidelberg.de:6081/fcgi-bin/iipsrv.fcgi?IIIF=";
declare variable $naddara-config:iiif-server-path := "kjc-sv036/commons/Abou_Naddara/";

(:~
 : Returns the repo.xml descriptor for the current application.
 :)
declare function naddara-config:repo-descriptor() as element(repo:meta) {
    doc(concat($naddara-config:app-root, "/repo.xml"))/repo:meta
};

(:~
 : Returns the expath-pkg.xml descriptor for the current application.
 :)
declare function naddara-config:expath-descriptor() as element(expath:package) {
    doc(concat($naddara-config:app-root, "/expath-pkg.xml"))/expath:package
};

(:~
 : For debugging: generates a table showing all properties defined
 : in the application descriptors.
 :)
declare function naddara-config:app-info($node as node(), $params as element(parameters)?, $modes as item()*) {
    let $expath := naddara-config:expath-descriptor()
    let $repo := naddara-config:repo-descriptor()
    return
        <table class="app-info">
            <tr>
                <td>app collection:</td>
                <td>{$naddara-config:app-root}</td>
            </tr>
            {
                for $attr in ($expath/@*, $expath/*, $repo/*)
                return
                    <tr>
                        <td>{node-name($attr)}:</td>
                        <td>{$attr/string()}</td>
                    </tr>
            }
        </table>
};