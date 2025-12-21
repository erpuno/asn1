package smimesymmetrickeydistribution2009

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type X2009GLAdministration int

const (
    X2009GLAdministrationUnmanaged X2009GLAdministration = 0
    X2009GLAdministrationManaged X2009GLAdministration = 1
    X2009GLAdministrationClosed X2009GLAdministration = 2
)

