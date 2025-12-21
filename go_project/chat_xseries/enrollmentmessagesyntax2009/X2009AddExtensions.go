package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009AddExtensions struct {
    PkiDataReference X2009BodyPartID
    CertReferences []X2009BodyPartID
    Extensions []asn1.RawValue
}
