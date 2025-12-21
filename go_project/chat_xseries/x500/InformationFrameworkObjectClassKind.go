package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkObjectClassKind int

const (
    InformationFrameworkObjectClassKindAbstract InformationFrameworkObjectClassKind = 0
    InformationFrameworkObjectClassKindStructural InformationFrameworkObjectClassKind = 1
    InformationFrameworkObjectClassKindAuxiliary InformationFrameworkObjectClassKind = 2
)

