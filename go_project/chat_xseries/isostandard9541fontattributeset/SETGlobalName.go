package isostandard9541fontattributeset

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/iso9541sn"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SETGlobalName struct {
    PrefixIndex SETCode `asn1:"optional,tag:0"`
    NameValue iso9541sn.SNStructuredName `asn1:"tag:1"`
}
