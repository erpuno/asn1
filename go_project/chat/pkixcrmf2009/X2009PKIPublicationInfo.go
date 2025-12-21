package pkixcrmf2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PKIPublicationInfo struct {
    Action int64
    PubInfos []X2009SinglePubInfo `asn1:"optional"`
}
