package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkixcrmf2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CMCPublicationInfo struct {
    HashAlg asn1.RawValue
    CertHashes [][]byte
    PubInfo pkixcrmf2009.X2009PKIPublicationInfo
}
