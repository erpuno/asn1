package smimesymmetrickeydistribution2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009GLUseKEK struct {
    GlInfo X2009GLInfo
    GlOwnerInfo []X2009GLOwnerInfo
    GlAdministration X2009GLAdministration
    GlKeyAttributes X2009GLKeyAttributes `asn1:"optional"`
}
