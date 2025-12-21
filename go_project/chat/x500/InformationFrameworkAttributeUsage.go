package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type InformationFrameworkAttributeUsage int

const (
    InformationFrameworkAttributeUsageUserApplications InformationFrameworkAttributeUsage = 0
    InformationFrameworkAttributeUsageDirectoryOperation InformationFrameworkAttributeUsage = 1
    InformationFrameworkAttributeUsageDistributedOperation InformationFrameworkAttributeUsage = 2
    InformationFrameworkAttributeUsageDSAOperation InformationFrameworkAttributeUsage = 3
)

