package basicaccesscontrol

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

var BasicAccessControlRuleBasedAccessControl = asn1.ObjectIdentifier{3}
