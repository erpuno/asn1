package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorsProtection int

const (
    DescriptorsProtectionUnprotected DescriptorsProtection = 0
    DescriptorsProtectionProtected DescriptorsProtection = 1
)

