package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesThreeNums struct {
    Column1 AttributesRealOrInt
    Column2 AttributesRealOrInt
    Column3 AttributesRealOrInt
}
