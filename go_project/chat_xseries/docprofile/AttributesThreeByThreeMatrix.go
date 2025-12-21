package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesThreeByThreeMatrix struct {
    Row1 AttributesThreeNums
    Row2 AttributesThreeNums
    Row3 AttributesThreeNums
}
