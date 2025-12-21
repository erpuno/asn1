package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorDocumentSecurityAttributes struct {
    SealedInfoEncoding asn1.ObjectIdentifier `asn1:"optional,tag:7"`
    OdaSecurityLabel DescriptorOdaSecurityLabel `asn1:"optional,tag:0"`
    SealedDocProfiles DescriptorSealedDocProfiles `asn1:"optional,set,tag:1"`
    PresealedDocBodyparts DescriptorSealedDocBodyparts `asn1:"optional,set,tag:2"`
    PostsealedDocBodyparts DescriptorSealedDocBodyparts `asn1:"optional,set,tag:3"`
    EncipheredDocProfiles DescriptorProtectedDocParts `asn1:"optional,set,tag:4"`
    PreencipheredDocBodyparts DescriptorProtectedDocParts `asn1:"optional,set,tag:5"`
    PostencipheredDocBodyparts DescriptorProtectedDocParts `asn1:"optional,set,tag:6"`
    SealedLinks DescriptorSealedDocBodyparts `asn1:"optional,set,tag:8"`
}
