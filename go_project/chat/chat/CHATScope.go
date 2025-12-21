package chat

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type CHATScope int

const (
    CHATScopeProfile CHATScope = 0
    CHATScopeFolder CHATScope = 1
    CHATScopeContact CHATScope = 2
    CHATScopeMember CHATScope = 3
    CHATScopeRoom CHATScope = 4
    CHATScopeChat CHATScope = 5
    CHATScopeMessage CHATScope = 6
)

