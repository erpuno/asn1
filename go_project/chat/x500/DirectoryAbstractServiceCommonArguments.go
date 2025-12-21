package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceCommonArguments struct {
    ServiceControls DirectoryAbstractServiceServiceControls `asn1:"tag:30"`
    SecurityParameters DirectoryAbstractServiceSecurityParameters `asn1:"optional,tag:29"`
    Requestor InformationFrameworkDistinguishedName `asn1:"optional,tag:28"`
    OperationProgress DirectoryAbstractServiceOperationProgress `asn1:"tag:27"`
    AliasedRDNs int64 `asn1:"optional,tag:26"`
    CriticalExtensions asn1.BitString `asn1:"optional,tag:25"`
    ReferenceType DirectoryAbstractServiceReferenceType `asn1:"optional,tag:24"`
    EntryOnly bool `asn1:"tag:23"`
    NameResolveOnMaste bool `asn1:"tag:21"`
    OperationContexts DirectoryAbstractServiceContextSelection `asn1:"optional,tag:20"`
    FamilyGrouping DirectoryAbstractServiceFamilyGrouping `asn1:"tag:19"`
}
