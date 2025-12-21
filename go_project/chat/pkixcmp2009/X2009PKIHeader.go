package pkixcmp2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat/pkix1implicit2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009PKIHeader struct {
    Pvno int64
    Sender pkix1implicit2009.X2009GeneralName
    Recipient pkix1implicit2009.X2009GeneralName
    MessageTime time.Time `asn1:"optional,tag:0"`
    ProtectionAlg asn1.RawValue `asn1:"optional,tag:1"`
    SenderKID pkix1implicit2009.X2009KeyIdentifier `asn1:"optional,tag:2"`
    RecipKID pkix1implicit2009.X2009KeyIdentifier `asn1:"optional,tag:3"`
    TransactionID []byte `asn1:"optional,tag:4"`
    SenderNonce []byte `asn1:"optional,tag:5"`
    RecipNonce []byte `asn1:"optional,tag:6"`
    FreeText X2009PKIFreeText `asn1:"optional,tag:7"`
    GeneralInfo []X2009InfoTypeAndValue `asn1:"optional,tag:8"`
}
