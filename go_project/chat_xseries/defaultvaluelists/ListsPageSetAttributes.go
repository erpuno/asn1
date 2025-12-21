package defaultvaluelists

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type ListsPageSetAttributes struct {
    LayoutStreamCategories asn1.RawValue `asn1:"optional"`
    LayoutStreamSubCategories asn1.RawValue `asn1:"optional"`
}
