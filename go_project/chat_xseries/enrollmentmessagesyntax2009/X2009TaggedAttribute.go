package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009TaggedAttribute struct {
    BodyPartID X2009BodyPartID
    AttrType asn1.ObjectIdentifier
    AttrValues []asn1.RawValue `asn1:"set"`
}
