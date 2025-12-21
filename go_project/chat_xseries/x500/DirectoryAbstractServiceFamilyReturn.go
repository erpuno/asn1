package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceFamilyReturn struct {
    MemberSelect int
    FamilySelect []asn1.ObjectIdentifier `asn1:"optional"`
}
