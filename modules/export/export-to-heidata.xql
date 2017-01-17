xquery version "3.1";

declare namespace mods = "http://www.loc.gov/mods/v3";

let $documents := collection("/data/naddara")/mods:mods
let $delete-displayLabel-attr-of-number-element :=
    for $element in $documents//mods:detail/mods:number[@displayLabel]
    
    return update delete $element/@displayLabel

let $delete-order-attr-of-detail-element :=
    for $element in $documents//mods:part/mods:detail[@order]
    
    return update delete $element/@order
    
let $insert-note-element-instead-of-displayLabel-attr-of-dateIssued-element :=
    for $element in $documents//mods:dateIssued[@displayLabel]
    let $displayLabel-content := $element/@displayLabel
    let $text-content := $element/text()
    let $note := <note xmlns="http://www.loc.gov/mods/v3" type="edition" displayLabel="{$displayLabel-content}">{$text-content}</note>
    
    return
        (
            update insert $note preceding $element/root()/*/mods:relatedItem
            ,
            update delete $element
        )
        

return $insert-note-element-instead-of-displayLabel-attr-of-dateIssued-element
