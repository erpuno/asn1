package docprofile

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesColourSpaceCalibrationType int

const (
    AttributesColourSpaceCalibrationTypeNoCalibration AttributesColourSpaceCalibrationType = 0
    AttributesColourSpaceCalibrationTypeMatrices AttributesColourSpaceCalibrationType = 1
    AttributesColourSpaceCalibrationTypeLookupTables AttributesColourSpaceCalibrationType = 2
    AttributesColourSpaceCalibrationTypeMatricesAndLookupTables AttributesColourSpaceCalibrationType = 3
)

