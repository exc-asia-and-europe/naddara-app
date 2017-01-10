xquery version "1.0";

declare variable $exist:path external;
declare variable $exist:resource external;

if ($exist:path eq "/") then
    (: forward root path to index.xql :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <redirect url="index.html"/>
    </dispatch>
else if (ends-with($exist:resource, ".html")) then
    (: the html page is run through view.xql to expand templates :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <view>
            <forward url="modules/view.xql"/>
        </view>
    </dispatch>
else if (starts-with($exist:path, "/images/")) then
    let $real-resources-path := substring-after($exist:path, "/images")
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="/images/scale/{$real-resources-path}" absolute="yes"/>
        </dispatch>
else if (fn:starts-with($exist:path, "/libs/")) then
    let $lib-path := fn:concat("/", substring-after($exist:path, 'libs/')) 
    return
        <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
            <forward url="{$lib-path}" absolute="yes"/>
        </dispatch>
else
    (: everything else is passed through :)
    <dispatch xmlns="http://exist.sourceforge.net/NS/exist">
        <cache-control cache="yes"/>
    </dispatch>