package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009IdentityProofV2 struct {
    ProofAlgID asn1.RawValue
    MacAlgId asn1.RawValue
    Witness []byte
}
