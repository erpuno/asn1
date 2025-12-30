ASN.1 Compiler
==============

ISO 8824 ITU/IETF X.680-690 ERP/1 ASN.1 DER Code Generation Compiler created by Namdak Tönpa.

Supported Languages
-------------------

* C99
* Swift
* Rust
* Go
* Java
* TypeScript

Articles
--------

ARTICLES

The detailed worklog is presented as series of articles.

* <a href="https://tonpa.guru/stream/2010/2010-10-18 LDAP.htm">2010-10-18 LDAP</a>
* <a href="https://tonpa.guru/stream/2020/2020-02-03 Кваліфікований Електронний Підпис.htm">2020-02-03 Кваліфікований Електронний Підпис</a>
* <a href="https://tonpa.guru/stream/2023/2023-06-22 Месенжер.htm">2023-06-22 CMS Месенжер (Пітч)</a>
* <a href="https://chat.erp.uno">2023-06-30 ЧАТ X.509 (Домашня сторінка)</a>
* <a href="https://tonpa.guru/stream/2023/2023-07-05 CMS SMIME.htm">2023-07-05 CMS S/MIME</a>
* <a href="https://tonpa.guru/stream/2023/2023-07-16 CMS Compliance.htm">2023-07-16 CMS Compliance</a>
* <a href="https://tonpa.guru/stream/2023/2023-07-20 LDAP Compliance.htm">2023-07-20 LDAP Compliance</a>
* <a href="https://ldap.erp.uno">2023-07-25 LDAP 13.7.24 (Домашня сторінка)</a>
* <a href="https://authority.erp.uno">2023-07-30 CA X.509 (Домашня сторінка)</a>
* <a href="https://tonpa.guru/stream/2023/2023-07-21 CMP CMC EST.htm">2023-07-21 CMP/CMC/EST</a>
* <a href="https://tonpa.guru/stream/2023/2023-07-27 MLS.htm">2023-07-21 MLS ROOM CHAT</a>
* <a href="https://tonpa.guru/stream/2023/2023-08-05 CA CURVE.htm">2023-08-05 CA CURVE</a>
* <a href="https://tonpa.guru/stream/2023/2023-08-07 CHAT ASN.1.htm">2023-08-07 CHAT ASN.1</a>
* <a href="https://tonpa.guru/stream/2023/2023-08-08 ASN.1 Компілятор.htm">2023-08-08 ASN.1 Компілятор</a>
* <a href="https://tonpa.guru/stream/2023/2023-09-01 ASN1.EX X.680.htm">2023-09-01 ASN1.EX X.680</a>
* <a href="https://tonpa.guru/stream/2024/2024-10-29 EST.htm">2024-10-29 EST сервер 7030</a>
* <a href="https://tonpa.guru/stream/2024/2024-11-17 EUDI.htm">2024-11-17 EUDI</a>
* <a href="https://tonpa.guru/stream/2024/2024-11-20 CBOR COSE.htm">2024-11-20 CBOR COSE</a>
* <a href="https://tonpa.guru/stream/2024/2024-11-21 MSO MDoc.htm">2024-11-21 MSO MDoc</a>

X-Series
--------

X-Series profile contains full set of ITU standards. To regenerate Sources/Suite/XSeries folder use ./x-series.ex script.

```
AESKeyWrapWithPad-02.asn1
AESKeyWrapWithPad-88.asn1
ANSI-X9-42.asn1
ANSI-X9-62.asn1
AlgorithmInformation-2009.asn1
AttributeCertificateVersion1-2009.asn1
AuthenticationFramework.asn1
BasicAccessControl.asn1
CMS-AES-CCM-and-AES-GCM-2009.asn1
CMSAesRsaesOaep-2009.asn1
CMSECCAlgs-2009-02.asn1
CMSECDHAlgs-2017.asn1
CertificateExtensions.asn1
Character-Coding-Attributes.asn1
Character-Presentation-Attributes.asn1
Character-Profile-Attributes.asn1
Colour-Attributes.asn1
CryptographicMessageSyntax-2009.asn1
CryptographicMessageSyntax-2010.asn1
CryptographicMessageSyntaxAlgorithms-2009.asn1
DOR-definition.asn1
Default-Value-Lists.asn1
DirectoryAbstractService.asn1
Document-Profile-Descriptor.asn1
EnrollmentMessageSyntax-2009.asn1
ExtendedSecurityServices-2009.asn1
External-References.asn1
Geo-Gr-Coding-Attributes.asn1
Geo-Gr-Presentation-Attributes.asn1
Geo-Gr-Profile-Attributes.asn1
ISO-STANDARD-9541-FONT-ATTRIBUTE-SET.asn1
ISO9541-SN.asn1
Identifiers-and-Expressions.asn1
InformationFramework.asn1
Layout-Descriptors.asn1
Link-Descriptors.asn1
Location-Expressions.asn1
Logical-Descriptors.asn1
MultipleSignatures-2010.asn1
OCSP.asn1
PKCS-10.asn1
PKCS-12.asn1
PKCS-5.asn1
PKCS-7.asn1
PKCS-8.asn1
PKCS-9.asn1
PKIX-CommonTypes-2009.asn1
PKIX-X400Address-2009.asn1
PKIX1-PSS-OAEP-Algorithms-2009.asn1
PKIX1Explicit-2009.asn1
PKIX1Explicit88.asn1
PKIX1Implicit-2009.asn1
PKIX1Implicit88.asn1
PKIXAlgs-2009.asn1
PKIXAttributeCertificate-2009.asn1
PKIXCMP-2009.asn1
PKIXCRMF-2009.asn1
Raster-Gr-Coding-Attributes.asn1
Raster-Gr-Presentation-Attributes.asn1
Raster-Gr-Profile-Attributes.asn1
SMIMESymmetricKeyDistribution-2009.asn1
SecureMimeMessageV3dot1-2009.asn1
SelectedAttributeTypes.asn1
Style-Descriptors.asn1
Subprofiles.asn1
Temporal-Relationships.asn1
Text-Units.asn1
UpperBounds.asn1
UsefulDefinitions.asn1
Videotex-Coding-Attributes.asn1
```

Basic
-----

Basic profile contains CHAT, LDAP and Ukrainian Cryptography Envelopes KEP and DSTU. To regenerate Sources/Suite/Basic folder use ./basic.ex script.

```
CHAT.asn1
DSTU.asn1
KEP.asn1
LDAP.asn1     
```

Minimal
-------

Minimal profile contains vital viability testing. To regenerate Sources/Suite/Minimal folder use ./minimal.ex script. Suite profile contains minimal ASN.1 definition that should cover all compiler branches.

```
SUITE-EXPLICIT.asn1
SUITE-IMPLICIT.asn1
```

Authors
-------

* <a href="https://github.com/Iho">Iho</a> Ігор Горобець
* <a href="https://github.com/MonetaPM">MonetaPM</a> Євгеній Гадібіров
* <a href="https://github.com/5HT">5HT</a> Максим Сохацький

OM A HUM
