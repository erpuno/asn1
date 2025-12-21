package dordefinition

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var DefinitionDorSyntaxAsn1 = asn1.ObjectIdentifier{2, 0}
