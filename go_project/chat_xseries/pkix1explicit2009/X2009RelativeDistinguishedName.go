package pkix1explicit2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkixcommontypes2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009RelativeDistinguishedName []pkixcommontypes2009.X2009SingleAttribute
