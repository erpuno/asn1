package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkDITContentRule struct {
    StructuralObjectClass asn1.ObjectIdentifier
    Auxiliaries []asn1.ObjectIdentifier `asn1:"optional,set"`
    Mandatory []asn1.ObjectIdentifier `asn1:"optional,set,tag:1"`
    Optional []asn1.ObjectIdentifier `asn1:"optional,set,tag:2"`
    Precluded []asn1.ObjectIdentifier `asn1:"optional,set,tag:3"`
}
