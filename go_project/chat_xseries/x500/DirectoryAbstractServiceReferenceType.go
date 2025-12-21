package x500

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type DirectoryAbstractServiceReferenceType int

const (
    DirectoryAbstractServiceReferenceTypeSuperior DirectoryAbstractServiceReferenceType = 1
    DirectoryAbstractServiceReferenceTypeSubordinate DirectoryAbstractServiceReferenceType = 2
    DirectoryAbstractServiceReferenceTypeCross DirectoryAbstractServiceReferenceType = 3
    DirectoryAbstractServiceReferenceTypeNonSpecificSubordinate DirectoryAbstractServiceReferenceType = 4
    DirectoryAbstractServiceReferenceTypeSupplier DirectoryAbstractServiceReferenceType = 5
    DirectoryAbstractServiceReferenceTypeMaster DirectoryAbstractServiceReferenceType = 6
    DirectoryAbstractServiceReferenceTypeImmediateSuperior DirectoryAbstractServiceReferenceType = 7
    DirectoryAbstractServiceReferenceTypeSelf DirectoryAbstractServiceReferenceType = 8
)

