package videotexcodingattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesProfile int

const (
    AttributesProfileUndefined AttributesProfile = 0
    AttributesProfileProfile1 AttributesProfile = 81
    AttributesProfileProfile2 AttributesProfile = 82
    AttributesProfileProfile3 AttributesProfile = 83
    AttributesProfileProfile4 AttributesProfile = 84
    AttributesProfileProfileX11 AttributesProfile = 85
    AttributesProfileProfileX12 AttributesProfile = 86
    AttributesProfileProfileX13 AttributesProfile = 87
    AttributesProfileProfileX14 AttributesProfile = 88
    AttributesProfileProfileX21 AttributesProfile = 89
    AttributesProfileProfileX22 AttributesProfile = 90
    AttributesProfileProfileX23 AttributesProfile = 91
    AttributesProfileProfileX24 AttributesProfile = 92
)

