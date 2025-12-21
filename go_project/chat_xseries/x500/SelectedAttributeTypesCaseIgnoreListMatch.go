package x500

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/pkix1explicit88"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SelectedAttributeTypesCaseIgnoreListMatch []pkix1explicit88.PKIX1Explicit88DirectoryString
