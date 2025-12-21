package iso9541sn

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SNStructuredName struct {
    OwnerName SNOwnerName `asn1:"optional,tag:0"`
    OwnerDescription SNMessage `asn1:"optional,tag:1"`
    ObjectName []SNObjectNameComponent `asn1:"optional,tag:2"`
    ObjectDescription SNMessage `asn1:"optional,tag:3"`
}
