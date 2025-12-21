package ansix942

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X42ALGORITHMID struct {
    Algorithm asn1.ObjectIdentifier
    Parameters asn1.RawValue `asn1:"optional"`
}

