package pkix1implicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Implicit88AccessDescription struct {
    AccessMethod asn1.ObjectIdentifier
    AccessLocation PKIX1Implicit88GeneralName
}
