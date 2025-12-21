package pkixcrmf2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009SubsequentMessage int

const (
    X2009SubsequentMessageEncrCert X2009SubsequentMessage = 0
    X2009SubsequentMessageChallengeResp X2009SubsequentMessage = 1
)

