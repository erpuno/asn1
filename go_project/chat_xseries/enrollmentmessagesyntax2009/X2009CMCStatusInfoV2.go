package enrollmentmessagesyntax2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009CMCStatusInfoV2 struct {
    CMCStatus X2009CMCStatus
    BodyList []X2009BodyPartReference
    StatusString string `asn1:"optional"`
    OtherInfo asn1.RawValue `asn1:"optional"`
}
