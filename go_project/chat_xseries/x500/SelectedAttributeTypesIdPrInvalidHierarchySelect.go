package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var SelectedAttributeTypesIdPrInvalidHierarchySelect = asn1.ObjectIdentifier{24}
