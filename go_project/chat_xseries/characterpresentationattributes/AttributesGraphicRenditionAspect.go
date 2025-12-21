package characterpresentationattributes

import (
    "encoding/asn1"
    "time"

)

var _ = asn1.RawValue{}
var _ = time.Time{}
var _ = asn1.ObjectIdentifier{}

type AttributesGraphicRenditionAspect int

const (
    AttributesGraphicRenditionAspectCancel AttributesGraphicRenditionAspect = 0
    AttributesGraphicRenditionAspectIncreasedIntensity AttributesGraphicRenditionAspect = 1
    AttributesGraphicRenditionAspectDecreasedIntensity AttributesGraphicRenditionAspect = 2
    AttributesGraphicRenditionAspectItalicized AttributesGraphicRenditionAspect = 3
    AttributesGraphicRenditionAspectUnderlined AttributesGraphicRenditionAspect = 4
    AttributesGraphicRenditionAspectSlowlyBlinking AttributesGraphicRenditionAspect = 5
    AttributesGraphicRenditionAspectRapidlyBlinking AttributesGraphicRenditionAspect = 6
    AttributesGraphicRenditionAspectNegativeImage AttributesGraphicRenditionAspect = 7
    AttributesGraphicRenditionAspectCrossedOut AttributesGraphicRenditionAspect = 9
    AttributesGraphicRenditionAspectPrimaryFont AttributesGraphicRenditionAspect = 10
    AttributesGraphicRenditionAspectFirstAlternativeFont AttributesGraphicRenditionAspect = 11
    AttributesGraphicRenditionAspectSecondAlternativeFont AttributesGraphicRenditionAspect = 12
    AttributesGraphicRenditionAspectThirdAlternativeFont AttributesGraphicRenditionAspect = 13
    AttributesGraphicRenditionAspectFourthAlternativeFont AttributesGraphicRenditionAspect = 14
    AttributesGraphicRenditionAspectFifthAlternativeFont AttributesGraphicRenditionAspect = 15
    AttributesGraphicRenditionAspectSixthAlternativeFont AttributesGraphicRenditionAspect = 16
    AttributesGraphicRenditionAspectSeventhAlternativeFont AttributesGraphicRenditionAspect = 17
    AttributesGraphicRenditionAspectEighthAlternativeFont AttributesGraphicRenditionAspect = 18
    AttributesGraphicRenditionAspectNinthAlternativeFont AttributesGraphicRenditionAspect = 19
    AttributesGraphicRenditionAspectDoublyUnderlined AttributesGraphicRenditionAspect = 21
    AttributesGraphicRenditionAspectNormalIntensity AttributesGraphicRenditionAspect = 22
    AttributesGraphicRenditionAspectNotItalicized AttributesGraphicRenditionAspect = 23
    AttributesGraphicRenditionAspectNotUnderlined AttributesGraphicRenditionAspect = 24
    AttributesGraphicRenditionAspectSteady AttributesGraphicRenditionAspect = 25
    AttributesGraphicRenditionAspectVariableSpacing AttributesGraphicRenditionAspect = 26
    AttributesGraphicRenditionAspectPositiveImage AttributesGraphicRenditionAspect = 27
    AttributesGraphicRenditionAspectNotCrossedOut AttributesGraphicRenditionAspect = 29
    AttributesGraphicRenditionAspectBlackForeground AttributesGraphicRenditionAspect = 30
    AttributesGraphicRenditionAspectRedForeground AttributesGraphicRenditionAspect = 31
    AttributesGraphicRenditionAspectGreenForeground AttributesGraphicRenditionAspect = 32
    AttributesGraphicRenditionAspectYellowForeground AttributesGraphicRenditionAspect = 33
    AttributesGraphicRenditionAspectBlueForeground AttributesGraphicRenditionAspect = 34
    AttributesGraphicRenditionAspectMagentaForeground AttributesGraphicRenditionAspect = 35
    AttributesGraphicRenditionAspectCyanForeground AttributesGraphicRenditionAspect = 36
    AttributesGraphicRenditionAspectWhiteForeground AttributesGraphicRenditionAspect = 37
    AttributesGraphicRenditionAspectSelectCharForegroundColour AttributesGraphicRenditionAspect = 38
    AttributesGraphicRenditionAspectBlackBackground AttributesGraphicRenditionAspect = 40
    AttributesGraphicRenditionAspectRedBackground AttributesGraphicRenditionAspect = 41
    AttributesGraphicRenditionAspectGreenBackground AttributesGraphicRenditionAspect = 42
    AttributesGraphicRenditionAspectYellowBackground AttributesGraphicRenditionAspect = 43
    AttributesGraphicRenditionAspectBlueBackground AttributesGraphicRenditionAspect = 44
    AttributesGraphicRenditionAspectMagentaBackground AttributesGraphicRenditionAspect = 45
    AttributesGraphicRenditionAspectCyanBackground AttributesGraphicRenditionAspect = 46
    AttributesGraphicRenditionAspectWhiteBackground AttributesGraphicRenditionAspect = 47
    AttributesGraphicRenditionAspectSelectCharBackgroundColour AttributesGraphicRenditionAspect = 48
    AttributesGraphicRenditionAspectNotVariableSpacing AttributesGraphicRenditionAspect = 50
)

