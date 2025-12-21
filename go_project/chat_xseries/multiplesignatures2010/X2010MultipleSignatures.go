package multiplesignatures2010

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/cryptographicmessagesyntax2010"
    "tobirama/chat_xseries/extendedsecurityservices2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2010MultipleSignatures struct {
    BodyHashAlg cryptographicmessagesyntax2010.X2010DigestAlgorithmIdentifier
    SignAlg cryptographicmessagesyntax2010.X2010SignatureAlgorithmIdentifier
    SignAttrsHash X2010SignAttrsHash
    Cert extendedsecurityservices2009.X2009ESSCertIDv2 `asn1:"optional"`
}
