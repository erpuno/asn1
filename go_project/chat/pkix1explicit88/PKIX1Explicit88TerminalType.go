package pkix1explicit88

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type PKIX1Explicit88TerminalType int

const (
    PKIX1Explicit88TerminalTypeTelex PKIX1Explicit88TerminalType = 3
    PKIX1Explicit88TerminalTypeTeletex PKIX1Explicit88TerminalType = 4
    PKIX1Explicit88TerminalTypeG3Facsimile PKIX1Explicit88TerminalType = 5
    PKIX1Explicit88TerminalTypeG4Facsimile PKIX1Explicit88TerminalType = 6
    PKIX1Explicit88TerminalTypeIa5Terminal PKIX1Explicit88TerminalType = 7
    PKIX1Explicit88TerminalTypeVideotex PKIX1Explicit88TerminalType = 8
)

