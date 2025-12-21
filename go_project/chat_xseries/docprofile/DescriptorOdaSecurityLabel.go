package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorOdaSecurityLabel struct {
    OdaLabelText DescriptorCharacterData `asn1:"optional,tag:0"`
    OdaLabelData []byte `asn1:"optional,tag:1"`
}
