package ocsp

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type OCSPResponseBytes struct {
    ResponseType asn1.ObjectIdentifier
    Response []byte
}
