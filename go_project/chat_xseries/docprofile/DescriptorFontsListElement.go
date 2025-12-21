package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorFontsListElement struct {
    FontIdentifier int64
    FontReference DescriptorFontReference
}
