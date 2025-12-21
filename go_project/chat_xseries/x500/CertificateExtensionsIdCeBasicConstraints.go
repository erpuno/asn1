package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var CertificateExtensionsIdCeBasicConstraints = asn1.ObjectIdentifier{19}
