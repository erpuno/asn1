package pkcs12

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkixcrmf2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X12KeyBag pkixcrmf2009.X2009PrivateKeyInfo