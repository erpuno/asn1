package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AuthenticationFrameworkVersion int

const (
    AuthenticationFrameworkVersionV1 AuthenticationFrameworkVersion = 0
    AuthenticationFrameworkVersionV2 AuthenticationFrameworkVersion = 1
    AuthenticationFrameworkVersionV3 AuthenticationFrameworkVersion = 2
)

