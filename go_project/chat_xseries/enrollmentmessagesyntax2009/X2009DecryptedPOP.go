package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009DecryptedPOP struct {
    BodyPartID X2009BodyPartID
    ThePOPAlgID asn1.RawValue
    ThePOP []byte
}
