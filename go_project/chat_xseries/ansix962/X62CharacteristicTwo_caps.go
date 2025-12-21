package ansix962

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X62CharacteristicTwo struct {
    M int64
    Basis asn1.ObjectIdentifier
    Parameters asn1.RawValue
}
