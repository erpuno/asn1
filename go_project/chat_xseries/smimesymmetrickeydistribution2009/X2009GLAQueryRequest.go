package smimesymmetrickeydistribution2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009GLAQueryRequest struct {
    GlaRequestType asn1.ObjectIdentifier
    GlaRequestValue asn1.RawValue
}
