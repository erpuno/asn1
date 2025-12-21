package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CMCUnsignedData struct {
    BodyPartPath X2009BodyPartPath
    Identifier asn1.ObjectIdentifier
    Content asn1.RawValue
}
