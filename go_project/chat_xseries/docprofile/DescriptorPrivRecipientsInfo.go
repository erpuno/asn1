package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DescriptorPrivRecipientsInfo struct {
    PrivilegedRecipients []DescriptorPersonalName `asn1:"optional,set,tag:0"`
    EnciphermentMethodInfo DescriptorMethodInformation `asn1:"optional,tag:1"`
    EnciphermentKeyInfo DescriptorKeyInformation `asn1:"optional,tag:2"`
}
