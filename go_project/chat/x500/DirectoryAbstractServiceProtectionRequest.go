package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceProtectionRequest int

const (
    DirectoryAbstractServiceProtectionRequestNone DirectoryAbstractServiceProtectionRequest = 0
    DirectoryAbstractServiceProtectionRequestSigned DirectoryAbstractServiceProtectionRequest = 1
    DirectoryAbstractServiceProtectionRequestEncrypted DirectoryAbstractServiceProtectionRequest = 2
    DirectoryAbstractServiceProtectionRequestSignedEncrypted DirectoryAbstractServiceProtectionRequest = 3
)

