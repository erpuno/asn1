package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PopLinkWitnessV2 struct {
    KeyGenAlgorithm asn1.RawValue
    MacAlgorithm asn1.RawValue
    Witness []byte
}
