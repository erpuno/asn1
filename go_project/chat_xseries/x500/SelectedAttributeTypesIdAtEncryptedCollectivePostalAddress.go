package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var SelectedAttributeTypesIdAtEncryptedCollectivePostalAddress = asn1.ObjectIdentifier{16, 1, 2}
