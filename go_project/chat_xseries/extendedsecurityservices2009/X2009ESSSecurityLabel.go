package extendedsecurityservices2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009ESSSecurityLabel struct {
    SecurityPolicyIdentifier X2009SecurityPolicyIdentifier
    SecurityClassification X2009SecurityClassification `asn1:"optional"`
    PrivacyMark X2009ESSPrivacyMark `asn1:"optional"`
    SecurityCategories X2009SecurityCategories `asn1:"optional,set"`
}
