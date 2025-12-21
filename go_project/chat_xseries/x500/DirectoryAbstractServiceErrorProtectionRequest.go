package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceErrorProtectionRequest int

const (
    DirectoryAbstractServiceErrorProtectionRequestNone DirectoryAbstractServiceErrorProtectionRequest = 0
    DirectoryAbstractServiceErrorProtectionRequestSigned DirectoryAbstractServiceErrorProtectionRequest = 1
    DirectoryAbstractServiceErrorProtectionRequestEncrypted DirectoryAbstractServiceErrorProtectionRequest = 2
    DirectoryAbstractServiceErrorProtectionRequestSignedEncrypted DirectoryAbstractServiceErrorProtectionRequest = 3
)

