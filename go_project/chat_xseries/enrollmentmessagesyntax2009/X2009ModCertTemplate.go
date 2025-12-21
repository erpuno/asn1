package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkixcrmf2009"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ModCertTemplate struct {
    PkiDataReference X2009BodyPartPath
    CertReferences X2009BodyPartList
    Replace bool
    CertTemplate pkixcrmf2009.X2009CertTemplate
}
