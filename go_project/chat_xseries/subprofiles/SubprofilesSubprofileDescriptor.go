package subprofiles

import (
    "encoding/asn1"
    "time"
    "tobirama/chat_xseries/locationexpressions"
)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type SubprofilesSubprofileDescriptor struct {
    SubprofileIdentifier SubprofilesSubprofileIdentifier `asn1:"tag:0"`
    SubprofileReference SubprofilesSubprofileReference `asn1:"optional,tag:1"`
    SubprofilePrecedence int64 `asn1:"optional,tag:2"`
    DocumentFragmentReference locationexpressions.ExpressionsLocationExpression `asn1:"tag:3"`
    ContentArchitectureClasses []asn1.ObjectIdentifier `asn1:"optional,set,tag:4"`
    DocumentFragmentManagementAttributes SubprofilesDocumentFragmentManagementAttributes `asn1:"optional,tag:5"`
}
