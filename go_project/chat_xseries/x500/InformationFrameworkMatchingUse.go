package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkMatchingUse struct {
    RestrictionType asn1.ObjectIdentifier
    RestrictionValue asn1.RawValue
}
