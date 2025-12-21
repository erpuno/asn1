package ansix942

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X42FieldID struct {
    FieldType asn1.ObjectIdentifier
    Parameters asn1.RawValue
}
