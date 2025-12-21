package iso9541sn

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SNOwnerName struct {
    ObjectIdentifier asn1.ObjectIdentifier `asn1:"optional,tag:0"`
    OwnerNameComponent []SNOwnerNameComponent `asn1:"optional,tag:1"`
}
