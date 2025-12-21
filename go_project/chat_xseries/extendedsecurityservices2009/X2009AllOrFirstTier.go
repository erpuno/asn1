package extendedsecurityservices2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009AllOrFirstTier int

const (
    X2009AllOrFirstTierAllReceipts X2009AllOrFirstTier = 0
    X2009AllOrFirstTierFirstTierRecipients X2009AllOrFirstTier = 1
)

