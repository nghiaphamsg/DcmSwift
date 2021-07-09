//
//  DicomSpec.swift
//  DICOM Test
//
//  Created by Rafael Warnault on 19/10/2017.
//  Copyright © 2017 OPALE, Rafaël Warnault. All rights reserved.
//

import Foundation




/**
 The DicomSpec class defines a set of helpers and data structures
 in order to facilitate the handling of the DICOM standard
 */
public class DicomSpec: NSObject, XMLParserDelegate {

    
    
    
    
    // MARK: - Members definition
    
    /**
     The DicomSpec is a singleton class
     */
    public static let shared = DicomSpec()
    
    /**
     Tags dictionnary by code
     */
    public var tags:[String: [String : String]] = [:]
    
    /**
     Tags dictionnary by name
     */
    public var tagsByName:[String: [String : String]] = [:]
    
    /**
     UID dictionnary by SOP Class
     */
    public var uids:[String: [String : String]] = [:]
    
    public var sopClassesArray:[[String : String]]       = []
    public var transferSyntaxArray:[[String : String]]   = []
    public var sopPairs:[String: [String]] = [:]
    
    private var parser = XMLParser()
    
    /**
     The `validate` flag is aimed to enable nor disable the DICOM specifications
     validation rules. If `validate` is true, DcmSwift will check for several values
     in DICOM dataset like Trasfer Syntaxes and SOP Classes.
     */
    public var validate = true
    
    
    
    // MARK: - Init
    private override init() {
        super.init()
        
        let data = xmlSpec.data(using: .utf8)
        self.parser = XMLParser(data: data!)
        self.parser.delegate = self
        
        self.parser.parse()
        
        self.sopPairs = [
            DicomConstants.verificationSOP: [
                TransferSyntax.implicitVRLittleEndian,
                TransferSyntax.explicitVRLittleEndian,
                TransferSyntax.explicitVRBigEndian
            ],
            DicomConstants.StudyRootQueryRetrieveInformationModelFIND: [
                TransferSyntax.implicitVRLittleEndian,
                TransferSyntax.explicitVRLittleEndian,
                TransferSyntax.explicitVRBigEndian
            ]
        ]
        
        for storageSOP in sopClassesArray {
            if let uid = storageSOP["uid"] {
                sopPairs[uid] = [
                    TransferSyntax.implicitVRLittleEndian,
                    TransferSyntax.explicitVRLittleEndian,
                    TransferSyntax.explicitVRBigEndian
                ]
            }
        }
    }
    
    
    
    
    

    
    
    
    // MARK: - Static VR helpers
    
    /**
     Returns the fixed length of the given VR
     following the DICOM standard.
     
     - Parameter vr: VR enum
     
     */
    public static func lengthOf(vr:VR.VR) -> Int {
        switch vr {
        case .AS:
            return 4
        case .AT:
            return 4
        case .DA:
            return 8
        case .DT:
            return 26
        case .FL:
            return 4
        case .FD:
            return 8
        case .SL:
            return 4
        case .SS:
            return 2
        case .UL:
            return 4
        case .US:
            return 2
        default:
            return 0
        }
    }
    
    
    /**
     Returns the max length of the given VR
     following the DICOM standard.
     
     - Parameter vr: VR enum
     
     */
    public static func maxLengthOf(vr:VR.VR) -> Int {
        switch vr {
        case .AE:
            return 16
        case .CS:
            return 16
        case .DA:
            return 18
        case .DS:
            return 16
        case .DT:
            return 26
        case .IS:
            return 12
        case .LO:
            return 64
        case .LT:
            return 10240
        case .OD:
            return 0
        case .OF:
            return 0
        case .PN:
            return 64
        case .SH:
            return 16
        case .ST:
            return 1024
        case .TM:
            return 64
        case .UT:
            return 0
        default:
            return 0
        }
    }
    
    
    
    

    
    
    
    /**
     Returns the string representation of the given VR
     following the DICOM standard.
     
     - Parameter vr: VR enum
     
     */
    public static func vr(for vr:String) -> VR.VR? {
        switch vr {
        case "AE":
            return .AE
        case "AS":
            return .AS
        case "AT":
            return .AT
        case "CS":
            return .CS
        case "DA":
            return .DA
        case "DS":
            return .DS
        case "DT":
            return .DT
        case "FL":
            return .FL
        case "FD":
            return .FD
        case "IS":
            return .IS
        case "LO":
            return .LO
        case "LT":
            return .LT
        case "OB":
            return .OB
        case "OD":
            return .OD
        case "OF":
            return .OF
        case "OW":
            return .OW
        case "PN":
            return .PN
        case "SH":
            return .SH
        case "SL":
            return .SL
        case "SQ":
            return .SQ
        case "SS":
            return .SS
        case "ST":
            return .ST
        case "TM":
            return .TM
        case "UI":
            return .UI
        case "UL":
            return .UL
        case "UN":
            return .UN
        case "US":
            return .US
        case "UT":
            return .UT
        case "US/SS":
            return .US
        case "OB/OW":
            return .OB
        default:
            return nil
        }
    }
    
    
    
    
    
    // MARK: - Public Methods
    
    /**
     Returns an array of every SOP Classes known
     by the current implemntation
     - Returns: An array of DICOM SOP Classes
     */
    public func sopClasses() -> [[String : String]] {
        return self.sopClassesArray
    }
    
    
    
    /**
     Returns an array of every Transfer Syntaxes known
     by the current implemntation
     - Returns: An array of DICOM Transfer Syntaxes
     */
    public func transferSyntaxes() -> [[String : String]] {
        return self.transferSyntaxArray
    }
    
    
    
    
    
    /**
     Return the tag name for a given code
     - Parameter code: string composed of DICOM group and element
     - Returns: A valid DcmSwift spec tag name
     */
    public func nameForTag(withCode code: String) -> String? {
        if tags.keys.contains(code) {
            return tags[code]!["keyword"]
        } else {
            return nil
        }
    }
    
    
    /**
     Return the name for a given UID
     - Parameter uid: DICOM SOP UID
     - Parameter append: Return a string with both UID and corresponding name
     - Returns: The corresponding name for the UID, or the UID if no name has been found
     */
    public func nameForUID(withUID uid:String, append:Bool = false) -> String {
        for (_, attrs) in self.uids {
            if attrs["uid"] == uid {
                if let keyword = attrs["keyword"] {
                    var str = keyword
                    if append { str = "\(keyword) (\(uid))" }
                    return str
                }
            }
        }
        return uid
    }
    
    
    /**
     Return the Value Representation (VR) for a given tag code
     - Parameter code: string composed of DICOM group and element
     - Returns: en VR enum
     */
    public func vrForTag(withCode code: String) -> VR.VR? {
        if tags.keys.contains(code) {
            if let t = tags[code] {
                if let v = t["vr"] {
                   return DicomSpec.vr(for:v)
                }
            }
        }
        
        return nil
    }
    
    
    /**
     Return a DataTag object for a given tag name
     - Parameter name: DcmSpec tag name
     - Returns: A new DataTag object
     */
    public func dataTag(forName name:String) -> DataTag? {
        if tagsByName.keys.contains(name) {
            if let group = tagsByName[name]?["group"] {
                if let element = tagsByName[name]?["element"] {
                    return DataTag(withGroup: group, element: element)
                }
            }
        }
        return nil
    }
    
    
    /**
     Check if the given Transfer Syntax is supported
     by the spec
     - Parameter transferSyntax: DICOM Transfer Syntax
     - Returns: true if the TS is supported by the spec
     */
    public func isSupported(transferSyntax ts:String) -> Bool {
        for tss in self.transferSyntaxes() {
            if tss["uid"]! == ts {
                return true
            }
        }
       return false
    }
    

    
    /**
     Check if the given SOP Class is supported
     by the spec
     - Parameter sopClass: DICOM SOP Class
     - Returns: true if the SOP is supported by the spec
     */
    public func isSupported(sopClass sc:String) -> Bool {
        for scs in self.sopClasses() {
            if scs["uid"]! == sc {
                return true
            }
        }
        return false
    }
    
    
    /**
    Check if the given Transfer Syntax is retired
    by the spec
    - Parameter transferSyntax: DICOM SOP Class
    - Returns: true if the SOP is retired by the spec
    */
    public func isRetired(transferSyntax sc:String) -> Bool {
        for tss in self.transferSyntaxes() {
            if sc == tss["uid"] {
                if tss["retired"] != nil {
                    return true
                }
            }
        }
        return false
    }
    
    
    /**
    Check if the given SOP Class is retired
    by the spec
    - Parameter sopClass: DICOM SOP Class
    - Returns: true if theSOP Class is retired by the spec
    */
    public func isRetired(sopClass sc:String) -> Bool {
        for scs in self.sopClasses() {
            if sc == scs["uid"] {
                if scs["retired"] != nil {
                    return true
                }
            }
        }
        return false
    }
    
    
    /**
    Check if the given Data Tag is retired
    by the spec
    - Parameter tag: DICOM DataTag Class
    - Returns: true if the Data Tag is retired by the spec
    */
    public func isRetired(tag dataTag:DataTag) -> Bool {
        if let tag = self.tagsByName[dataTag.name] {
            if tag["retired"] != nil {
                return true
            }
        }
        return false
    }
    
    
    
    
    // MARK: - XMLParser delegate
    
    
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "tag" {
            let tagCode = "\(attributeDict["group"]?.lowercased() ?? "")\(attributeDict["element"]?.lowercased() ?? "")"
            let name    = attributeDict["keyword"]!
            
            tags[tagCode]       = attributeDict
            tagsByName[name]    = attributeDict
        }
        else if elementName == "uid" {
            let uid = attributeDict["uid"] ?? ""
            uids[uid] = attributeDict
        }
    }
    
    
    public func parserDidEndDocument(_ parser: XMLParser) {
        // print(tags)
        // TODO: log spec loaded successfuly

        for (_, attrs) in self.uids {
            if attrs["type"] == "SOP Class" {
                self.sopClassesArray.append(attrs)
            }
            else if attrs["type"] == "Transfer Syntax" {
                self.transferSyntaxArray.append(attrs)
            }
        }
    }
    
    
    
    
    // MARK: - Validation Methods
    public func validate(file:DicomFile) -> [ValidationResult] {
        var results:[ValidationResult] = []
        
        // TODO: more file/dataset level validation
        if !file.hasPreamble {
            results.append(ValidationResult(file, message: "No prefix header was found", severity: .Notice))
        }
        
        if file.dataset.string(forTag: "TransferSyntaxUID") == nil {
            results.append(ValidationResult(file, message: "Undefined Transfer Syntax", severity: .Warning))
        }
        
        for e in file.dataset.allElements {
            results.append(contentsOf: validate(dataElement: e))
        }
        
        results.append(contentsOf: file.dataset.internalValidations)
        
        return results
    }
    
    public func validate(dataSet dataset:DataSet) -> [ValidationResult] {
        var results:[ValidationResult] = []
        
        for e in dataset.allElements {
            results.append(contentsOf: validate(dataElement: e))
        }
        
        results.append(contentsOf: dataset.internalValidations)
        
        return results
    }
    
    public func validate(dataElement element:DataElement) -> [ValidationResult] {
        var results:[ValidationResult] = []
        
        // check individual tags
        if element.name == "TransferSyntaxUID" {
            if !self.isSupported(transferSyntax: element.value as! String) {
                results.append(ValidationResult(element, message: "Transfer Syntax is not supported by this implementation [\(element.value)]", severity: .Warning))
            }
        }
        else if element.name == "SOPClassUID" {
            if !self.isSupported(sopClass: element.value as! String) {
                results.append(ValidationResult(element, message: "Transfer Syntax is not supported by this implementation [\(element.value)]", severity: .Warning))
            }
        }

        // check VR length
        var desiredLength = DicomSpec.lengthOf(vr: element.vr)
        if desiredLength != 0 && element.length > desiredLength {
            results.append(ValidationResult(element, message: "Invalid VR length of \(element.vr) element [\(element.name)] (\(element.length) > \(desiredLength))", severity: .Error))
        }
        
        // check max VR length
        desiredLength = DicomSpec.maxLengthOf(vr: element.vr)
        if desiredLength != 0 && element.length > desiredLength {
            results.append(ValidationResult(element, message: "Invalid max VR length of \(element.vr) element [\(element.name)] (\(element.length) > \(desiredLength))", severity: .Warning))
        }
        
        // check if tag is retired
        if self.isRetired(tag: element.tag) {
            results.append(ValidationResult(element, message: "Tag \(element.tag) \(element.name) is retired", severity: .Notice))
        }
        
        // check if tag is known
        if element.name == "Unknow" {
            results.append(ValidationResult(element, message: "Unknow tag, may be private", severity: .Notice))
        }
        
        // check if VR is respected
        let neededVR = vrForTag(withCode: element.tagCode())
        if element.name != "Unknow" && element.vr != neededVR {
            results.append(ValidationResult(element, message: "Value Representation mismatch, \(neededVR) required", severity: .Error))
        }
        
        return results
    }
}



/**
 ValidationResults are used by the validation process of the DicomSpec
 to store results alongside severity level and corresponding informations message
 */
public class ValidationResult : CustomStringConvertible, Comparable {
    public enum Severity:Int {
        case Notice = 0
        case Warning
        case Error
        case Fatal
    }
    
    
    public var object:Any?
    public var severity:Severity = .Notice
    public var message:String = ""
    
    
    public init(_ object:Any, message:String, severity:Severity = .Notice) {
        self.object         = object
        self.message        = message
        self.severity       = severity
    }
    
    public static func ==(lhs: ValidationResult, rhs: ValidationResult) -> Bool {
        return lhs.severity.rawValue == rhs.severity.rawValue
    }
    
    public static func <(lhs: ValidationResult, rhs: ValidationResult) -> Bool {
        return lhs.severity.rawValue > rhs.severity.rawValue
    }
    
    /**
     A string description of the DICOM object
     */
    public var description: String {
        return "\(self.object!) -> [\(self.severity)] \(self.message)"
    }
}





/*
 * Hard coded minimal DICOM spec in XML, mainly handle dataset tags and uids based constants.
 * The XML document is coming form here :
 * https://github.com/fo-dicom/fo-dicom/blob/development/DICOM/Dictionaries/DICOM%20Dictionary.xml */
let xmlSpec = """
<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<dictionary version=\"2017c\">
    <tag group=\"7fe0\" element=\"0000\" keyword=\"PrivateGroupLength\" vr=\"UL\" vm=\"1\">Command Group Length</tag>
    <tag group=\"0000\" element=\"0000\" keyword=\"CommandGroupLength\" vr=\"UL\" vm=\"1\">Command Group Length</tag>
    <tag group=\"0000\" element=\"0002\" keyword=\"AffectedSOPClassUID\" vr=\"UI\" vm=\"1\">Affected SOP Class UID</tag>
    <tag group=\"0000\" element=\"0003\" keyword=\"RequestedSOPClassUID\" vr=\"UI\" vm=\"1\">Requested SOP Class UID</tag>
    <tag group=\"0000\" element=\"0100\" keyword=\"CommandField\" vr=\"US\" vm=\"1\">Command Field</tag>
    <tag group=\"0000\" element=\"0110\" keyword=\"MessageID\" vr=\"US\" vm=\"1\">Message ID</tag>
    <tag group=\"0000\" element=\"0120\" keyword=\"MessageIDBeingRespondedTo\" vr=\"US\" vm=\"1\">Message ID Being Responded To</tag>
    <tag group=\"0000\" element=\"0600\" keyword=\"MoveDestination\" vr=\"AE\" vm=\"1\">Move Destination</tag>
    <tag group=\"0000\" element=\"0700\" keyword=\"Priority\" vr=\"US\" vm=\"1\">Priority</tag>
    <tag group=\"0000\" element=\"0800\" keyword=\"CommandDataSetType\" vr=\"US\" vm=\"1\">Command Data Set Type</tag>
    <tag group=\"0000\" element=\"0900\" keyword=\"Status\" vr=\"US\" vm=\"1\">Status</tag>
    <tag group=\"0000\" element=\"0901\" keyword=\"OffendingElement\" vr=\"AT\" vm=\"1-n\">Offending Element</tag>
    <tag group=\"0000\" element=\"0902\" keyword=\"ErrorComment\" vr=\"LO\" vm=\"1\">Error Comment</tag>
    <tag group=\"0000\" element=\"0903\" keyword=\"ErrorID\" vr=\"US\" vm=\"1\">Error ID</tag>
    <tag group=\"0000\" element=\"1000\" keyword=\"AffectedSOPInstanceUID\" vr=\"UI\" vm=\"1\">Affected SOP Instance UID</tag>
    <tag group=\"0000\" element=\"1001\" keyword=\"RequestedSOPInstanceUID\" vr=\"UI\" vm=\"1\">Requested SOP Instance UID</tag>
    <tag group=\"0000\" element=\"1002\" keyword=\"EventTypeID\" vr=\"US\" vm=\"1\">Event Type ID</tag>
    <tag group=\"0000\" element=\"1005\" keyword=\"AttributeIdentifierList\" vr=\"AT\" vm=\"1-n\">Attribute Identifier List</tag>
    <tag group=\"0000\" element=\"1008\" keyword=\"ActionTypeID\" vr=\"US\" vm=\"1\">Action Type ID</tag>
    <tag group=\"0000\" element=\"1020\" keyword=\"NumberOfRemainingSuboperations\" vr=\"US\" vm=\"1\">Number of Remaining Sub-operations</tag>
    <tag group=\"0000\" element=\"1021\" keyword=\"NumberOfCompletedSuboperations\" vr=\"US\" vm=\"1\">Number of Completed Sub-operations</tag>
    <tag group=\"0000\" element=\"1022\" keyword=\"NumberOfFailedSuboperations\" vr=\"US\" vm=\"1\">Number of Failed Sub-operations</tag>
    <tag group=\"0000\" element=\"1023\" keyword=\"NumberOfWarningSuboperations\" vr=\"US\" vm=\"1\">Number of Warning Sub-operations</tag>
    <tag group=\"0000\" element=\"1030\" keyword=\"MoveOriginatorApplicationEntityTitle\" vr=\"AE\" vm=\"1\">Move Originator Application Entity Title</tag>
    <tag group=\"0000\" element=\"1031\" keyword=\"MoveOriginatorMessageID\" vr=\"US\" vm=\"1\">Move Originator Message ID</tag>
    <tag group=\"0000\" element=\"0001\" keyword=\"CommandLengthToEnd\" vr=\"UL\" vm=\"1\" retired=\"true\">Command Length to End</tag>
    <tag group=\"0000\" element=\"0010\" keyword=\"CommandRecognitionCode\" vr=\"SH\" vm=\"1\" retired=\"true\">Command Recognition Code</tag>
    <tag group=\"0000\" element=\"0200\" keyword=\"Initiator\" vr=\"AE\" vm=\"1\" retired=\"true\">Initiator</tag>
    <tag group=\"0000\" element=\"0300\" keyword=\"Receiver\" vr=\"AE\" vm=\"1\" retired=\"true\">Receiver</tag>
    <tag group=\"0000\" element=\"0400\" keyword=\"FindLocation\" vr=\"AE\" vm=\"1\" retired=\"true\">Find Location</tag>
    <tag group=\"0000\" element=\"0850\" keyword=\"NumberOfMatches\" vr=\"US\" vm=\"1\" retired=\"true\">Number of Matches</tag>
    <tag group=\"0000\" element=\"0860\" keyword=\"ResponseSequenceNumber\" vr=\"US\" vm=\"1\" retired=\"true\">Response Sequence Number</tag>
    <tag group=\"0000\" element=\"4000\" keyword=\"DialogReceiver\" vr=\"LT\" vm=\"1\" retired=\"true\">Dialog Receiver</tag>
    <tag group=\"0000\" element=\"4010\" keyword=\"TerminalType\" vr=\"LT\" vm=\"1\" retired=\"true\">Terminal Type</tag>
    <tag group=\"0000\" element=\"5010\" keyword=\"MessageSetID\" vr=\"SH\" vm=\"1\" retired=\"true\">Message Set ID</tag>
    <tag group=\"0000\" element=\"5020\" keyword=\"EndMessageID\" vr=\"SH\" vm=\"1\" retired=\"true\">End Message ID</tag>
    <tag group=\"0000\" element=\"5110\" keyword=\"DisplayFormat\" vr=\"LT\" vm=\"1\" retired=\"true\">Display Format</tag>
    <tag group=\"0000\" element=\"5120\" keyword=\"PagePositionID\" vr=\"LT\" vm=\"1\" retired=\"true\">Page Position ID</tag>
    <tag group=\"0000\" element=\"5130\" keyword=\"TextFormatID\" vr=\"CS\" vm=\"1\" retired=\"true\">Text Format ID</tag>
    <tag group=\"0000\" element=\"5140\" keyword=\"NormalReverse\" vr=\"CS\" vm=\"1\" retired=\"true\">Normal/Reverse</tag>
    <tag group=\"0000\" element=\"5150\" keyword=\"AddGrayScale\" vr=\"CS\" vm=\"1\" retired=\"true\">Add Gray Scale</tag>
    <tag group=\"0000\" element=\"5160\" keyword=\"Borders\" vr=\"CS\" vm=\"1\" retired=\"true\">Borders</tag>
    <tag group=\"0000\" element=\"5170\" keyword=\"Copies\" vr=\"IS\" vm=\"1\" retired=\"true\">Copies</tag>
    <tag group=\"0000\" element=\"5180\" keyword=\"CommandMagnificationType\" vr=\"CS\" vm=\"1\" retired=\"true\">Command Magnification Type</tag>
    <tag group=\"0000\" element=\"5190\" keyword=\"Erase\" vr=\"CS\" vm=\"1\" retired=\"true\">Erase</tag>
    <tag group=\"0000\" element=\"51A0\" keyword=\"Print\" vr=\"CS\" vm=\"1\" retired=\"true\">Print</tag>
    <tag group=\"0000\" element=\"51B0\" keyword=\"Overlays\" vr=\"US\" vm=\"1-n\" retired=\"true\">Overlays</tag>
    <tag group=\"0002\" element=\"0000\" keyword=\"FileMetaInformationGroupLength\" vr=\"UL\" vm=\"1\">File Meta Information Group Length</tag>
    <tag group=\"0002\" element=\"0001\" keyword=\"FileMetaInformationVersion\" vr=\"OB\" vm=\"1\">File Meta Information Version</tag>
    <tag group=\"0002\" element=\"0002\" keyword=\"MediaStorageSOPClassUID\" vr=\"UI\" vm=\"1\">Media Storage SOP Class UID</tag>
    <tag group=\"0002\" element=\"0003\" keyword=\"MediaStorageSOPInstanceUID\" vr=\"UI\" vm=\"1\">Media Storage SOP Instance UID</tag>
    <tag group=\"0002\" element=\"0010\" keyword=\"TransferSyntaxUID\" vr=\"UI\" vm=\"1\">Transfer Syntax UID</tag>
    <tag group=\"0002\" element=\"0012\" keyword=\"ImplementationClassUID\" vr=\"UI\" vm=\"1\">Implementation Class UID</tag>
    <tag group=\"0002\" element=\"0013\" keyword=\"ImplementationVersionName\" vr=\"SH\" vm=\"1\">Implementation Version Name</tag>
    <tag group=\"0002\" element=\"0016\" keyword=\"SourceApplicationEntityTitle\" vr=\"AE\" vm=\"1\">Source Application Entity Title</tag>
    <tag group=\"0002\" element=\"0017\" keyword=\"SendingApplicationEntityTitle\" vr=\"AE\" vm=\"1\">Sending Application Entity Title</tag>
    <tag group=\"0002\" element=\"0018\" keyword=\"ReceivingApplicationEntityTitle\" vr=\"AE\" vm=\"1\">Receiving Application Entity Title</tag>
    <tag group=\"0002\" element=\"0100\" keyword=\"PrivateInformationCreatorUID\" vr=\"UI\" vm=\"1\">Private Information Creator UID</tag>
    <tag group=\"0002\" element=\"0102\" keyword=\"PrivateInformation\" vr=\"OB\" vm=\"1\">Private Information</tag>
    <tag group=\"0004\" element=\"1130\" keyword=\"FileSetID\" vr=\"CS\" vm=\"1\">File-set ID</tag>
    <tag group=\"0004\" element=\"1141\" keyword=\"FileSetDescriptorFileID\" vr=\"CS\" vm=\"1-8\">File-set Descriptor File ID</tag>
    <tag group=\"0004\" element=\"1142\" keyword=\"SpecificCharacterSetOfFileSetDescriptorFile\" vr=\"CS\" vm=\"1\">Specific Character Set of File-set Descriptor File</tag>
    <tag group=\"0004\" element=\"1200\" keyword=\"OffsetOfTheFirstDirectoryRecordOfTheRootDirectoryEntity\" vr=\"UL\" vm=\"1\">Offset of the First Directory Record of the Root Directory Entity</tag>
    <tag group=\"0004\" element=\"1202\" keyword=\"OffsetOfTheLastDirectoryRecordOfTheRootDirectoryEntity\" vr=\"UL\" vm=\"1\">Offset of the Last Directory Record of the Root Directory Entity</tag>
    <tag group=\"0004\" element=\"1212\" keyword=\"FileSetConsistencyFlag\" vr=\"US\" vm=\"1\">File-set Consistency Flag</tag>
    <tag group=\"0004\" element=\"1220\" keyword=\"DirectoryRecordSequence\" vr=\"SQ\" vm=\"1\">Directory Record Sequence</tag>
    <tag group=\"0004\" element=\"1400\" keyword=\"OffsetOfTheNextDirectoryRecord\" vr=\"UL\" vm=\"1\">Offset of the Next Directory Record</tag>
    <tag group=\"0004\" element=\"1410\" keyword=\"RecordInUseFlag\" vr=\"US\" vm=\"1\">Record In-use Flag</tag>
    <tag group=\"0004\" element=\"1420\" keyword=\"OffsetOfReferencedLowerLevelDirectoryEntity\" vr=\"UL\" vm=\"1\">Offset of Referenced Lower-Level Directory Entity</tag>
    <tag group=\"0004\" element=\"1430\" keyword=\"DirectoryRecordType\" vr=\"CS\" vm=\"1\">Directory Record Type</tag>
    <tag group=\"0004\" element=\"1432\" keyword=\"PrivateRecordUID\" vr=\"UI\" vm=\"1\">Private Record UID</tag>
    <tag group=\"0004\" element=\"1500\" keyword=\"ReferencedFileID\" vr=\"CS\" vm=\"1-8\">Referenced File ID</tag>
    <tag group=\"0004\" element=\"1504\" keyword=\"MRDRDirectoryRecordOffset\" vr=\"UL\" vm=\"1\" retired=\"true\">MRDR Directory Record Offset</tag>
    <tag group=\"0004\" element=\"1510\" keyword=\"ReferencedSOPClassUIDInFile\" vr=\"UI\" vm=\"1\">Referenced SOP Class UID in File</tag>
    <tag group=\"0004\" element=\"1511\" keyword=\"ReferencedSOPInstanceUIDInFile\" vr=\"UI\" vm=\"1\">Referenced SOP Instance UID in File</tag>
    <tag group=\"0004\" element=\"1512\" keyword=\"ReferencedTransferSyntaxUIDInFile\" vr=\"UI\" vm=\"1\">Referenced Transfer Syntax UID in File</tag>
    <tag group=\"0004\" element=\"151A\" keyword=\"ReferencedRelatedGeneralSOPClassUIDInFile\" vr=\"UI\" vm=\"1-n\">Referenced Related General SOP Class UID in File</tag>
    <tag group=\"0004\" element=\"1600\" keyword=\"NumberOfReferences\" vr=\"UL\" vm=\"1\" retired=\"true\">Number of References</tag>
    <tag group=\"0008\" element=\"0000\" keyword=\"GenericGroupLength\" vr=\"UL\" vm=\"1\" retired=\"true\">Generic Group Length</tag>
    <tag group=\"0008\" element=\"0001\" keyword=\"LengthToEnd\" vr=\"UL\" vm=\"1\" retired=\"true\">Length to End</tag>
    <tag group=\"0008\" element=\"0005\" keyword=\"SpecificCharacterSet\" vr=\"CS\" vm=\"1-n\">Specific Character Set</tag>
    <tag group=\"0008\" element=\"0006\" keyword=\"LanguageCodeSequence\" vr=\"SQ\" vm=\"1\">Language Code Sequence</tag>
    <tag group=\"0008\" element=\"0008\" keyword=\"ImageType\" vr=\"CS\" vm=\"2-n\">Image Type</tag>
    <tag group=\"0008\" element=\"0010\" keyword=\"RecognitionCode\" vr=\"SH\" vm=\"1\" retired=\"true\">Recognition Code</tag>
    <tag group=\"0008\" element=\"0012\" keyword=\"InstanceCreationDate\" vr=\"DA\" vm=\"1\">Instance Creation Date</tag>
    <tag group=\"0008\" element=\"0013\" keyword=\"InstanceCreationTime\" vr=\"TM\" vm=\"1\">Instance Creation Time</tag>
    <tag group=\"0008\" element=\"0014\" keyword=\"InstanceCreatorUID\" vr=\"UI\" vm=\"1\">Instance Creator UID</tag>
    <tag group=\"0008\" element=\"0015\" keyword=\"InstanceCoercionDateTime\" vr=\"DT\" vm=\"1\">Instance Coercion DateTime</tag>
    <tag group=\"0008\" element=\"0016\" keyword=\"SOPClassUID\" vr=\"UI\" vm=\"1\">SOP Class UID</tag>
    <tag group=\"0008\" element=\"0018\" keyword=\"SOPInstanceUID\" vr=\"UI\" vm=\"1\">SOP Instance UID</tag>
    <tag group=\"0008\" element=\"001A\" keyword=\"RelatedGeneralSOPClassUID\" vr=\"UI\" vm=\"1-n\">Related General SOP Class UID</tag>
    <tag group=\"0008\" element=\"001B\" keyword=\"OriginalSpecializedSOPClassUID\" vr=\"UI\" vm=\"1\">Original Specialized SOP Class UID</tag>
    <tag group=\"0008\" element=\"0020\" keyword=\"StudyDate\" vr=\"DA\" vm=\"1\">Study Date</tag>
    <tag group=\"0008\" element=\"0021\" keyword=\"SeriesDate\" vr=\"DA\" vm=\"1\">Series Date</tag>
    <tag group=\"0008\" element=\"0022\" keyword=\"AcquisitionDate\" vr=\"DA\" vm=\"1\">Acquisition Date</tag>
    <tag group=\"0008\" element=\"0023\" keyword=\"ContentDate\" vr=\"DA\" vm=\"1\">Content Date</tag>
    <tag group=\"0008\" element=\"0024\" keyword=\"OverlayDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Overlay Date</tag>
    <tag group=\"0008\" element=\"0025\" keyword=\"CurveDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Curve Date</tag>
    <tag group=\"0008\" element=\"002A\" keyword=\"AcquisitionDateTime\" vr=\"DT\" vm=\"1\">Acquisition DateTime</tag>
    <tag group=\"0008\" element=\"0030\" keyword=\"StudyTime\" vr=\"TM\" vm=\"1\">Study Time</tag>
    <tag group=\"0008\" element=\"0031\" keyword=\"SeriesTime\" vr=\"TM\" vm=\"1\">Series Time</tag>
    <tag group=\"0008\" element=\"0032\" keyword=\"AcquisitionTime\" vr=\"TM\" vm=\"1\">Acquisition Time</tag>
    <tag group=\"0008\" element=\"0033\" keyword=\"ContentTime\" vr=\"TM\" vm=\"1\">Content Time</tag>
    <tag group=\"0008\" element=\"0034\" keyword=\"OverlayTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Overlay Time</tag>
    <tag group=\"0008\" element=\"0035\" keyword=\"CurveTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Curve Time</tag>
    <tag group=\"0008\" element=\"0040\" keyword=\"DataSetType\" vr=\"US\" vm=\"1\" retired=\"true\">Data Set Type</tag>
    <tag group=\"0008\" element=\"0041\" keyword=\"DataSetSubtype\" vr=\"LO\" vm=\"1\" retired=\"true\">Data Set Subtype</tag>
    <tag group=\"0008\" element=\"0042\" keyword=\"NuclearMedicineSeriesType\" vr=\"CS\" vm=\"1\" retired=\"true\">Nuclear Medicine Series Type</tag>
    <tag group=\"0008\" element=\"0050\" keyword=\"AccessionNumber\" vr=\"SH\" vm=\"1\">Accession Number</tag>
    <tag group=\"0008\" element=\"0051\" keyword=\"IssuerOfAccessionNumberSequence\" vr=\"SQ\" vm=\"1\">Issuer of Accession Number Sequence</tag>
    <tag group=\"0008\" element=\"0052\" keyword=\"QueryRetrieveLevel\" vr=\"CS\" vm=\"1\">Query/Retrieve Level</tag>
    <tag group=\"0008\" element=\"0053\" keyword=\"QueryRetrieveView\" vr=\"CS\" vm=\"1\">Query/Retrieve View</tag>
    <tag group=\"0008\" element=\"0054\" keyword=\"RetrieveAETitle\" vr=\"AE\" vm=\"1-n\">Retrieve AE Title</tag>
    <tag group=\"0008\" element=\"0055\" keyword=\"StationAETitle\" vr=\"AE\" vm=\"1\">Station  AE Title</tag>
    <tag group=\"0008\" element=\"0056\" keyword=\"InstanceAvailability\" vr=\"CS\" vm=\"1\">Instance Availability</tag>
    <tag group=\"0008\" element=\"0058\" keyword=\"FailedSOPInstanceUIDList\" vr=\"UI\" vm=\"1-n\">Failed SOP Instance UID List</tag>
    <tag group=\"0008\" element=\"0060\" keyword=\"Modality\" vr=\"CS\" vm=\"1\">Modality</tag>
    <tag group=\"0008\" element=\"0061\" keyword=\"ModalitiesInStudy\" vr=\"CS\" vm=\"1-n\">Modalities in Study</tag>
    <tag group=\"0008\" element=\"0062\" keyword=\"SOPClassesInStudy\" vr=\"UI\" vm=\"1-n\">SOP Classes in Study</tag>
    <tag group=\"0008\" element=\"0064\" keyword=\"ConversionType\" vr=\"CS\" vm=\"1\">Conversion Type</tag>
    <tag group=\"0008\" element=\"0068\" keyword=\"PresentationIntentType\" vr=\"CS\" vm=\"1\">Presentation Intent Type</tag>
    <tag group=\"0008\" element=\"0070\" keyword=\"Manufacturer\" vr=\"LO\" vm=\"1\">Manufacturer</tag>
    <tag group=\"0008\" element=\"0080\" keyword=\"InstitutionName\" vr=\"LO\" vm=\"1\">Institution Name</tag>
    <tag group=\"0008\" element=\"0081\" keyword=\"InstitutionAddress\" vr=\"ST\" vm=\"1\">Institution Address</tag>
    <tag group=\"0008\" element=\"0082\" keyword=\"InstitutionCodeSequence\" vr=\"SQ\" vm=\"1\">Institution Code Sequence</tag>
    <tag group=\"0008\" element=\"0090\" keyword=\"ReferringPhysicianName\" vr=\"PN\" vm=\"1\">Referring Physician's Name</tag>
    <tag group=\"0008\" element=\"0092\" keyword=\"ReferringPhysicianAddress\" vr=\"ST\" vm=\"1\">Referring Physician's Address</tag>
    <tag group=\"0008\" element=\"0094\" keyword=\"ReferringPhysicianTelephoneNumbers\" vr=\"SH\" vm=\"1-n\">Referring Physician's Telephone Numbers</tag>
    <tag group=\"0008\" element=\"0096\" keyword=\"ReferringPhysicianIdentificationSequence\" vr=\"SQ\" vm=\"1\">Referring Physician Identification Sequence</tag>
    <tag group=\"0008\" element=\"009C\" keyword=\"ConsultingPhysicianName\" vr=\"PN\" vm=\"1-n\">Consulting Physician's Name</tag>
    <tag group=\"0008\" element=\"009D\" keyword=\"ConsultingPhysicianIdentificationSequence\" vr=\"SQ\" vm=\"1\">Consulting Physician Identification Sequence</tag>
    <tag group=\"0008\" element=\"0100\" keyword=\"CodeValue\" vr=\"SH\" vm=\"1\">Code Value</tag>
    <tag group=\"0008\" element=\"0101\" keyword=\"ExtendedCodeValue\" vr=\"LO\" vm=\"1\">Extended Code Value</tag>
    <tag group=\"0008\" element=\"0102\" keyword=\"CodingSchemeDesignator\" vr=\"SH\" vm=\"1\">Coding Scheme Designator</tag>
    <tag group=\"0008\" element=\"0103\" keyword=\"CodingSchemeVersion\" vr=\"SH\" vm=\"1\">Coding Scheme Version</tag>
    <tag group=\"0008\" element=\"0104\" keyword=\"CodeMeaning\" vr=\"LO\" vm=\"1\">Code Meaning</tag>
    <tag group=\"0008\" element=\"0105\" keyword=\"MappingResource\" vr=\"CS\" vm=\"1\">Mapping Resource</tag>
    <tag group=\"0008\" element=\"0106\" keyword=\"ContextGroupVersion\" vr=\"DT\" vm=\"1\">Context Group Version</tag>
    <tag group=\"0008\" element=\"0107\" keyword=\"ContextGroupLocalVersion\" vr=\"DT\" vm=\"1\">Context Group Local Version</tag>
    <tag group=\"0008\" element=\"0108\" keyword=\"ExtendedCodeMeaning\" vr=\"LT\" vm=\"1\">Extended Code Meaning</tag>
    <tag group=\"0008\" element=\"0109\" keyword=\"CodingSchemeResourcesSequence\" vr=\"SQ\" vm=\"1\">Coding Scheme Resources Sequence</tag>
    <tag group=\"0008\" element=\"010A\" keyword=\"CodingSchemeURLType\" vr=\"CS\" vm=\"1\">Coding Scheme URL Type</tag>
    <tag group=\"0008\" element=\"010B\" keyword=\"ContextGroupExtensionFlag\" vr=\"CS\" vm=\"1\">Context Group Extension Flag</tag>
    <tag group=\"0008\" element=\"010C\" keyword=\"CodingSchemeUID\" vr=\"UI\" vm=\"1\">Coding Scheme UID</tag>
    <tag group=\"0008\" element=\"010D\" keyword=\"ContextGroupExtensionCreatorUID\" vr=\"UI\" vm=\"1\">Context Group Extension Creator UID</tag>
    <tag group=\"0008\" element=\"010E\" keyword=\"CodingSchemeURL\" vr=\"UR\" vm=\"1\">Coding Scheme URL</tag>
    <tag group=\"0008\" element=\"010F\" keyword=\"ContextIdentifier\" vr=\"CS\" vm=\"1\">Context Identifier</tag>
    <tag group=\"0008\" element=\"0110\" keyword=\"CodingSchemeIdentificationSequence\" vr=\"SQ\" vm=\"1\">Coding Scheme Identification Sequence</tag>
    <tag group=\"0008\" element=\"0112\" keyword=\"CodingSchemeRegistry\" vr=\"LO\" vm=\"1\">Coding Scheme Registry</tag>
    <tag group=\"0008\" element=\"0114\" keyword=\"CodingSchemeExternalID\" vr=\"ST\" vm=\"1\">Coding Scheme External ID</tag>
    <tag group=\"0008\" element=\"0115\" keyword=\"CodingSchemeName\" vr=\"ST\" vm=\"1\">Coding Scheme Name</tag>
    <tag group=\"0008\" element=\"0116\" keyword=\"CodingSchemeResponsibleOrganization\" vr=\"ST\" vm=\"1\">Coding Scheme Responsible Organization</tag>
    <tag group=\"0008\" element=\"0117\" keyword=\"ContextUID\" vr=\"UI\" vm=\"1\">Context UID</tag>
    <tag group=\"0008\" element=\"0118\" keyword=\"MappingResourceUID\" vr=\"UI\" vm=\"1\">Mapping Resource UID</tag>
    <tag group=\"0008\" element=\"0119\" keyword=\"LongCodeValue\" vr=\"UC\" vm=\"1\">Long Code Value</tag>
    <tag group=\"0008\" element=\"0120\" keyword=\"URNCodeValue\" vr=\"UR\" vm=\"1\">URN Code Value</tag>
    <tag group=\"0008\" element=\"0121\" keyword=\"EquivalentCodeSequence\" vr=\"SQ\" vm=\"1\">Equivalent Code Sequence</tag>
    <tag group=\"0008\" element=\"0122\" keyword=\"MappingResourceName\" vr=\"LO\" vm=\"1\">Mapping Resource Name</tag>
    <tag group=\"0008\" element=\"0123\" keyword=\"ContextGroupIdentificationSequence\" vr=\"SQ\" vm=\"1\">Context Group Identification Sequence</tag>
    <tag group=\"0008\" element=\"0124\" keyword=\"MappingResourceIdentificationSequence\" vr=\"SQ\" vm=\"1\">Mapping Resource Identification Sequence</tag>
    <tag group=\"0008\" element=\"0201\" keyword=\"TimezoneOffsetFromUTC\" vr=\"SH\" vm=\"1\">Timezone Offset From UTC</tag>
    <tag group=\"0008\" element=\"0220\" keyword=\"ResponsibleGroupCodeSequence\" vr=\"SQ\" vm=\"1\">Responsible Group Code Sequence</tag>
    <tag group=\"0008\" element=\"0221\" keyword=\"EquipmentModality\" vr=\"CS\" vm=\"1\">Equipment Modality</tag>
    <tag group=\"0008\" element=\"0222\" keyword=\"ManufacturerRelatedModelGroup\" vr=\"LO\" vm=\"1\">Manufacturer's Related Model Group</tag>
    <tag group=\"0008\" element=\"0300\" keyword=\"PrivateDataElementCharacteristicsSequence\" vr=\"SQ\" vm=\"1\">Private Data Element Characteristics Sequence</tag>
    <tag group=\"0008\" element=\"0301\" keyword=\"PrivateGroupReference\" vr=\"US\" vm=\"1\">Private Group Reference</tag>
    <tag group=\"0008\" element=\"0302\" keyword=\"PrivateCreatorReference\" vr=\"LO\" vm=\"1\">Private Creator Reference</tag>
    <tag group=\"0008\" element=\"0303\" keyword=\"BlockIdentifyingInformationStatus\" vr=\"CS\" vm=\"1\">Block Identifying Information Status</tag>
    <tag group=\"0008\" element=\"0304\" keyword=\"NonidentifyingPrivateElements\" vr=\"US\" vm=\"1-n\">Nonidentifying Private Elements</tag>
    <tag group=\"0008\" element=\"0306\" keyword=\"IdentifyingPrivateElements\" vr=\"US\" vm=\"1-n\">Identifying Private Elements</tag>
    <tag group=\"0008\" element=\"0305\" keyword=\"DeidentificationActionSequence\" vr=\"SQ\" vm=\"1\">Deidentification Action Sequence</tag>
    <tag group=\"0008\" element=\"0307\" keyword=\"DeidentificationAction\" vr=\"CS\" vm=\"1\">Deidentification Action</tag>
    <tag group=\"0008\" element=\"0308\" keyword=\"PrivateDataElement\" vr=\"US\" vm=\"1\">Private Data Element</tag>
    <tag group=\"0008\" element=\"0309\" keyword=\"PrivateDataElementValueMultiplicity\" vr=\"UL\" vm=\"1-3\">Private Data Element Value Multiplicity</tag>
    <tag group=\"0008\" element=\"030A\" keyword=\"PrivateDataElementValueRepresentation\" vr=\"CS\" vm=\"1\">Private Data Element Value Representation</tag>
    <tag group=\"0008\" element=\"030B\" keyword=\"PrivateDataElementNumberOfItems\" vr=\"UL\" vm=\"1-2\">Private Data Element Number of Items</tag>
    <tag group=\"0008\" element=\"030C\" keyword=\"PrivateDataElementName\" vr=\"UC\" vm=\"1\">Private Data Element Name</tag>
    <tag group=\"0008\" element=\"030D\" keyword=\"PrivateDataElementKeyword\" vr=\"UC\" vm=\"1\">Private Data Element Keyword</tag>
    <tag group=\"0008\" element=\"030E\" keyword=\"PrivateDataElementDescription\" vr=\"UT\" vm=\"1\">Private Data Element Description</tag>
    <tag group=\"0008\" element=\"030F\" keyword=\"PrivateDataElementEncoding\" vr=\"UT\" vm=\"1\">Private Data Element Encoding</tag>
    <tag group=\"0008\" element=\"0310\" keyword=\"PrivateDataElementDefinitionSequence\" vr=\"SQ\" vm=\"1\">Private Data Element Definition Sequence</tag>
    <tag group=\"0008\" element=\"1000\" keyword=\"NetworkID\" vr=\"AE\" vm=\"1\" retired=\"true\">Network ID</tag>
    <tag group=\"0008\" element=\"1010\" keyword=\"StationName\" vr=\"SH\" vm=\"1\">Station Name</tag>
    <tag group=\"0008\" element=\"1030\" keyword=\"StudyDescription\" vr=\"LO\" vm=\"1\">Study Description</tag>
    <tag group=\"0008\" element=\"1032\" keyword=\"ProcedureCodeSequence\" vr=\"SQ\" vm=\"1\">Procedure Code Sequence</tag>
    <tag group=\"0008\" element=\"103E\" keyword=\"SeriesDescription\" vr=\"LO\" vm=\"1\">Series Description</tag>
    <tag group=\"0008\" element=\"103F\" keyword=\"SeriesDescriptionCodeSequence\" vr=\"SQ\" vm=\"1\">Series Description Code Sequence</tag>
    <tag group=\"0008\" element=\"1040\" keyword=\"InstitutionalDepartmentName\" vr=\"LO\" vm=\"1\">Institutional Department Name</tag>
    <tag group=\"0008\" element=\"1048\" keyword=\"PhysiciansOfRecord\" vr=\"PN\" vm=\"1-n\">Physician(s) of Record</tag>
    <tag group=\"0008\" element=\"1049\" keyword=\"PhysiciansOfRecordIdentificationSequence\" vr=\"SQ\" vm=\"1\">Physician(s) of Record Identification Sequence</tag>
    <tag group=\"0008\" element=\"1050\" keyword=\"PerformingPhysicianName\" vr=\"PN\" vm=\"1-n\">Performing Physician's Name</tag>
    <tag group=\"0008\" element=\"1052\" keyword=\"PerformingPhysicianIdentificationSequence\" vr=\"SQ\" vm=\"1\">Performing Physician Identification Sequence</tag>
    <tag group=\"0008\" element=\"1060\" keyword=\"NameOfPhysiciansReadingStudy\" vr=\"PN\" vm=\"1-n\">Name of Physician(s) Reading Study</tag>
    <tag group=\"0008\" element=\"1062\" keyword=\"PhysiciansReadingStudyIdentificationSequence\" vr=\"SQ\" vm=\"1\">Physician(s) Reading Study Identification Sequence</tag>
    <tag group=\"0008\" element=\"1070\" keyword=\"OperatorsName\" vr=\"PN\" vm=\"1-n\">Operators' Name</tag>
    <tag group=\"0008\" element=\"1072\" keyword=\"OperatorIdentificationSequence\" vr=\"SQ\" vm=\"1\">Operator Identification Sequence</tag>
    <tag group=\"0008\" element=\"1080\" keyword=\"AdmittingDiagnosesDescription\" vr=\"LO\" vm=\"1-n\">Admitting Diagnoses Description</tag>
    <tag group=\"0008\" element=\"1084\" keyword=\"AdmittingDiagnosesCodeSequence\" vr=\"SQ\" vm=\"1\">Admitting Diagnoses Code Sequence</tag>
    <tag group=\"0008\" element=\"1090\" keyword=\"ManufacturerModelName\" vr=\"LO\" vm=\"1\">Manufacturer's Model Name</tag>
    <tag group=\"0008\" element=\"1100\" keyword=\"ReferencedResultsSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced Results Sequence</tag>
    <tag group=\"0008\" element=\"1110\" keyword=\"ReferencedStudySequence\" vr=\"SQ\" vm=\"1\">Referenced Study Sequence</tag>
    <tag group=\"0008\" element=\"1111\" keyword=\"ReferencedPerformedProcedureStepSequence\" vr=\"SQ\" vm=\"1\">Referenced Performed Procedure Step Sequence</tag>
    <tag group=\"0008\" element=\"1115\" keyword=\"ReferencedSeriesSequence\" vr=\"SQ\" vm=\"1\">Referenced Series Sequence</tag>
    <tag group=\"0008\" element=\"1120\" keyword=\"ReferencedPatientSequence\" vr=\"SQ\" vm=\"1\">Referenced Patient Sequence</tag>
    <tag group=\"0008\" element=\"1125\" keyword=\"ReferencedVisitSequence\" vr=\"SQ\" vm=\"1\">Referenced Visit Sequence</tag>
    <tag group=\"0008\" element=\"1130\" keyword=\"ReferencedOverlaySequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced Overlay Sequence</tag>
    <tag group=\"0008\" element=\"1134\" keyword=\"ReferencedStereometricInstanceSequence\" vr=\"SQ\" vm=\"1\">Referenced Stereometric Instance Sequence</tag>
    <tag group=\"0008\" element=\"113A\" keyword=\"ReferencedWaveformSequence\" vr=\"SQ\" vm=\"1\">Referenced Waveform Sequence</tag>
    <tag group=\"0008\" element=\"1140\" keyword=\"ReferencedImageSequence\" vr=\"SQ\" vm=\"1\">Referenced Image Sequence</tag>
    <tag group=\"0008\" element=\"1145\" keyword=\"ReferencedCurveSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced Curve Sequence</tag>
    <tag group=\"0008\" element=\"114A\" keyword=\"ReferencedInstanceSequence\" vr=\"SQ\" vm=\"1\">Referenced Instance Sequence</tag>
    <tag group=\"0008\" element=\"114B\" keyword=\"ReferencedRealWorldValueMappingInstanceSequence\" vr=\"SQ\" vm=\"1\">Referenced Real World Value Mapping Instance Sequence</tag>
    <tag group=\"0008\" element=\"1150\" keyword=\"ReferencedSOPClassUID\" vr=\"UI\" vm=\"1\">Referenced SOP Class UID</tag>
    <tag group=\"0008\" element=\"1155\" keyword=\"ReferencedSOPInstanceUID\" vr=\"UI\" vm=\"1\">Referenced SOP Instance UID</tag>
    <tag group=\"0008\" element=\"115A\" keyword=\"SOPClassesSupported\" vr=\"UI\" vm=\"1-n\">SOP Classes Supported</tag>
    <tag group=\"0008\" element=\"1160\" keyword=\"ReferencedFrameNumber\" vr=\"IS\" vm=\"1-n\">Referenced Frame Number</tag>
    <tag group=\"0008\" element=\"1161\" keyword=\"SimpleFrameList\" vr=\"UL\" vm=\"1-n\">Simple Frame List</tag>
    <tag group=\"0008\" element=\"1162\" keyword=\"CalculatedFrameList\" vr=\"UL\" vm=\"3-3n\">Calculated Frame List</tag>
    <tag group=\"0008\" element=\"1163\" keyword=\"TimeRange\" vr=\"FD\" vm=\"2\">Time Range</tag>
    <tag group=\"0008\" element=\"1164\" keyword=\"FrameExtractionSequence\" vr=\"SQ\" vm=\"1\">Frame Extraction Sequence</tag>
    <tag group=\"0008\" element=\"1167\" keyword=\"MultiFrameSourceSOPInstanceUID\" vr=\"UI\" vm=\"1\">Multi-frame Source SOP Instance UID</tag>
    <tag group=\"0008\" element=\"1190\" keyword=\"RetrieveURL\" vr=\"UR\" vm=\"1\">Retrieve URL</tag>
    <tag group=\"0008\" element=\"1195\" keyword=\"TransactionUID\" vr=\"UI\" vm=\"1\">Transaction UID</tag>
    <tag group=\"0008\" element=\"1196\" keyword=\"WarningReason\" vr=\"US\" vm=\"1\">Warning Reason</tag>
    <tag group=\"0008\" element=\"1197\" keyword=\"FailureReason\" vr=\"US\" vm=\"1\">Failure Reason</tag>
    <tag group=\"0008\" element=\"1198\" keyword=\"FailedSOPSequence\" vr=\"SQ\" vm=\"1\">Failed SOP Sequence</tag>
    <tag group=\"0008\" element=\"1199\" keyword=\"ReferencedSOPSequence\" vr=\"SQ\" vm=\"1\">Referenced SOP Sequence</tag>
    <tag group=\"0008\" element=\"119A\" keyword=\"OtherFailuresSequence\" vr=\"SQ\" vm=\"1\">Other Failures Sequence</tag>
    <tag group=\"0008\" element=\"1200\" keyword=\"StudiesContainingOtherReferencedInstancesSequence\" vr=\"SQ\" vm=\"1\">Studies Containing Other Referenced Instances Sequence</tag>
    <tag group=\"0008\" element=\"1250\" keyword=\"RelatedSeriesSequence\" vr=\"SQ\" vm=\"1\">Related Series Sequence</tag>
    <tag group=\"0008\" element=\"2110\" keyword=\"LossyImageCompressionRetired\" vr=\"CS\" vm=\"1\" retired=\"true\">Lossy Image Compression (Retired)</tag>
    <tag group=\"0008\" element=\"2111\" keyword=\"DerivationDescription\" vr=\"ST\" vm=\"1\">Derivation Description</tag>
    <tag group=\"0008\" element=\"2112\" keyword=\"SourceImageSequence\" vr=\"SQ\" vm=\"1\">Source Image Sequence</tag>
    <tag group=\"0008\" element=\"2120\" keyword=\"StageName\" vr=\"SH\" vm=\"1\">Stage Name</tag>
    <tag group=\"0008\" element=\"2122\" keyword=\"StageNumber\" vr=\"IS\" vm=\"1\">Stage Number</tag>
    <tag group=\"0008\" element=\"2124\" keyword=\"NumberOfStages\" vr=\"IS\" vm=\"1\">Number of Stages</tag>
    <tag group=\"0008\" element=\"2127\" keyword=\"ViewName\" vr=\"SH\" vm=\"1\">View Name</tag>
    <tag group=\"0008\" element=\"2128\" keyword=\"ViewNumber\" vr=\"IS\" vm=\"1\">View Number</tag>
    <tag group=\"0008\" element=\"2129\" keyword=\"NumberOfEventTimers\" vr=\"IS\" vm=\"1\">Number of Event Timers</tag>
    <tag group=\"0008\" element=\"212A\" keyword=\"NumberOfViewsInStage\" vr=\"IS\" vm=\"1\">Number of Views in Stage</tag>
    <tag group=\"0008\" element=\"2130\" keyword=\"EventElapsedTimes\" vr=\"DS\" vm=\"1-n\">Event Elapsed Time(s)</tag>
    <tag group=\"0008\" element=\"2132\" keyword=\"EventTimerNames\" vr=\"LO\" vm=\"1-n\">Event Timer Name(s)</tag>
    <tag group=\"0008\" element=\"2133\" keyword=\"EventTimerSequence\" vr=\"SQ\" vm=\"1\">Event Timer Sequence</tag>
    <tag group=\"0008\" element=\"2134\" keyword=\"EventTimeOffset\" vr=\"FD\" vm=\"1\">Event Time Offset</tag>
    <tag group=\"0008\" element=\"2135\" keyword=\"EventCodeSequence\" vr=\"SQ\" vm=\"1\">Event Code Sequence</tag>
    <tag group=\"0008\" element=\"2142\" keyword=\"StartTrim\" vr=\"IS\" vm=\"1\">Start Trim</tag>
    <tag group=\"0008\" element=\"2143\" keyword=\"StopTrim\" vr=\"IS\" vm=\"1\">Stop Trim</tag>
    <tag group=\"0008\" element=\"2144\" keyword=\"RecommendedDisplayFrameRate\" vr=\"IS\" vm=\"1\">Recommended Display Frame Rate</tag>
    <tag group=\"0008\" element=\"2200\" keyword=\"TransducerPosition\" vr=\"CS\" vm=\"1\" retired=\"true\">Transducer Position</tag>
    <tag group=\"0008\" element=\"2204\" keyword=\"TransducerOrientation\" vr=\"CS\" vm=\"1\" retired=\"true\">Transducer Orientation</tag>
    <tag group=\"0008\" element=\"2208\" keyword=\"AnatomicStructure\" vr=\"CS\" vm=\"1\" retired=\"true\">Anatomic Structure</tag>
    <tag group=\"0008\" element=\"2218\" keyword=\"AnatomicRegionSequence\" vr=\"SQ\" vm=\"1\">Anatomic Region Sequence</tag>
    <tag group=\"0008\" element=\"2220\" keyword=\"AnatomicRegionModifierSequence\" vr=\"SQ\" vm=\"1\">Anatomic Region Modifier Sequence</tag>
    <tag group=\"0008\" element=\"2228\" keyword=\"PrimaryAnatomicStructureSequence\" vr=\"SQ\" vm=\"1\">Primary Anatomic Structure Sequence</tag>
    <tag group=\"0008\" element=\"2229\" keyword=\"AnatomicStructureSpaceOrRegionSequence\" vr=\"SQ\" vm=\"1\">Anatomic Structure, Space or Region Sequence</tag>
    <tag group=\"0008\" element=\"2230\" keyword=\"PrimaryAnatomicStructureModifierSequence\" vr=\"SQ\" vm=\"1\">Primary Anatomic Structure Modifier Sequence</tag>
    <tag group=\"0008\" element=\"2240\" keyword=\"TransducerPositionSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Transducer Position Sequence</tag>
    <tag group=\"0008\" element=\"2242\" keyword=\"TransducerPositionModifierSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Transducer Position Modifier Sequence</tag>
    <tag group=\"0008\" element=\"2244\" keyword=\"TransducerOrientationSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Transducer Orientation Sequence</tag>
    <tag group=\"0008\" element=\"2246\" keyword=\"TransducerOrientationModifierSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Transducer Orientation Modifier Sequence</tag>
    <tag group=\"0008\" element=\"2251\" keyword=\"AnatomicStructureSpaceOrRegionCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Anatomic Structure Space Or Region Code Sequence (Trial)</tag>
    <tag group=\"0008\" element=\"2253\" keyword=\"AnatomicPortalOfEntranceCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Anatomic Portal Of Entrance Code Sequence (Trial)</tag>
    <tag group=\"0008\" element=\"2255\" keyword=\"AnatomicApproachDirectionCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Anatomic Approach Direction Code Sequence (Trial)</tag>
    <tag group=\"0008\" element=\"2256\" keyword=\"AnatomicPerspectiveDescriptionTrial\" vr=\"ST\" vm=\"1\" retired=\"true\">Anatomic Perspective Description (Trial)</tag>
    <tag group=\"0008\" element=\"2257\" keyword=\"AnatomicPerspectiveCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Anatomic Perspective Code Sequence (Trial)</tag>
    <tag group=\"0008\" element=\"2258\" keyword=\"AnatomicLocationOfExaminingInstrumentDescriptionTrial\" vr=\"ST\" vm=\"1\" retired=\"true\">Anatomic Location Of Examining Instrument Description (Trial)</tag>
    <tag group=\"0008\" element=\"2259\" keyword=\"AnatomicLocationOfExaminingInstrumentCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Anatomic Location Of Examining Instrument Code Sequence (Trial)</tag>
    <tag group=\"0008\" element=\"225A\" keyword=\"AnatomicStructureSpaceOrRegionModifierCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Anatomic Structure Space Or Region Modifier Code Sequence (Trial)</tag>
    <tag group=\"0008\" element=\"225C\" keyword=\"OnAxisBackgroundAnatomicStructureCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">On Axis Background Anatomic Structure Code Sequence (Trial)</tag>
    <tag group=\"0008\" element=\"3001\" keyword=\"AlternateRepresentationSequence\" vr=\"SQ\" vm=\"1\">Alternate Representation Sequence</tag>
    <tag group=\"0008\" element=\"3010\" keyword=\"IrradiationEventUID\" vr=\"UI\" vm=\"1-n\">Irradiation Event UID</tag>
    <tag group=\"0008\" element=\"3011\" keyword=\"SourceIrradiationEventSequence\" vr=\"SQ\" vm=\"1\">Source Irradiation Event Sequence</tag>
    <tag group=\"0008\" element=\"3012\" keyword=\"RadiopharmaceuticalAdministrationEventUID\" vr=\"UI\" vm=\"1\">Radiopharmaceutical Administration Event UID</tag>
    <tag group=\"0008\" element=\"4000\" keyword=\"IdentifyingComments\" vr=\"LT\" vm=\"1\" retired=\"true\">Identifying Comments</tag>
    <tag group=\"0008\" element=\"9007\" keyword=\"FrameType\" vr=\"CS\" vm=\"4\">Frame Type</tag>
    <tag group=\"0008\" element=\"9092\" keyword=\"ReferencedImageEvidenceSequence\" vr=\"SQ\" vm=\"1\">Referenced Image Evidence Sequence</tag>
    <tag group=\"0008\" element=\"9121\" keyword=\"ReferencedRawDataSequence\" vr=\"SQ\" vm=\"1\">Referenced Raw Data Sequence</tag>
    <tag group=\"0008\" element=\"9123\" keyword=\"CreatorVersionUID\" vr=\"UI\" vm=\"1\">Creator-Version UID</tag>
    <tag group=\"0008\" element=\"9124\" keyword=\"DerivationImageSequence\" vr=\"SQ\" vm=\"1\">Derivation Image Sequence</tag>
    <tag group=\"0008\" element=\"9154\" keyword=\"SourceImageEvidenceSequence\" vr=\"SQ\" vm=\"1\">Source Image Evidence Sequence</tag>
    <tag group=\"0008\" element=\"9205\" keyword=\"PixelPresentation\" vr=\"CS\" vm=\"1\">Pixel Presentation</tag>
    <tag group=\"0008\" element=\"9206\" keyword=\"VolumetricProperties\" vr=\"CS\" vm=\"1\">Volumetric Properties</tag>
    <tag group=\"0008\" element=\"9207\" keyword=\"VolumeBasedCalculationTechnique\" vr=\"CS\" vm=\"1\">Volume Based Calculation Technique</tag>
    <tag group=\"0008\" element=\"9208\" keyword=\"ComplexImageComponent\" vr=\"CS\" vm=\"1\">Complex Image Component</tag>
    <tag group=\"0008\" element=\"9209\" keyword=\"AcquisitionContrast\" vr=\"CS\" vm=\"1\">Acquisition Contrast</tag>
    <tag group=\"0008\" element=\"9215\" keyword=\"DerivationCodeSequence\" vr=\"SQ\" vm=\"1\">Derivation Code Sequence</tag>
    <tag group=\"0008\" element=\"9237\" keyword=\"ReferencedPresentationStateSequence\" vr=\"SQ\" vm=\"1\">Referenced Presentation State Sequence</tag>
    <tag group=\"0008\" element=\"9410\" keyword=\"ReferencedOtherPlaneSequence\" vr=\"SQ\" vm=\"1\">Referenced Other Plane Sequence</tag>
    <tag group=\"0008\" element=\"9458\" keyword=\"FrameDisplaySequence\" vr=\"SQ\" vm=\"1\">Frame Display Sequence</tag>
    <tag group=\"0008\" element=\"9459\" keyword=\"RecommendedDisplayFrameRateInFloat\" vr=\"FL\" vm=\"1\">Recommended Display Frame Rate in Float</tag>
    <tag group=\"0008\" element=\"9460\" keyword=\"SkipFrameRangeFlag\" vr=\"CS\" vm=\"1\">Skip Frame Range Flag</tag>
    <tag group=\"0010\" element=\"0010\" keyword=\"PatientName\" vr=\"PN\" vm=\"1\">Patient's Name</tag>
    <tag group=\"0010\" element=\"0020\" keyword=\"PatientID\" vr=\"LO\" vm=\"1\">Patient ID</tag>
    <tag group=\"0010\" element=\"0021\" keyword=\"IssuerOfPatientID\" vr=\"LO\" vm=\"1\">Issuer of Patient ID</tag>
    <tag group=\"0010\" element=\"0022\" keyword=\"TypeOfPatientID\" vr=\"CS\" vm=\"1\">Type of Patient ID</tag>
    <tag group=\"0010\" element=\"0024\" keyword=\"IssuerOfPatientIDQualifiersSequence\" vr=\"SQ\" vm=\"1\">Issuer of Patient ID Qualifiers Sequence</tag>
    <tag group=\"0010\" element=\"0026\" keyword=\"SourcePatientGroupIdentificationSequence\" vr=\"SQ\" vm=\"1\">Source Patient Group Identification Sequence</tag>
    <tag group=\"0010\" element=\"0027\" keyword=\"GroupOfPatientsIdentificationSequence\" vr=\"SQ\" vm=\"1\">Group of Patients Identification Sequence</tag>
    <tag group=\"0010\" element=\"0028\" keyword=\"SubjectRelativePositionInImage\" vr=\"US\" vm=\"3\">Subject Relative Position in Image</tag>
    <tag group=\"0010\" element=\"0030\" keyword=\"PatientBirthDate\" vr=\"DA\" vm=\"1\">Patient's Birth Date</tag>
    <tag group=\"0010\" element=\"0032\" keyword=\"PatientBirthTime\" vr=\"TM\" vm=\"1\">Patient's Birth Time</tag>
    <tag group=\"0010\" element=\"0033\" keyword=\"PatientBirthDateInAlternativeCalendar\" vr=\"LO\" vm=\"1\">Patient's Birth Date in Alternative Calendar</tag>
    <tag group=\"0010\" element=\"0034\" keyword=\"PatientDeathDateInAlternativeCalendar\" vr=\"LO\" vm=\"1\">Patient's Death Date in Alternative Calendar</tag>
    <tag group=\"0010\" element=\"0035\" keyword=\"PatientAlternativeCalendar\" vr=\"CS\" vm=\"1\">Patient's Alternative Calendar</tag>
    <tag group=\"0010\" element=\"0040\" keyword=\"PatientSex\" vr=\"CS\" vm=\"1\">Patient's Sex</tag>
    <tag group=\"0010\" element=\"0050\" keyword=\"PatientInsurancePlanCodeSequence\" vr=\"SQ\" vm=\"1\">Patient's Insurance Plan Code Sequence</tag>
    <tag group=\"0010\" element=\"0101\" keyword=\"PatientPrimaryLanguageCodeSequence\" vr=\"SQ\" vm=\"1\">Patient's Primary Language Code Sequence</tag>
    <tag group=\"0010\" element=\"0102\" keyword=\"PatientPrimaryLanguageModifierCodeSequence\" vr=\"SQ\" vm=\"1\">Patient's Primary Language Modifier Code Sequence</tag>
    <tag group=\"0010\" element=\"0200\" keyword=\"QualityControlSubject\" vr=\"CS\" vm=\"1\">Quality Control Subject</tag>
    <tag group=\"0010\" element=\"0201\" keyword=\"QualityControlSubjectTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Quality Control Subject Type Code Sequence</tag>
    <tag group=\"0010\" element=\"0212\" keyword=\"StrainDescription\" vr=\"UC\" vm=\"1\">Strain Description</tag>
    <tag group=\"0010\" element=\"0213\" keyword=\"StrainNomenclature\" vr=\"LO\" vm=\"1\">Strain Nomenclature</tag>
    <tag group=\"0010\" element=\"0214\" keyword=\"StrainStockNumber\" vr=\"LO\" vm=\"1\">Strain Stock Number</tag>
    <tag group=\"0010\" element=\"0215\" keyword=\"StrainSourceRegistryCodeSequence\" vr=\"SQ\" vm=\"1\">Strain Source Registry Code Sequence</tag>
    <tag group=\"0010\" element=\"0216\" keyword=\"StrainStockSequence\" vr=\"SQ\" vm=\"1\">Strain Stock Sequence</tag>
    <tag group=\"0010\" element=\"0217\" keyword=\"StrainSource\" vr=\"LO\" vm=\"1\">Strain Source</tag>
    <tag group=\"0010\" element=\"0218\" keyword=\"StrainAdditionalInformation\" vr=\"UT\" vm=\"1\">Strain Additional Information</tag>
    <tag group=\"0010\" element=\"0219\" keyword=\"StrainCodeSequence\" vr=\"SQ\" vm=\"1\">Strain Code Sequence</tag>
    <tag group=\"0010\" element=\"0221\" keyword=\"GeneticModificationsSequence\" vr=\"SQ\" vm=\"1\">Genetic Modifications Sequence</tag>
    <tag group=\"0010\" element=\"0222\" keyword=\"GeneticModificationsDescription\" vr=\"UC\" vm=\"1\">Genetic Modifications Description</tag>
    <tag group=\"0010\" element=\"0223\" keyword=\"GeneticModificationsNomenclature\" vr=\"LO\" vm=\"1\">Genetic Modifications Nomenclature</tag>
    <tag group=\"0010\" element=\"0229\" keyword=\"GeneticModificationsCodeSequence\" vr=\"SQ\" vm=\"1\">Genetic Modifications Code Sequence</tag>
    <tag group=\"0010\" element=\"1000\" keyword=\"OtherPatientIDs\" vr=\"LO\" vm=\"1-n\" retired=\"true\">Other Patient IDs</tag>
    <tag group=\"0010\" element=\"1001\" keyword=\"OtherPatientNames\" vr=\"PN\" vm=\"1-n\">Other Patient Names</tag>
    <tag group=\"0010\" element=\"1002\" keyword=\"OtherPatientIDsSequence\" vr=\"SQ\" vm=\"1\">Other Patient IDs Sequence</tag>
    <tag group=\"0010\" element=\"1005\" keyword=\"PatientBirthName\" vr=\"PN\" vm=\"1\">Patient's Birth Name</tag>
    <tag group=\"0010\" element=\"1010\" keyword=\"PatientAge\" vr=\"AS\" vm=\"1\">Patient's Age</tag>
    <tag group=\"0010\" element=\"1020\" keyword=\"PatientSize\" vr=\"DS\" vm=\"1\">Patient's Size</tag>
    <tag group=\"0010\" element=\"1021\" keyword=\"PatientSizeCodeSequence\" vr=\"SQ\" vm=\"1\">Patient's Size Code Sequence</tag>
    <tag group=\"0010\" element=\"1022\" keyword=\"PatientBodyMassIndex\" vr=\"DS\" vm=\"1\">Patient's Body Mass Index</tag>
    <tag group=\"0010\" element=\"1023\" keyword=\"MeasuredAPDimension\" vr=\"DS\" vm=\"1\">Measured AP Dimension</tag>
    <tag group=\"0010\" element=\"1024\" keyword=\"MeasuredLateralDimension\" vr=\"DS\" vm=\"1\">Measured Lateral Dimension</tag>
    <tag group=\"0010\" element=\"1030\" keyword=\"PatientWeight\" vr=\"DS\" vm=\"1\">Patient's Weight</tag>
    <tag group=\"0010\" element=\"1040\" keyword=\"PatientAddress\" vr=\"LO\" vm=\"1\">Patient's Address</tag>
    <tag group=\"0010\" element=\"1050\" keyword=\"InsurancePlanIdentification\" vr=\"LO\" vm=\"1-n\" retired=\"true\">Insurance Plan Identification</tag>
    <tag group=\"0010\" element=\"1060\" keyword=\"PatientMotherBirthName\" vr=\"PN\" vm=\"1\">Patient's Mother's Birth Name</tag>
    <tag group=\"0010\" element=\"1080\" keyword=\"MilitaryRank\" vr=\"LO\" vm=\"1\">Military Rank</tag>
    <tag group=\"0010\" element=\"1081\" keyword=\"BranchOfService\" vr=\"LO\" vm=\"1\">Branch of Service</tag>
    <tag group=\"0010\" element=\"1090\" keyword=\"MedicalRecordLocator\" vr=\"LO\" vm=\"1\" retired=\"true\">Medical Record Locator</tag>
    <tag group=\"0010\" element=\"1100\" keyword=\"ReferencedPatientPhotoSequence\" vr=\"SQ\" vm=\"1\">Referenced Patient Photo Sequence</tag>
    <tag group=\"0010\" element=\"2000\" keyword=\"MedicalAlerts\" vr=\"LO\" vm=\"1-n\">Medical Alerts</tag>
    <tag group=\"0010\" element=\"2110\" keyword=\"Allergies\" vr=\"LO\" vm=\"1-n\">Allergies</tag>
    <tag group=\"0010\" element=\"2150\" keyword=\"CountryOfResidence\" vr=\"LO\" vm=\"1\">Country of Residence</tag>
    <tag group=\"0010\" element=\"2152\" keyword=\"RegionOfResidence\" vr=\"LO\" vm=\"1\">Region of Residence</tag>
    <tag group=\"0010\" element=\"2154\" keyword=\"PatientTelephoneNumbers\" vr=\"SH\" vm=\"1-n\">Patient's Telephone Numbers</tag>
    <tag group=\"0010\" element=\"2155\" keyword=\"PatientTelecomInformation\" vr=\"LT\" vm=\"1\">Patient's Telecom Information</tag>
    <tag group=\"0010\" element=\"2160\" keyword=\"EthnicGroup\" vr=\"SH\" vm=\"1\">Ethnic Group</tag>
    <tag group=\"0010\" element=\"2180\" keyword=\"Occupation\" vr=\"SH\" vm=\"1\">Occupation</tag>
    <tag group=\"0010\" element=\"21A0\" keyword=\"SmokingStatus\" vr=\"CS\" vm=\"1\">Smoking Status</tag>
    <tag group=\"0010\" element=\"21B0\" keyword=\"AdditionalPatientHistory\" vr=\"LT\" vm=\"1\">Additional Patient History</tag>
    <tag group=\"0010\" element=\"21C0\" keyword=\"PregnancyStatus\" vr=\"US\" vm=\"1\">Pregnancy Status</tag>
    <tag group=\"0010\" element=\"21D0\" keyword=\"LastMenstrualDate\" vr=\"DA\" vm=\"1\">Last Menstrual Date</tag>
    <tag group=\"0010\" element=\"21F0\" keyword=\"PatientReligiousPreference\" vr=\"LO\" vm=\"1\">Patient's Religious Preference</tag>
    <tag group=\"0010\" element=\"2201\" keyword=\"PatientSpeciesDescription\" vr=\"LO\" vm=\"1\">Patient Species Description</tag>
    <tag group=\"0010\" element=\"2202\" keyword=\"PatientSpeciesCodeSequence\" vr=\"SQ\" vm=\"1\">Patient Species Code Sequence</tag>
    <tag group=\"0010\" element=\"2203\" keyword=\"PatientSexNeutered\" vr=\"CS\" vm=\"1\">Patient's Sex Neutered</tag>
    <tag group=\"0010\" element=\"2210\" keyword=\"AnatomicalOrientationType\" vr=\"CS\" vm=\"1\">Anatomical Orientation Type</tag>
    <tag group=\"0010\" element=\"2292\" keyword=\"PatientBreedDescription\" vr=\"LO\" vm=\"1\">Patient Breed Description</tag>
    <tag group=\"0010\" element=\"2293\" keyword=\"PatientBreedCodeSequence\" vr=\"SQ\" vm=\"1\">Patient Breed Code Sequence</tag>
    <tag group=\"0010\" element=\"2294\" keyword=\"BreedRegistrationSequence\" vr=\"SQ\" vm=\"1\">Breed Registration Sequence</tag>
    <tag group=\"0010\" element=\"2295\" keyword=\"BreedRegistrationNumber\" vr=\"LO\" vm=\"1\">Breed Registration Number</tag>
    <tag group=\"0010\" element=\"2296\" keyword=\"BreedRegistryCodeSequence\" vr=\"SQ\" vm=\"1\">Breed Registry Code Sequence</tag>
    <tag group=\"0010\" element=\"2297\" keyword=\"ResponsiblePerson\" vr=\"PN\" vm=\"1\">Responsible Person</tag>
    <tag group=\"0010\" element=\"2298\" keyword=\"ResponsiblePersonRole\" vr=\"CS\" vm=\"1\">Responsible Person Role</tag>
    <tag group=\"0010\" element=\"2299\" keyword=\"ResponsibleOrganization\" vr=\"LO\" vm=\"1\">Responsible Organization</tag>
    <tag group=\"0010\" element=\"4000\" keyword=\"PatientComments\" vr=\"LT\" vm=\"1\">Patient Comments</tag>
    <tag group=\"0010\" element=\"9431\" keyword=\"ExaminedBodyThickness\" vr=\"FL\" vm=\"1\">Examined Body Thickness</tag>
    <tag group=\"0012\" element=\"0010\" keyword=\"ClinicalTrialSponsorName\" vr=\"LO\" vm=\"1\">Clinical Trial Sponsor Name</tag>
    <tag group=\"0012\" element=\"0020\" keyword=\"ClinicalTrialProtocolID\" vr=\"LO\" vm=\"1\">Clinical Trial Protocol ID</tag>
    <tag group=\"0012\" element=\"0021\" keyword=\"ClinicalTrialProtocolName\" vr=\"LO\" vm=\"1\">Clinical Trial Protocol Name</tag>
    <tag group=\"0012\" element=\"0030\" keyword=\"ClinicalTrialSiteID\" vr=\"LO\" vm=\"1\">Clinical Trial Site ID</tag>
    <tag group=\"0012\" element=\"0031\" keyword=\"ClinicalTrialSiteName\" vr=\"LO\" vm=\"1\">Clinical Trial Site Name</tag>
    <tag group=\"0012\" element=\"0040\" keyword=\"ClinicalTrialSubjectID\" vr=\"LO\" vm=\"1\">Clinical Trial Subject ID</tag>
    <tag group=\"0012\" element=\"0042\" keyword=\"ClinicalTrialSubjectReadingID\" vr=\"LO\" vm=\"1\">Clinical Trial Subject Reading ID</tag>
    <tag group=\"0012\" element=\"0050\" keyword=\"ClinicalTrialTimePointID\" vr=\"LO\" vm=\"1\">Clinical Trial Time Point ID</tag>
    <tag group=\"0012\" element=\"0051\" keyword=\"ClinicalTrialTimePointDescription\" vr=\"ST\" vm=\"1\">Clinical Trial Time Point Description</tag>
    <tag group=\"0012\" element=\"0060\" keyword=\"ClinicalTrialCoordinatingCenterName\" vr=\"LO\" vm=\"1\">Clinical Trial Coordinating Center Name</tag>
    <tag group=\"0012\" element=\"0062\" keyword=\"PatientIdentityRemoved\" vr=\"CS\" vm=\"1\">Patient Identity Removed</tag>
    <tag group=\"0012\" element=\"0063\" keyword=\"DeidentificationMethod\" vr=\"LO\" vm=\"1-n\">De-identification Method</tag>
    <tag group=\"0012\" element=\"0064\" keyword=\"DeidentificationMethodCodeSequence\" vr=\"SQ\" vm=\"1\">De-identification Method Code Sequence</tag>
    <tag group=\"0012\" element=\"0071\" keyword=\"ClinicalTrialSeriesID\" vr=\"LO\" vm=\"1\">Clinical Trial Series ID</tag>
    <tag group=\"0012\" element=\"0072\" keyword=\"ClinicalTrialSeriesDescription\" vr=\"LO\" vm=\"1\">Clinical Trial Series Description</tag>
    <tag group=\"0012\" element=\"0081\" keyword=\"ClinicalTrialProtocolEthicsCommitteeName\" vr=\"LO\" vm=\"1\">Clinical Trial Protocol Ethics Committee Name</tag>
    <tag group=\"0012\" element=\"0082\" keyword=\"ClinicalTrialProtocolEthicsCommitteeApprovalNumber\" vr=\"LO\" vm=\"1\">Clinical Trial Protocol Ethics Committee Approval Number</tag>
    <tag group=\"0012\" element=\"0083\" keyword=\"ConsentForClinicalTrialUseSequence\" vr=\"SQ\" vm=\"1\">Consent for Clinical Trial Use Sequence</tag>
    <tag group=\"0012\" element=\"0084\" keyword=\"DistributionType\" vr=\"CS\" vm=\"1\">Distribution Type</tag>
    <tag group=\"0012\" element=\"0085\" keyword=\"ConsentForDistributionFlag\" vr=\"CS\" vm=\"1\">Consent for Distribution Flag</tag>
    <tag group=\"0012\" element=\"0086\" keyword=\"EthicsCommitteeApprovalEffectivenessStartDate\" vr=\"DA\" vm=\"1\">Ethics Committee Approval Effectiveness Start Date</tag>
    <tag group=\"0012\" element=\"0087\" keyword=\"EthicsCommitteeApprovalEffectivenessEndDate\" vr=\"DA\" vm=\"1\">Ethics Committee Approval Effectiveness End Date</tag>
    <tag group=\"0014\" element=\"0023\" keyword=\"CADFileFormat\" vr=\"ST\" vm=\"1\" retired=\"true\">CAD File Format</tag>
    <tag group=\"0014\" element=\"0024\" keyword=\"ComponentReferenceSystem\" vr=\"ST\" vm=\"1\" retired=\"true\">Component Reference System</tag>
    <tag group=\"0014\" element=\"0025\" keyword=\"ComponentManufacturingProcedure\" vr=\"ST\" vm=\"1\">Component Manufacturing Procedure</tag>
    <tag group=\"0014\" element=\"0028\" keyword=\"ComponentManufacturer\" vr=\"ST\" vm=\"1\">Component Manufacturer</tag>
    <tag group=\"0014\" element=\"0030\" keyword=\"MaterialThickness\" vr=\"DS\" vm=\"1-n\">Material Thickness</tag>
    <tag group=\"0014\" element=\"0032\" keyword=\"MaterialPipeDiameter\" vr=\"DS\" vm=\"1-n\">Material Pipe Diameter</tag>
    <tag group=\"0014\" element=\"0034\" keyword=\"MaterialIsolationDiameter\" vr=\"DS\" vm=\"1-n\">Material Isolation Diameter</tag>
    <tag group=\"0014\" element=\"0042\" keyword=\"MaterialGrade\" vr=\"ST\" vm=\"1\">Material Grade</tag>
    <tag group=\"0014\" element=\"0044\" keyword=\"MaterialPropertiesDescription\" vr=\"ST\" vm=\"1\">Material Properties Description</tag>
    <tag group=\"0014\" element=\"0045\" keyword=\"MaterialPropertiesFileFormatRetired\" vr=\"ST\" vm=\"1\" retired=\"true\">Material Properties File Format (Retired)</tag>
    <tag group=\"0014\" element=\"0046\" keyword=\"MaterialNotes\" vr=\"LT\" vm=\"1\">Material Notes</tag>
    <tag group=\"0014\" element=\"0050\" keyword=\"ComponentShape\" vr=\"CS\" vm=\"1\">Component Shape</tag>
    <tag group=\"0014\" element=\"0052\" keyword=\"CurvatureType\" vr=\"CS\" vm=\"1\">Curvature Type</tag>
    <tag group=\"0014\" element=\"0054\" keyword=\"OuterDiameter\" vr=\"DS\" vm=\"1\">Outer Diameter</tag>
    <tag group=\"0014\" element=\"0056\" keyword=\"InnerDiameter\" vr=\"DS\" vm=\"1\">Inner Diameter</tag>
    <tag group=\"0014\" element=\"0100\" keyword=\"ComponentWelderIDs\" vr=\"LO\" vm=\"1-n\">Component Welder IDs</tag>
    <tag group=\"0014\" element=\"0101\" keyword=\"SecondaryApprovalStatus\" vr=\"CS\" vm=\"1\">Secondary Approval Status</tag>
    <tag group=\"0014\" element=\"0102\" keyword=\"SecondaryReviewDate\" vr=\"DA\" vm=\"1\">Secondary Review Date</tag>
    <tag group=\"0014\" element=\"0103\" keyword=\"SecondaryReviewTime\" vr=\"TM\" vm=\"1\">Secondary Review Time</tag>
    <tag group=\"0014\" element=\"0104\" keyword=\"SecondaryReviewerName\" vr=\"PN\" vm=\"1\">Secondary Reviewer Name</tag>
    <tag group=\"0014\" element=\"0105\" keyword=\"RepairID\" vr=\"ST\" vm=\"1\">Repair ID</tag>
    <tag group=\"0014\" element=\"0106\" keyword=\"MultipleComponentApprovalSequence\" vr=\"SQ\" vm=\"1\">Multiple Component Approval Sequence</tag>
    <tag group=\"0014\" element=\"0107\" keyword=\"OtherApprovalStatus\" vr=\"CS\" vm=\"1-n\">Other Approval Status</tag>
    <tag group=\"0014\" element=\"0108\" keyword=\"OtherSecondaryApprovalStatus\" vr=\"CS\" vm=\"1-n\">Other Secondary Approval Status</tag>
    <tag group=\"0014\" element=\"1010\" keyword=\"ActualEnvironmentalConditions\" vr=\"ST\" vm=\"1\">Actual Environmental Conditions</tag>
    <tag group=\"0014\" element=\"1020\" keyword=\"ExpiryDate\" vr=\"DA\" vm=\"1\">Expiry Date</tag>
    <tag group=\"0014\" element=\"1040\" keyword=\"EnvironmentalConditions\" vr=\"ST\" vm=\"1\">Environmental Conditions</tag>
    <tag group=\"0014\" element=\"2002\" keyword=\"EvaluatorSequence\" vr=\"SQ\" vm=\"1\">Evaluator Sequence</tag>
    <tag group=\"0014\" element=\"2004\" keyword=\"EvaluatorNumber\" vr=\"IS\" vm=\"1\">Evaluator Number</tag>
    <tag group=\"0014\" element=\"2006\" keyword=\"EvaluatorName\" vr=\"PN\" vm=\"1\">Evaluator Name</tag>
    <tag group=\"0014\" element=\"2008\" keyword=\"EvaluationAttempt\" vr=\"IS\" vm=\"1\">Evaluation Attempt</tag>
    <tag group=\"0014\" element=\"2012\" keyword=\"IndicationSequence\" vr=\"SQ\" vm=\"1\">Indication Sequence</tag>
    <tag group=\"0014\" element=\"2014\" keyword=\"IndicationNumber\" vr=\"IS\" vm=\"1\">Indication Number</tag>
    <tag group=\"0014\" element=\"2016\" keyword=\"IndicationLabel\" vr=\"SH\" vm=\"1\">Indication Label</tag>
    <tag group=\"0014\" element=\"2018\" keyword=\"IndicationDescription\" vr=\"ST\" vm=\"1\">Indication Description</tag>
    <tag group=\"0014\" element=\"201A\" keyword=\"IndicationType\" vr=\"CS\" vm=\"1-n\">Indication Type</tag>
    <tag group=\"0014\" element=\"201C\" keyword=\"IndicationDisposition\" vr=\"CS\" vm=\"1\">Indication Disposition</tag>
    <tag group=\"0014\" element=\"201E\" keyword=\"IndicationROISequence\" vr=\"SQ\" vm=\"1\">Indication ROI Sequence</tag>
    <tag group=\"0014\" element=\"2030\" keyword=\"IndicationPhysicalPropertySequence\" vr=\"SQ\" vm=\"1\">Indication Physical Property Sequence</tag>
    <tag group=\"0014\" element=\"2032\" keyword=\"PropertyLabel\" vr=\"SH\" vm=\"1\">Property Label</tag>
    <tag group=\"0014\" element=\"2202\" keyword=\"CoordinateSystemNumberOfAxes\" vr=\"IS\" vm=\"1\">Coordinate System Number of Axes</tag>
    <tag group=\"0014\" element=\"2204\" keyword=\"CoordinateSystemAxesSequence\" vr=\"SQ\" vm=\"1\">Coordinate System Axes Sequence</tag>
    <tag group=\"0014\" element=\"2206\" keyword=\"CoordinateSystemAxisDescription\" vr=\"ST\" vm=\"1\">Coordinate System Axis Description</tag>
    <tag group=\"0014\" element=\"2208\" keyword=\"CoordinateSystemDataSetMapping\" vr=\"CS\" vm=\"1\">Coordinate System Data Set Mapping</tag>
    <tag group=\"0014\" element=\"220A\" keyword=\"CoordinateSystemAxisNumber\" vr=\"IS\" vm=\"1\">Coordinate System Axis Number</tag>
    <tag group=\"0014\" element=\"220C\" keyword=\"CoordinateSystemAxisType\" vr=\"CS\" vm=\"1\">Coordinate System Axis Type</tag>
    <tag group=\"0014\" element=\"220E\" keyword=\"CoordinateSystemAxisUnits\" vr=\"CS\" vm=\"1\">Coordinate System Axis Units</tag>
    <tag group=\"0014\" element=\"2210\" keyword=\"CoordinateSystemAxisValues\" vr=\"OB\" vm=\"1\">Coordinate System Axis Values</tag>
    <tag group=\"0014\" element=\"2220\" keyword=\"CoordinateSystemTransformSequence\" vr=\"SQ\" vm=\"1\">Coordinate System Transform Sequence</tag>
    <tag group=\"0014\" element=\"2222\" keyword=\"TransformDescription\" vr=\"ST\" vm=\"1\">Transform Description</tag>
    <tag group=\"0014\" element=\"2224\" keyword=\"TransformNumberOfAxes\" vr=\"IS\" vm=\"1\">Transform Number of Axes</tag>
    <tag group=\"0014\" element=\"2226\" keyword=\"TransformOrderOfAxes\" vr=\"IS\" vm=\"1-n\">Transform Order of Axes</tag>
    <tag group=\"0014\" element=\"2228\" keyword=\"TransformedAxisUnits\" vr=\"CS\" vm=\"1\">Transformed Axis Units</tag>
    <tag group=\"0014\" element=\"222A\" keyword=\"CoordinateSystemTransformRotationAndScaleMatrix\" vr=\"DS\" vm=\"1-n\">Coordinate System Transform Rotation and Scale Matrix</tag>
    <tag group=\"0014\" element=\"222C\" keyword=\"CoordinateSystemTransformTranslationMatrix\" vr=\"DS\" vm=\"1-n\">Coordinate System Transform Translation Matrix</tag>
    <tag group=\"0014\" element=\"3011\" keyword=\"InternalDetectorFrameTime\" vr=\"DS\" vm=\"1\">Internal Detector Frame Time</tag>
    <tag group=\"0014\" element=\"3012\" keyword=\"NumberOfFramesIntegrated\" vr=\"DS\" vm=\"1\">Number of Frames Integrated</tag>
    <tag group=\"0014\" element=\"3020\" keyword=\"DetectorTemperatureSequence\" vr=\"SQ\" vm=\"1\">Detector Temperature Sequence</tag>
    <tag group=\"0014\" element=\"3022\" keyword=\"SensorName\" vr=\"ST\" vm=\"1\">Sensor Name</tag>
    <tag group=\"0014\" element=\"3024\" keyword=\"HorizontalOffsetOfSensor\" vr=\"DS\" vm=\"1\">Horizontal Offset of Sensor</tag>
    <tag group=\"0014\" element=\"3026\" keyword=\"VerticalOffsetOfSensor\" vr=\"DS\" vm=\"1\">Vertical Offset of Sensor</tag>
    <tag group=\"0014\" element=\"3028\" keyword=\"SensorTemperature\" vr=\"DS\" vm=\"1\">Sensor Temperature</tag>
    <tag group=\"0014\" element=\"3040\" keyword=\"DarkCurrentSequence\" vr=\"SQ\" vm=\"1\">Dark Current Sequence</tag>
    <tag group=\"0014\" element=\"3050\" keyword=\"DarkCurrentCounts\" vr=\"OB/OW\" vm=\"1\">Dark Current Counts</tag>
    <tag group=\"0014\" element=\"3060\" keyword=\"GainCorrectionReferenceSequence\" vr=\"SQ\" vm=\"1\">Gain Correction Reference Sequence</tag>
    <tag group=\"0014\" element=\"3070\" keyword=\"AirCounts\" vr=\"OB/OW\" vm=\"1\">Air Counts</tag>
    <tag group=\"0014\" element=\"3071\" keyword=\"KVUsedInGainCalibration\" vr=\"DS\" vm=\"1\">KV Used in Gain Calibration</tag>
    <tag group=\"0014\" element=\"3072\" keyword=\"MAUsedInGainCalibration\" vr=\"DS\" vm=\"1\">MA Used in Gain Calibration</tag>
    <tag group=\"0014\" element=\"3073\" keyword=\"NumberOfFramesUsedForIntegration\" vr=\"DS\" vm=\"1\">Number of Frames Used for Integration</tag>
    <tag group=\"0014\" element=\"3074\" keyword=\"FilterMaterialUsedInGainCalibration\" vr=\"LO\" vm=\"1\">Filter Material Used in Gain Calibration</tag>
    <tag group=\"0014\" element=\"3075\" keyword=\"FilterThicknessUsedInGainCalibration\" vr=\"DS\" vm=\"1\">Filter Thickness Used in Gain Calibration</tag>
    <tag group=\"0014\" element=\"3076\" keyword=\"DateOfGainCalibration\" vr=\"DA\" vm=\"1\">Date of Gain Calibration</tag>
    <tag group=\"0014\" element=\"3077\" keyword=\"TimeOfGainCalibration\" vr=\"TM\" vm=\"1\">Time of Gain Calibration</tag>
    <tag group=\"0014\" element=\"3080\" keyword=\"BadPixelImage\" vr=\"OB\" vm=\"1\">Bad Pixel Image</tag>
    <tag group=\"0014\" element=\"3099\" keyword=\"CalibrationNotes\" vr=\"LT\" vm=\"1\">Calibration Notes</tag>
    <tag group=\"0014\" element=\"4002\" keyword=\"PulserEquipmentSequence\" vr=\"SQ\" vm=\"1\">Pulser Equipment Sequence</tag>
    <tag group=\"0014\" element=\"4004\" keyword=\"PulserType\" vr=\"CS\" vm=\"1\">Pulser Type</tag>
    <tag group=\"0014\" element=\"4006\" keyword=\"PulserNotes\" vr=\"LT\" vm=\"1\">Pulser Notes</tag>
    <tag group=\"0014\" element=\"4008\" keyword=\"ReceiverEquipmentSequence\" vr=\"SQ\" vm=\"1\">Receiver Equipment Sequence</tag>
    <tag group=\"0014\" element=\"400A\" keyword=\"AmplifierType\" vr=\"CS\" vm=\"1\">Amplifier Type</tag>
    <tag group=\"0014\" element=\"400C\" keyword=\"ReceiverNotes\" vr=\"LT\" vm=\"1\">Receiver Notes</tag>
    <tag group=\"0014\" element=\"400E\" keyword=\"PreAmplifierEquipmentSequence\" vr=\"SQ\" vm=\"1\">Pre-Amplifier Equipment Sequence</tag>
    <tag group=\"0014\" element=\"400F\" keyword=\"PreAmplifierNotes\" vr=\"LT\" vm=\"1\">Pre-Amplifier Notes</tag>
    <tag group=\"0014\" element=\"4010\" keyword=\"TransmitTransducerSequence\" vr=\"SQ\" vm=\"1\">Transmit Transducer Sequence</tag>
    <tag group=\"0014\" element=\"4011\" keyword=\"ReceiveTransducerSequence\" vr=\"SQ\" vm=\"1\">Receive Transducer Sequence</tag>
    <tag group=\"0014\" element=\"4012\" keyword=\"NumberOfElements\" vr=\"US\" vm=\"1\">Number of Elements</tag>
    <tag group=\"0014\" element=\"4013\" keyword=\"ElementShape\" vr=\"CS\" vm=\"1\">Element Shape</tag>
    <tag group=\"0014\" element=\"4014\" keyword=\"ElementDimensionA\" vr=\"DS\" vm=\"1\">Element Dimension A</tag>
    <tag group=\"0014\" element=\"4015\" keyword=\"ElementDimensionB\" vr=\"DS\" vm=\"1\">Element Dimension B</tag>
    <tag group=\"0014\" element=\"4016\" keyword=\"ElementPitchA\" vr=\"DS\" vm=\"1\">Element Pitch A</tag>
    <tag group=\"0014\" element=\"4017\" keyword=\"MeasuredBeamDimensionA\" vr=\"DS\" vm=\"1\">Measured Beam Dimension A</tag>
    <tag group=\"0014\" element=\"4018\" keyword=\"MeasuredBeamDimensionB\" vr=\"DS\" vm=\"1\">Measured Beam Dimension B</tag>
    <tag group=\"0014\" element=\"4019\" keyword=\"LocationOfMeasuredBeamDiameter\" vr=\"DS\" vm=\"1\">Location of Measured Beam Diameter</tag>
    <tag group=\"0014\" element=\"401A\" keyword=\"NominalFrequency\" vr=\"DS\" vm=\"1\">Nominal Frequency</tag>
    <tag group=\"0014\" element=\"401B\" keyword=\"MeasuredCenterFrequency\" vr=\"DS\" vm=\"1\">Measured Center Frequency</tag>
    <tag group=\"0014\" element=\"401C\" keyword=\"MeasuredBandwidth\" vr=\"DS\" vm=\"1\">Measured Bandwidth</tag>
    <tag group=\"0014\" element=\"401D\" keyword=\"ElementPitchB\" vr=\"DS\" vm=\"1\">Element Pitch B</tag>
    <tag group=\"0014\" element=\"4020\" keyword=\"PulserSettingsSequence\" vr=\"SQ\" vm=\"1\">Pulser Settings Sequence</tag>
    <tag group=\"0014\" element=\"4022\" keyword=\"PulseWidth\" vr=\"DS\" vm=\"1\">Pulse Width</tag>
    <tag group=\"0014\" element=\"4024\" keyword=\"ExcitationFrequency\" vr=\"DS\" vm=\"1\">Excitation Frequency</tag>
    <tag group=\"0014\" element=\"4026\" keyword=\"ModulationType\" vr=\"CS\" vm=\"1\">Modulation Type</tag>
    <tag group=\"0014\" element=\"4028\" keyword=\"Damping\" vr=\"DS\" vm=\"1\">Damping</tag>
    <tag group=\"0014\" element=\"4030\" keyword=\"ReceiverSettingsSequence\" vr=\"SQ\" vm=\"1\">Receiver Settings Sequence</tag>
    <tag group=\"0014\" element=\"4031\" keyword=\"AcquiredSoundpathLength\" vr=\"DS\" vm=\"1\">Acquired Soundpath Length</tag>
    <tag group=\"0014\" element=\"4032\" keyword=\"AcquisitionCompressionType\" vr=\"CS\" vm=\"1\">Acquisition Compression Type</tag>
    <tag group=\"0014\" element=\"4033\" keyword=\"AcquisitionSampleSize\" vr=\"IS\" vm=\"1\">Acquisition Sample Size</tag>
    <tag group=\"0014\" element=\"4034\" keyword=\"RectifierSmoothing\" vr=\"DS\" vm=\"1\">Rectifier Smoothing</tag>
    <tag group=\"0014\" element=\"4035\" keyword=\"DACSequence\" vr=\"SQ\" vm=\"1\">DAC Sequence</tag>
    <tag group=\"0014\" element=\"4036\" keyword=\"DACType\" vr=\"CS\" vm=\"1\">DAC Type</tag>
    <tag group=\"0014\" element=\"4038\" keyword=\"DACGainPoints\" vr=\"DS\" vm=\"1-n\">DAC Gain Points</tag>
    <tag group=\"0014\" element=\"403A\" keyword=\"DACTimePoints\" vr=\"DS\" vm=\"1-n\">DAC Time Points</tag>
    <tag group=\"0014\" element=\"403C\" keyword=\"DACAmplitude\" vr=\"DS\" vm=\"1-n\">DAC Amplitude</tag>
    <tag group=\"0014\" element=\"4040\" keyword=\"PreAmplifierSettingsSequence\" vr=\"SQ\" vm=\"1\">Pre-Amplifier Settings Sequence</tag>
    <tag group=\"0014\" element=\"4050\" keyword=\"TransmitTransducerSettingsSequence\" vr=\"SQ\" vm=\"1\">Transmit Transducer Settings Sequence</tag>
    <tag group=\"0014\" element=\"4051\" keyword=\"ReceiveTransducerSettingsSequence\" vr=\"SQ\" vm=\"1\">Receive Transducer Settings Sequence</tag>
    <tag group=\"0014\" element=\"4052\" keyword=\"IncidentAngle\" vr=\"DS\" vm=\"1\">Incident Angle</tag>
    <tag group=\"0014\" element=\"4054\" keyword=\"CouplingTechnique\" vr=\"ST\" vm=\"1\">Coupling Technique</tag>
    <tag group=\"0014\" element=\"4056\" keyword=\"CouplingMedium\" vr=\"ST\" vm=\"1\">Coupling Medium</tag>
    <tag group=\"0014\" element=\"4057\" keyword=\"CouplingVelocity\" vr=\"DS\" vm=\"1\">Coupling Velocity</tag>
    <tag group=\"0014\" element=\"4058\" keyword=\"ProbeCenterLocationX\" vr=\"DS\" vm=\"1\">Probe Center Location X</tag>
    <tag group=\"0014\" element=\"4059\" keyword=\"ProbeCenterLocationZ\" vr=\"DS\" vm=\"1\">Probe Center Location Z</tag>
    <tag group=\"0014\" element=\"405A\" keyword=\"SoundPathLength\" vr=\"DS\" vm=\"1\">Sound Path Length</tag>
    <tag group=\"0014\" element=\"405C\" keyword=\"DelayLawIdentifier\" vr=\"ST\" vm=\"1\">Delay Law Identifier</tag>
    <tag group=\"0014\" element=\"4060\" keyword=\"GateSettingsSequence\" vr=\"SQ\" vm=\"1\">Gate Settings Sequence</tag>
    <tag group=\"0014\" element=\"4062\" keyword=\"GateThreshold\" vr=\"DS\" vm=\"1\">Gate Threshold</tag>
    <tag group=\"0014\" element=\"4064\" keyword=\"VelocityOfSound\" vr=\"DS\" vm=\"1\">Velocity of Sound</tag>
    <tag group=\"0014\" element=\"4070\" keyword=\"CalibrationSettingsSequence\" vr=\"SQ\" vm=\"1\">Calibration Settings Sequence</tag>
    <tag group=\"0014\" element=\"4072\" keyword=\"CalibrationProcedure\" vr=\"ST\" vm=\"1\">Calibration Procedure</tag>
    <tag group=\"0014\" element=\"4074\" keyword=\"ProcedureVersion\" vr=\"SH\" vm=\"1\">Procedure Version</tag>
    <tag group=\"0014\" element=\"4076\" keyword=\"ProcedureCreationDate\" vr=\"DA\" vm=\"1\">Procedure Creation Date</tag>
    <tag group=\"0014\" element=\"4078\" keyword=\"ProcedureExpirationDate\" vr=\"DA\" vm=\"1\">Procedure Expiration Date</tag>
    <tag group=\"0014\" element=\"407A\" keyword=\"ProcedureLastModifiedDate\" vr=\"DA\" vm=\"1\">Procedure Last Modified Date</tag>
    <tag group=\"0014\" element=\"407C\" keyword=\"CalibrationTime\" vr=\"TM\" vm=\"1-n\">Calibration Time</tag>
    <tag group=\"0014\" element=\"407E\" keyword=\"CalibrationDate\" vr=\"DA\" vm=\"1-n\">Calibration Date</tag>
    <tag group=\"0014\" element=\"4080\" keyword=\"ProbeDriveEquipmentSequence\" vr=\"SQ\" vm=\"1\">Probe Drive Equipment Sequence</tag>
    <tag group=\"0014\" element=\"4081\" keyword=\"DriveType\" vr=\"CS\" vm=\"1\">Drive Type</tag>
    <tag group=\"0014\" element=\"4082\" keyword=\"ProbeDriveNotes\" vr=\"LT\" vm=\"1\">Probe Drive Notes</tag>
    <tag group=\"0014\" element=\"4083\" keyword=\"DriveProbeSequence\" vr=\"SQ\" vm=\"1\">Drive Probe Sequence</tag>
    <tag group=\"0014\" element=\"4084\" keyword=\"ProbeInductance\" vr=\"DS\" vm=\"1\">Probe Inductance</tag>
    <tag group=\"0014\" element=\"4085\" keyword=\"ProbeResistance\" vr=\"DS\" vm=\"1\">Probe Resistance</tag>
    <tag group=\"0014\" element=\"4086\" keyword=\"ReceiveProbeSequence\" vr=\"SQ\" vm=\"1\">Receive Probe Sequence</tag>
    <tag group=\"0014\" element=\"4087\" keyword=\"ProbeDriveSettingsSequence\" vr=\"SQ\" vm=\"1\">Probe Drive Settings Sequence</tag>
    <tag group=\"0014\" element=\"4088\" keyword=\"BridgeResistors\" vr=\"DS\" vm=\"1\">Bridge Resistors</tag>
    <tag group=\"0014\" element=\"4089\" keyword=\"ProbeOrientationAngle\" vr=\"DS\" vm=\"1\">Probe Orientation Angle</tag>
    <tag group=\"0014\" element=\"408B\" keyword=\"UserSelectedGainY\" vr=\"DS\" vm=\"1\">User Selected Gain Y</tag>
    <tag group=\"0014\" element=\"408C\" keyword=\"UserSelectedPhase\" vr=\"DS\" vm=\"1\">User Selected Phase</tag>
    <tag group=\"0014\" element=\"408D\" keyword=\"UserSelectedOffsetX\" vr=\"DS\" vm=\"1\">User Selected Offset X</tag>
    <tag group=\"0014\" element=\"408E\" keyword=\"UserSelectedOffsetY\" vr=\"DS\" vm=\"1\">User Selected Offset Y</tag>
    <tag group=\"0014\" element=\"4091\" keyword=\"ChannelSettingsSequence\" vr=\"SQ\" vm=\"1\">Channel Settings Sequence</tag>
    <tag group=\"0014\" element=\"4092\" keyword=\"ChannelThreshold\" vr=\"DS\" vm=\"1\">Channel Threshold</tag>
    <tag group=\"0014\" element=\"409A\" keyword=\"ScannerSettingsSequence\" vr=\"SQ\" vm=\"1\">Scanner Settings Sequence</tag>
    <tag group=\"0014\" element=\"409B\" keyword=\"ScanProcedure\" vr=\"ST\" vm=\"1\">Scan Procedure</tag>
    <tag group=\"0014\" element=\"409C\" keyword=\"TranslationRateX\" vr=\"DS\" vm=\"1\">Translation Rate X</tag>
    <tag group=\"0014\" element=\"409D\" keyword=\"TranslationRateY\" vr=\"DS\" vm=\"1\">Translation Rate Y</tag>
    <tag group=\"0014\" element=\"409F\" keyword=\"ChannelOverlap\" vr=\"DS\" vm=\"1\">Channel Overlap</tag>
    <tag group=\"0014\" element=\"40A0\" keyword=\"ImageQualityIndicatorType\" vr=\"LO\" vm=\"1\">Image Quality Indicator Type</tag>
    <tag group=\"0014\" element=\"40A1\" keyword=\"ImageQualityIndicatorMaterial\" vr=\"LO\" vm=\"1\">Image Quality Indicator Material</tag>
    <tag group=\"0014\" element=\"40A2\" keyword=\"ImageQualityIndicatorSize\" vr=\"LO\" vm=\"1\">Image Quality Indicator Size</tag>
    <tag group=\"0014\" element=\"5002\" keyword=\"LINACEnergy\" vr=\"IS\" vm=\"1\">LINAC Energy</tag>
    <tag group=\"0014\" element=\"5004\" keyword=\"LINACOutput\" vr=\"IS\" vm=\"1\">LINAC Output</tag>
    <tag group=\"0014\" element=\"5100\" keyword=\"ActiveAperture\" vr=\"US\" vm=\"1\">Active Aperture</tag>
    <tag group=\"0014\" element=\"5101\" keyword=\"TotalAperture\" vr=\"DS\" vm=\"1\">Total Aperture</tag>
    <tag group=\"0014\" element=\"5102\" keyword=\"ApertureElevation\" vr=\"DS\" vm=\"1\">Aperture Elevation</tag>
    <tag group=\"0014\" element=\"5103\" keyword=\"MainLobeAngle\" vr=\"DS\" vm=\"1\">Main Lobe Angle</tag>
    <tag group=\"0014\" element=\"5104\" keyword=\"MainRoofAngle\" vr=\"DS\" vm=\"1\">Main Roof Angle</tag>
    <tag group=\"0014\" element=\"5105\" keyword=\"ConnectorType\" vr=\"CS\" vm=\"1\">Connector Type</tag>
    <tag group=\"0014\" element=\"5106\" keyword=\"WedgeModelNumber\" vr=\"SH\" vm=\"1\">Wedge Model Number</tag>
    <tag group=\"0014\" element=\"5107\" keyword=\"WedgeAngleFloat\" vr=\"DS\" vm=\"1\">Wedge Angle Float</tag>
    <tag group=\"0014\" element=\"5108\" keyword=\"WedgeRoofAngle\" vr=\"DS\" vm=\"1\">Wedge Roof Angle</tag>
    <tag group=\"0014\" element=\"5109\" keyword=\"WedgeElement1Position\" vr=\"CS\" vm=\"1\">Wedge Element 1 Position</tag>
    <tag group=\"0014\" element=\"510A\" keyword=\"WedgeMaterialVelocity\" vr=\"DS\" vm=\"1\">Wedge Material Velocity</tag>
    <tag group=\"0014\" element=\"510B\" keyword=\"WedgeMaterial\" vr=\"SH\" vm=\"1\">Wedge Material</tag>
    <tag group=\"0014\" element=\"510C\" keyword=\"WedgeOffsetZ\" vr=\"DS\" vm=\"1\">Wedge Offset Z</tag>
    <tag group=\"0014\" element=\"510D\" keyword=\"WedgeOriginOffsetX\" vr=\"DS\" vm=\"1\">Wedge Origin Offset X</tag>
    <tag group=\"0014\" element=\"510E\" keyword=\"WedgeTimeDelay\" vr=\"DS\" vm=\"1\">Wedge Time Delay</tag>
    <tag group=\"0014\" element=\"510F\" keyword=\"WedgeName\" vr=\"SH\" vm=\"1\">Wedge Name</tag>
    <tag group=\"0014\" element=\"5110\" keyword=\"WedgeManufacturerName\" vr=\"SH\" vm=\"1\">Wedge Manufacturer Name</tag>
    <tag group=\"0014\" element=\"5111\" keyword=\"WedgeDescription\" vr=\"LO\" vm=\"1\">Wedge Description</tag>
    <tag group=\"0014\" element=\"5112\" keyword=\"NominalBeamAngle\" vr=\"DS\" vm=\"1\">Nominal Beam Angle</tag>
    <tag group=\"0014\" element=\"5113\" keyword=\"WedgeOffsetX\" vr=\"DS\" vm=\"1\">Wedge Offset X</tag>
    <tag group=\"0014\" element=\"5114\" keyword=\"WedgeOffsetY\" vr=\"DS\" vm=\"1\">Wedge Offset Y</tag>
    <tag group=\"0014\" element=\"5115\" keyword=\"WedgeTotalLength\" vr=\"DS\" vm=\"1\">Wedge Total Length</tag>
    <tag group=\"0014\" element=\"5116\" keyword=\"WedgeInContactLength\" vr=\"DS\" vm=\"1\">Wedge In Contact Length</tag>
    <tag group=\"0014\" element=\"5117\" keyword=\"WedgeFrontGap\" vr=\"DS\" vm=\"1\">Wedge Front Gap</tag>
    <tag group=\"0014\" element=\"5118\" keyword=\"WedgeTotalHeight\" vr=\"DS\" vm=\"1\">Wedge Total Height</tag>
    <tag group=\"0014\" element=\"5119\" keyword=\"WedgeFrontHeight\" vr=\"DS\" vm=\"1\">Wedge Front Height</tag>
    <tag group=\"0014\" element=\"511A\" keyword=\"WedgeRearHeight\" vr=\"DS\" vm=\"1\">Wedge Rear Height</tag>
    <tag group=\"0014\" element=\"511B\" keyword=\"WedgeTotalWidth\" vr=\"DS\" vm=\"1\">Wedge Total Width</tag>
    <tag group=\"0014\" element=\"511C\" keyword=\"WedgeInContactWidth\" vr=\"DS\" vm=\"1\">Wedge In Contact Width</tag>
    <tag group=\"0014\" element=\"511D\" keyword=\"WedgeChamferHeight\" vr=\"DS\" vm=\"1\">Wedge Chamfer Height</tag>
    <tag group=\"0014\" element=\"511E\" keyword=\"WedgeCurve\" vr=\"CS\" vm=\"1\">Wedge Curve</tag>
    <tag group=\"0014\" element=\"511F\" keyword=\"RadiusAlongWedge\" vr=\"DS\" vm=\"1\">Radius Along the Wedge</tag>
    <tag group=\"0018\" element=\"0010\" keyword=\"ContrastBolusAgent\" vr=\"LO\" vm=\"1\">Contrast/Bolus Agent</tag>
    <tag group=\"0018\" element=\"0012\" keyword=\"ContrastBolusAgentSequence\" vr=\"SQ\" vm=\"1\">Contrast/Bolus Agent Sequence</tag>
    <tag group=\"0018\" element=\"0013\" keyword=\"ContrastBolusT1Relaxivity\" vr=\"FL\" vm=\"1\">Contrast/Bolus T1 Relaxivity</tag>
    <tag group=\"0018\" element=\"0014\" keyword=\"ContrastBolusAdministrationRouteSequence\" vr=\"SQ\" vm=\"1\">Contrast/Bolus Administration Route Sequence</tag>
    <tag group=\"0018\" element=\"0015\" keyword=\"BodyPartExamined\" vr=\"CS\" vm=\"1\">Body Part Examined</tag>
    <tag group=\"0018\" element=\"0020\" keyword=\"ScanningSequence\" vr=\"CS\" vm=\"1-n\">Scanning Sequence</tag>
    <tag group=\"0018\" element=\"0021\" keyword=\"SequenceVariant\" vr=\"CS\" vm=\"1-n\">Sequence Variant</tag>
    <tag group=\"0018\" element=\"0022\" keyword=\"ScanOptions\" vr=\"CS\" vm=\"1-n\">Scan Options</tag>
    <tag group=\"0018\" element=\"0023\" keyword=\"MRAcquisitionType\" vr=\"CS\" vm=\"1\">MR Acquisition Type</tag>
    <tag group=\"0018\" element=\"0024\" keyword=\"SequenceName\" vr=\"SH\" vm=\"1\">Sequence Name</tag>
    <tag group=\"0018\" element=\"0025\" keyword=\"AngioFlag\" vr=\"CS\" vm=\"1\">Angio Flag</tag>
    <tag group=\"0018\" element=\"0026\" keyword=\"InterventionDrugInformationSequence\" vr=\"SQ\" vm=\"1\">Intervention Drug Information Sequence</tag>
    <tag group=\"0018\" element=\"0027\" keyword=\"InterventionDrugStopTime\" vr=\"TM\" vm=\"1\">Intervention Drug Stop Time</tag>
    <tag group=\"0018\" element=\"0028\" keyword=\"InterventionDrugDose\" vr=\"DS\" vm=\"1\">Intervention Drug Dose</tag>
    <tag group=\"0018\" element=\"0029\" keyword=\"InterventionDrugCodeSequence\" vr=\"SQ\" vm=\"1\">Intervention Drug Code Sequence</tag>
    <tag group=\"0018\" element=\"002A\" keyword=\"AdditionalDrugSequence\" vr=\"SQ\" vm=\"1\">Additional Drug Sequence</tag>
    <tag group=\"0018\" element=\"0030\" keyword=\"Radionuclide\" vr=\"LO\" vm=\"1-n\" retired=\"true\">Radionuclide</tag>
    <tag group=\"0018\" element=\"0031\" keyword=\"Radiopharmaceutical\" vr=\"LO\" vm=\"1\">Radiopharmaceutical</tag>
    <tag group=\"0018\" element=\"0032\" keyword=\"EnergyWindowCenterline\" vr=\"DS\" vm=\"1\" retired=\"true\">Energy Window Centerline</tag>
    <tag group=\"0018\" element=\"0033\" keyword=\"EnergyWindowTotalWidth\" vr=\"DS\" vm=\"1-n\" retired=\"true\">Energy Window Total Width</tag>
    <tag group=\"0018\" element=\"0034\" keyword=\"InterventionDrugName\" vr=\"LO\" vm=\"1\">Intervention Drug Name</tag>
    <tag group=\"0018\" element=\"0035\" keyword=\"InterventionDrugStartTime\" vr=\"TM\" vm=\"1\">Intervention Drug Start Time</tag>
    <tag group=\"0018\" element=\"0036\" keyword=\"InterventionSequence\" vr=\"SQ\" vm=\"1\">Intervention Sequence</tag>
    <tag group=\"0018\" element=\"0037\" keyword=\"TherapyType\" vr=\"CS\" vm=\"1\" retired=\"true\">Therapy Type</tag>
    <tag group=\"0018\" element=\"0038\" keyword=\"InterventionStatus\" vr=\"CS\" vm=\"1\">Intervention Status</tag>
    <tag group=\"0018\" element=\"0039\" keyword=\"TherapyDescription\" vr=\"CS\" vm=\"1\" retired=\"true\">Therapy Description</tag>
    <tag group=\"0018\" element=\"003A\" keyword=\"InterventionDescription\" vr=\"ST\" vm=\"1\">Intervention Description</tag>
    <tag group=\"0018\" element=\"0040\" keyword=\"CineRate\" vr=\"IS\" vm=\"1\">Cine Rate</tag>
    <tag group=\"0018\" element=\"0042\" keyword=\"InitialCineRunState\" vr=\"CS\" vm=\"1\">Initial Cine Run State</tag>
    <tag group=\"0018\" element=\"0050\" keyword=\"SliceThickness\" vr=\"DS\" vm=\"1\">Slice Thickness</tag>
    <tag group=\"0018\" element=\"0060\" keyword=\"KVP\" vr=\"DS\" vm=\"1\">KVP</tag>
    <tag group=\"0018\" element=\"0070\" keyword=\"CountsAccumulated\" vr=\"IS\" vm=\"1\">Counts Accumulated</tag>
    <tag group=\"0018\" element=\"0071\" keyword=\"AcquisitionTerminationCondition\" vr=\"CS\" vm=\"1\">Acquisition Termination Condition</tag>
    <tag group=\"0018\" element=\"0072\" keyword=\"EffectiveDuration\" vr=\"DS\" vm=\"1\">Effective Duration</tag>
    <tag group=\"0018\" element=\"0073\" keyword=\"AcquisitionStartCondition\" vr=\"CS\" vm=\"1\">Acquisition Start Condition</tag>
    <tag group=\"0018\" element=\"0074\" keyword=\"AcquisitionStartConditionData\" vr=\"IS\" vm=\"1\">Acquisition Start Condition Data</tag>
    <tag group=\"0018\" element=\"0075\" keyword=\"AcquisitionTerminationConditionData\" vr=\"IS\" vm=\"1\">Acquisition Termination Condition Data</tag>
    <tag group=\"0018\" element=\"0080\" keyword=\"RepetitionTime\" vr=\"DS\" vm=\"1\">Repetition Time</tag>
    <tag group=\"0018\" element=\"0081\" keyword=\"EchoTime\" vr=\"DS\" vm=\"1\">Echo Time</tag>
    <tag group=\"0018\" element=\"0082\" keyword=\"InversionTime\" vr=\"DS\" vm=\"1\">Inversion Time</tag>
    <tag group=\"0018\" element=\"0083\" keyword=\"NumberOfAverages\" vr=\"DS\" vm=\"1\">Number of Averages</tag>
    <tag group=\"0018\" element=\"0084\" keyword=\"ImagingFrequency\" vr=\"DS\" vm=\"1\">Imaging Frequency</tag>
    <tag group=\"0018\" element=\"0085\" keyword=\"ImagedNucleus\" vr=\"SH\" vm=\"1\">Imaged Nucleus</tag>
    <tag group=\"0018\" element=\"0086\" keyword=\"EchoNumbers\" vr=\"IS\" vm=\"1-n\">Echo Number(s)</tag>
    <tag group=\"0018\" element=\"0087\" keyword=\"MagneticFieldStrength\" vr=\"DS\" vm=\"1\">Magnetic Field Strength</tag>
    <tag group=\"0018\" element=\"0088\" keyword=\"SpacingBetweenSlices\" vr=\"DS\" vm=\"1\">Spacing Between Slices</tag>
    <tag group=\"0018\" element=\"0089\" keyword=\"NumberOfPhaseEncodingSteps\" vr=\"IS\" vm=\"1\">Number of Phase Encoding Steps</tag>
    <tag group=\"0018\" element=\"0090\" keyword=\"DataCollectionDiameter\" vr=\"DS\" vm=\"1\">Data Collection Diameter</tag>
    <tag group=\"0018\" element=\"0091\" keyword=\"EchoTrainLength\" vr=\"IS\" vm=\"1\">Echo Train Length</tag>
    <tag group=\"0018\" element=\"0093\" keyword=\"PercentSampling\" vr=\"DS\" vm=\"1\">Percent Sampling</tag>
    <tag group=\"0018\" element=\"0094\" keyword=\"PercentPhaseFieldOfView\" vr=\"DS\" vm=\"1\">Percent Phase Field of View</tag>
    <tag group=\"0018\" element=\"0095\" keyword=\"PixelBandwidth\" vr=\"DS\" vm=\"1\">Pixel Bandwidth</tag>
    <tag group=\"0018\" element=\"1000\" keyword=\"DeviceSerialNumber\" vr=\"LO\" vm=\"1\">Device Serial Number</tag>
    <tag group=\"0018\" element=\"1002\" keyword=\"DeviceUID\" vr=\"UI\" vm=\"1\">Device UID</tag>
    <tag group=\"0018\" element=\"1003\" keyword=\"DeviceID\" vr=\"LO\" vm=\"1\">Device ID</tag>
    <tag group=\"0018\" element=\"1004\" keyword=\"PlateID\" vr=\"LO\" vm=\"1\">Plate ID</tag>
    <tag group=\"0018\" element=\"1005\" keyword=\"GeneratorID\" vr=\"LO\" vm=\"1\">Generator ID</tag>
    <tag group=\"0018\" element=\"1006\" keyword=\"GridID\" vr=\"LO\" vm=\"1\">Grid ID</tag>
    <tag group=\"0018\" element=\"1007\" keyword=\"CassetteID\" vr=\"LO\" vm=\"1\">Cassette ID</tag>
    <tag group=\"0018\" element=\"1008\" keyword=\"GantryID\" vr=\"LO\" vm=\"1\">Gantry ID</tag>
    <tag group=\"0018\" element=\"1009\" keyword=\"UniqueDeviceIdentifier\" vr=\"UT\" vm=\"1\">Unique Device Identifier</tag>
    <tag group=\"0018\" element=\"100A\" keyword=\"UDISequence\" vr=\"SQ\" vm=\"1\">UDI Sequence</tag>
    <tag group=\"0018\" element=\"1010\" keyword=\"SecondaryCaptureDeviceID\" vr=\"LO\" vm=\"1\">Secondary Capture Device ID</tag>
    <tag group=\"0018\" element=\"1011\" keyword=\"HardcopyCreationDeviceID\" vr=\"LO\" vm=\"1\" retired=\"true\">Hardcopy Creation Device ID</tag>
    <tag group=\"0018\" element=\"1012\" keyword=\"DateOfSecondaryCapture\" vr=\"DA\" vm=\"1\">Date of Secondary Capture</tag>
    <tag group=\"0018\" element=\"1014\" keyword=\"TimeOfSecondaryCapture\" vr=\"TM\" vm=\"1\">Time of Secondary Capture</tag>
    <tag group=\"0018\" element=\"1016\" keyword=\"SecondaryCaptureDeviceManufacturer\" vr=\"LO\" vm=\"1\">Secondary Capture Device Manufacturer</tag>
    <tag group=\"0018\" element=\"1017\" keyword=\"HardcopyDeviceManufacturer\" vr=\"LO\" vm=\"1\" retired=\"true\">Hardcopy Device Manufacturer</tag>
    <tag group=\"0018\" element=\"1018\" keyword=\"SecondaryCaptureDeviceManufacturerModelName\" vr=\"LO\" vm=\"1\">Secondary Capture Device Manufacturer's Model Name</tag>
    <tag group=\"0018\" element=\"1019\" keyword=\"SecondaryCaptureDeviceSoftwareVersions\" vr=\"LO\" vm=\"1-n\">Secondary Capture Device Software Versions</tag>
    <tag group=\"0018\" element=\"101A\" keyword=\"HardcopyDeviceSoftwareVersion\" vr=\"LO\" vm=\"1-n\" retired=\"true\">Hardcopy Device Software Version</tag>
    <tag group=\"0018\" element=\"101B\" keyword=\"HardcopyDeviceManufacturerModelName\" vr=\"LO\" vm=\"1\" retired=\"true\">Hardcopy Device Manufacturer's Model Name</tag>
    <tag group=\"0018\" element=\"1020\" keyword=\"SoftwareVersions\" vr=\"LO\" vm=\"1-n\">Software Version(s)</tag>
    <tag group=\"0018\" element=\"1022\" keyword=\"VideoImageFormatAcquired\" vr=\"SH\" vm=\"1\">Video Image Format Acquired</tag>
    <tag group=\"0018\" element=\"1023\" keyword=\"DigitalImageFormatAcquired\" vr=\"LO\" vm=\"1\">Digital Image Format Acquired</tag>
    <tag group=\"0018\" element=\"1030\" keyword=\"ProtocolName\" vr=\"LO\" vm=\"1\">Protocol Name</tag>
    <tag group=\"0018\" element=\"1040\" keyword=\"ContrastBolusRoute\" vr=\"LO\" vm=\"1\">Contrast/Bolus Route</tag>
    <tag group=\"0018\" element=\"1041\" keyword=\"ContrastBolusVolume\" vr=\"DS\" vm=\"1\">Contrast/Bolus Volume</tag>
    <tag group=\"0018\" element=\"1042\" keyword=\"ContrastBolusStartTime\" vr=\"TM\" vm=\"1\">Contrast/Bolus Start Time</tag>
    <tag group=\"0018\" element=\"1043\" keyword=\"ContrastBolusStopTime\" vr=\"TM\" vm=\"1\">Contrast/Bolus Stop Time</tag>
    <tag group=\"0018\" element=\"1044\" keyword=\"ContrastBolusTotalDose\" vr=\"DS\" vm=\"1\">Contrast/Bolus Total Dose</tag>
    <tag group=\"0018\" element=\"1045\" keyword=\"SyringeCounts\" vr=\"IS\" vm=\"1\">Syringe Counts</tag>
    <tag group=\"0018\" element=\"1046\" keyword=\"ContrastFlowRate\" vr=\"DS\" vm=\"1-n\">Contrast Flow Rate</tag>
    <tag group=\"0018\" element=\"1047\" keyword=\"ContrastFlowDuration\" vr=\"DS\" vm=\"1-n\">Contrast Flow Duration</tag>
    <tag group=\"0018\" element=\"1048\" keyword=\"ContrastBolusIngredient\" vr=\"CS\" vm=\"1\">Contrast/Bolus Ingredient</tag>
    <tag group=\"0018\" element=\"1049\" keyword=\"ContrastBolusIngredientConcentration\" vr=\"DS\" vm=\"1\">Contrast/Bolus Ingredient Concentration</tag>
    <tag group=\"0018\" element=\"1050\" keyword=\"SpatialResolution\" vr=\"DS\" vm=\"1\">Spatial Resolution</tag>
    <tag group=\"0018\" element=\"1060\" keyword=\"TriggerTime\" vr=\"DS\" vm=\"1\">Trigger Time</tag>
    <tag group=\"0018\" element=\"1061\" keyword=\"TriggerSourceOrType\" vr=\"LO\" vm=\"1\">Trigger Source or Type</tag>
    <tag group=\"0018\" element=\"1062\" keyword=\"NominalInterval\" vr=\"IS\" vm=\"1\">Nominal Interval</tag>
    <tag group=\"0018\" element=\"1063\" keyword=\"FrameTime\" vr=\"DS\" vm=\"1\">Frame Time</tag>
    <tag group=\"0018\" element=\"1064\" keyword=\"CardiacFramingType\" vr=\"LO\" vm=\"1\">Cardiac Framing Type</tag>
    <tag group=\"0018\" element=\"1065\" keyword=\"FrameTimeVector\" vr=\"DS\" vm=\"1-n\">Frame Time Vector</tag>
    <tag group=\"0018\" element=\"1066\" keyword=\"FrameDelay\" vr=\"DS\" vm=\"1\">Frame Delay</tag>
    <tag group=\"0018\" element=\"1067\" keyword=\"ImageTriggerDelay\" vr=\"DS\" vm=\"1\">Image Trigger Delay</tag>
    <tag group=\"0018\" element=\"1068\" keyword=\"MultiplexGroupTimeOffset\" vr=\"DS\" vm=\"1\">Multiplex Group Time Offset</tag>
    <tag group=\"0018\" element=\"1069\" keyword=\"TriggerTimeOffset\" vr=\"DS\" vm=\"1\">Trigger Time Offset</tag>
    <tag group=\"0018\" element=\"106A\" keyword=\"SynchronizationTrigger\" vr=\"CS\" vm=\"1\">Synchronization Trigger</tag>
    <tag group=\"0018\" element=\"106C\" keyword=\"SynchronizationChannel\" vr=\"US\" vm=\"2\">Synchronization Channel</tag>
    <tag group=\"0018\" element=\"106E\" keyword=\"TriggerSamplePosition\" vr=\"UL\" vm=\"1\">Trigger Sample Position</tag>
    <tag group=\"0018\" element=\"1070\" keyword=\"RadiopharmaceuticalRoute\" vr=\"LO\" vm=\"1\">Radiopharmaceutical Route</tag>
    <tag group=\"0018\" element=\"1071\" keyword=\"RadiopharmaceuticalVolume\" vr=\"DS\" vm=\"1\">Radiopharmaceutical Volume</tag>
    <tag group=\"0018\" element=\"1072\" keyword=\"RadiopharmaceuticalStartTime\" vr=\"TM\" vm=\"1\">Radiopharmaceutical Start Time</tag>
    <tag group=\"0018\" element=\"1073\" keyword=\"RadiopharmaceuticalStopTime\" vr=\"TM\" vm=\"1\">Radiopharmaceutical Stop Time</tag>
    <tag group=\"0018\" element=\"1074\" keyword=\"RadionuclideTotalDose\" vr=\"DS\" vm=\"1\">Radionuclide Total Dose</tag>
    <tag group=\"0018\" element=\"1075\" keyword=\"RadionuclideHalfLife\" vr=\"DS\" vm=\"1\">Radionuclide Half Life</tag>
    <tag group=\"0018\" element=\"1076\" keyword=\"RadionuclidePositronFraction\" vr=\"DS\" vm=\"1\">Radionuclide Positron Fraction</tag>
    <tag group=\"0018\" element=\"1077\" keyword=\"RadiopharmaceuticalSpecificActivity\" vr=\"DS\" vm=\"1\">Radiopharmaceutical Specific Activity</tag>
    <tag group=\"0018\" element=\"1078\" keyword=\"RadiopharmaceuticalStartDateTime\" vr=\"DT\" vm=\"1\">Radiopharmaceutical Start DateTime</tag>
    <tag group=\"0018\" element=\"1079\" keyword=\"RadiopharmaceuticalStopDateTime\" vr=\"DT\" vm=\"1\">Radiopharmaceutical Stop DateTime</tag>
    <tag group=\"0018\" element=\"1080\" keyword=\"BeatRejectionFlag\" vr=\"CS\" vm=\"1\">Beat Rejection Flag</tag>
    <tag group=\"0018\" element=\"1081\" keyword=\"LowRRValue\" vr=\"IS\" vm=\"1\">Low R-R Value</tag>
    <tag group=\"0018\" element=\"1082\" keyword=\"HighRRValue\" vr=\"IS\" vm=\"1\">High R-R Value</tag>
    <tag group=\"0018\" element=\"1083\" keyword=\"IntervalsAcquired\" vr=\"IS\" vm=\"1\">Intervals Acquired</tag>
    <tag group=\"0018\" element=\"1084\" keyword=\"IntervalsRejected\" vr=\"IS\" vm=\"1\">Intervals Rejected</tag>
    <tag group=\"0018\" element=\"1085\" keyword=\"PVCRejection\" vr=\"LO\" vm=\"1\">PVC Rejection</tag>
    <tag group=\"0018\" element=\"1086\" keyword=\"SkipBeats\" vr=\"IS\" vm=\"1\">Skip Beats</tag>
    <tag group=\"0018\" element=\"1088\" keyword=\"HeartRate\" vr=\"IS\" vm=\"1\">Heart Rate</tag>
    <tag group=\"0018\" element=\"1090\" keyword=\"CardiacNumberOfImages\" vr=\"IS\" vm=\"1\">Cardiac Number of Images</tag>
    <tag group=\"0018\" element=\"1094\" keyword=\"TriggerWindow\" vr=\"IS\" vm=\"1\">Trigger Window</tag>
    <tag group=\"0018\" element=\"1100\" keyword=\"ReconstructionDiameter\" vr=\"DS\" vm=\"1\">Reconstruction Diameter</tag>
    <tag group=\"0018\" element=\"1110\" keyword=\"DistanceSourceToDetector\" vr=\"DS\" vm=\"1\">Distance Source to Detector</tag>
    <tag group=\"0018\" element=\"1111\" keyword=\"DistanceSourceToPatient\" vr=\"DS\" vm=\"1\">Distance Source to Patient</tag>
    <tag group=\"0018\" element=\"1114\" keyword=\"EstimatedRadiographicMagnificationFactor\" vr=\"DS\" vm=\"1\">Estimated Radiographic Magnification Factor</tag>
    <tag group=\"0018\" element=\"1120\" keyword=\"GantryDetectorTilt\" vr=\"DS\" vm=\"1\">Gantry/Detector Tilt</tag>
    <tag group=\"0018\" element=\"1121\" keyword=\"GantryDetectorSlew\" vr=\"DS\" vm=\"1\">Gantry/Detector Slew</tag>
    <tag group=\"0018\" element=\"1130\" keyword=\"TableHeight\" vr=\"DS\" vm=\"1\">Table Height</tag>
    <tag group=\"0018\" element=\"1131\" keyword=\"TableTraverse\" vr=\"DS\" vm=\"1\">Table Traverse</tag>
    <tag group=\"0018\" element=\"1134\" keyword=\"TableMotion\" vr=\"CS\" vm=\"1\">Table Motion</tag>
    <tag group=\"0018\" element=\"1135\" keyword=\"TableVerticalIncrement\" vr=\"DS\" vm=\"1-n\">Table Vertical Increment</tag>
    <tag group=\"0018\" element=\"1136\" keyword=\"TableLateralIncrement\" vr=\"DS\" vm=\"1-n\">Table Lateral Increment</tag>
    <tag group=\"0018\" element=\"1137\" keyword=\"TableLongitudinalIncrement\" vr=\"DS\" vm=\"1-n\">Table Longitudinal Increment</tag>
    <tag group=\"0018\" element=\"1138\" keyword=\"TableAngle\" vr=\"DS\" vm=\"1\">Table Angle</tag>
    <tag group=\"0018\" element=\"113A\" keyword=\"TableType\" vr=\"CS\" vm=\"1\">Table Type</tag>
    <tag group=\"0018\" element=\"1140\" keyword=\"RotationDirection\" vr=\"CS\" vm=\"1\">Rotation Direction</tag>
    <tag group=\"0018\" element=\"1141\" keyword=\"AngularPosition\" vr=\"DS\" vm=\"1\" retired=\"true\">Angular Position</tag>
    <tag group=\"0018\" element=\"1142\" keyword=\"RadialPosition\" vr=\"DS\" vm=\"1-n\">Radial Position</tag>
    <tag group=\"0018\" element=\"1143\" keyword=\"ScanArc\" vr=\"DS\" vm=\"1\">Scan Arc</tag>
    <tag group=\"0018\" element=\"1144\" keyword=\"AngularStep\" vr=\"DS\" vm=\"1\">Angular Step</tag>
    <tag group=\"0018\" element=\"1145\" keyword=\"CenterOfRotationOffset\" vr=\"DS\" vm=\"1\">Center of Rotation Offset</tag>
    <tag group=\"0018\" element=\"1146\" keyword=\"RotationOffset\" vr=\"DS\" vm=\"1-n\" retired=\"true\">Rotation Offset</tag>
    <tag group=\"0018\" element=\"1147\" keyword=\"FieldOfViewShape\" vr=\"CS\" vm=\"1\">Field of View Shape</tag>
    <tag group=\"0018\" element=\"1149\" keyword=\"FieldOfViewDimensions\" vr=\"IS\" vm=\"1-2\">Field of View Dimension(s)</tag>
    <tag group=\"0018\" element=\"1150\" keyword=\"ExposureTime\" vr=\"IS\" vm=\"1\">Exposure Time</tag>
    <tag group=\"0018\" element=\"1151\" keyword=\"XRayTubeCurrent\" vr=\"IS\" vm=\"1\">X-Ray Tube Current</tag>
    <tag group=\"0018\" element=\"1152\" keyword=\"Exposure\" vr=\"IS\" vm=\"1\">Exposure</tag>
    <tag group=\"0018\" element=\"1153\" keyword=\"ExposureInuAs\" vr=\"IS\" vm=\"1\">Exposure in µAs</tag>
    <tag group=\"0018\" element=\"1154\" keyword=\"AveragePulseWidth\" vr=\"DS\" vm=\"1\">Average Pulse Width</tag>
    <tag group=\"0018\" element=\"1155\" keyword=\"RadiationSetting\" vr=\"CS\" vm=\"1\">Radiation Setting</tag>
    <tag group=\"0018\" element=\"1156\" keyword=\"RectificationType\" vr=\"CS\" vm=\"1\">Rectification Type</tag>
    <tag group=\"0018\" element=\"115A\" keyword=\"RadiationMode\" vr=\"CS\" vm=\"1\">Radiation Mode</tag>
    <tag group=\"0018\" element=\"115E\" keyword=\"ImageAndFluoroscopyAreaDoseProduct\" vr=\"DS\" vm=\"1\">Image and Fluoroscopy Area Dose Product</tag>
    <tag group=\"0018\" element=\"1160\" keyword=\"FilterType\" vr=\"SH\" vm=\"1\">Filter Type</tag>
    <tag group=\"0018\" element=\"1161\" keyword=\"TypeOfFilters\" vr=\"LO\" vm=\"1-n\">Type of Filters</tag>
    <tag group=\"0018\" element=\"1162\" keyword=\"IntensifierSize\" vr=\"DS\" vm=\"1\">Intensifier Size</tag>
    <tag group=\"0018\" element=\"1164\" keyword=\"ImagerPixelSpacing\" vr=\"DS\" vm=\"2\">Imager Pixel Spacing</tag>
    <tag group=\"0018\" element=\"1166\" keyword=\"Grid\" vr=\"CS\" vm=\"1-n\">Grid</tag>
    <tag group=\"0018\" element=\"1170\" keyword=\"GeneratorPower\" vr=\"IS\" vm=\"1\">Generator Power</tag>
    <tag group=\"0018\" element=\"1180\" keyword=\"CollimatorGridName\" vr=\"SH\" vm=\"1\">Collimator/grid Name</tag>
    <tag group=\"0018\" element=\"1181\" keyword=\"CollimatorType\" vr=\"CS\" vm=\"1\">Collimator Type</tag>
    <tag group=\"0018\" element=\"1182\" keyword=\"FocalDistance\" vr=\"IS\" vm=\"1-2\">Focal Distance</tag>
    <tag group=\"0018\" element=\"1183\" keyword=\"XFocusCenter\" vr=\"DS\" vm=\"1-2\">X Focus Center</tag>
    <tag group=\"0018\" element=\"1184\" keyword=\"YFocusCenter\" vr=\"DS\" vm=\"1-2\">Y Focus Center</tag>
    <tag group=\"0018\" element=\"1190\" keyword=\"FocalSpots\" vr=\"DS\" vm=\"1-n\">Focal Spot(s)</tag>
    <tag group=\"0018\" element=\"1191\" keyword=\"AnodeTargetMaterial\" vr=\"CS\" vm=\"1\">Anode Target Material</tag>
    <tag group=\"0018\" element=\"11A0\" keyword=\"BodyPartThickness\" vr=\"DS\" vm=\"1\">Body Part Thickness</tag>
    <tag group=\"0018\" element=\"11A2\" keyword=\"CompressionForce\" vr=\"DS\" vm=\"1\">Compression Force</tag>
    <tag group=\"0018\" element=\"11A4\" keyword=\"PaddleDescription\" vr=\"LO\" vm=\"1\">Paddle Description</tag>
    <tag group=\"0018\" element=\"1200\" keyword=\"DateOfLastCalibration\" vr=\"DA\" vm=\"1-n\">Date of Last Calibration</tag>
    <tag group=\"0018\" element=\"1201\" keyword=\"TimeOfLastCalibration\" vr=\"TM\" vm=\"1-n\">Time of Last Calibration</tag>
    <tag group=\"0018\" element=\"1202\" keyword=\"DateTimeOfLastCalibration\" vr=\"DT\" vm=\"1\">DateTime of Last Calibration</tag>
    <tag group=\"0018\" element=\"1210\" keyword=\"ConvolutionKernel\" vr=\"SH\" vm=\"1-n\">Convolution Kernel</tag>
    <tag group=\"0018\" element=\"1240\" keyword=\"UpperLowerPixelValues\" vr=\"IS\" vm=\"1-n\" retired=\"true\">Upper/Lower Pixel Values</tag>
    <tag group=\"0018\" element=\"1242\" keyword=\"ActualFrameDuration\" vr=\"IS\" vm=\"1\">Actual Frame Duration</tag>
    <tag group=\"0018\" element=\"1243\" keyword=\"CountRate\" vr=\"IS\" vm=\"1\">Count Rate</tag>
    <tag group=\"0018\" element=\"1244\" keyword=\"PreferredPlaybackSequencing\" vr=\"US\" vm=\"1\">Preferred Playback Sequencing</tag>
    <tag group=\"0018\" element=\"1250\" keyword=\"ReceiveCoilName\" vr=\"SH\" vm=\"1\">Receive Coil Name</tag>
    <tag group=\"0018\" element=\"1251\" keyword=\"TransmitCoilName\" vr=\"SH\" vm=\"1\">Transmit Coil Name</tag>
    <tag group=\"0018\" element=\"1260\" keyword=\"PlateType\" vr=\"SH\" vm=\"1\">Plate Type</tag>
    <tag group=\"0018\" element=\"1261\" keyword=\"PhosphorType\" vr=\"LO\" vm=\"1\">Phosphor Type</tag>
    <tag group=\"0018\" element=\"1271\" keyword=\"WaterEquivalentDiameter\" vr=\"FD\" vm=\"1\">Water Equivalent Diameter</tag>
    <tag group=\"0018\" element=\"1272\" keyword=\"WaterEquivalentDiameterCalculationMethodCodeSequence\" vr=\"SQ\" vm=\"1\">Water Equivalent Diameter Calculation Method Code Sequence</tag>
    <tag group=\"0018\" element=\"1300\" keyword=\"ScanVelocity\" vr=\"DS\" vm=\"1\">Scan Velocity</tag>
    <tag group=\"0018\" element=\"1301\" keyword=\"WholeBodyTechnique\" vr=\"CS\" vm=\"1-n\">Whole Body Technique</tag>
    <tag group=\"0018\" element=\"1302\" keyword=\"ScanLength\" vr=\"IS\" vm=\"1\">Scan Length</tag>
    <tag group=\"0018\" element=\"1310\" keyword=\"AcquisitionMatrix\" vr=\"US\" vm=\"4\">Acquisition Matrix</tag>
    <tag group=\"0018\" element=\"1312\" keyword=\"InPlanePhaseEncodingDirection\" vr=\"CS\" vm=\"1\">In-plane Phase Encoding Direction</tag>
    <tag group=\"0018\" element=\"1314\" keyword=\"FlipAngle\" vr=\"DS\" vm=\"1\">Flip Angle</tag>
    <tag group=\"0018\" element=\"1315\" keyword=\"VariableFlipAngleFlag\" vr=\"CS\" vm=\"1\">Variable Flip Angle Flag</tag>
    <tag group=\"0018\" element=\"1316\" keyword=\"SAR\" vr=\"DS\" vm=\"1\">SAR</tag>
    <tag group=\"0018\" element=\"1318\" keyword=\"dBdt\" vr=\"DS\" vm=\"1\">dB/dt</tag>
    <tag group=\"0018\" element=\"1320\" keyword=\"B1rms\" vr=\"FL\" vm=\"1\">B1rms</tag>
    <tag group=\"0018\" element=\"1400\" keyword=\"AcquisitionDeviceProcessingDescription\" vr=\"LO\" vm=\"1\">Acquisition Device Processing Description</tag>
    <tag group=\"0018\" element=\"1401\" keyword=\"AcquisitionDeviceProcessingCode\" vr=\"LO\" vm=\"1\">Acquisition Device Processing Code</tag>
    <tag group=\"0018\" element=\"1402\" keyword=\"CassetteOrientation\" vr=\"CS\" vm=\"1\">Cassette Orientation</tag>
    <tag group=\"0018\" element=\"1403\" keyword=\"CassetteSize\" vr=\"CS\" vm=\"1\">Cassette Size</tag>
    <tag group=\"0018\" element=\"1404\" keyword=\"ExposuresOnPlate\" vr=\"US\" vm=\"1\">Exposures on Plate</tag>
    <tag group=\"0018\" element=\"1405\" keyword=\"RelativeXRayExposure\" vr=\"IS\" vm=\"1\">Relative X-Ray Exposure</tag>
    <tag group=\"0018\" element=\"1411\" keyword=\"ExposureIndex\" vr=\"DS\" vm=\"1\">Exposure Index</tag>
    <tag group=\"0018\" element=\"1412\" keyword=\"TargetExposureIndex\" vr=\"DS\" vm=\"1\">Target Exposure Index</tag>
    <tag group=\"0018\" element=\"1413\" keyword=\"DeviationIndex\" vr=\"DS\" vm=\"1\">Deviation Index</tag>
    <tag group=\"0018\" element=\"1450\" keyword=\"ColumnAngulation\" vr=\"DS\" vm=\"1\">Column Angulation</tag>
    <tag group=\"0018\" element=\"1460\" keyword=\"TomoLayerHeight\" vr=\"DS\" vm=\"1\">Tomo Layer Height</tag>
    <tag group=\"0018\" element=\"1470\" keyword=\"TomoAngle\" vr=\"DS\" vm=\"1\">Tomo Angle</tag>
    <tag group=\"0018\" element=\"1480\" keyword=\"TomoTime\" vr=\"DS\" vm=\"1\">Tomo Time</tag>
    <tag group=\"0018\" element=\"1490\" keyword=\"TomoType\" vr=\"CS\" vm=\"1\">Tomo Type</tag>
    <tag group=\"0018\" element=\"1491\" keyword=\"TomoClass\" vr=\"CS\" vm=\"1\">Tomo Class</tag>
    <tag group=\"0018\" element=\"1495\" keyword=\"NumberOfTomosynthesisSourceImages\" vr=\"IS\" vm=\"1\">Number of Tomosynthesis Source Images</tag>
    <tag group=\"0018\" element=\"1500\" keyword=\"PositionerMotion\" vr=\"CS\" vm=\"1\">Positioner Motion</tag>
    <tag group=\"0018\" element=\"1508\" keyword=\"PositionerType\" vr=\"CS\" vm=\"1\">Positioner Type</tag>
    <tag group=\"0018\" element=\"1510\" keyword=\"PositionerPrimaryAngle\" vr=\"DS\" vm=\"1\">Positioner Primary Angle</tag>
    <tag group=\"0018\" element=\"1511\" keyword=\"PositionerSecondaryAngle\" vr=\"DS\" vm=\"1\">Positioner Secondary Angle</tag>
    <tag group=\"0018\" element=\"1520\" keyword=\"PositionerPrimaryAngleIncrement\" vr=\"DS\" vm=\"1-n\">Positioner Primary Angle Increment</tag>
    <tag group=\"0018\" element=\"1521\" keyword=\"PositionerSecondaryAngleIncrement\" vr=\"DS\" vm=\"1-n\">Positioner Secondary Angle Increment</tag>
    <tag group=\"0018\" element=\"1530\" keyword=\"DetectorPrimaryAngle\" vr=\"DS\" vm=\"1\">Detector Primary Angle</tag>
    <tag group=\"0018\" element=\"1531\" keyword=\"DetectorSecondaryAngle\" vr=\"DS\" vm=\"1\">Detector Secondary Angle</tag>
    <tag group=\"0018\" element=\"1600\" keyword=\"ShutterShape\" vr=\"CS\" vm=\"1-3\">Shutter Shape</tag>
    <tag group=\"0018\" element=\"1602\" keyword=\"ShutterLeftVerticalEdge\" vr=\"IS\" vm=\"1\">Shutter Left Vertical Edge</tag>
    <tag group=\"0018\" element=\"1604\" keyword=\"ShutterRightVerticalEdge\" vr=\"IS\" vm=\"1\">Shutter Right Vertical Edge</tag>
    <tag group=\"0018\" element=\"1606\" keyword=\"ShutterUpperHorizontalEdge\" vr=\"IS\" vm=\"1\">Shutter Upper Horizontal Edge</tag>
    <tag group=\"0018\" element=\"1608\" keyword=\"ShutterLowerHorizontalEdge\" vr=\"IS\" vm=\"1\">Shutter Lower Horizontal Edge</tag>
    <tag group=\"0018\" element=\"1610\" keyword=\"CenterOfCircularShutter\" vr=\"IS\" vm=\"2\">Center of Circular Shutter</tag>
    <tag group=\"0018\" element=\"1612\" keyword=\"RadiusOfCircularShutter\" vr=\"IS\" vm=\"1\">Radius of Circular Shutter</tag>
    <tag group=\"0018\" element=\"1620\" keyword=\"VerticesOfThePolygonalShutter\" vr=\"IS\" vm=\"2-2n\">Vertices of the Polygonal Shutter</tag>
    <tag group=\"0018\" element=\"1622\" keyword=\"ShutterPresentationValue\" vr=\"US\" vm=\"1\">Shutter Presentation Value</tag>
    <tag group=\"0018\" element=\"1623\" keyword=\"ShutterOverlayGroup\" vr=\"US\" vm=\"1\">Shutter Overlay Group</tag>
    <tag group=\"0018\" element=\"1624\" keyword=\"ShutterPresentationColorCIELabValue\" vr=\"US\" vm=\"3\">Shutter Presentation Color CIELab Value</tag>
    <tag group=\"0018\" element=\"1700\" keyword=\"CollimatorShape\" vr=\"CS\" vm=\"1-3\">Collimator Shape</tag>
    <tag group=\"0018\" element=\"1702\" keyword=\"CollimatorLeftVerticalEdge\" vr=\"IS\" vm=\"1\">Collimator Left Vertical Edge</tag>
    <tag group=\"0018\" element=\"1704\" keyword=\"CollimatorRightVerticalEdge\" vr=\"IS\" vm=\"1\">Collimator Right Vertical Edge</tag>
    <tag group=\"0018\" element=\"1706\" keyword=\"CollimatorUpperHorizontalEdge\" vr=\"IS\" vm=\"1\">Collimator Upper Horizontal Edge</tag>
    <tag group=\"0018\" element=\"1708\" keyword=\"CollimatorLowerHorizontalEdge\" vr=\"IS\" vm=\"1\">Collimator Lower Horizontal Edge</tag>
    <tag group=\"0018\" element=\"1710\" keyword=\"CenterOfCircularCollimator\" vr=\"IS\" vm=\"2\">Center of Circular Collimator</tag>
    <tag group=\"0018\" element=\"1712\" keyword=\"RadiusOfCircularCollimator\" vr=\"IS\" vm=\"1\">Radius of Circular Collimator</tag>
    <tag group=\"0018\" element=\"1720\" keyword=\"VerticesOfThePolygonalCollimator\" vr=\"IS\" vm=\"2-2n\">Vertices of the Polygonal Collimator</tag>
    <tag group=\"0018\" element=\"1800\" keyword=\"AcquisitionTimeSynchronized\" vr=\"CS\" vm=\"1\">Acquisition Time Synchronized</tag>
    <tag group=\"0018\" element=\"1801\" keyword=\"TimeSource\" vr=\"SH\" vm=\"1\">Time Source</tag>
    <tag group=\"0018\" element=\"1802\" keyword=\"TimeDistributionProtocol\" vr=\"CS\" vm=\"1\">Time Distribution Protocol</tag>
    <tag group=\"0018\" element=\"1803\" keyword=\"NTPSourceAddress\" vr=\"LO\" vm=\"1\">NTP Source Address</tag>
    <tag group=\"0018\" element=\"2001\" keyword=\"PageNumberVector\" vr=\"IS\" vm=\"1-n\">Page Number Vector</tag>
    <tag group=\"0018\" element=\"2002\" keyword=\"FrameLabelVector\" vr=\"SH\" vm=\"1-n\">Frame Label Vector</tag>
    <tag group=\"0018\" element=\"2003\" keyword=\"FramePrimaryAngleVector\" vr=\"DS\" vm=\"1-n\">Frame Primary Angle Vector</tag>
    <tag group=\"0018\" element=\"2004\" keyword=\"FrameSecondaryAngleVector\" vr=\"DS\" vm=\"1-n\">Frame Secondary Angle Vector</tag>
    <tag group=\"0018\" element=\"2005\" keyword=\"SliceLocationVector\" vr=\"DS\" vm=\"1-n\">Slice Location Vector</tag>
    <tag group=\"0018\" element=\"2006\" keyword=\"DisplayWindowLabelVector\" vr=\"SH\" vm=\"1-n\">Display Window Label Vector</tag>
    <tag group=\"0018\" element=\"2010\" keyword=\"NominalScannedPixelSpacing\" vr=\"DS\" vm=\"2\">Nominal Scanned Pixel Spacing</tag>
    <tag group=\"0018\" element=\"2020\" keyword=\"DigitizingDeviceTransportDirection\" vr=\"CS\" vm=\"1\">Digitizing Device Transport Direction</tag>
    <tag group=\"0018\" element=\"2030\" keyword=\"RotationOfScannedFilm\" vr=\"DS\" vm=\"1\">Rotation of Scanned Film</tag>
    <tag group=\"0018\" element=\"2041\" keyword=\"BiopsyTargetSequence\" vr=\"SQ\" vm=\"1\">Biopsy Target Sequence</tag>
    <tag group=\"0018\" element=\"2042\" keyword=\"TargetUID\" vr=\"UI\" vm=\"1\">Target UID</tag>
    <tag group=\"0018\" element=\"2043\" keyword=\"LocalizingCursorPosition\" vr=\"FL\" vm=\"2\">Localizing Cursor Position</tag>
    <tag group=\"0018\" element=\"2044\" keyword=\"CalculatedTargetPosition\" vr=\"FL\" vm=\"3\">Calculated Target Position</tag>
    <tag group=\"0018\" element=\"2045\" keyword=\"TargetLabel\" vr=\"SH\" vm=\"1\">Target Label</tag>
    <tag group=\"0018\" element=\"2046\" keyword=\"DisplayedZValue\" vr=\"FL\" vm=\"1\">Displayed Z Value</tag>
    <tag group=\"0018\" element=\"3100\" keyword=\"IVUSAcquisition\" vr=\"CS\" vm=\"1\">IVUS Acquisition</tag>
    <tag group=\"0018\" element=\"3101\" keyword=\"IVUSPullbackRate\" vr=\"DS\" vm=\"1\">IVUS Pullback Rate</tag>
    <tag group=\"0018\" element=\"3102\" keyword=\"IVUSGatedRate\" vr=\"DS\" vm=\"1\">IVUS Gated Rate</tag>
    <tag group=\"0018\" element=\"3103\" keyword=\"IVUSPullbackStartFrameNumber\" vr=\"IS\" vm=\"1\">IVUS Pullback Start Frame Number</tag>
    <tag group=\"0018\" element=\"3104\" keyword=\"IVUSPullbackStopFrameNumber\" vr=\"IS\" vm=\"1\">IVUS Pullback Stop Frame Number</tag>
    <tag group=\"0018\" element=\"3105\" keyword=\"LesionNumber\" vr=\"IS\" vm=\"1-n\">Lesion Number</tag>
    <tag group=\"0018\" element=\"4000\" keyword=\"AcquisitionComments\" vr=\"LT\" vm=\"1\" retired=\"true\">Acquisition Comments</tag>
    <tag group=\"0018\" element=\"5000\" keyword=\"OutputPower\" vr=\"SH\" vm=\"1-n\">Output Power</tag>
    <tag group=\"0018\" element=\"5010\" keyword=\"TransducerData\" vr=\"LO\" vm=\"1-n\">Transducer Data</tag>
    <tag group=\"0018\" element=\"5012\" keyword=\"FocusDepth\" vr=\"DS\" vm=\"1\">Focus Depth</tag>
    <tag group=\"0018\" element=\"5020\" keyword=\"ProcessingFunction\" vr=\"LO\" vm=\"1\">Processing Function</tag>
    <tag group=\"0018\" element=\"5021\" keyword=\"PostprocessingFunction\" vr=\"LO\" vm=\"1\" retired=\"true\">Postprocessing Function</tag>
    <tag group=\"0018\" element=\"5022\" keyword=\"MechanicalIndex\" vr=\"DS\" vm=\"1\">Mechanical Index</tag>
    <tag group=\"0018\" element=\"5024\" keyword=\"BoneThermalIndex\" vr=\"DS\" vm=\"1\">Bone Thermal Index</tag>
    <tag group=\"0018\" element=\"5026\" keyword=\"CranialThermalIndex\" vr=\"DS\" vm=\"1\">Cranial Thermal Index</tag>
    <tag group=\"0018\" element=\"5027\" keyword=\"SoftTissueThermalIndex\" vr=\"DS\" vm=\"1\">Soft Tissue Thermal Index</tag>
    <tag group=\"0018\" element=\"5028\" keyword=\"SoftTissueFocusThermalIndex\" vr=\"DS\" vm=\"1\">Soft Tissue-focus Thermal Index</tag>
    <tag group=\"0018\" element=\"5029\" keyword=\"SoftTissueSurfaceThermalIndex\" vr=\"DS\" vm=\"1\">Soft Tissue-surface Thermal Index</tag>
    <tag group=\"0018\" element=\"5030\" keyword=\"DynamicRange\" vr=\"DS\" vm=\"1\" retired=\"true\">Dynamic Range</tag>
    <tag group=\"0018\" element=\"5040\" keyword=\"TotalGain\" vr=\"DS\" vm=\"1\" retired=\"true\">Total Gain</tag>
    <tag group=\"0018\" element=\"5050\" keyword=\"DepthOfScanField\" vr=\"IS\" vm=\"1\">Depth of Scan Field</tag>
    <tag group=\"0018\" element=\"5100\" keyword=\"PatientPosition\" vr=\"CS\" vm=\"1\">Patient Position</tag>
    <tag group=\"0018\" element=\"5101\" keyword=\"ViewPosition\" vr=\"CS\" vm=\"1\">View Position</tag>
    <tag group=\"0018\" element=\"5104\" keyword=\"ProjectionEponymousNameCodeSequence\" vr=\"SQ\" vm=\"1\">Projection Eponymous Name Code Sequence</tag>
    <tag group=\"0018\" element=\"5210\" keyword=\"ImageTransformationMatrix\" vr=\"DS\" vm=\"6\" retired=\"true\">Image Transformation Matrix</tag>
    <tag group=\"0018\" element=\"5212\" keyword=\"ImageTranslationVector\" vr=\"DS\" vm=\"3\" retired=\"true\">Image Translation Vector</tag>
    <tag group=\"0018\" element=\"6000\" keyword=\"Sensitivity\" vr=\"DS\" vm=\"1\">Sensitivity</tag>
    <tag group=\"0018\" element=\"6011\" keyword=\"SequenceOfUltrasoundRegions\" vr=\"SQ\" vm=\"1\">Sequence of Ultrasound Regions</tag>
    <tag group=\"0018\" element=\"6012\" keyword=\"RegionSpatialFormat\" vr=\"US\" vm=\"1\">Region Spatial Format</tag>
    <tag group=\"0018\" element=\"6014\" keyword=\"RegionDataType\" vr=\"US\" vm=\"1\">Region Data Type</tag>
    <tag group=\"0018\" element=\"6016\" keyword=\"RegionFlags\" vr=\"UL\" vm=\"1\">Region Flags</tag>
    <tag group=\"0018\" element=\"6018\" keyword=\"RegionLocationMinX0\" vr=\"UL\" vm=\"1\">Region Location Min X0</tag>
    <tag group=\"0018\" element=\"601A\" keyword=\"RegionLocationMinY0\" vr=\"UL\" vm=\"1\">Region Location Min Y0</tag>
    <tag group=\"0018\" element=\"601C\" keyword=\"RegionLocationMaxX1\" vr=\"UL\" vm=\"1\">Region Location Max X1</tag>
    <tag group=\"0018\" element=\"601E\" keyword=\"RegionLocationMaxY1\" vr=\"UL\" vm=\"1\">Region Location Max Y1</tag>
    <tag group=\"0018\" element=\"6020\" keyword=\"ReferencePixelX0\" vr=\"SL\" vm=\"1\">Reference Pixel X0</tag>
    <tag group=\"0018\" element=\"6022\" keyword=\"ReferencePixelY0\" vr=\"SL\" vm=\"1\">Reference Pixel Y0</tag>
    <tag group=\"0018\" element=\"6024\" keyword=\"PhysicalUnitsXDirection\" vr=\"US\" vm=\"1\">Physical Units X Direction</tag>
    <tag group=\"0018\" element=\"6026\" keyword=\"PhysicalUnitsYDirection\" vr=\"US\" vm=\"1\">Physical Units Y Direction</tag>
    <tag group=\"0018\" element=\"6028\" keyword=\"ReferencePixelPhysicalValueX\" vr=\"FD\" vm=\"1\">Reference Pixel Physical Value X</tag>
    <tag group=\"0018\" element=\"602A\" keyword=\"ReferencePixelPhysicalValueY\" vr=\"FD\" vm=\"1\">Reference Pixel Physical Value Y</tag>
    <tag group=\"0018\" element=\"602C\" keyword=\"PhysicalDeltaX\" vr=\"FD\" vm=\"1\">Physical Delta X</tag>
    <tag group=\"0018\" element=\"602E\" keyword=\"PhysicalDeltaY\" vr=\"FD\" vm=\"1\">Physical Delta Y</tag>
    <tag group=\"0018\" element=\"6030\" keyword=\"TransducerFrequency\" vr=\"UL\" vm=\"1\">Transducer Frequency</tag>
    <tag group=\"0018\" element=\"6031\" keyword=\"TransducerType\" vr=\"CS\" vm=\"1\">Transducer Type</tag>
    <tag group=\"0018\" element=\"6032\" keyword=\"PulseRepetitionFrequency\" vr=\"UL\" vm=\"1\">Pulse Repetition Frequency</tag>
    <tag group=\"0018\" element=\"6034\" keyword=\"DopplerCorrectionAngle\" vr=\"FD\" vm=\"1\">Doppler Correction Angle</tag>
    <tag group=\"0018\" element=\"6036\" keyword=\"SteeringAngle\" vr=\"FD\" vm=\"1\">Steering Angle</tag>
    <tag group=\"0018\" element=\"6038\" keyword=\"DopplerSampleVolumeXPositionRetired\" vr=\"UL\" vm=\"1\" retired=\"true\">Doppler Sample Volume X Position (Retired)</tag>
    <tag group=\"0018\" element=\"6039\" keyword=\"DopplerSampleVolumeXPosition\" vr=\"SL\" vm=\"1\">Doppler Sample Volume X Position</tag>
    <tag group=\"0018\" element=\"603A\" keyword=\"DopplerSampleVolumeYPositionRetired\" vr=\"UL\" vm=\"1\" retired=\"true\">Doppler Sample Volume Y Position (Retired)</tag>
    <tag group=\"0018\" element=\"603B\" keyword=\"DopplerSampleVolumeYPosition\" vr=\"SL\" vm=\"1\">Doppler Sample Volume Y Position</tag>
    <tag group=\"0018\" element=\"603C\" keyword=\"TMLinePositionX0Retired\" vr=\"UL\" vm=\"1\" retired=\"true\">TM-Line Position X0 (Retired)</tag>
    <tag group=\"0018\" element=\"603D\" keyword=\"TMLinePositionX0\" vr=\"SL\" vm=\"1\">TM-Line Position X0</tag>
    <tag group=\"0018\" element=\"603E\" keyword=\"TMLinePositionY0Retired\" vr=\"UL\" vm=\"1\" retired=\"true\">TM-Line Position Y0 (Retired)</tag>
    <tag group=\"0018\" element=\"603F\" keyword=\"TMLinePositionY0\" vr=\"SL\" vm=\"1\">TM-Line Position Y0</tag>
    <tag group=\"0018\" element=\"6040\" keyword=\"TMLinePositionX1Retired\" vr=\"UL\" vm=\"1\" retired=\"true\">TM-Line Position X1 (Retired)</tag>
    <tag group=\"0018\" element=\"6041\" keyword=\"TMLinePositionX1\" vr=\"SL\" vm=\"1\">TM-Line Position X1</tag>
    <tag group=\"0018\" element=\"6042\" keyword=\"TMLinePositionY1Retired\" vr=\"UL\" vm=\"1\" retired=\"true\">TM-Line Position Y1 (Retired)</tag>
    <tag group=\"0018\" element=\"6043\" keyword=\"TMLinePositionY1\" vr=\"SL\" vm=\"1\">TM-Line Position Y1</tag>
    <tag group=\"0018\" element=\"6044\" keyword=\"PixelComponentOrganization\" vr=\"US\" vm=\"1\">Pixel Component Organization</tag>
    <tag group=\"0018\" element=\"6046\" keyword=\"PixelComponentMask\" vr=\"UL\" vm=\"1\">Pixel Component Mask</tag>
    <tag group=\"0018\" element=\"6048\" keyword=\"PixelComponentRangeStart\" vr=\"UL\" vm=\"1\">Pixel Component Range Start</tag>
    <tag group=\"0018\" element=\"604A\" keyword=\"PixelComponentRangeStop\" vr=\"UL\" vm=\"1\">Pixel Component Range Stop</tag>
    <tag group=\"0018\" element=\"604C\" keyword=\"PixelComponentPhysicalUnits\" vr=\"US\" vm=\"1\">Pixel Component Physical Units</tag>
    <tag group=\"0018\" element=\"604E\" keyword=\"PixelComponentDataType\" vr=\"US\" vm=\"1\">Pixel Component Data Type</tag>
    <tag group=\"0018\" element=\"6050\" keyword=\"NumberOfTableBreakPoints\" vr=\"UL\" vm=\"1\">Number of Table Break Points</tag>
    <tag group=\"0018\" element=\"6052\" keyword=\"TableOfXBreakPoints\" vr=\"UL\" vm=\"1-n\">Table of X Break Points</tag>
    <tag group=\"0018\" element=\"6054\" keyword=\"TableOfYBreakPoints\" vr=\"FD\" vm=\"1-n\">Table of Y Break Points</tag>
    <tag group=\"0018\" element=\"6056\" keyword=\"NumberOfTableEntries\" vr=\"UL\" vm=\"1\">Number of Table Entries</tag>
    <tag group=\"0018\" element=\"6058\" keyword=\"TableOfPixelValues\" vr=\"UL\" vm=\"1-n\">Table of Pixel Values</tag>
    <tag group=\"0018\" element=\"605A\" keyword=\"TableOfParameterValues\" vr=\"FL\" vm=\"1-n\">Table of Parameter Values</tag>
    <tag group=\"0018\" element=\"6060\" keyword=\"RWaveTimeVector\" vr=\"FL\" vm=\"1-n\">R Wave Time Vector</tag>
    <tag group=\"0018\" element=\"7000\" keyword=\"DetectorConditionsNominalFlag\" vr=\"CS\" vm=\"1\">Detector Conditions Nominal Flag</tag>
    <tag group=\"0018\" element=\"7001\" keyword=\"DetectorTemperature\" vr=\"DS\" vm=\"1\">Detector Temperature</tag>
    <tag group=\"0018\" element=\"7004\" keyword=\"DetectorType\" vr=\"CS\" vm=\"1\">Detector Type</tag>
    <tag group=\"0018\" element=\"7005\" keyword=\"DetectorConfiguration\" vr=\"CS\" vm=\"1\">Detector Configuration</tag>
    <tag group=\"0018\" element=\"7006\" keyword=\"DetectorDescription\" vr=\"LT\" vm=\"1\">Detector Description</tag>
    <tag group=\"0018\" element=\"7008\" keyword=\"DetectorMode\" vr=\"LT\" vm=\"1\">Detector Mode</tag>
    <tag group=\"0018\" element=\"700A\" keyword=\"DetectorID\" vr=\"SH\" vm=\"1\">Detector ID</tag>
    <tag group=\"0018\" element=\"700C\" keyword=\"DateOfLastDetectorCalibration\" vr=\"DA\" vm=\"1\">Date of Last Detector Calibration</tag>
    <tag group=\"0018\" element=\"700E\" keyword=\"TimeOfLastDetectorCalibration\" vr=\"TM\" vm=\"1\">Time of Last Detector Calibration</tag>
    <tag group=\"0018\" element=\"7010\" keyword=\"ExposuresOnDetectorSinceLastCalibration\" vr=\"IS\" vm=\"1\">Exposures on Detector Since Last Calibration</tag>
    <tag group=\"0018\" element=\"7011\" keyword=\"ExposuresOnDetectorSinceManufactured\" vr=\"IS\" vm=\"1\">Exposures on Detector Since Manufactured</tag>
    <tag group=\"0018\" element=\"7012\" keyword=\"DetectorTimeSinceLastExposure\" vr=\"DS\" vm=\"1\">Detector Time Since Last Exposure</tag>
    <tag group=\"0018\" element=\"7014\" keyword=\"DetectorActiveTime\" vr=\"DS\" vm=\"1\">Detector Active Time</tag>
    <tag group=\"0018\" element=\"7016\" keyword=\"DetectorActivationOffsetFromExposure\" vr=\"DS\" vm=\"1\">Detector Activation Offset From Exposure</tag>
    <tag group=\"0018\" element=\"701A\" keyword=\"DetectorBinning\" vr=\"DS\" vm=\"2\">Detector Binning</tag>
    <tag group=\"0018\" element=\"7020\" keyword=\"DetectorElementPhysicalSize\" vr=\"DS\" vm=\"2\">Detector Element Physical Size</tag>
    <tag group=\"0018\" element=\"7022\" keyword=\"DetectorElementSpacing\" vr=\"DS\" vm=\"2\">Detector Element Spacing</tag>
    <tag group=\"0018\" element=\"7024\" keyword=\"DetectorActiveShape\" vr=\"CS\" vm=\"1\">Detector Active Shape</tag>
    <tag group=\"0018\" element=\"7026\" keyword=\"DetectorActiveDimensions\" vr=\"DS\" vm=\"1-2\">Detector Active Dimension(s)</tag>
    <tag group=\"0018\" element=\"7028\" keyword=\"DetectorActiveOrigin\" vr=\"DS\" vm=\"2\">Detector Active Origin</tag>
    <tag group=\"0018\" element=\"702A\" keyword=\"DetectorManufacturerName\" vr=\"LO\" vm=\"1\">Detector Manufacturer Name</tag>
    <tag group=\"0018\" element=\"702B\" keyword=\"DetectorManufacturerModelName\" vr=\"LO\" vm=\"1\">Detector Manufacturer's Model Name</tag>
    <tag group=\"0018\" element=\"7030\" keyword=\"FieldOfViewOrigin\" vr=\"DS\" vm=\"2\">Field of View Origin</tag>
    <tag group=\"0018\" element=\"7032\" keyword=\"FieldOfViewRotation\" vr=\"DS\" vm=\"1\">Field of View Rotation</tag>
    <tag group=\"0018\" element=\"7034\" keyword=\"FieldOfViewHorizontalFlip\" vr=\"CS\" vm=\"1\">Field of View Horizontal Flip</tag>
    <tag group=\"0018\" element=\"7036\" keyword=\"PixelDataAreaOriginRelativeToFOV\" vr=\"FL\" vm=\"2\">Pixel Data Area Origin Relative To FOV</tag>
    <tag group=\"0018\" element=\"7038\" keyword=\"PixelDataAreaRotationAngleRelativeToFOV\" vr=\"FL\" vm=\"1\">Pixel Data Area Rotation Angle Relative To FOV</tag>
    <tag group=\"0018\" element=\"7040\" keyword=\"GridAbsorbingMaterial\" vr=\"LT\" vm=\"1\">Grid Absorbing Material</tag>
    <tag group=\"0018\" element=\"7041\" keyword=\"GridSpacingMaterial\" vr=\"LT\" vm=\"1\">Grid Spacing Material</tag>
    <tag group=\"0018\" element=\"7042\" keyword=\"GridThickness\" vr=\"DS\" vm=\"1\">Grid Thickness</tag>
    <tag group=\"0018\" element=\"7044\" keyword=\"GridPitch\" vr=\"DS\" vm=\"1\">Grid Pitch</tag>
    <tag group=\"0018\" element=\"7046\" keyword=\"GridAspectRatio\" vr=\"IS\" vm=\"2\">Grid Aspect Ratio</tag>
    <tag group=\"0018\" element=\"7048\" keyword=\"GridPeriod\" vr=\"DS\" vm=\"1\">Grid Period</tag>
    <tag group=\"0018\" element=\"704C\" keyword=\"GridFocalDistance\" vr=\"DS\" vm=\"1\">Grid Focal Distance</tag>
    <tag group=\"0018\" element=\"7050\" keyword=\"FilterMaterial\" vr=\"CS\" vm=\"1-n\">Filter Material</tag>
    <tag group=\"0018\" element=\"7052\" keyword=\"FilterThicknessMinimum\" vr=\"DS\" vm=\"1-n\">Filter Thickness Minimum</tag>
    <tag group=\"0018\" element=\"7054\" keyword=\"FilterThicknessMaximum\" vr=\"DS\" vm=\"1-n\">Filter Thickness Maximum</tag>
    <tag group=\"0018\" element=\"7056\" keyword=\"FilterBeamPathLengthMinimum\" vr=\"FL\" vm=\"1-n\">Filter Beam Path Length Minimum</tag>
    <tag group=\"0018\" element=\"7058\" keyword=\"FilterBeamPathLengthMaximum\" vr=\"FL\" vm=\"1-n\">Filter Beam Path Length Maximum</tag>
    <tag group=\"0018\" element=\"7060\" keyword=\"ExposureControlMode\" vr=\"CS\" vm=\"1\">Exposure Control Mode</tag>
    <tag group=\"0018\" element=\"7062\" keyword=\"ExposureControlModeDescription\" vr=\"LT\" vm=\"1\">Exposure Control Mode Description</tag>
    <tag group=\"0018\" element=\"7064\" keyword=\"ExposureStatus\" vr=\"CS\" vm=\"1\">Exposure Status</tag>
    <tag group=\"0018\" element=\"7065\" keyword=\"PhototimerSetting\" vr=\"DS\" vm=\"1\">Phototimer Setting</tag>
    <tag group=\"0018\" element=\"8150\" keyword=\"ExposureTimeInuS\" vr=\"DS\" vm=\"1\">Exposure Time in µS</tag>
    <tag group=\"0018\" element=\"8151\" keyword=\"XRayTubeCurrentInuA\" vr=\"DS\" vm=\"1\">X-Ray Tube Current in µA</tag>
    <tag group=\"0018\" element=\"9004\" keyword=\"ContentQualification\" vr=\"CS\" vm=\"1\">Content Qualification</tag>
    <tag group=\"0018\" element=\"9005\" keyword=\"PulseSequenceName\" vr=\"SH\" vm=\"1\">Pulse Sequence Name</tag>
    <tag group=\"0018\" element=\"9006\" keyword=\"MRImagingModifierSequence\" vr=\"SQ\" vm=\"1\">MR Imaging Modifier Sequence</tag>
    <tag group=\"0018\" element=\"9008\" keyword=\"EchoPulseSequence\" vr=\"CS\" vm=\"1\">Echo Pulse Sequence</tag>
    <tag group=\"0018\" element=\"9009\" keyword=\"InversionRecovery\" vr=\"CS\" vm=\"1\">Inversion Recovery</tag>
    <tag group=\"0018\" element=\"9010\" keyword=\"FlowCompensation\" vr=\"CS\" vm=\"1\">Flow Compensation</tag>
    <tag group=\"0018\" element=\"9011\" keyword=\"MultipleSpinEcho\" vr=\"CS\" vm=\"1\">Multiple Spin Echo</tag>
    <tag group=\"0018\" element=\"9012\" keyword=\"MultiPlanarExcitation\" vr=\"CS\" vm=\"1\">Multi-planar Excitation</tag>
    <tag group=\"0018\" element=\"9014\" keyword=\"PhaseContrast\" vr=\"CS\" vm=\"1\">Phase Contrast</tag>
    <tag group=\"0018\" element=\"9015\" keyword=\"TimeOfFlightContrast\" vr=\"CS\" vm=\"1\">Time of Flight Contrast</tag>
    <tag group=\"0018\" element=\"9016\" keyword=\"Spoiling\" vr=\"CS\" vm=\"1\">Spoiling</tag>
    <tag group=\"0018\" element=\"9017\" keyword=\"SteadyStatePulseSequence\" vr=\"CS\" vm=\"1\">Steady State Pulse Sequence</tag>
    <tag group=\"0018\" element=\"9018\" keyword=\"EchoPlanarPulseSequence\" vr=\"CS\" vm=\"1\">Echo Planar Pulse Sequence</tag>
    <tag group=\"0018\" element=\"9019\" keyword=\"TagAngleFirstAxis\" vr=\"FD\" vm=\"1\">Tag Angle First Axis</tag>
    <tag group=\"0018\" element=\"9020\" keyword=\"MagnetizationTransfer\" vr=\"CS\" vm=\"1\">Magnetization Transfer</tag>
    <tag group=\"0018\" element=\"9021\" keyword=\"T2Preparation\" vr=\"CS\" vm=\"1\">T2 Preparation</tag>
    <tag group=\"0018\" element=\"9022\" keyword=\"BloodSignalNulling\" vr=\"CS\" vm=\"1\">Blood Signal Nulling</tag>
    <tag group=\"0018\" element=\"9024\" keyword=\"SaturationRecovery\" vr=\"CS\" vm=\"1\">Saturation Recovery</tag>
    <tag group=\"0018\" element=\"9025\" keyword=\"SpectrallySelectedSuppression\" vr=\"CS\" vm=\"1\">Spectrally Selected Suppression</tag>
    <tag group=\"0018\" element=\"9026\" keyword=\"SpectrallySelectedExcitation\" vr=\"CS\" vm=\"1\">Spectrally Selected Excitation</tag>
    <tag group=\"0018\" element=\"9027\" keyword=\"SpatialPresaturation\" vr=\"CS\" vm=\"1\">Spatial Pre-saturation</tag>
    <tag group=\"0018\" element=\"9028\" keyword=\"Tagging\" vr=\"CS\" vm=\"1\">Tagging</tag>
    <tag group=\"0018\" element=\"9029\" keyword=\"OversamplingPhase\" vr=\"CS\" vm=\"1\">Oversampling Phase</tag>
    <tag group=\"0018\" element=\"9030\" keyword=\"TagSpacingFirstDimension\" vr=\"FD\" vm=\"1\">Tag Spacing First Dimension</tag>
    <tag group=\"0018\" element=\"9032\" keyword=\"GeometryOfKSpaceTraversal\" vr=\"CS\" vm=\"1\">Geometry of k-Space Traversal</tag>
    <tag group=\"0018\" element=\"9033\" keyword=\"SegmentedKSpaceTraversal\" vr=\"CS\" vm=\"1\">Segmented k-Space Traversal</tag>
    <tag group=\"0018\" element=\"9034\" keyword=\"RectilinearPhaseEncodeReordering\" vr=\"CS\" vm=\"1\">Rectilinear Phase Encode Reordering</tag>
    <tag group=\"0018\" element=\"9035\" keyword=\"TagThickness\" vr=\"FD\" vm=\"1\">Tag Thickness</tag>
    <tag group=\"0018\" element=\"9036\" keyword=\"PartialFourierDirection\" vr=\"CS\" vm=\"1\">Partial Fourier Direction</tag>
    <tag group=\"0018\" element=\"9037\" keyword=\"CardiacSynchronizationTechnique\" vr=\"CS\" vm=\"1\">Cardiac Synchronization Technique</tag>
    <tag group=\"0018\" element=\"9041\" keyword=\"ReceiveCoilManufacturerName\" vr=\"LO\" vm=\"1\">Receive Coil Manufacturer Name</tag>
    <tag group=\"0018\" element=\"9042\" keyword=\"MRReceiveCoilSequence\" vr=\"SQ\" vm=\"1\">MR Receive Coil Sequence</tag>
    <tag group=\"0018\" element=\"9043\" keyword=\"ReceiveCoilType\" vr=\"CS\" vm=\"1\">Receive Coil Type</tag>
    <tag group=\"0018\" element=\"9044\" keyword=\"QuadratureReceiveCoil\" vr=\"CS\" vm=\"1\">Quadrature Receive Coil</tag>
    <tag group=\"0018\" element=\"9045\" keyword=\"MultiCoilDefinitionSequence\" vr=\"SQ\" vm=\"1\">Multi-Coil Definition Sequence</tag>
    <tag group=\"0018\" element=\"9046\" keyword=\"MultiCoilConfiguration\" vr=\"LO\" vm=\"1\">Multi-Coil Configuration</tag>
    <tag group=\"0018\" element=\"9047\" keyword=\"MultiCoilElementName\" vr=\"SH\" vm=\"1\">Multi-Coil Element Name</tag>
    <tag group=\"0018\" element=\"9048\" keyword=\"MultiCoilElementUsed\" vr=\"CS\" vm=\"1\">Multi-Coil Element Used</tag>
    <tag group=\"0018\" element=\"9049\" keyword=\"MRTransmitCoilSequence\" vr=\"SQ\" vm=\"1\">MR Transmit Coil Sequence</tag>
    <tag group=\"0018\" element=\"9050\" keyword=\"TransmitCoilManufacturerName\" vr=\"LO\" vm=\"1\">Transmit Coil Manufacturer Name</tag>
    <tag group=\"0018\" element=\"9051\" keyword=\"TransmitCoilType\" vr=\"CS\" vm=\"1\">Transmit Coil Type</tag>
    <tag group=\"0018\" element=\"9052\" keyword=\"SpectralWidth\" vr=\"FD\" vm=\"1-2\">Spectral Width</tag>
    <tag group=\"0018\" element=\"9053\" keyword=\"ChemicalShiftReference\" vr=\"FD\" vm=\"1-2\">Chemical Shift Reference</tag>
    <tag group=\"0018\" element=\"9054\" keyword=\"VolumeLocalizationTechnique\" vr=\"CS\" vm=\"1\">Volume Localization Technique</tag>
    <tag group=\"0018\" element=\"9058\" keyword=\"MRAcquisitionFrequencyEncodingSteps\" vr=\"US\" vm=\"1\">MR Acquisition Frequency Encoding Steps</tag>
    <tag group=\"0018\" element=\"9059\" keyword=\"Decoupling\" vr=\"CS\" vm=\"1\">De-coupling</tag>
    <tag group=\"0018\" element=\"9060\" keyword=\"DecoupledNucleus\" vr=\"CS\" vm=\"1-2\">De-coupled Nucleus</tag>
    <tag group=\"0018\" element=\"9061\" keyword=\"DecouplingFrequency\" vr=\"FD\" vm=\"1-2\">De-coupling Frequency</tag>
    <tag group=\"0018\" element=\"9062\" keyword=\"DecouplingMethod\" vr=\"CS\" vm=\"1\">De-coupling Method</tag>
    <tag group=\"0018\" element=\"9063\" keyword=\"DecouplingChemicalShiftReference\" vr=\"FD\" vm=\"1-2\">De-coupling Chemical Shift Reference</tag>
    <tag group=\"0018\" element=\"9064\" keyword=\"KSpaceFiltering\" vr=\"CS\" vm=\"1\">k-space Filtering</tag>
    <tag group=\"0018\" element=\"9065\" keyword=\"TimeDomainFiltering\" vr=\"CS\" vm=\"1-2\">Time Domain Filtering</tag>
    <tag group=\"0018\" element=\"9066\" keyword=\"NumberOfZeroFills\" vr=\"US\" vm=\"1-2\">Number of Zero Fills</tag>
    <tag group=\"0018\" element=\"9067\" keyword=\"BaselineCorrection\" vr=\"CS\" vm=\"1\">Baseline Correction</tag>
    <tag group=\"0018\" element=\"9069\" keyword=\"ParallelReductionFactorInPlane\" vr=\"FD\" vm=\"1\">Parallel Reduction Factor In-plane</tag>
    <tag group=\"0018\" element=\"9070\" keyword=\"CardiacRRIntervalSpecified\" vr=\"FD\" vm=\"1\">Cardiac R-R Interval Specified</tag>
    <tag group=\"0018\" element=\"9073\" keyword=\"AcquisitionDuration\" vr=\"FD\" vm=\"1\">Acquisition Duration</tag>
    <tag group=\"0018\" element=\"9074\" keyword=\"FrameAcquisitionDateTime\" vr=\"DT\" vm=\"1\">Frame Acquisition DateTime</tag>
    <tag group=\"0018\" element=\"9075\" keyword=\"DiffusionDirectionality\" vr=\"CS\" vm=\"1\">Diffusion Directionality</tag>
    <tag group=\"0018\" element=\"9076\" keyword=\"DiffusionGradientDirectionSequence\" vr=\"SQ\" vm=\"1\">Diffusion Gradient Direction Sequence</tag>
    <tag group=\"0018\" element=\"9077\" keyword=\"ParallelAcquisition\" vr=\"CS\" vm=\"1\">Parallel Acquisition</tag>
    <tag group=\"0018\" element=\"9078\" keyword=\"ParallelAcquisitionTechnique\" vr=\"CS\" vm=\"1\">Parallel Acquisition Technique</tag>
    <tag group=\"0018\" element=\"9079\" keyword=\"InversionTimes\" vr=\"FD\" vm=\"1-n\">Inversion Times</tag>
    <tag group=\"0018\" element=\"9080\" keyword=\"MetaboliteMapDescription\" vr=\"ST\" vm=\"1\">Metabolite Map Description</tag>
    <tag group=\"0018\" element=\"9081\" keyword=\"PartialFourier\" vr=\"CS\" vm=\"1\">Partial Fourier</tag>
    <tag group=\"0018\" element=\"9082\" keyword=\"EffectiveEchoTime\" vr=\"FD\" vm=\"1\">Effective Echo Time</tag>
    <tag group=\"0018\" element=\"9083\" keyword=\"MetaboliteMapCodeSequence\" vr=\"SQ\" vm=\"1\">Metabolite Map Code Sequence</tag>
    <tag group=\"0018\" element=\"9084\" keyword=\"ChemicalShiftSequence\" vr=\"SQ\" vm=\"1\">Chemical Shift Sequence</tag>
    <tag group=\"0018\" element=\"9085\" keyword=\"CardiacSignalSource\" vr=\"CS\" vm=\"1\">Cardiac Signal Source</tag>
    <tag group=\"0018\" element=\"9087\" keyword=\"DiffusionBValue\" vr=\"FD\" vm=\"1\">Diffusion b-value</tag>
    <tag group=\"0018\" element=\"9089\" keyword=\"DiffusionGradientOrientation\" vr=\"FD\" vm=\"3\">Diffusion Gradient Orientation</tag>
    <tag group=\"0018\" element=\"9090\" keyword=\"VelocityEncodingDirection\" vr=\"FD\" vm=\"3\">Velocity Encoding Direction</tag>
    <tag group=\"0018\" element=\"9091\" keyword=\"VelocityEncodingMinimumValue\" vr=\"FD\" vm=\"1\">Velocity Encoding Minimum Value</tag>
    <tag group=\"0018\" element=\"9092\" keyword=\"VelocityEncodingAcquisitionSequence\" vr=\"SQ\" vm=\"1\">Velocity Encoding Acquisition Sequence</tag>
    <tag group=\"0018\" element=\"9093\" keyword=\"NumberOfKSpaceTrajectories\" vr=\"US\" vm=\"1\">Number of k-Space Trajectories</tag>
    <tag group=\"0018\" element=\"9094\" keyword=\"CoverageOfKSpace\" vr=\"CS\" vm=\"1\">Coverage of k-Space</tag>
    <tag group=\"0018\" element=\"9095\" keyword=\"SpectroscopyAcquisitionPhaseRows\" vr=\"UL\" vm=\"1\">Spectroscopy Acquisition Phase Rows</tag>
    <tag group=\"0018\" element=\"9096\" keyword=\"ParallelReductionFactorInPlaneRetired\" vr=\"FD\" vm=\"1\" retired=\"true\">Parallel Reduction Factor In-plane (Retired)</tag>
    <tag group=\"0018\" element=\"9098\" keyword=\"TransmitterFrequency\" vr=\"FD\" vm=\"1-2\">Transmitter Frequency</tag>
    <tag group=\"0018\" element=\"9100\" keyword=\"ResonantNucleus\" vr=\"CS\" vm=\"1-2\">Resonant Nucleus</tag>
    <tag group=\"0018\" element=\"9101\" keyword=\"FrequencyCorrection\" vr=\"CS\" vm=\"1\">Frequency Correction</tag>
    <tag group=\"0018\" element=\"9103\" keyword=\"MRSpectroscopyFOVGeometrySequence\" vr=\"SQ\" vm=\"1\">MR Spectroscopy FOV/Geometry Sequence</tag>
    <tag group=\"0018\" element=\"9104\" keyword=\"SlabThickness\" vr=\"FD\" vm=\"1\">Slab Thickness</tag>
    <tag group=\"0018\" element=\"9105\" keyword=\"SlabOrientation\" vr=\"FD\" vm=\"3\">Slab Orientation</tag>
    <tag group=\"0018\" element=\"9106\" keyword=\"MidSlabPosition\" vr=\"FD\" vm=\"3\">Mid Slab Position</tag>
    <tag group=\"0018\" element=\"9107\" keyword=\"MRSpatialSaturationSequence\" vr=\"SQ\" vm=\"1\">MR Spatial Saturation Sequence</tag>
    <tag group=\"0018\" element=\"9112\" keyword=\"MRTimingAndRelatedParametersSequence\" vr=\"SQ\" vm=\"1\">MR Timing and Related Parameters Sequence</tag>
    <tag group=\"0018\" element=\"9114\" keyword=\"MREchoSequence\" vr=\"SQ\" vm=\"1\">MR Echo Sequence</tag>
    <tag group=\"0018\" element=\"9115\" keyword=\"MRModifierSequence\" vr=\"SQ\" vm=\"1\">MR Modifier Sequence</tag>
    <tag group=\"0018\" element=\"9117\" keyword=\"MRDiffusionSequence\" vr=\"SQ\" vm=\"1\">MR Diffusion Sequence</tag>
    <tag group=\"0018\" element=\"9118\" keyword=\"CardiacSynchronizationSequence\" vr=\"SQ\" vm=\"1\">Cardiac Synchronization Sequence</tag>
    <tag group=\"0018\" element=\"9119\" keyword=\"MRAveragesSequence\" vr=\"SQ\" vm=\"1\">MR Averages Sequence</tag>
    <tag group=\"0018\" element=\"9125\" keyword=\"MRFOVGeometrySequence\" vr=\"SQ\" vm=\"1\">MR FOV/Geometry Sequence</tag>
    <tag group=\"0018\" element=\"9126\" keyword=\"VolumeLocalizationSequence\" vr=\"SQ\" vm=\"1\">Volume Localization Sequence</tag>
    <tag group=\"0018\" element=\"9127\" keyword=\"SpectroscopyAcquisitionDataColumns\" vr=\"UL\" vm=\"1\">Spectroscopy Acquisition Data Columns</tag>
    <tag group=\"0018\" element=\"9147\" keyword=\"DiffusionAnisotropyType\" vr=\"CS\" vm=\"1\">Diffusion Anisotropy Type</tag>
    <tag group=\"0018\" element=\"9151\" keyword=\"FrameReferenceDateTime\" vr=\"DT\" vm=\"1\">Frame Reference DateTime</tag>
    <tag group=\"0018\" element=\"9152\" keyword=\"MRMetaboliteMapSequence\" vr=\"SQ\" vm=\"1\">MR Metabolite Map Sequence</tag>
    <tag group=\"0018\" element=\"9155\" keyword=\"ParallelReductionFactorOutOfPlane\" vr=\"FD\" vm=\"1\">Parallel Reduction Factor out-of-plane</tag>
    <tag group=\"0018\" element=\"9159\" keyword=\"SpectroscopyAcquisitionOutOfPlanePhaseSteps\" vr=\"UL\" vm=\"1\">Spectroscopy Acquisition Out-of-plane Phase Steps</tag>
    <tag group=\"0018\" element=\"9166\" keyword=\"BulkMotionStatus\" vr=\"CS\" vm=\"1\" retired=\"true\">Bulk Motion Status</tag>
    <tag group=\"0018\" element=\"9168\" keyword=\"ParallelReductionFactorSecondInPlane\" vr=\"FD\" vm=\"1\">Parallel Reduction Factor Second In-plane</tag>
    <tag group=\"0018\" element=\"9169\" keyword=\"CardiacBeatRejectionTechnique\" vr=\"CS\" vm=\"1\">Cardiac Beat Rejection Technique</tag>
    <tag group=\"0018\" element=\"9170\" keyword=\"RespiratoryMotionCompensationTechnique\" vr=\"CS\" vm=\"1\">Respiratory Motion Compensation Technique</tag>
    <tag group=\"0018\" element=\"9171\" keyword=\"RespiratorySignalSource\" vr=\"CS\" vm=\"1\">Respiratory Signal Source</tag>
    <tag group=\"0018\" element=\"9172\" keyword=\"BulkMotionCompensationTechnique\" vr=\"CS\" vm=\"1\">Bulk Motion Compensation Technique</tag>
    <tag group=\"0018\" element=\"9173\" keyword=\"BulkMotionSignalSource\" vr=\"CS\" vm=\"1\">Bulk Motion Signal Source</tag>
    <tag group=\"0018\" element=\"9174\" keyword=\"ApplicableSafetyStandardAgency\" vr=\"CS\" vm=\"1\">Applicable Safety Standard Agency</tag>
    <tag group=\"0018\" element=\"9175\" keyword=\"ApplicableSafetyStandardDescription\" vr=\"LO\" vm=\"1\">Applicable Safety Standard Description</tag>
    <tag group=\"0018\" element=\"9176\" keyword=\"OperatingModeSequence\" vr=\"SQ\" vm=\"1\">Operating Mode Sequence</tag>
    <tag group=\"0018\" element=\"9177\" keyword=\"OperatingModeType\" vr=\"CS\" vm=\"1\">Operating Mode Type</tag>
    <tag group=\"0018\" element=\"9178\" keyword=\"OperatingMode\" vr=\"CS\" vm=\"1\">Operating Mode</tag>
    <tag group=\"0018\" element=\"9179\" keyword=\"SpecificAbsorptionRateDefinition\" vr=\"CS\" vm=\"1\">Specific Absorption Rate Definition</tag>
    <tag group=\"0018\" element=\"9180\" keyword=\"GradientOutputType\" vr=\"CS\" vm=\"1\">Gradient Output Type</tag>
    <tag group=\"0018\" element=\"9181\" keyword=\"SpecificAbsorptionRateValue\" vr=\"FD\" vm=\"1\">Specific Absorption Rate Value</tag>
    <tag group=\"0018\" element=\"9182\" keyword=\"GradientOutput\" vr=\"FD\" vm=\"1\">Gradient Output</tag>
    <tag group=\"0018\" element=\"9183\" keyword=\"FlowCompensationDirection\" vr=\"CS\" vm=\"1\">Flow Compensation Direction</tag>
    <tag group=\"0018\" element=\"9184\" keyword=\"TaggingDelay\" vr=\"FD\" vm=\"1\">Tagging Delay</tag>
    <tag group=\"0018\" element=\"9185\" keyword=\"RespiratoryMotionCompensationTechniqueDescription\" vr=\"ST\" vm=\"1\">Respiratory Motion Compensation Technique Description</tag>
    <tag group=\"0018\" element=\"9186\" keyword=\"RespiratorySignalSourceID\" vr=\"SH\" vm=\"1\">Respiratory Signal Source ID</tag>
    <tag group=\"0018\" element=\"9195\" keyword=\"ChemicalShiftMinimumIntegrationLimitInHz\" vr=\"FD\" vm=\"1\" retired=\"true\">Chemical Shift Minimum Integration Limit in Hz</tag>
    <tag group=\"0018\" element=\"9196\" keyword=\"ChemicalShiftMaximumIntegrationLimitInHz\" vr=\"FD\" vm=\"1\" retired=\"true\">Chemical Shift Maximum Integration Limit in Hz</tag>
    <tag group=\"0018\" element=\"9197\" keyword=\"MRVelocityEncodingSequence\" vr=\"SQ\" vm=\"1\">MR Velocity Encoding Sequence</tag>
    <tag group=\"0018\" element=\"9198\" keyword=\"FirstOrderPhaseCorrection\" vr=\"CS\" vm=\"1\">First Order Phase Correction</tag>
    <tag group=\"0018\" element=\"9199\" keyword=\"WaterReferencedPhaseCorrection\" vr=\"CS\" vm=\"1\">Water Referenced Phase Correction</tag>
    <tag group=\"0018\" element=\"9200\" keyword=\"MRSpectroscopyAcquisitionType\" vr=\"CS\" vm=\"1\">MR Spectroscopy Acquisition Type</tag>
    <tag group=\"0018\" element=\"9214\" keyword=\"RespiratoryCyclePosition\" vr=\"CS\" vm=\"1\">Respiratory Cycle Position</tag>
    <tag group=\"0018\" element=\"9217\" keyword=\"VelocityEncodingMaximumValue\" vr=\"FD\" vm=\"1\">Velocity Encoding Maximum Value</tag>
    <tag group=\"0018\" element=\"9218\" keyword=\"TagSpacingSecondDimension\" vr=\"FD\" vm=\"1\">Tag Spacing Second Dimension</tag>
    <tag group=\"0018\" element=\"9219\" keyword=\"TagAngleSecondAxis\" vr=\"SS\" vm=\"1\">Tag Angle Second Axis</tag>
    <tag group=\"0018\" element=\"9220\" keyword=\"FrameAcquisitionDuration\" vr=\"FD\" vm=\"1\">Frame Acquisition Duration</tag>
    <tag group=\"0018\" element=\"9226\" keyword=\"MRImageFrameTypeSequence\" vr=\"SQ\" vm=\"1\">MR Image Frame Type Sequence</tag>
    <tag group=\"0018\" element=\"9227\" keyword=\"MRSpectroscopyFrameTypeSequence\" vr=\"SQ\" vm=\"1\">MR Spectroscopy Frame Type Sequence</tag>
    <tag group=\"0018\" element=\"9231\" keyword=\"MRAcquisitionPhaseEncodingStepsInPlane\" vr=\"US\" vm=\"1\">MR Acquisition Phase Encoding Steps in-plane</tag>
    <tag group=\"0018\" element=\"9232\" keyword=\"MRAcquisitionPhaseEncodingStepsOutOfPlane\" vr=\"US\" vm=\"1\">MR Acquisition Phase Encoding Steps out-of-plane</tag>
    <tag group=\"0018\" element=\"9234\" keyword=\"SpectroscopyAcquisitionPhaseColumns\" vr=\"UL\" vm=\"1\">Spectroscopy Acquisition Phase Columns</tag>
    <tag group=\"0018\" element=\"9236\" keyword=\"CardiacCyclePosition\" vr=\"CS\" vm=\"1\">Cardiac Cycle Position</tag>
    <tag group=\"0018\" element=\"9239\" keyword=\"SpecificAbsorptionRateSequence\" vr=\"SQ\" vm=\"1\">Specific Absorption Rate Sequence</tag>
    <tag group=\"0018\" element=\"9240\" keyword=\"RFEchoTrainLength\" vr=\"US\" vm=\"1\">RF Echo Train Length</tag>
    <tag group=\"0018\" element=\"9241\" keyword=\"GradientEchoTrainLength\" vr=\"US\" vm=\"1\">Gradient Echo Train Length</tag>
    <tag group=\"0018\" element=\"9250\" keyword=\"ArterialSpinLabelingContrast\" vr=\"CS\" vm=\"1\">Arterial Spin Labeling Contrast</tag>
    <tag group=\"0018\" element=\"9251\" keyword=\"MRArterialSpinLabelingSequence\" vr=\"SQ\" vm=\"1\">MR Arterial Spin Labeling Sequence</tag>
    <tag group=\"0018\" element=\"9252\" keyword=\"ASLTechniqueDescription\" vr=\"LO\" vm=\"1\">ASL Technique Description</tag>
    <tag group=\"0018\" element=\"9253\" keyword=\"ASLSlabNumber\" vr=\"US\" vm=\"1\">ASL Slab Number</tag>
    <tag group=\"0018\" element=\"9254\" keyword=\"ASLSlabThickness\" vr=\"FD\" vm=\"1\">ASL Slab Thickness</tag>
    <tag group=\"0018\" element=\"9255\" keyword=\"ASLSlabOrientation\" vr=\"FD\" vm=\"3\">ASL Slab Orientation</tag>
    <tag group=\"0018\" element=\"9256\" keyword=\"ASLMidSlabPosition\" vr=\"FD\" vm=\"3\">ASL Mid Slab Position</tag>
    <tag group=\"0018\" element=\"9257\" keyword=\"ASLContext\" vr=\"CS\" vm=\"1\">ASL Context</tag>
    <tag group=\"0018\" element=\"9258\" keyword=\"ASLPulseTrainDuration\" vr=\"UL\" vm=\"1\">ASL Pulse Train Duration</tag>
    <tag group=\"0018\" element=\"9259\" keyword=\"ASLCrusherFlag\" vr=\"CS\" vm=\"1\">ASL Crusher Flag</tag>
    <tag group=\"0018\" element=\"925A\" keyword=\"ASLCrusherFlowLimit\" vr=\"FD\" vm=\"1\">ASL Crusher Flow Limit</tag>
    <tag group=\"0018\" element=\"925B\" keyword=\"ASLCrusherDescription\" vr=\"LO\" vm=\"1\">ASL Crusher Description</tag>
    <tag group=\"0018\" element=\"925C\" keyword=\"ASLBolusCutoffFlag\" vr=\"CS\" vm=\"1\">ASL Bolus Cut-off Flag</tag>
    <tag group=\"0018\" element=\"925D\" keyword=\"ASLBolusCutoffTimingSequence\" vr=\"SQ\" vm=\"1\">ASL Bolus Cut-off Timing Sequence</tag>
    <tag group=\"0018\" element=\"925E\" keyword=\"ASLBolusCutoffTechnique\" vr=\"LO\" vm=\"1\">ASL Bolus Cut-off Technique</tag>
    <tag group=\"0018\" element=\"925F\" keyword=\"ASLBolusCutoffDelayTime\" vr=\"UL\" vm=\"1\">ASL Bolus Cut-off Delay Time</tag>
    <tag group=\"0018\" element=\"9260\" keyword=\"ASLSlabSequence\" vr=\"SQ\" vm=\"1\">ASL Slab Sequence</tag>
    <tag group=\"0018\" element=\"9295\" keyword=\"ChemicalShiftMinimumIntegrationLimitInppm\" vr=\"FD\" vm=\"1\">Chemical Shift Minimum Integration Limit in ppm</tag>
    <tag group=\"0018\" element=\"9296\" keyword=\"ChemicalShiftMaximumIntegrationLimitInppm\" vr=\"FD\" vm=\"1\">Chemical Shift Maximum Integration Limit in ppm</tag>
    <tag group=\"0018\" element=\"9297\" keyword=\"WaterReferenceAcquisition\" vr=\"CS\" vm=\"1\">Water Reference Acquisition</tag>
    <tag group=\"0018\" element=\"9298\" keyword=\"EchoPeakPosition\" vr=\"IS\" vm=\"1\">Echo Peak Position</tag>
    <tag group=\"0018\" element=\"9301\" keyword=\"CTAcquisitionTypeSequence\" vr=\"SQ\" vm=\"1\">CT Acquisition Type Sequence</tag>
    <tag group=\"0018\" element=\"9302\" keyword=\"AcquisitionType\" vr=\"CS\" vm=\"1\">Acquisition Type</tag>
    <tag group=\"0018\" element=\"9303\" keyword=\"TubeAngle\" vr=\"FD\" vm=\"1\">Tube Angle</tag>
    <tag group=\"0018\" element=\"9304\" keyword=\"CTAcquisitionDetailsSequence\" vr=\"SQ\" vm=\"1\">CT Acquisition Details Sequence</tag>
    <tag group=\"0018\" element=\"9305\" keyword=\"RevolutionTime\" vr=\"FD\" vm=\"1\">Revolution Time</tag>
    <tag group=\"0018\" element=\"9306\" keyword=\"SingleCollimationWidth\" vr=\"FD\" vm=\"1\">Single Collimation Width</tag>
    <tag group=\"0018\" element=\"9307\" keyword=\"TotalCollimationWidth\" vr=\"FD\" vm=\"1\">Total Collimation Width</tag>
    <tag group=\"0018\" element=\"9308\" keyword=\"CTTableDynamicsSequence\" vr=\"SQ\" vm=\"1\">CT Table Dynamics Sequence</tag>
    <tag group=\"0018\" element=\"9309\" keyword=\"TableSpeed\" vr=\"FD\" vm=\"1\">Table Speed</tag>
    <tag group=\"0018\" element=\"9310\" keyword=\"TableFeedPerRotation\" vr=\"FD\" vm=\"1\">Table Feed per Rotation</tag>
    <tag group=\"0018\" element=\"9311\" keyword=\"SpiralPitchFactor\" vr=\"FD\" vm=\"1\">Spiral Pitch Factor</tag>
    <tag group=\"0018\" element=\"9312\" keyword=\"CTGeometrySequence\" vr=\"SQ\" vm=\"1\">CT Geometry Sequence</tag>
    <tag group=\"0018\" element=\"9313\" keyword=\"DataCollectionCenterPatient\" vr=\"FD\" vm=\"3\">Data Collection Center (Patient)</tag>
    <tag group=\"0018\" element=\"9314\" keyword=\"CTReconstructionSequence\" vr=\"SQ\" vm=\"1\">CT Reconstruction Sequence</tag>
    <tag group=\"0018\" element=\"9315\" keyword=\"ReconstructionAlgorithm\" vr=\"CS\" vm=\"1\">Reconstruction Algorithm</tag>
    <tag group=\"0018\" element=\"9316\" keyword=\"ConvolutionKernelGroup\" vr=\"CS\" vm=\"1\">Convolution Kernel Group</tag>
    <tag group=\"0018\" element=\"9317\" keyword=\"ReconstructionFieldOfView\" vr=\"FD\" vm=\"2\">Reconstruction Field of View</tag>
    <tag group=\"0018\" element=\"9318\" keyword=\"ReconstructionTargetCenterPatient\" vr=\"FD\" vm=\"3\">Reconstruction Target Center (Patient)</tag>
    <tag group=\"0018\" element=\"9319\" keyword=\"ReconstructionAngle\" vr=\"FD\" vm=\"1\">Reconstruction Angle</tag>
    <tag group=\"0018\" element=\"9320\" keyword=\"ImageFilter\" vr=\"SH\" vm=\"1\">Image Filter</tag>
    <tag group=\"0018\" element=\"9321\" keyword=\"CTExposureSequence\" vr=\"SQ\" vm=\"1\">CT Exposure Sequence</tag>
    <tag group=\"0018\" element=\"9322\" keyword=\"ReconstructionPixelSpacing\" vr=\"FD\" vm=\"2\">Reconstruction Pixel Spacing</tag>
    <tag group=\"0018\" element=\"9323\" keyword=\"ExposureModulationType\" vr=\"CS\" vm=\"1-n\">Exposure Modulation Type</tag>
    <tag group=\"0018\" element=\"9324\" keyword=\"EstimatedDoseSaving\" vr=\"FD\" vm=\"1\">Estimated Dose Saving</tag>
    <tag group=\"0018\" element=\"9325\" keyword=\"CTXRayDetailsSequence\" vr=\"SQ\" vm=\"1\">CT X-Ray Details Sequence</tag>
    <tag group=\"0018\" element=\"9326\" keyword=\"CTPositionSequence\" vr=\"SQ\" vm=\"1\">CT Position Sequence</tag>
    <tag group=\"0018\" element=\"9327\" keyword=\"TablePosition\" vr=\"FD\" vm=\"1\">Table Position</tag>
    <tag group=\"0018\" element=\"9328\" keyword=\"ExposureTimeInms\" vr=\"FD\" vm=\"1\">Exposure Time in ms</tag>
    <tag group=\"0018\" element=\"9329\" keyword=\"CTImageFrameTypeSequence\" vr=\"SQ\" vm=\"1\">CT Image Frame Type Sequence</tag>
    <tag group=\"0018\" element=\"9330\" keyword=\"XRayTubeCurrentInmA\" vr=\"FD\" vm=\"1\">X-Ray Tube Current in mA</tag>
    <tag group=\"0018\" element=\"9332\" keyword=\"ExposureInmAs\" vr=\"FD\" vm=\"1\">Exposure in mAs</tag>
    <tag group=\"0018\" element=\"9333\" keyword=\"ConstantVolumeFlag\" vr=\"CS\" vm=\"1\">Constant Volume Flag</tag>
    <tag group=\"0018\" element=\"9334\" keyword=\"FluoroscopyFlag\" vr=\"CS\" vm=\"1\">Fluoroscopy Flag</tag>
    <tag group=\"0018\" element=\"9335\" keyword=\"DistanceSourceToDataCollectionCenter\" vr=\"FD\" vm=\"1\">Distance Source to Data Collection Center</tag>
    <tag group=\"0018\" element=\"9337\" keyword=\"ContrastBolusAgentNumber\" vr=\"US\" vm=\"1\">Contrast/Bolus Agent Number</tag>
    <tag group=\"0018\" element=\"9338\" keyword=\"ContrastBolusIngredientCodeSequence\" vr=\"SQ\" vm=\"1\">Contrast/Bolus Ingredient Code Sequence</tag>
    <tag group=\"0018\" element=\"9340\" keyword=\"ContrastAdministrationProfileSequence\" vr=\"SQ\" vm=\"1\">Contrast Administration Profile Sequence</tag>
    <tag group=\"0018\" element=\"9341\" keyword=\"ContrastBolusUsageSequence\" vr=\"SQ\" vm=\"1\">Contrast/Bolus Usage Sequence</tag>
    <tag group=\"0018\" element=\"9342\" keyword=\"ContrastBolusAgentAdministered\" vr=\"CS\" vm=\"1\">Contrast/Bolus Agent Administered</tag>
    <tag group=\"0018\" element=\"9343\" keyword=\"ContrastBolusAgentDetected\" vr=\"CS\" vm=\"1\">Contrast/Bolus Agent Detected</tag>
    <tag group=\"0018\" element=\"9344\" keyword=\"ContrastBolusAgentPhase\" vr=\"CS\" vm=\"1\">Contrast/Bolus Agent Phase</tag>
    <tag group=\"0018\" element=\"9345\" keyword=\"CTDIvol\" vr=\"FD\" vm=\"1\">CTDIvol</tag>
    <tag group=\"0018\" element=\"9346\" keyword=\"CTDIPhantomTypeCodeSequence\" vr=\"SQ\" vm=\"1\">CTDI Phantom Type Code Sequence</tag>
    <tag group=\"0018\" element=\"9351\" keyword=\"CalciumScoringMassFactorPatient\" vr=\"FL\" vm=\"1\">Calcium Scoring Mass Factor Patient</tag>
    <tag group=\"0018\" element=\"9352\" keyword=\"CalciumScoringMassFactorDevice\" vr=\"FL\" vm=\"3\">Calcium Scoring Mass Factor Device</tag>
    <tag group=\"0018\" element=\"9353\" keyword=\"EnergyWeightingFactor\" vr=\"FL\" vm=\"1\">Energy Weighting Factor</tag>
    <tag group=\"0018\" element=\"9360\" keyword=\"CTAdditionalXRaySourceSequence\" vr=\"SQ\" vm=\"1\">CT Additional X-Ray Source Sequence</tag>
    <tag group=\"0018\" element=\"9401\" keyword=\"ProjectionPixelCalibrationSequence\" vr=\"SQ\" vm=\"1\">Projection Pixel Calibration Sequence</tag>
    <tag group=\"0018\" element=\"9402\" keyword=\"DistanceSourceToIsocenter\" vr=\"FL\" vm=\"1\">Distance Source to Isocenter</tag>
    <tag group=\"0018\" element=\"9403\" keyword=\"DistanceObjectToTableTop\" vr=\"FL\" vm=\"1\">Distance Object to Table Top</tag>
    <tag group=\"0018\" element=\"9404\" keyword=\"ObjectPixelSpacingInCenterOfBeam\" vr=\"FL\" vm=\"2\">Object Pixel Spacing in Center of Beam</tag>
    <tag group=\"0018\" element=\"9405\" keyword=\"PositionerPositionSequence\" vr=\"SQ\" vm=\"1\">Positioner Position Sequence</tag>
    <tag group=\"0018\" element=\"9406\" keyword=\"TablePositionSequence\" vr=\"SQ\" vm=\"1\">Table Position Sequence</tag>
    <tag group=\"0018\" element=\"9407\" keyword=\"CollimatorShapeSequence\" vr=\"SQ\" vm=\"1\">Collimator Shape Sequence</tag>
    <tag group=\"0018\" element=\"9410\" keyword=\"PlanesInAcquisition\" vr=\"CS\" vm=\"1\">Planes in Acquisition</tag>
    <tag group=\"0018\" element=\"9412\" keyword=\"XAXRFFrameCharacteristicsSequence\" vr=\"SQ\" vm=\"1\">XA/XRF Frame Characteristics Sequence</tag>
    <tag group=\"0018\" element=\"9417\" keyword=\"FrameAcquisitionSequence\" vr=\"SQ\" vm=\"1\">Frame Acquisition Sequence</tag>
    <tag group=\"0018\" element=\"9420\" keyword=\"XRayReceptorType\" vr=\"CS\" vm=\"1\">X-Ray Receptor Type</tag>
    <tag group=\"0018\" element=\"9423\" keyword=\"AcquisitionProtocolName\" vr=\"LO\" vm=\"1\">Acquisition Protocol Name</tag>
    <tag group=\"0018\" element=\"9424\" keyword=\"AcquisitionProtocolDescription\" vr=\"LT\" vm=\"1\">Acquisition Protocol Description</tag>
    <tag group=\"0018\" element=\"9425\" keyword=\"ContrastBolusIngredientOpaque\" vr=\"CS\" vm=\"1\">Contrast/Bolus Ingredient Opaque</tag>
    <tag group=\"0018\" element=\"9426\" keyword=\"DistanceReceptorPlaneToDetectorHousing\" vr=\"FL\" vm=\"1\">Distance Receptor Plane to Detector Housing</tag>
    <tag group=\"0018\" element=\"9427\" keyword=\"IntensifierActiveShape\" vr=\"CS\" vm=\"1\">Intensifier Active Shape</tag>
    <tag group=\"0018\" element=\"9428\" keyword=\"IntensifierActiveDimensions\" vr=\"FL\" vm=\"1-2\">Intensifier Active Dimension(s)</tag>
    <tag group=\"0018\" element=\"9429\" keyword=\"PhysicalDetectorSize\" vr=\"FL\" vm=\"2\">Physical Detector Size</tag>
    <tag group=\"0018\" element=\"9430\" keyword=\"PositionOfIsocenterProjection\" vr=\"FL\" vm=\"2\">Position of Isocenter Projection</tag>
    <tag group=\"0018\" element=\"9432\" keyword=\"FieldOfViewSequence\" vr=\"SQ\" vm=\"1\">Field of View Sequence</tag>
    <tag group=\"0018\" element=\"9433\" keyword=\"FieldOfViewDescription\" vr=\"LO\" vm=\"1\">Field of View Description</tag>
    <tag group=\"0018\" element=\"9434\" keyword=\"ExposureControlSensingRegionsSequence\" vr=\"SQ\" vm=\"1\">Exposure Control Sensing Regions Sequence</tag>
    <tag group=\"0018\" element=\"9435\" keyword=\"ExposureControlSensingRegionShape\" vr=\"CS\" vm=\"1\">Exposure Control Sensing Region Shape</tag>
    <tag group=\"0018\" element=\"9436\" keyword=\"ExposureControlSensingRegionLeftVerticalEdge\" vr=\"SS\" vm=\"1\">Exposure Control Sensing Region Left Vertical Edge</tag>
    <tag group=\"0018\" element=\"9437\" keyword=\"ExposureControlSensingRegionRightVerticalEdge\" vr=\"SS\" vm=\"1\">Exposure Control Sensing Region Right Vertical Edge</tag>
    <tag group=\"0018\" element=\"9438\" keyword=\"ExposureControlSensingRegionUpperHorizontalEdge\" vr=\"SS\" vm=\"1\">Exposure Control Sensing Region Upper Horizontal Edge</tag>
    <tag group=\"0018\" element=\"9439\" keyword=\"ExposureControlSensingRegionLowerHorizontalEdge\" vr=\"SS\" vm=\"1\">Exposure Control Sensing Region Lower Horizontal Edge</tag>
    <tag group=\"0018\" element=\"9440\" keyword=\"CenterOfCircularExposureControlSensingRegion\" vr=\"SS\" vm=\"2\">Center of Circular Exposure Control Sensing Region</tag>
    <tag group=\"0018\" element=\"9441\" keyword=\"RadiusOfCircularExposureControlSensingRegion\" vr=\"US\" vm=\"1\">Radius of Circular Exposure Control Sensing Region</tag>
    <tag group=\"0018\" element=\"9442\" keyword=\"VerticesOfThePolygonalExposureControlSensingRegion\" vr=\"SS\" vm=\"2-n\">Vertices of the Polygonal Exposure Control Sensing Region</tag>
    <tag group=\"0018\" element=\"9447\" keyword=\"ColumnAngulationPatient\" vr=\"FL\" vm=\"1\">Column Angulation (Patient)</tag>
    <tag group=\"0018\" element=\"9449\" keyword=\"BeamAngle\" vr=\"FL\" vm=\"1\">Beam Angle</tag>
    <tag group=\"0018\" element=\"9451\" keyword=\"FrameDetectorParametersSequence\" vr=\"SQ\" vm=\"1\">Frame Detector Parameters Sequence</tag>
    <tag group=\"0018\" element=\"9452\" keyword=\"CalculatedAnatomyThickness\" vr=\"FL\" vm=\"1\">Calculated Anatomy Thickness</tag>
    <tag group=\"0018\" element=\"9455\" keyword=\"CalibrationSequence\" vr=\"SQ\" vm=\"1\">Calibration Sequence</tag>
    <tag group=\"0018\" element=\"9456\" keyword=\"ObjectThicknessSequence\" vr=\"SQ\" vm=\"1\">Object Thickness Sequence</tag>
    <tag group=\"0018\" element=\"9457\" keyword=\"PlaneIdentification\" vr=\"CS\" vm=\"1\">Plane Identification</tag>
    <tag group=\"0018\" element=\"9461\" keyword=\"FieldOfViewDimensionsInFloat\" vr=\"FL\" vm=\"1-2\">Field of View Dimension(s) in Float</tag>
    <tag group=\"0018\" element=\"9462\" keyword=\"IsocenterReferenceSystemSequence\" vr=\"SQ\" vm=\"1\">Isocenter Reference System Sequence</tag>
    <tag group=\"0018\" element=\"9463\" keyword=\"PositionerIsocenterPrimaryAngle\" vr=\"FL\" vm=\"1\">Positioner Isocenter Primary Angle</tag>
    <tag group=\"0018\" element=\"9464\" keyword=\"PositionerIsocenterSecondaryAngle\" vr=\"FL\" vm=\"1\">Positioner Isocenter Secondary Angle</tag>
    <tag group=\"0018\" element=\"9465\" keyword=\"PositionerIsocenterDetectorRotationAngle\" vr=\"FL\" vm=\"1\">Positioner Isocenter Detector Rotation Angle</tag>
    <tag group=\"0018\" element=\"9466\" keyword=\"TableXPositionToIsocenter\" vr=\"FL\" vm=\"1\">Table X Position to Isocenter</tag>
    <tag group=\"0018\" element=\"9467\" keyword=\"TableYPositionToIsocenter\" vr=\"FL\" vm=\"1\">Table Y Position to Isocenter</tag>
    <tag group=\"0018\" element=\"9468\" keyword=\"TableZPositionToIsocenter\" vr=\"FL\" vm=\"1\">Table Z Position to Isocenter</tag>
    <tag group=\"0018\" element=\"9469\" keyword=\"TableHorizontalRotationAngle\" vr=\"FL\" vm=\"1\">Table Horizontal Rotation Angle</tag>
    <tag group=\"0018\" element=\"9470\" keyword=\"TableHeadTiltAngle\" vr=\"FL\" vm=\"1\">Table Head Tilt Angle</tag>
    <tag group=\"0018\" element=\"9471\" keyword=\"TableCradleTiltAngle\" vr=\"FL\" vm=\"1\">Table Cradle Tilt Angle</tag>
    <tag group=\"0018\" element=\"9472\" keyword=\"FrameDisplayShutterSequence\" vr=\"SQ\" vm=\"1\">Frame Display Shutter Sequence</tag>
    <tag group=\"0018\" element=\"9473\" keyword=\"AcquiredImageAreaDoseProduct\" vr=\"FL\" vm=\"1\">Acquired Image Area Dose Product</tag>
    <tag group=\"0018\" element=\"9474\" keyword=\"CArmPositionerTabletopRelationship\" vr=\"CS\" vm=\"1\">C-arm Positioner Tabletop Relationship</tag>
    <tag group=\"0018\" element=\"9476\" keyword=\"XRayGeometrySequence\" vr=\"SQ\" vm=\"1\">X-Ray Geometry Sequence</tag>
    <tag group=\"0018\" element=\"9477\" keyword=\"IrradiationEventIdentificationSequence\" vr=\"SQ\" vm=\"1\">Irradiation Event Identification Sequence</tag>
    <tag group=\"0018\" element=\"9504\" keyword=\"XRay3DFrameTypeSequence\" vr=\"SQ\" vm=\"1\">X-Ray 3D Frame Type Sequence</tag>
    <tag group=\"0018\" element=\"9506\" keyword=\"ContributingSourcesSequence\" vr=\"SQ\" vm=\"1\">Contributing Sources Sequence</tag>
    <tag group=\"0018\" element=\"9507\" keyword=\"XRay3DAcquisitionSequence\" vr=\"SQ\" vm=\"1\">X-Ray 3D Acquisition Sequence</tag>
    <tag group=\"0018\" element=\"9508\" keyword=\"PrimaryPositionerScanArc\" vr=\"FL\" vm=\"1\">Primary Positioner Scan Arc</tag>
    <tag group=\"0018\" element=\"9509\" keyword=\"SecondaryPositionerScanArc\" vr=\"FL\" vm=\"1\">Secondary Positioner Scan Arc</tag>
    <tag group=\"0018\" element=\"9510\" keyword=\"PrimaryPositionerScanStartAngle\" vr=\"FL\" vm=\"1\">Primary Positioner Scan Start Angle</tag>
    <tag group=\"0018\" element=\"9511\" keyword=\"SecondaryPositionerScanStartAngle\" vr=\"FL\" vm=\"1\">Secondary Positioner Scan Start Angle</tag>
    <tag group=\"0018\" element=\"9514\" keyword=\"PrimaryPositionerIncrement\" vr=\"FL\" vm=\"1\">Primary Positioner Increment</tag>
    <tag group=\"0018\" element=\"9515\" keyword=\"SecondaryPositionerIncrement\" vr=\"FL\" vm=\"1\">Secondary Positioner Increment</tag>
    <tag group=\"0018\" element=\"9516\" keyword=\"StartAcquisitionDateTime\" vr=\"DT\" vm=\"1\">Start Acquisition DateTime</tag>
    <tag group=\"0018\" element=\"9517\" keyword=\"EndAcquisitionDateTime\" vr=\"DT\" vm=\"1\">End Acquisition DateTime</tag>
    <tag group=\"0018\" element=\"9518\" keyword=\"PrimaryPositionerIncrementSign\" vr=\"SS\" vm=\"1\">Primary Positioner Increment Sign</tag>
    <tag group=\"0018\" element=\"9519\" keyword=\"SecondaryPositionerIncrementSign\" vr=\"SS\" vm=\"1\">Secondary Positioner Increment Sign</tag>
    <tag group=\"0018\" element=\"9524\" keyword=\"ApplicationName\" vr=\"LO\" vm=\"1\">Application Name</tag>
    <tag group=\"0018\" element=\"9525\" keyword=\"ApplicationVersion\" vr=\"LO\" vm=\"1\">Application Version</tag>
    <tag group=\"0018\" element=\"9526\" keyword=\"ApplicationManufacturer\" vr=\"LO\" vm=\"1\">Application Manufacturer</tag>
    <tag group=\"0018\" element=\"9527\" keyword=\"AlgorithmType\" vr=\"CS\" vm=\"1\">Algorithm Type</tag>
    <tag group=\"0018\" element=\"9528\" keyword=\"AlgorithmDescription\" vr=\"LO\" vm=\"1\">Algorithm Description</tag>
    <tag group=\"0018\" element=\"9530\" keyword=\"XRay3DReconstructionSequence\" vr=\"SQ\" vm=\"1\">X-Ray 3D Reconstruction Sequence</tag>
    <tag group=\"0018\" element=\"9531\" keyword=\"ReconstructionDescription\" vr=\"LO\" vm=\"1\">Reconstruction Description</tag>
    <tag group=\"0018\" element=\"9538\" keyword=\"PerProjectionAcquisitionSequence\" vr=\"SQ\" vm=\"1\">Per Projection Acquisition Sequence</tag>
    <tag group=\"0018\" element=\"9541\" keyword=\"DetectorPositionSequence\" vr=\"SQ\" vm=\"1\">Detector Position Sequence</tag>
    <tag group=\"0018\" element=\"9542\" keyword=\"XRayAcquisitionDoseSequence\" vr=\"SQ\" vm=\"1\">X-Ray Acquisition Dose Sequence</tag>
    <tag group=\"0018\" element=\"9543\" keyword=\"XRaySourceIsocenterPrimaryAngle\" vr=\"FD\" vm=\"1\">X-Ray Source Isocenter Primary Angle</tag>
    <tag group=\"0018\" element=\"9544\" keyword=\"XRaySourceIsocenterSecondaryAngle\" vr=\"FD\" vm=\"1\">X-Ray Source Isocenter Secondary Angle</tag>
    <tag group=\"0018\" element=\"9545\" keyword=\"BreastSupportIsocenterPrimaryAngle\" vr=\"FD\" vm=\"1\">Breast Support Isocenter Primary Angle</tag>
    <tag group=\"0018\" element=\"9546\" keyword=\"BreastSupportIsocenterSecondaryAngle\" vr=\"FD\" vm=\"1\">Breast Support Isocenter Secondary Angle</tag>
    <tag group=\"0018\" element=\"9547\" keyword=\"BreastSupportXPositionToIsocenter\" vr=\"FD\" vm=\"1\">Breast Support X Position to Isocenter</tag>
    <tag group=\"0018\" element=\"9548\" keyword=\"BreastSupportYPositionToIsocenter\" vr=\"FD\" vm=\"1\">Breast Support Y Position to Isocenter</tag>
    <tag group=\"0018\" element=\"9549\" keyword=\"BreastSupportZPositionToIsocenter\" vr=\"FD\" vm=\"1\">Breast Support Z Position to Isocenter</tag>
    <tag group=\"0018\" element=\"9550\" keyword=\"DetectorIsocenterPrimaryAngle\" vr=\"FD\" vm=\"1\">Detector Isocenter Primary Angle</tag>
    <tag group=\"0018\" element=\"9551\" keyword=\"DetectorIsocenterSecondaryAngle\" vr=\"FD\" vm=\"1\">Detector Isocenter Secondary Angle</tag>
    <tag group=\"0018\" element=\"9552\" keyword=\"DetectorXPositionToIsocenter\" vr=\"FD\" vm=\"1\">Detector X Position to Isocenter</tag>
    <tag group=\"0018\" element=\"9553\" keyword=\"DetectorYPositionToIsocenter\" vr=\"FD\" vm=\"1\">Detector Y Position to Isocenter</tag>
    <tag group=\"0018\" element=\"9554\" keyword=\"DetectorZPositionToIsocenter\" vr=\"FD\" vm=\"1\">Detector Z Position to Isocenter</tag>
    <tag group=\"0018\" element=\"9555\" keyword=\"XRayGridSequence\" vr=\"SQ\" vm=\"1\">X-Ray Grid Sequence</tag>
    <tag group=\"0018\" element=\"9556\" keyword=\"XRayFilterSequence\" vr=\"SQ\" vm=\"1\">X-Ray Filter Sequence</tag>
    <tag group=\"0018\" element=\"9557\" keyword=\"DetectorActiveAreaTLHCPosition\" vr=\"FD\" vm=\"3\">Detector Active Area TLHC Position</tag>
    <tag group=\"0018\" element=\"9558\" keyword=\"DetectorActiveAreaOrientation\" vr=\"FD\" vm=\"6\">Detector Active Area Orientation</tag>
    <tag group=\"0018\" element=\"9559\" keyword=\"PositionerPrimaryAngleDirection\" vr=\"CS\" vm=\"1\">Positioner Primary Angle Direction</tag>
    <tag group=\"0018\" element=\"9601\" keyword=\"DiffusionBMatrixSequence\" vr=\"SQ\" vm=\"1\">Diffusion b-matrix Sequence</tag>
    <tag group=\"0018\" element=\"9602\" keyword=\"DiffusionBValueXX\" vr=\"FD\" vm=\"1\">Diffusion b-value XX</tag>
    <tag group=\"0018\" element=\"9603\" keyword=\"DiffusionBValueXY\" vr=\"FD\" vm=\"1\">Diffusion b-value XY</tag>
    <tag group=\"0018\" element=\"9604\" keyword=\"DiffusionBValueXZ\" vr=\"FD\" vm=\"1\">Diffusion b-value XZ</tag>
    <tag group=\"0018\" element=\"9605\" keyword=\"DiffusionBValueYY\" vr=\"FD\" vm=\"1\">Diffusion b-value YY</tag>
    <tag group=\"0018\" element=\"9606\" keyword=\"DiffusionBValueYZ\" vr=\"FD\" vm=\"1\">Diffusion b-value YZ</tag>
    <tag group=\"0018\" element=\"9607\" keyword=\"DiffusionBValueZZ\" vr=\"FD\" vm=\"1\">Diffusion b-value ZZ</tag>
    <tag group=\"0018\" element=\"9621\" keyword=\"FunctionalMRSequence\" vr=\"SQ\" vm=\"1\">Functional MR Sequence</tag>
    <tag group=\"0018\" element=\"9622\" keyword=\"FunctionalSettlingPhaseFramesPresent\" vr=\"CS\" vm=\"1\">Functional Settling Phase Frames Present</tag>
    <tag group=\"0018\" element=\"9623\" keyword=\"FunctionalSyncPulse\" vr=\"DT\" vm=\"1\">Functional Sync Pulse</tag>
    <tag group=\"0018\" element=\"9624\" keyword=\"SettlingPhaseFrame\" vr=\"CS\" vm=\"1\">Settling Phase Frame</tag>
    <tag group=\"0018\" element=\"9701\" keyword=\"DecayCorrectionDateTime\" vr=\"DT\" vm=\"1\">Decay Correction DateTime</tag>
    <tag group=\"0018\" element=\"9715\" keyword=\"StartDensityThreshold\" vr=\"FD\" vm=\"1\">Start Density Threshold</tag>
    <tag group=\"0018\" element=\"9716\" keyword=\"StartRelativeDensityDifferenceThreshold\" vr=\"FD\" vm=\"1\">Start Relative Density Difference Threshold</tag>
    <tag group=\"0018\" element=\"9717\" keyword=\"StartCardiacTriggerCountThreshold\" vr=\"FD\" vm=\"1\">Start Cardiac Trigger Count Threshold</tag>
    <tag group=\"0018\" element=\"9718\" keyword=\"StartRespiratoryTriggerCountThreshold\" vr=\"FD\" vm=\"1\">Start Respiratory Trigger Count Threshold</tag>
    <tag group=\"0018\" element=\"9719\" keyword=\"TerminationCountsThreshold\" vr=\"FD\" vm=\"1\">Termination Counts Threshold</tag>
    <tag group=\"0018\" element=\"9720\" keyword=\"TerminationDensityThreshold\" vr=\"FD\" vm=\"1\">Termination Density Threshold</tag>
    <tag group=\"0018\" element=\"9721\" keyword=\"TerminationRelativeDensityThreshold\" vr=\"FD\" vm=\"1\">Termination Relative Density Threshold</tag>
    <tag group=\"0018\" element=\"9722\" keyword=\"TerminationTimeThreshold\" vr=\"FD\" vm=\"1\">Termination Time Threshold</tag>
    <tag group=\"0018\" element=\"9723\" keyword=\"TerminationCardiacTriggerCountThreshold\" vr=\"FD\" vm=\"1\">Termination Cardiac Trigger Count Threshold</tag>
    <tag group=\"0018\" element=\"9724\" keyword=\"TerminationRespiratoryTriggerCountThreshold\" vr=\"FD\" vm=\"1\">Termination Respiratory Trigger Count Threshold</tag>
    <tag group=\"0018\" element=\"9725\" keyword=\"DetectorGeometry\" vr=\"CS\" vm=\"1\">Detector Geometry</tag>
    <tag group=\"0018\" element=\"9726\" keyword=\"TransverseDetectorSeparation\" vr=\"FD\" vm=\"1\">Transverse Detector Separation</tag>
    <tag group=\"0018\" element=\"9727\" keyword=\"AxialDetectorDimension\" vr=\"FD\" vm=\"1\">Axial Detector Dimension</tag>
    <tag group=\"0018\" element=\"9729\" keyword=\"RadiopharmaceuticalAgentNumber\" vr=\"US\" vm=\"1\">Radiopharmaceutical Agent Number</tag>
    <tag group=\"0018\" element=\"9732\" keyword=\"PETFrameAcquisitionSequence\" vr=\"SQ\" vm=\"1\">PET Frame Acquisition Sequence</tag>
    <tag group=\"0018\" element=\"9733\" keyword=\"PETDetectorMotionDetailsSequence\" vr=\"SQ\" vm=\"1\">PET Detector Motion Details Sequence</tag>
    <tag group=\"0018\" element=\"9734\" keyword=\"PETTableDynamicsSequence\" vr=\"SQ\" vm=\"1\">PET Table Dynamics Sequence</tag>
    <tag group=\"0018\" element=\"9735\" keyword=\"PETPositionSequence\" vr=\"SQ\" vm=\"1\">PET Position Sequence</tag>
    <tag group=\"0018\" element=\"9736\" keyword=\"PETFrameCorrectionFactorsSequence\" vr=\"SQ\" vm=\"1\">PET Frame Correction Factors Sequence</tag>
    <tag group=\"0018\" element=\"9737\" keyword=\"RadiopharmaceuticalUsageSequence\" vr=\"SQ\" vm=\"1\">Radiopharmaceutical Usage Sequence</tag>
    <tag group=\"0018\" element=\"9738\" keyword=\"AttenuationCorrectionSource\" vr=\"CS\" vm=\"1\">Attenuation Correction Source</tag>
    <tag group=\"0018\" element=\"9739\" keyword=\"NumberOfIterations\" vr=\"US\" vm=\"1\">Number of Iterations</tag>
    <tag group=\"0018\" element=\"9740\" keyword=\"NumberOfSubsets\" vr=\"US\" vm=\"1\">Number of Subsets</tag>
    <tag group=\"0018\" element=\"9749\" keyword=\"PETReconstructionSequence\" vr=\"SQ\" vm=\"1\">PET Reconstruction Sequence</tag>
    <tag group=\"0018\" element=\"9751\" keyword=\"PETFrameTypeSequence\" vr=\"SQ\" vm=\"1\">PET Frame Type Sequence</tag>
    <tag group=\"0018\" element=\"9755\" keyword=\"TimeOfFlightInformationUsed\" vr=\"CS\" vm=\"1\">Time of Flight Information Used</tag>
    <tag group=\"0018\" element=\"9756\" keyword=\"ReconstructionType\" vr=\"CS\" vm=\"1\">Reconstruction Type</tag>
    <tag group=\"0018\" element=\"9758\" keyword=\"DecayCorrected\" vr=\"CS\" vm=\"1\">Decay Corrected</tag>
    <tag group=\"0018\" element=\"9759\" keyword=\"AttenuationCorrected\" vr=\"CS\" vm=\"1\">Attenuation Corrected</tag>
    <tag group=\"0018\" element=\"9760\" keyword=\"ScatterCorrected\" vr=\"CS\" vm=\"1\">Scatter Corrected</tag>
    <tag group=\"0018\" element=\"9761\" keyword=\"DeadTimeCorrected\" vr=\"CS\" vm=\"1\">Dead Time Corrected</tag>
    <tag group=\"0018\" element=\"9762\" keyword=\"GantryMotionCorrected\" vr=\"CS\" vm=\"1\">Gantry Motion Corrected</tag>
    <tag group=\"0018\" element=\"9763\" keyword=\"PatientMotionCorrected\" vr=\"CS\" vm=\"1\">Patient Motion Corrected</tag>
    <tag group=\"0018\" element=\"9764\" keyword=\"CountLossNormalizationCorrected\" vr=\"CS\" vm=\"1\">Count Loss Normalization Corrected</tag>
    <tag group=\"0018\" element=\"9765\" keyword=\"RandomsCorrected\" vr=\"CS\" vm=\"1\">Randoms Corrected</tag>
    <tag group=\"0018\" element=\"9766\" keyword=\"NonUniformRadialSamplingCorrected\" vr=\"CS\" vm=\"1\">Non-uniform Radial Sampling Corrected</tag>
    <tag group=\"0018\" element=\"9767\" keyword=\"SensitivityCalibrated\" vr=\"CS\" vm=\"1\">Sensitivity Calibrated</tag>
    <tag group=\"0018\" element=\"9768\" keyword=\"DetectorNormalizationCorrection\" vr=\"CS\" vm=\"1\">Detector Normalization Correction</tag>
    <tag group=\"0018\" element=\"9769\" keyword=\"IterativeReconstructionMethod\" vr=\"CS\" vm=\"1\">Iterative Reconstruction Method</tag>
    <tag group=\"0018\" element=\"9770\" keyword=\"AttenuationCorrectionTemporalRelationship\" vr=\"CS\" vm=\"1\">Attenuation Correction Temporal Relationship</tag>
    <tag group=\"0018\" element=\"9771\" keyword=\"PatientPhysiologicalStateSequence\" vr=\"SQ\" vm=\"1\">Patient Physiological State Sequence</tag>
    <tag group=\"0018\" element=\"9772\" keyword=\"PatientPhysiologicalStateCodeSequence\" vr=\"SQ\" vm=\"1\">Patient Physiological State Code Sequence</tag>
    <tag group=\"0018\" element=\"9801\" keyword=\"DepthsOfFocus\" vr=\"FD\" vm=\"1-n\">Depth(s) of Focus</tag>
    <tag group=\"0018\" element=\"9803\" keyword=\"ExcludedIntervalsSequence\" vr=\"SQ\" vm=\"1\">Excluded Intervals Sequence</tag>
    <tag group=\"0018\" element=\"9804\" keyword=\"ExclusionStartDateTime\" vr=\"DT\" vm=\"1\">Exclusion Start DateTime</tag>
    <tag group=\"0018\" element=\"9805\" keyword=\"ExclusionDuration\" vr=\"FD\" vm=\"1\">Exclusion Duration</tag>
    <tag group=\"0018\" element=\"9806\" keyword=\"USImageDescriptionSequence\" vr=\"SQ\" vm=\"1\">US Image Description Sequence</tag>
    <tag group=\"0018\" element=\"9807\" keyword=\"ImageDataTypeSequence\" vr=\"SQ\" vm=\"1\">Image Data Type Sequence</tag>
    <tag group=\"0018\" element=\"9808\" keyword=\"DataType\" vr=\"CS\" vm=\"1\">Data Type</tag>
    <tag group=\"0018\" element=\"9809\" keyword=\"TransducerScanPatternCodeSequence\" vr=\"SQ\" vm=\"1\">Transducer Scan Pattern Code Sequence</tag>
    <tag group=\"0018\" element=\"980B\" keyword=\"AliasedDataType\" vr=\"CS\" vm=\"1\">Aliased Data Type</tag>
    <tag group=\"0018\" element=\"980C\" keyword=\"PositionMeasuringDeviceUsed\" vr=\"CS\" vm=\"1\">Position Measuring Device Used</tag>
    <tag group=\"0018\" element=\"980D\" keyword=\"TransducerGeometryCodeSequence\" vr=\"SQ\" vm=\"1\">Transducer Geometry Code Sequence</tag>
    <tag group=\"0018\" element=\"980E\" keyword=\"TransducerBeamSteeringCodeSequence\" vr=\"SQ\" vm=\"1\">Transducer Beam Steering Code Sequence</tag>
    <tag group=\"0018\" element=\"980F\" keyword=\"TransducerApplicationCodeSequence\" vr=\"SQ\" vm=\"1\">Transducer Application Code Sequence</tag>
    <tag group=\"0018\" element=\"9810\" keyword=\"ZeroVelocityPixelValue\" vr=\"US/SS\" vm=\"1\">Zero Velocity Pixel Value</tag>
    <tag group=\"0018\" element=\"9900\" keyword=\"ReferenceLocationLabel\" vr=\"LO\" vm=\"1\">Reference Location Label</tag>
    <tag group=\"0018\" element=\"9901\" keyword=\"ReferenceLocationDescription\" vr=\"UT\" vm=\"1\">Reference Location Description</tag>
    <tag group=\"0018\" element=\"9902\" keyword=\"ReferenceBasisCodeSequence\" vr=\"SQ\" vm=\"1\">Reference Basis Code Sequence</tag>
    <tag group=\"0018\" element=\"9903\" keyword=\"ReferenceGeometryCodeSequence\" vr=\"SQ\" vm=\"1\">Reference Geometry Code Sequence</tag>
    <tag group=\"0018\" element=\"9904\" keyword=\"OffsetDistance\" vr=\"DS\" vm=\"1\">Offset Distance</tag>
    <tag group=\"0018\" element=\"9905\" keyword=\"OffsetDirection\" vr=\"CS\" vm=\"1\">Offset Direction</tag>
    <tag group=\"0018\" element=\"9906\" keyword=\"PotentialScheduledProtocolCodeSequence\" vr=\"SQ\" vm=\"1\">Potential Scheduled Protocol Code Sequence</tag>
    <tag group=\"0018\" element=\"9907\" keyword=\"PotentialRequestedProcedureCodeSequence\" vr=\"SQ\" vm=\"1\">Potential Requested Procedure Code Sequence</tag>
    <tag group=\"0018\" element=\"9908\" keyword=\"PotentialReasonsForProcedure\" vr=\"UC\" vm=\"1-n\">Potential Reasons for Procedure</tag>
    <tag group=\"0018\" element=\"9909\" keyword=\"PotentialReasonsForProcedureCodeSequence\" vr=\"SQ\" vm=\"1\">Potential Reasons for Procedure Code Sequence</tag>
    <tag group=\"0018\" element=\"990A\" keyword=\"PotentialDiagnosticTasks\" vr=\"UC\" vm=\"1-n\">Potential Diagnostic Tasks</tag>
    <tag group=\"0018\" element=\"990B\" keyword=\"ContraindicationsCodeSequence\" vr=\"SQ\" vm=\"1\">Contraindications Code Sequence</tag>
    <tag group=\"0018\" element=\"990C\" keyword=\"ReferencedDefinedProtocolSequence\" vr=\"SQ\" vm=\"1\">Referenced Defined Protocol Sequence</tag>
    <tag group=\"0018\" element=\"990D\" keyword=\"ReferencedPerformedProtocolSequence\" vr=\"SQ\" vm=\"1\">Referenced Performed Protocol Sequence</tag>
    <tag group=\"0018\" element=\"990E\" keyword=\"PredecessorProtocolSequence\" vr=\"SQ\" vm=\"1\">Predecessor Protocol Sequence</tag>
    <tag group=\"0018\" element=\"990F\" keyword=\"ProtocolPlanningInformation\" vr=\"UT\" vm=\"1\">Protocol Planning Information</tag>
    <tag group=\"0018\" element=\"9910\" keyword=\"ProtocolDesignRationale\" vr=\"UT\" vm=\"1\">Protocol Design Rationale</tag>
    <tag group=\"0018\" element=\"9911\" keyword=\"PatientSpecificationSequence\" vr=\"SQ\" vm=\"1\">Patient Specification Sequence</tag>
    <tag group=\"0018\" element=\"9912\" keyword=\"ModelSpecificationSequence\" vr=\"SQ\" vm=\"1\">Model Specification Sequence</tag>
    <tag group=\"0018\" element=\"9913\" keyword=\"ParametersSpecificationSequence\" vr=\"SQ\" vm=\"1\">Parameters Specification Sequence</tag>
    <tag group=\"0018\" element=\"9914\" keyword=\"InstructionSequence\" vr=\"SQ\" vm=\"1\">Instruction Sequence</tag>
    <tag group=\"0018\" element=\"9915\" keyword=\"InstructionIndex\" vr=\"US\" vm=\"1\">Instruction Index</tag>
    <tag group=\"0018\" element=\"9916\" keyword=\"InstructionText\" vr=\"LO\" vm=\"1\">Instruction Text</tag>
    <tag group=\"0018\" element=\"9917\" keyword=\"InstructionDescription\" vr=\"UT\" vm=\"1\">Instruction Description</tag>
    <tag group=\"0018\" element=\"9918\" keyword=\"InstructionPerformedFlag\" vr=\"CS\" vm=\"1\">Instruction Performed Flag</tag>
    <tag group=\"0018\" element=\"9919\" keyword=\"InstructionPerformedDateTime\" vr=\"DT\" vm=\"1\">Instruction Performed DateTime</tag>
    <tag group=\"0018\" element=\"991A\" keyword=\"InstructionPerformanceComment\" vr=\"UT\" vm=\"1\">Instruction Performance Comment</tag>
    <tag group=\"0018\" element=\"991B\" keyword=\"PatientPositioningInstructionSequence\" vr=\"SQ\" vm=\"1\">Patient Positioning Instruction Sequence</tag>
    <tag group=\"0018\" element=\"991C\" keyword=\"PositioningMethodCodeSequence\" vr=\"SQ\" vm=\"1\">Positioning Method Code Sequence</tag>
    <tag group=\"0018\" element=\"991D\" keyword=\"PositioningLandmarkSequence\" vr=\"SQ\" vm=\"1\">Positioning Landmark Sequence</tag>
    <tag group=\"0018\" element=\"991E\" keyword=\"TargetFrameOfReferenceUID\" vr=\"UI\" vm=\"1\">Target Frame of Reference UID</tag>
    <tag group=\"0018\" element=\"991F\" keyword=\"AcquisitionProtocolElementSpecificationSequence\" vr=\"SQ\" vm=\"1\">Acquisition Protocol Element Specification Sequence</tag>
    <tag group=\"0018\" element=\"9920\" keyword=\"AcquisitionProtocolElementSequence\" vr=\"SQ\" vm=\"1\">Acquisition Protocol Element Sequence</tag>
    <tag group=\"0018\" element=\"9921\" keyword=\"ProtocolElementNumber\" vr=\"US\" vm=\"1\">Protocol Element Number</tag>
    <tag group=\"0018\" element=\"9922\" keyword=\"ProtocolElementName\" vr=\"LO\" vm=\"1\">Protocol Element Name</tag>
    <tag group=\"0018\" element=\"9923\" keyword=\"ProtocolElementCharacteristicsSummary\" vr=\"UT\" vm=\"1\">Protocol Element Characteristics Summary</tag>
    <tag group=\"0018\" element=\"9924\" keyword=\"ProtocolElementPurpose\" vr=\"UT\" vm=\"1\">Protocol Element Purpose</tag>
    <tag group=\"0018\" element=\"9930\" keyword=\"AcquisitionMotion\" vr=\"CS\" vm=\"1\">Acquisition Motion</tag>
    <tag group=\"0018\" element=\"9931\" keyword=\"AcquisitionStartLocationSequence\" vr=\"SQ\" vm=\"1\">Acquisition Start Location Sequence</tag>
    <tag group=\"0018\" element=\"9932\" keyword=\"AcquisitionEndLocationSequence\" vr=\"SQ\" vm=\"1\">Acquisition End Location Sequence</tag>
    <tag group=\"0018\" element=\"9933\" keyword=\"ReconstructionProtocolElementSpecificationSequence\" vr=\"SQ\" vm=\"1\">Reconstruction Protocol Element Specification Sequence</tag>
    <tag group=\"0018\" element=\"9934\" keyword=\"ReconstructionProtocolElementSequence\" vr=\"SQ\" vm=\"1\">Reconstruction Protocol Element Sequence</tag>
    <tag group=\"0018\" element=\"9935\" keyword=\"StorageProtocolElementSpecificationSequence\" vr=\"SQ\" vm=\"1\">Storage Protocol Element Specification Sequence</tag>
    <tag group=\"0018\" element=\"9936\" keyword=\"StorageProtocolElementSequence\" vr=\"SQ\" vm=\"1\">Storage Protocol Element Sequence</tag>
    <tag group=\"0018\" element=\"9937\" keyword=\"RequestedSeriesDescription\" vr=\"LO\" vm=\"1\">Requested Series Description</tag>
    <tag group=\"0018\" element=\"9938\" keyword=\"SourceAcquisitionProtocolElementNumber\" vr=\"US\" vm=\"1-n\">Source Acquisition Protocol Element Number</tag>
    <tag group=\"0018\" element=\"9939\" keyword=\"SourceAcquisitionBeamNumber\" vr=\"US\" vm=\"1-n\">Source Acquisition Beam Number</tag>
    <tag group=\"0018\" element=\"993A\" keyword=\"SourceReconstructionProtocolElementNumber\" vr=\"US\" vm=\"1-n\">Source Reconstruction Protocol Element Number</tag>
    <tag group=\"0018\" element=\"993B\" keyword=\"ReconstructionStartLocationSequence\" vr=\"SQ\" vm=\"1\">Reconstruction Start Location Sequence</tag>
    <tag group=\"0018\" element=\"993C\" keyword=\"ReconstructionEndLocationSequence\" vr=\"SQ\" vm=\"1\">Reconstruction End Location Sequence</tag>
    <tag group=\"0018\" element=\"993D\" keyword=\"ReconstructionAlgorithmSequence\" vr=\"SQ\" vm=\"1\">Reconstruction Algorithm Sequence</tag>
    <tag group=\"0018\" element=\"993E\" keyword=\"ReconstructionTargetCenterLocationSequence\" vr=\"SQ\" vm=\"1\">Reconstruction Target Center Location Sequence</tag>
    <tag group=\"0018\" element=\"9941\" keyword=\"ImageFilterDescription\" vr=\"UT\" vm=\"1\">Image Filter Description</tag>
    <tag group=\"0018\" element=\"9942\" keyword=\"CTDIvolNotificationTrigger\" vr=\"FD\" vm=\"1\">CTDIvol Notification Trigger</tag>
    <tag group=\"0018\" element=\"9943\" keyword=\"DLPNotificationTrigger\" vr=\"FD\" vm=\"1\">DLP Notification Trigger</tag>
    <tag group=\"0018\" element=\"9944\" keyword=\"AutoKVPSelectionType\" vr=\"CS\" vm=\"1\">Auto KVP Selection Type</tag>
    <tag group=\"0018\" element=\"9945\" keyword=\"AutoKVPUpperBound\" vr=\"FD\" vm=\"1\">Auto KVP Upper Bound</tag>
    <tag group=\"0018\" element=\"9946\" keyword=\"AutoKVPLowerBound\" vr=\"FD\" vm=\"1\">Auto KVP Lower Bound</tag>
    <tag group=\"0018\" element=\"9947\" keyword=\"ProtocolDefinedPatientPosition\" vr=\"CS\" vm=\"1\">Protocol Defined Patient Position</tag>
    <tag group=\"0018\" element=\"A001\" keyword=\"ContributingEquipmentSequence\" vr=\"SQ\" vm=\"1\">Contributing Equipment Sequence</tag>
    <tag group=\"0018\" element=\"A002\" keyword=\"ContributionDateTime\" vr=\"DT\" vm=\"1\">Contribution DateTime</tag>
    <tag group=\"0018\" element=\"A003\" keyword=\"ContributionDescription\" vr=\"ST\" vm=\"1\">Contribution Description</tag>
    <tag group=\"0020\" element=\"000D\" keyword=\"StudyInstanceUID\" vr=\"UI\" vm=\"1\">Study Instance UID</tag>
    <tag group=\"0020\" element=\"000E\" keyword=\"SeriesInstanceUID\" vr=\"UI\" vm=\"1\">Series Instance UID</tag>
    <tag group=\"0020\" element=\"0010\" keyword=\"StudyID\" vr=\"SH\" vm=\"1\">Study ID</tag>
    <tag group=\"0020\" element=\"0011\" keyword=\"SeriesNumber\" vr=\"IS\" vm=\"1\">Series Number</tag>
    <tag group=\"0020\" element=\"0012\" keyword=\"AcquisitionNumber\" vr=\"IS\" vm=\"1\">Acquisition Number</tag>
    <tag group=\"0020\" element=\"0013\" keyword=\"InstanceNumber\" vr=\"IS\" vm=\"1\">Instance Number</tag>
    <tag group=\"0020\" element=\"0014\" keyword=\"IsotopeNumber\" vr=\"IS\" vm=\"1\" retired=\"true\">Isotope Number</tag>
    <tag group=\"0020\" element=\"0015\" keyword=\"PhaseNumber\" vr=\"IS\" vm=\"1\" retired=\"true\">Phase Number</tag>
    <tag group=\"0020\" element=\"0016\" keyword=\"IntervalNumber\" vr=\"IS\" vm=\"1\" retired=\"true\">Interval Number</tag>
    <tag group=\"0020\" element=\"0017\" keyword=\"TimeSlotNumber\" vr=\"IS\" vm=\"1\" retired=\"true\">Time Slot Number</tag>
    <tag group=\"0020\" element=\"0018\" keyword=\"AngleNumber\" vr=\"IS\" vm=\"1\" retired=\"true\">Angle Number</tag>
    <tag group=\"0020\" element=\"0019\" keyword=\"ItemNumber\" vr=\"IS\" vm=\"1\">Item Number</tag>
    <tag group=\"0020\" element=\"0020\" keyword=\"PatientOrientation\" vr=\"CS\" vm=\"2\">Patient Orientation</tag>
    <tag group=\"0020\" element=\"0022\" keyword=\"OverlayNumber\" vr=\"IS\" vm=\"1\" retired=\"true\">Overlay Number</tag>
    <tag group=\"0020\" element=\"0024\" keyword=\"CurveNumber\" vr=\"IS\" vm=\"1\" retired=\"true\">Curve Number</tag>
    <tag group=\"0020\" element=\"0026\" keyword=\"LUTNumber\" vr=\"IS\" vm=\"1\" retired=\"true\">LUT Number</tag>
    <tag group=\"0020\" element=\"0030\" keyword=\"ImagePosition\" vr=\"DS\" vm=\"3\" retired=\"true\">Image Position</tag>
    <tag group=\"0020\" element=\"0032\" keyword=\"ImagePositionPatient\" vr=\"DS\" vm=\"3\">Image Position (Patient)</tag>
    <tag group=\"0020\" element=\"0035\" keyword=\"ImageOrientation\" vr=\"DS\" vm=\"6\" retired=\"true\">Image Orientation</tag>
    <tag group=\"0020\" element=\"0037\" keyword=\"ImageOrientationPatient\" vr=\"DS\" vm=\"6\">Image Orientation (Patient)</tag>
    <tag group=\"0020\" element=\"0050\" keyword=\"Location\" vr=\"DS\" vm=\"1\" retired=\"true\">Location</tag>
    <tag group=\"0020\" element=\"0052\" keyword=\"FrameOfReferenceUID\" vr=\"UI\" vm=\"1\">Frame of Reference UID</tag>
    <tag group=\"0020\" element=\"0060\" keyword=\"Laterality\" vr=\"CS\" vm=\"1\">Laterality</tag>
    <tag group=\"0020\" element=\"0062\" keyword=\"ImageLaterality\" vr=\"CS\" vm=\"1\">Image Laterality</tag>
    <tag group=\"0020\" element=\"0070\" keyword=\"ImageGeometryType\" vr=\"LO\" vm=\"1\" retired=\"true\">Image Geometry Type</tag>
    <tag group=\"0020\" element=\"0080\" keyword=\"MaskingImage\" vr=\"CS\" vm=\"1-n\" retired=\"true\">Masking Image</tag>
    <tag group=\"0020\" element=\"00AA\" keyword=\"ReportNumber\" vr=\"IS\" vm=\"1\" retired=\"true\">Report Number</tag>
    <tag group=\"0020\" element=\"0100\" keyword=\"TemporalPositionIdentifier\" vr=\"IS\" vm=\"1\">Temporal Position Identifier</tag>
    <tag group=\"0020\" element=\"0105\" keyword=\"NumberOfTemporalPositions\" vr=\"IS\" vm=\"1\">Number of Temporal Positions</tag>
    <tag group=\"0020\" element=\"0110\" keyword=\"TemporalResolution\" vr=\"DS\" vm=\"1\">Temporal Resolution</tag>
    <tag group=\"0020\" element=\"0200\" keyword=\"SynchronizationFrameOfReferenceUID\" vr=\"UI\" vm=\"1\">Synchronization Frame of Reference UID</tag>
    <tag group=\"0020\" element=\"0242\" keyword=\"SOPInstanceUIDOfConcatenationSource\" vr=\"UI\" vm=\"1\">SOP Instance UID of Concatenation Source</tag>
    <tag group=\"0020\" element=\"1000\" keyword=\"SeriesInStudy\" vr=\"IS\" vm=\"1\" retired=\"true\">Series in Study</tag>
    <tag group=\"0020\" element=\"1001\" keyword=\"AcquisitionsInSeries\" vr=\"IS\" vm=\"1\" retired=\"true\">Acquisitions in Series</tag>
    <tag group=\"0020\" element=\"1002\" keyword=\"ImagesInAcquisition\" vr=\"IS\" vm=\"1\">Images in Acquisition</tag>
    <tag group=\"0020\" element=\"1003\" keyword=\"ImagesInSeries\" vr=\"IS\" vm=\"1\" retired=\"true\">Images in Series</tag>
    <tag group=\"0020\" element=\"1004\" keyword=\"AcquisitionsInStudy\" vr=\"IS\" vm=\"1\" retired=\"true\">Acquisitions in Study</tag>
    <tag group=\"0020\" element=\"1005\" keyword=\"ImagesInStudy\" vr=\"IS\" vm=\"1\" retired=\"true\">Images in Study</tag>
    <tag group=\"0020\" element=\"1020\" keyword=\"Reference\" vr=\"LO\" vm=\"1-n\" retired=\"true\">Reference</tag>
    <tag group=\"0020\" element=\"103F\" keyword=\"TargetPositionReferenceIndicator\" vr=\"LO\" vm=\"1\">Target Position Reference Indicator</tag>
    <tag group=\"0020\" element=\"1040\" keyword=\"PositionReferenceIndicator\" vr=\"LO\" vm=\"1\">Position Reference Indicator</tag>
    <tag group=\"0020\" element=\"1041\" keyword=\"SliceLocation\" vr=\"DS\" vm=\"1\">Slice Location</tag>
    <tag group=\"0020\" element=\"1070\" keyword=\"OtherStudyNumbers\" vr=\"IS\" vm=\"1-n\" retired=\"true\">Other Study Numbers</tag>
    <tag group=\"0020\" element=\"1200\" keyword=\"NumberOfPatientRelatedStudies\" vr=\"IS\" vm=\"1\">Number of Patient Related Studies</tag>
    <tag group=\"0020\" element=\"1202\" keyword=\"NumberOfPatientRelatedSeries\" vr=\"IS\" vm=\"1\">Number of Patient Related Series</tag>
    <tag group=\"0020\" element=\"1204\" keyword=\"NumberOfPatientRelatedInstances\" vr=\"IS\" vm=\"1\">Number of Patient Related Instances</tag>
    <tag group=\"0020\" element=\"1206\" keyword=\"NumberOfStudyRelatedSeries\" vr=\"IS\" vm=\"1\">Number of Study Related Series</tag>
    <tag group=\"0020\" element=\"1208\" keyword=\"NumberOfStudyRelatedInstances\" vr=\"IS\" vm=\"1\">Number of Study Related Instances</tag>
    <tag group=\"0020\" element=\"1209\" keyword=\"NumberOfSeriesRelatedInstances\" vr=\"IS\" vm=\"1\">Number of Series Related Instances</tag>
    <tag group=\"0020\" element=\"31xx\" keyword=\"SourceImageIDs\" vr=\"CS\" vm=\"1-n\" retired=\"true\">Source Image IDs</tag>
    <tag group=\"0020\" element=\"3401\" keyword=\"ModifyingDeviceID\" vr=\"CS\" vm=\"1\" retired=\"true\">Modifying Device ID</tag>
    <tag group=\"0020\" element=\"3402\" keyword=\"ModifiedImageID\" vr=\"CS\" vm=\"1\" retired=\"true\">Modified Image ID</tag>
    <tag group=\"0020\" element=\"3403\" keyword=\"ModifiedImageDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Modified Image Date</tag>
    <tag group=\"0020\" element=\"3404\" keyword=\"ModifyingDeviceManufacturer\" vr=\"LO\" vm=\"1\" retired=\"true\">Modifying Device Manufacturer</tag>
    <tag group=\"0020\" element=\"3405\" keyword=\"ModifiedImageTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Modified Image Time</tag>
    <tag group=\"0020\" element=\"3406\" keyword=\"ModifiedImageDescription\" vr=\"LO\" vm=\"1\" retired=\"true\">Modified Image Description</tag>
    <tag group=\"0020\" element=\"4000\" keyword=\"ImageComments\" vr=\"LT\" vm=\"1\">Image Comments</tag>
    <tag group=\"0020\" element=\"5000\" keyword=\"OriginalImageIdentification\" vr=\"AT\" vm=\"1-n\" retired=\"true\">Original Image Identification</tag>
    <tag group=\"0020\" element=\"5002\" keyword=\"OriginalImageIdentificationNomenclature\" vr=\"LO\" vm=\"1-n\" retired=\"true\">Original Image Identification Nomenclature</tag>
    <tag group=\"0020\" element=\"9056\" keyword=\"StackID\" vr=\"SH\" vm=\"1\">Stack ID</tag>
    <tag group=\"0020\" element=\"9057\" keyword=\"InStackPositionNumber\" vr=\"UL\" vm=\"1\">In-Stack Position Number</tag>
    <tag group=\"0020\" element=\"9071\" keyword=\"FrameAnatomySequence\" vr=\"SQ\" vm=\"1\">Frame Anatomy Sequence</tag>
    <tag group=\"0020\" element=\"9072\" keyword=\"FrameLaterality\" vr=\"CS\" vm=\"1\">Frame Laterality</tag>
    <tag group=\"0020\" element=\"9111\" keyword=\"FrameContentSequence\" vr=\"SQ\" vm=\"1\">Frame Content Sequence</tag>
    <tag group=\"0020\" element=\"9113\" keyword=\"PlanePositionSequence\" vr=\"SQ\" vm=\"1\">Plane Position Sequence</tag>
    <tag group=\"0020\" element=\"9116\" keyword=\"PlaneOrientationSequence\" vr=\"SQ\" vm=\"1\">Plane Orientation Sequence</tag>
    <tag group=\"0020\" element=\"9128\" keyword=\"TemporalPositionIndex\" vr=\"UL\" vm=\"1\">Temporal Position Index</tag>
    <tag group=\"0020\" element=\"9153\" keyword=\"NominalCardiacTriggerDelayTime\" vr=\"FD\" vm=\"1\">Nominal Cardiac Trigger Delay Time</tag>
    <tag group=\"0020\" element=\"9154\" keyword=\"NominalCardiacTriggerTimePriorToRPeak\" vr=\"FL\" vm=\"1\">Nominal Cardiac Trigger Time Prior To R-Peak</tag>
    <tag group=\"0020\" element=\"9155\" keyword=\"ActualCardiacTriggerTimePriorToRPeak\" vr=\"FL\" vm=\"1\">Actual Cardiac Trigger Time Prior To R-Peak</tag>
    <tag group=\"0020\" element=\"9156\" keyword=\"FrameAcquisitionNumber\" vr=\"US\" vm=\"1\">Frame Acquisition Number</tag>
    <tag group=\"0020\" element=\"9157\" keyword=\"DimensionIndexValues\" vr=\"UL\" vm=\"1-n\">Dimension Index Values</tag>
    <tag group=\"0020\" element=\"9158\" keyword=\"FrameComments\" vr=\"LT\" vm=\"1\">Frame Comments</tag>
    <tag group=\"0020\" element=\"9161\" keyword=\"ConcatenationUID\" vr=\"UI\" vm=\"1\">Concatenation UID</tag>
    <tag group=\"0020\" element=\"9162\" keyword=\"InConcatenationNumber\" vr=\"US\" vm=\"1\">In-concatenation Number</tag>
    <tag group=\"0020\" element=\"9163\" keyword=\"InConcatenationTotalNumber\" vr=\"US\" vm=\"1\">In-concatenation Total Number</tag>
    <tag group=\"0020\" element=\"9164\" keyword=\"DimensionOrganizationUID\" vr=\"UI\" vm=\"1\">Dimension Organization UID</tag>
    <tag group=\"0020\" element=\"9165\" keyword=\"DimensionIndexPointer\" vr=\"AT\" vm=\"1\">Dimension Index Pointer</tag>
    <tag group=\"0020\" element=\"9167\" keyword=\"FunctionalGroupPointer\" vr=\"AT\" vm=\"1\">Functional Group Pointer</tag>
    <tag group=\"0020\" element=\"9170\" keyword=\"UnassignedSharedConvertedAttributesSequence\" vr=\"SQ\" vm=\"1\">Unassigned Shared Converted Attributes Sequence</tag>
    <tag group=\"0020\" element=\"9171\" keyword=\"UnassignedPerFrameConvertedAttributesSequence\" vr=\"SQ\" vm=\"1\">Unassigned Per-Frame Converted Attributes Sequence</tag>
    <tag group=\"0020\" element=\"9172\" keyword=\"ConversionSourceAttributesSequence\" vr=\"SQ\" vm=\"1\">Conversion Source Attributes Sequence</tag>
    <tag group=\"0020\" element=\"9213\" keyword=\"DimensionIndexPrivateCreator\" vr=\"LO\" vm=\"1\">Dimension Index Private Creator</tag>
    <tag group=\"0020\" element=\"9221\" keyword=\"DimensionOrganizationSequence\" vr=\"SQ\" vm=\"1\">Dimension Organization Sequence</tag>
    <tag group=\"0020\" element=\"9222\" keyword=\"DimensionIndexSequence\" vr=\"SQ\" vm=\"1\">Dimension Index Sequence</tag>
    <tag group=\"0020\" element=\"9228\" keyword=\"ConcatenationFrameOffsetNumber\" vr=\"UL\" vm=\"1\">Concatenation Frame Offset Number</tag>
    <tag group=\"0020\" element=\"9238\" keyword=\"FunctionalGroupPrivateCreator\" vr=\"LO\" vm=\"1\">Functional Group Private Creator</tag>
    <tag group=\"0020\" element=\"9241\" keyword=\"NominalPercentageOfCardiacPhase\" vr=\"FL\" vm=\"1\">Nominal Percentage of Cardiac Phase</tag>
    <tag group=\"0020\" element=\"9245\" keyword=\"NominalPercentageOfRespiratoryPhase\" vr=\"FL\" vm=\"1\">Nominal Percentage of Respiratory Phase</tag>
    <tag group=\"0020\" element=\"9246\" keyword=\"StartingRespiratoryAmplitude\" vr=\"FL\" vm=\"1\">Starting Respiratory Amplitude</tag>
    <tag group=\"0020\" element=\"9247\" keyword=\"StartingRespiratoryPhase\" vr=\"CS\" vm=\"1\">Starting Respiratory Phase</tag>
    <tag group=\"0020\" element=\"9248\" keyword=\"EndingRespiratoryAmplitude\" vr=\"FL\" vm=\"1\">Ending Respiratory Amplitude</tag>
    <tag group=\"0020\" element=\"9249\" keyword=\"EndingRespiratoryPhase\" vr=\"CS\" vm=\"1\">Ending Respiratory Phase</tag>
    <tag group=\"0020\" element=\"9250\" keyword=\"RespiratoryTriggerType\" vr=\"CS\" vm=\"1\">Respiratory Trigger Type</tag>
    <tag group=\"0020\" element=\"9251\" keyword=\"RRIntervalTimeNominal\" vr=\"FD\" vm=\"1\">R-R Interval Time Nominal</tag>
    <tag group=\"0020\" element=\"9252\" keyword=\"ActualCardiacTriggerDelayTime\" vr=\"FD\" vm=\"1\">Actual Cardiac Trigger Delay Time</tag>
    <tag group=\"0020\" element=\"9253\" keyword=\"RespiratorySynchronizationSequence\" vr=\"SQ\" vm=\"1\">Respiratory Synchronization Sequence</tag>
    <tag group=\"0020\" element=\"9254\" keyword=\"RespiratoryIntervalTime\" vr=\"FD\" vm=\"1\">Respiratory Interval Time</tag>
    <tag group=\"0020\" element=\"9255\" keyword=\"NominalRespiratoryTriggerDelayTime\" vr=\"FD\" vm=\"1\">Nominal Respiratory Trigger Delay Time</tag>
    <tag group=\"0020\" element=\"9256\" keyword=\"RespiratoryTriggerDelayThreshold\" vr=\"FD\" vm=\"1\">Respiratory Trigger Delay Threshold</tag>
    <tag group=\"0020\" element=\"9257\" keyword=\"ActualRespiratoryTriggerDelayTime\" vr=\"FD\" vm=\"1\">Actual Respiratory Trigger Delay Time</tag>
    <tag group=\"0020\" element=\"9301\" keyword=\"ImagePositionVolume\" vr=\"FD\" vm=\"3\">Image Position (Volume)</tag>
    <tag group=\"0020\" element=\"9302\" keyword=\"ImageOrientationVolume\" vr=\"FD\" vm=\"6\">Image Orientation (Volume)</tag>
    <tag group=\"0020\" element=\"9307\" keyword=\"UltrasoundAcquisitionGeometry\" vr=\"CS\" vm=\"1\">Ultrasound Acquisition Geometry</tag>
    <tag group=\"0020\" element=\"9308\" keyword=\"ApexPosition\" vr=\"FD\" vm=\"3\">Apex Position</tag>
    <tag group=\"0020\" element=\"9309\" keyword=\"VolumeToTransducerMappingMatrix\" vr=\"FD\" vm=\"16\">Volume to Transducer Mapping Matrix</tag>
    <tag group=\"0020\" element=\"930A\" keyword=\"VolumeToTableMappingMatrix\" vr=\"FD\" vm=\"16\">Volume to Table Mapping Matrix</tag>
    <tag group=\"0020\" element=\"930B\" keyword=\"VolumeToTransducerRelationship\" vr=\"CS\" vm=\"1\">Volume to Transducer Relationship</tag>
    <tag group=\"0020\" element=\"930C\" keyword=\"PatientFrameOfReferenceSource\" vr=\"CS\" vm=\"1\">Patient Frame of Reference Source</tag>
    <tag group=\"0020\" element=\"930D\" keyword=\"TemporalPositionTimeOffset\" vr=\"FD\" vm=\"1\">Temporal Position Time Offset</tag>
    <tag group=\"0020\" element=\"930E\" keyword=\"PlanePositionVolumeSequence\" vr=\"SQ\" vm=\"1\">Plane Position (Volume) Sequence</tag>
    <tag group=\"0020\" element=\"930F\" keyword=\"PlaneOrientationVolumeSequence\" vr=\"SQ\" vm=\"1\">Plane Orientation (Volume) Sequence</tag>
    <tag group=\"0020\" element=\"9310\" keyword=\"TemporalPositionSequence\" vr=\"SQ\" vm=\"1\">Temporal Position Sequence</tag>
    <tag group=\"0020\" element=\"9311\" keyword=\"DimensionOrganizationType\" vr=\"CS\" vm=\"1\">Dimension Organization Type</tag>
    <tag group=\"0020\" element=\"9312\" keyword=\"VolumeFrameOfReferenceUID\" vr=\"UI\" vm=\"1\">Volume Frame of Reference UID</tag>
    <tag group=\"0020\" element=\"9313\" keyword=\"TableFrameOfReferenceUID\" vr=\"UI\" vm=\"1\">Table Frame of Reference UID</tag>
    <tag group=\"0020\" element=\"9421\" keyword=\"DimensionDescriptionLabel\" vr=\"LO\" vm=\"1\">Dimension Description Label</tag>
    <tag group=\"0020\" element=\"9450\" keyword=\"PatientOrientationInFrameSequence\" vr=\"SQ\" vm=\"1\">Patient Orientation in Frame Sequence</tag>
    <tag group=\"0020\" element=\"9453\" keyword=\"FrameLabel\" vr=\"LO\" vm=\"1\">Frame Label</tag>
    <tag group=\"0020\" element=\"9518\" keyword=\"AcquisitionIndex\" vr=\"US\" vm=\"1-n\">Acquisition Index</tag>
    <tag group=\"0020\" element=\"9529\" keyword=\"ContributingSOPInstancesReferenceSequence\" vr=\"SQ\" vm=\"1\">Contributing SOP Instances Reference Sequence</tag>
    <tag group=\"0020\" element=\"9536\" keyword=\"ReconstructionIndex\" vr=\"US\" vm=\"1\">Reconstruction Index</tag>
    <tag group=\"0022\" element=\"0001\" keyword=\"LightPathFilterPassThroughWavelength\" vr=\"US\" vm=\"1\">Light Path Filter Pass-Through Wavelength</tag>
    <tag group=\"0022\" element=\"0002\" keyword=\"LightPathFilterPassBand\" vr=\"US\" vm=\"2\">Light Path Filter Pass Band</tag>
    <tag group=\"0022\" element=\"0003\" keyword=\"ImagePathFilterPassThroughWavelength\" vr=\"US\" vm=\"1\">Image Path Filter Pass-Through Wavelength</tag>
    <tag group=\"0022\" element=\"0004\" keyword=\"ImagePathFilterPassBand\" vr=\"US\" vm=\"2\">Image Path Filter Pass Band</tag>
    <tag group=\"0022\" element=\"0005\" keyword=\"PatientEyeMovementCommanded\" vr=\"CS\" vm=\"1\">Patient Eye Movement Commanded</tag>
    <tag group=\"0022\" element=\"0006\" keyword=\"PatientEyeMovementCommandCodeSequence\" vr=\"SQ\" vm=\"1\">Patient Eye Movement Command Code Sequence</tag>
    <tag group=\"0022\" element=\"0007\" keyword=\"SphericalLensPower\" vr=\"FL\" vm=\"1\">Spherical Lens Power</tag>
    <tag group=\"0022\" element=\"0008\" keyword=\"CylinderLensPower\" vr=\"FL\" vm=\"1\">Cylinder Lens Power</tag>
    <tag group=\"0022\" element=\"0009\" keyword=\"CylinderAxis\" vr=\"FL\" vm=\"1\">Cylinder Axis</tag>
    <tag group=\"0022\" element=\"000A\" keyword=\"EmmetropicMagnification\" vr=\"FL\" vm=\"1\">Emmetropic Magnification</tag>
    <tag group=\"0022\" element=\"000B\" keyword=\"IntraOcularPressure\" vr=\"FL\" vm=\"1\">Intra Ocular Pressure</tag>
    <tag group=\"0022\" element=\"000C\" keyword=\"HorizontalFieldOfView\" vr=\"FL\" vm=\"1\">Horizontal Field of View</tag>
    <tag group=\"0022\" element=\"000D\" keyword=\"PupilDilated\" vr=\"CS\" vm=\"1\">Pupil Dilated</tag>
    <tag group=\"0022\" element=\"000E\" keyword=\"DegreeOfDilation\" vr=\"FL\" vm=\"1\">Degree of Dilation</tag>
    <tag group=\"0022\" element=\"0010\" keyword=\"StereoBaselineAngle\" vr=\"FL\" vm=\"1\">Stereo Baseline Angle</tag>
    <tag group=\"0022\" element=\"0011\" keyword=\"StereoBaselineDisplacement\" vr=\"FL\" vm=\"1\">Stereo Baseline Displacement</tag>
    <tag group=\"0022\" element=\"0012\" keyword=\"StereoHorizontalPixelOffset\" vr=\"FL\" vm=\"1\">Stereo Horizontal Pixel Offset</tag>
    <tag group=\"0022\" element=\"0013\" keyword=\"StereoVerticalPixelOffset\" vr=\"FL\" vm=\"1\">Stereo Vertical Pixel Offset</tag>
    <tag group=\"0022\" element=\"0014\" keyword=\"StereoRotation\" vr=\"FL\" vm=\"1\">Stereo Rotation</tag>
    <tag group=\"0022\" element=\"0015\" keyword=\"AcquisitionDeviceTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Acquisition Device Type Code Sequence</tag>
    <tag group=\"0022\" element=\"0016\" keyword=\"IlluminationTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Illumination Type Code Sequence</tag>
    <tag group=\"0022\" element=\"0017\" keyword=\"LightPathFilterTypeStackCodeSequence\" vr=\"SQ\" vm=\"1\">Light Path Filter Type Stack Code Sequence</tag>
    <tag group=\"0022\" element=\"0018\" keyword=\"ImagePathFilterTypeStackCodeSequence\" vr=\"SQ\" vm=\"1\">Image Path Filter Type Stack Code Sequence</tag>
    <tag group=\"0022\" element=\"0019\" keyword=\"LensesCodeSequence\" vr=\"SQ\" vm=\"1\">Lenses Code Sequence</tag>
    <tag group=\"0022\" element=\"001A\" keyword=\"ChannelDescriptionCodeSequence\" vr=\"SQ\" vm=\"1\">Channel Description Code Sequence</tag>
    <tag group=\"0022\" element=\"001B\" keyword=\"RefractiveStateSequence\" vr=\"SQ\" vm=\"1\">Refractive State Sequence</tag>
    <tag group=\"0022\" element=\"001C\" keyword=\"MydriaticAgentCodeSequence\" vr=\"SQ\" vm=\"1\">Mydriatic Agent Code Sequence</tag>
    <tag group=\"0022\" element=\"001D\" keyword=\"RelativeImagePositionCodeSequence\" vr=\"SQ\" vm=\"1\">Relative Image Position Code Sequence</tag>
    <tag group=\"0022\" element=\"001E\" keyword=\"CameraAngleOfView\" vr=\"FL\" vm=\"1\">Camera Angle of View</tag>
    <tag group=\"0022\" element=\"0020\" keyword=\"StereoPairsSequence\" vr=\"SQ\" vm=\"1\">Stereo Pairs Sequence</tag>
    <tag group=\"0022\" element=\"0021\" keyword=\"LeftImageSequence\" vr=\"SQ\" vm=\"1\">Left Image Sequence</tag>
    <tag group=\"0022\" element=\"0022\" keyword=\"RightImageSequence\" vr=\"SQ\" vm=\"1\">Right Image Sequence</tag>
    <tag group=\"0022\" element=\"0028\" keyword=\"StereoPairsPresent\" vr=\"CS\" vm=\"1\">Stereo Pairs Present</tag>
    <tag group=\"0022\" element=\"0030\" keyword=\"AxialLengthOfTheEye\" vr=\"FL\" vm=\"1\">Axial Length of the Eye</tag>
    <tag group=\"0022\" element=\"0031\" keyword=\"OphthalmicFrameLocationSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Frame Location Sequence</tag>
    <tag group=\"0022\" element=\"0032\" keyword=\"ReferenceCoordinates\" vr=\"FL\" vm=\"2-2n\">Reference Coordinates</tag>
    <tag group=\"0022\" element=\"0035\" keyword=\"DepthSpatialResolution\" vr=\"FL\" vm=\"1\">Depth Spatial Resolution</tag>
    <tag group=\"0022\" element=\"0036\" keyword=\"MaximumDepthDistortion\" vr=\"FL\" vm=\"1\">Maximum Depth Distortion</tag>
    <tag group=\"0022\" element=\"0037\" keyword=\"AlongScanSpatialResolution\" vr=\"FL\" vm=\"1\">Along-scan Spatial Resolution</tag>
    <tag group=\"0022\" element=\"0038\" keyword=\"MaximumAlongScanDistortion\" vr=\"FL\" vm=\"1\">Maximum Along-scan Distortion</tag>
    <tag group=\"0022\" element=\"0039\" keyword=\"OphthalmicImageOrientation\" vr=\"CS\" vm=\"1\">Ophthalmic Image Orientation</tag>
    <tag group=\"0022\" element=\"0041\" keyword=\"DepthOfTransverseImage\" vr=\"FL\" vm=\"1\">Depth of Transverse Image</tag>
    <tag group=\"0022\" element=\"0042\" keyword=\"MydriaticAgentConcentrationUnitsSequence\" vr=\"SQ\" vm=\"1\">Mydriatic Agent Concentration Units Sequence</tag>
    <tag group=\"0022\" element=\"0048\" keyword=\"AcrossScanSpatialResolution\" vr=\"FL\" vm=\"1\">Across-scan Spatial Resolution</tag>
    <tag group=\"0022\" element=\"0049\" keyword=\"MaximumAcrossScanDistortion\" vr=\"FL\" vm=\"1\">Maximum Across-scan Distortion</tag>
    <tag group=\"0022\" element=\"004E\" keyword=\"MydriaticAgentConcentration\" vr=\"DS\" vm=\"1\">Mydriatic Agent Concentration</tag>
    <tag group=\"0022\" element=\"0055\" keyword=\"IlluminationWaveLength\" vr=\"FL\" vm=\"1\">Illumination Wave Length</tag>
    <tag group=\"0022\" element=\"0056\" keyword=\"IlluminationPower\" vr=\"FL\" vm=\"1\">Illumination Power</tag>
    <tag group=\"0022\" element=\"0057\" keyword=\"IlluminationBandwidth\" vr=\"FL\" vm=\"1\">Illumination Bandwidth</tag>
    <tag group=\"0022\" element=\"0058\" keyword=\"MydriaticAgentSequence\" vr=\"SQ\" vm=\"1\">Mydriatic Agent Sequence</tag>
    <tag group=\"0022\" element=\"1007\" keyword=\"OphthalmicAxialMeasurementsRightEyeSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Axial Measurements Right Eye Sequence</tag>
    <tag group=\"0022\" element=\"1008\" keyword=\"OphthalmicAxialMeasurementsLeftEyeSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Axial Measurements Left Eye Sequence</tag>
    <tag group=\"0022\" element=\"1009\" keyword=\"OphthalmicAxialMeasurementsDeviceType\" vr=\"CS\" vm=\"1\">Ophthalmic Axial Measurements Device Type</tag>
    <tag group=\"0022\" element=\"1010\" keyword=\"OphthalmicAxialLengthMeasurementsType\" vr=\"CS\" vm=\"1\">Ophthalmic Axial Length Measurements Type</tag>
    <tag group=\"0022\" element=\"1012\" keyword=\"OphthalmicAxialLengthSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Axial Length Sequence</tag>
    <tag group=\"0022\" element=\"1019\" keyword=\"OphthalmicAxialLength\" vr=\"FL\" vm=\"1\">Ophthalmic Axial Length</tag>
    <tag group=\"0022\" element=\"1024\" keyword=\"LensStatusCodeSequence\" vr=\"SQ\" vm=\"1\">Lens Status Code Sequence</tag>
    <tag group=\"0022\" element=\"1025\" keyword=\"VitreousStatusCodeSequence\" vr=\"SQ\" vm=\"1\">Vitreous Status Code Sequence</tag>
    <tag group=\"0022\" element=\"1028\" keyword=\"IOLFormulaCodeSequence\" vr=\"SQ\" vm=\"1\">IOL Formula Code Sequence</tag>
    <tag group=\"0022\" element=\"1029\" keyword=\"IOLFormulaDetail\" vr=\"LO\" vm=\"1\">IOL Formula Detail</tag>
    <tag group=\"0022\" element=\"1033\" keyword=\"KeratometerIndex\" vr=\"FL\" vm=\"1\">Keratometer Index</tag>
    <tag group=\"0022\" element=\"1035\" keyword=\"SourceOfOphthalmicAxialLengthCodeSequence\" vr=\"SQ\" vm=\"1\">Source of Ophthalmic Axial Length Code Sequence</tag>
    <tag group=\"0022\" element=\"1037\" keyword=\"TargetRefraction\" vr=\"FL\" vm=\"1\">Target Refraction</tag>
    <tag group=\"0022\" element=\"1039\" keyword=\"RefractiveProcedureOccurred\" vr=\"CS\" vm=\"1\">Refractive Procedure Occurred</tag>
    <tag group=\"0022\" element=\"1040\" keyword=\"RefractiveSurgeryTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Refractive Surgery Type Code Sequence</tag>
    <tag group=\"0022\" element=\"1044\" keyword=\"OphthalmicUltrasoundMethodCodeSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Ultrasound Method Code Sequence</tag>
    <tag group=\"0022\" element=\"1050\" keyword=\"OphthalmicAxialLengthMeasurementsSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Axial Length Measurements Sequence</tag>
    <tag group=\"0022\" element=\"1053\" keyword=\"IOLPower\" vr=\"FL\" vm=\"1\">IOL Power</tag>
    <tag group=\"0022\" element=\"1054\" keyword=\"PredictedRefractiveError\" vr=\"FL\" vm=\"1\">Predicted Refractive Error</tag>
    <tag group=\"0022\" element=\"1059\" keyword=\"OphthalmicAxialLengthVelocity\" vr=\"FL\" vm=\"1\">Ophthalmic Axial Length Velocity</tag>
    <tag group=\"0022\" element=\"1065\" keyword=\"LensStatusDescription\" vr=\"LO\" vm=\"1\">Lens Status Description</tag>
    <tag group=\"0022\" element=\"1066\" keyword=\"VitreousStatusDescription\" vr=\"LO\" vm=\"1\">Vitreous Status Description</tag>
    <tag group=\"0022\" element=\"1090\" keyword=\"IOLPowerSequence\" vr=\"SQ\" vm=\"1\">IOL Power Sequence</tag>
    <tag group=\"0022\" element=\"1092\" keyword=\"LensConstantSequence\" vr=\"SQ\" vm=\"1\">Lens Constant Sequence</tag>
    <tag group=\"0022\" element=\"1093\" keyword=\"IOLManufacturer\" vr=\"LO\" vm=\"1\">IOL Manufacturer</tag>
    <tag group=\"0022\" element=\"1094\" keyword=\"LensConstantDescription\" vr=\"LO\" vm=\"1\" retired=\"true\">Lens Constant Description</tag>
    <tag group=\"0022\" element=\"1095\" keyword=\"ImplantName\" vr=\"LO\" vm=\"1\">Implant Name</tag>
    <tag group=\"0022\" element=\"1096\" keyword=\"KeratometryMeasurementTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Keratometry Measurement Type Code Sequence</tag>
    <tag group=\"0022\" element=\"1097\" keyword=\"ImplantPartNumber\" vr=\"LO\" vm=\"1\">Implant Part Number</tag>
    <tag group=\"0022\" element=\"1100\" keyword=\"ReferencedOphthalmicAxialMeasurementsSequence\" vr=\"SQ\" vm=\"1\">Referenced Ophthalmic Axial Measurements Sequence</tag>
    <tag group=\"0022\" element=\"1101\" keyword=\"OphthalmicAxialLengthMeasurementsSegmentNameCodeSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Axial Length Measurements Segment Name Code Sequence</tag>
    <tag group=\"0022\" element=\"1103\" keyword=\"RefractiveErrorBeforeRefractiveSurgeryCodeSequence\" vr=\"SQ\" vm=\"1\">Refractive Error Before Refractive Surgery Code Sequence</tag>
    <tag group=\"0022\" element=\"1121\" keyword=\"IOLPowerForExactEmmetropia\" vr=\"FL\" vm=\"1\">IOL Power For Exact Emmetropia</tag>
    <tag group=\"0022\" element=\"1122\" keyword=\"IOLPowerForExactTargetRefraction\" vr=\"FL\" vm=\"1\">IOL Power For Exact Target Refraction</tag>
    <tag group=\"0022\" element=\"1125\" keyword=\"AnteriorChamberDepthDefinitionCodeSequence\" vr=\"SQ\" vm=\"1\">Anterior Chamber Depth Definition Code Sequence</tag>
    <tag group=\"0022\" element=\"1127\" keyword=\"LensThicknessSequence\" vr=\"SQ\" vm=\"1\">Lens Thickness Sequence</tag>
    <tag group=\"0022\" element=\"1128\" keyword=\"AnteriorChamberDepthSequence\" vr=\"SQ\" vm=\"1\">Anterior Chamber Depth Sequence</tag>
    <tag group=\"0022\" element=\"1130\" keyword=\"LensThickness\" vr=\"FL\" vm=\"1\">Lens Thickness</tag>
    <tag group=\"0022\" element=\"1131\" keyword=\"AnteriorChamberDepth\" vr=\"FL\" vm=\"1\">Anterior Chamber Depth</tag>
    <tag group=\"0022\" element=\"1132\" keyword=\"SourceOfLensThicknessDataCodeSequence\" vr=\"SQ\" vm=\"1\">Source of Lens Thickness Data Code Sequence</tag>
    <tag group=\"0022\" element=\"1133\" keyword=\"SourceOfAnteriorChamberDepthDataCodeSequence\" vr=\"SQ\" vm=\"1\">Source of Anterior Chamber Depth Data Code Sequence</tag>
    <tag group=\"0022\" element=\"1134\" keyword=\"SourceOfRefractiveMeasurementsSequence\" vr=\"SQ\" vm=\"1\">Source of Refractive Measurements Sequence</tag>
    <tag group=\"0022\" element=\"1135\" keyword=\"SourceOfRefractiveMeasurementsCodeSequence\" vr=\"SQ\" vm=\"1\">Source of Refractive Measurements Code Sequence</tag>
    <tag group=\"0022\" element=\"1140\" keyword=\"OphthalmicAxialLengthMeasurementModified\" vr=\"CS\" vm=\"1\">Ophthalmic Axial Length Measurement Modified</tag>
    <tag group=\"0022\" element=\"1150\" keyword=\"OphthalmicAxialLengthDataSourceCodeSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Axial Length Data Source Code Sequence</tag>
    <tag group=\"0022\" element=\"1153\" keyword=\"OphthalmicAxialLengthAcquisitionMethodCodeSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Ophthalmic Axial Length Acquisition Method Code Sequence</tag>
    <tag group=\"0022\" element=\"1155\" keyword=\"SignalToNoiseRatio\" vr=\"FL\" vm=\"1\">Signal to Noise Ratio</tag>
    <tag group=\"0022\" element=\"1159\" keyword=\"OphthalmicAxialLengthDataSourceDescription\" vr=\"LO\" vm=\"1\">Ophthalmic Axial Length Data Source Description</tag>
    <tag group=\"0022\" element=\"1210\" keyword=\"OphthalmicAxialLengthMeasurementsTotalLengthSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Axial Length Measurements Total Length Sequence</tag>
    <tag group=\"0022\" element=\"1211\" keyword=\"OphthalmicAxialLengthMeasurementsSegmentalLengthSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Axial Length Measurements Segmental Length Sequence</tag>
    <tag group=\"0022\" element=\"1212\" keyword=\"OphthalmicAxialLengthMeasurementsLengthSummationSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Axial Length Measurements Length Summation Sequence</tag>
    <tag group=\"0022\" element=\"1220\" keyword=\"UltrasoundOphthalmicAxialLengthMeasurementsSequence\" vr=\"SQ\" vm=\"1\">Ultrasound Ophthalmic Axial Length Measurements Sequence</tag>
    <tag group=\"0022\" element=\"1225\" keyword=\"OpticalOphthalmicAxialLengthMeasurementsSequence\" vr=\"SQ\" vm=\"1\">Optical Ophthalmic Axial Length Measurements Sequence</tag>
    <tag group=\"0022\" element=\"1230\" keyword=\"UltrasoundSelectedOphthalmicAxialLengthSequence\" vr=\"SQ\" vm=\"1\">Ultrasound Selected Ophthalmic Axial Length Sequence</tag>
    <tag group=\"0022\" element=\"1250\" keyword=\"OphthalmicAxialLengthSelectionMethodCodeSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Axial Length Selection Method Code Sequence</tag>
    <tag group=\"0022\" element=\"1255\" keyword=\"OpticalSelectedOphthalmicAxialLengthSequence\" vr=\"SQ\" vm=\"1\">Optical Selected Ophthalmic Axial Length Sequence</tag>
    <tag group=\"0022\" element=\"1257\" keyword=\"SelectedSegmentalOphthalmicAxialLengthSequence\" vr=\"SQ\" vm=\"1\">Selected Segmental Ophthalmic Axial Length Sequence</tag>
    <tag group=\"0022\" element=\"1260\" keyword=\"SelectedTotalOphthalmicAxialLengthSequence\" vr=\"SQ\" vm=\"1\">Selected Total Ophthalmic Axial Length Sequence</tag>
    <tag group=\"0022\" element=\"1262\" keyword=\"OphthalmicAxialLengthQualityMetricSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Axial Length Quality Metric Sequence</tag>
    <tag group=\"0022\" element=\"1265\" keyword=\"OphthalmicAxialLengthQualityMetricTypeCodeSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Ophthalmic Axial Length Quality Metric Type Code Sequence</tag>
    <tag group=\"0022\" element=\"1273\" keyword=\"OphthalmicAxialLengthQualityMetricTypeDescription\" vr=\"LO\" vm=\"1\" retired=\"true\">Ophthalmic Axial Length Quality Metric Type Description</tag>
    <tag group=\"0022\" element=\"1300\" keyword=\"IntraocularLensCalculationsRightEyeSequence\" vr=\"SQ\" vm=\"1\">Intraocular Lens Calculations Right Eye Sequence</tag>
    <tag group=\"0022\" element=\"1310\" keyword=\"IntraocularLensCalculationsLeftEyeSequence\" vr=\"SQ\" vm=\"1\">Intraocular Lens Calculations Left Eye Sequence</tag>
    <tag group=\"0022\" element=\"1330\" keyword=\"ReferencedOphthalmicAxialLengthMeasurementQCImageSequence\" vr=\"SQ\" vm=\"1\">Referenced Ophthalmic Axial Length Measurement QC Image Sequence</tag>
    <tag group=\"0022\" element=\"1415\" keyword=\"OphthalmicMappingDeviceType\" vr=\"CS\" vm=\"1\">Ophthalmic Mapping Device Type</tag>
    <tag group=\"0022\" element=\"1420\" keyword=\"AcquisitionMethodCodeSequence\" vr=\"SQ\" vm=\"1\">Acquisition Method Code Sequence</tag>
    <tag group=\"0022\" element=\"1423\" keyword=\"AcquisitionMethodAlgorithmSequence\" vr=\"SQ\" vm=\"1\">Acquisition Method Algorithm Sequence</tag>
    <tag group=\"0022\" element=\"1436\" keyword=\"OphthalmicThicknessMapTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Thickness Map Type Code Sequence</tag>
    <tag group=\"0022\" element=\"1443\" keyword=\"OphthalmicThicknessMappingNormalsSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Thickness Mapping Normals Sequence</tag>
    <tag group=\"0022\" element=\"1445\" keyword=\"RetinalThicknessDefinitionCodeSequence\" vr=\"SQ\" vm=\"1\">Retinal Thickness Definition Code Sequence</tag>
    <tag group=\"0022\" element=\"1450\" keyword=\"PixelValueMappingToCodedConceptSequence\" vr=\"SQ\" vm=\"1\">Pixel Value Mapping to Coded Concept Sequence</tag>
    <tag group=\"0022\" element=\"1452\" keyword=\"MappedPixelValue\" vr=\"US/SS\" vm=\"1\">Mapped Pixel Value</tag>
    <tag group=\"0022\" element=\"1454\" keyword=\"PixelValueMappingExplanation\" vr=\"LO\" vm=\"1\">Pixel Value Mapping Explanation</tag>
    <tag group=\"0022\" element=\"1458\" keyword=\"OphthalmicThicknessMapQualityThresholdSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Thickness Map Quality Threshold Sequence</tag>
    <tag group=\"0022\" element=\"1460\" keyword=\"OphthalmicThicknessMapThresholdQualityRating\" vr=\"FL\" vm=\"1\">Ophthalmic Thickness Map Threshold Quality Rating</tag>
    <tag group=\"0022\" element=\"1463\" keyword=\"AnatomicStructureReferencePoint\" vr=\"FL\" vm=\"2\">Anatomic Structure Reference Point</tag>
    <tag group=\"0022\" element=\"1465\" keyword=\"RegistrationToLocalizerSequence\" vr=\"SQ\" vm=\"1\">Registration to Localizer Sequence</tag>
    <tag group=\"0022\" element=\"1466\" keyword=\"RegisteredLocalizerUnits\" vr=\"CS\" vm=\"1\">Registered Localizer Units</tag>
    <tag group=\"0022\" element=\"1467\" keyword=\"RegisteredLocalizerTopLeftHandCorner\" vr=\"FL\" vm=\"2\">Registered Localizer Top Left Hand Corner</tag>
    <tag group=\"0022\" element=\"1468\" keyword=\"RegisteredLocalizerBottomRightHandCorner\" vr=\"FL\" vm=\"2\">Registered Localizer Bottom Right Hand Corner</tag>
    <tag group=\"0022\" element=\"1470\" keyword=\"OphthalmicThicknessMapQualityRatingSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Thickness Map Quality Rating Sequence</tag>
    <tag group=\"0022\" element=\"1472\" keyword=\"RelevantOPTAttributesSequence\" vr=\"SQ\" vm=\"1\">Relevant OPT Attributes Sequence</tag>
    <tag group=\"0022\" element=\"1512\" keyword=\"TransformationMethodCodeSequence\" vr=\"SQ\" vm=\"1\">Transformation Method Code Sequence</tag>
    <tag group=\"0022\" element=\"1513\" keyword=\"TransformationAlgorithmSequence\" vr=\"SQ\" vm=\"1\">Transformation Algorithm Sequence</tag>
    <tag group=\"0022\" element=\"1515\" keyword=\"OphthalmicAxialLengthMethod\" vr=\"CS\" vm=\"1\">Ophthalmic Axial Length Method</tag>
    <tag group=\"0022\" element=\"1517\" keyword=\"OphthalmicFOV\" vr=\"FL\" vm=\"1\">Ophthalmic FOV</tag>
    <tag group=\"0022\" element=\"1518\" keyword=\"TwoDimensionalToThreeDimensionalMapSequence\" vr=\"SQ\" vm=\"1\">Two Dimensional to Three Dimensional Map Sequence</tag>
    <tag group=\"0022\" element=\"1525\" keyword=\"WideFieldOphthalmicPhotographyQualityRatingSequence\" vr=\"SQ\" vm=\"1\">Wide Field Ophthalmic Photography Quality Rating Sequence</tag>
    <tag group=\"0022\" element=\"1526\" keyword=\"WideFieldOphthalmicPhotographyQualityThresholdSequence\" vr=\"SQ\" vm=\"1\">Wide Field Ophthalmic Photography Quality Threshold Sequence</tag>
    <tag group=\"0022\" element=\"1527\" keyword=\"WideFieldOphthalmicPhotographyThresholdQualityRating\" vr=\"FL\" vm=\"1\">Wide Field Ophthalmic Photography Threshold Quality Rating</tag>
    <tag group=\"0022\" element=\"1528\" keyword=\"XCoordinatesCenterPixelViewAngle\" vr=\"FL\" vm=\"1\">X Coordinates Center Pixel View Angle</tag>
    <tag group=\"0022\" element=\"1529\" keyword=\"YCoordinatesCenterPixelViewAngle\" vr=\"FL\" vm=\"1\">Y Coordinates Center Pixel View Angle</tag>
    <tag group=\"0022\" element=\"1530\" keyword=\"NumberOfMapPoints\" vr=\"UL\" vm=\"1\">Number of Map Points</tag>
    <tag group=\"0022\" element=\"1531\" keyword=\"TwoDimensionalToThreeDimensionalMapData\" vr=\"OF\" vm=\"1\">Two Dimensional to Three Dimensional Map Data</tag>
    <tag group=\"0022\" element=\"1612\" keyword=\"DerivationAlgorithmSequence\" vr=\"SQ\" vm=\"1\">Derivation Algorithm Sequence</tag>
    <tag group=\"0022\" element=\"1615\" keyword=\"OphthalmicImageTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Image Type Code Sequence</tag>
    <tag group=\"0022\" element=\"1616\" keyword=\"OphthalmicImageTypeDescription\" vr=\"LO\" vm=\"1\">Ophthalmic Image Type Description</tag>
    <tag group=\"0022\" element=\"1618\" keyword=\"ScanPatternTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Scan Pattern Type Code Sequence</tag>
    <tag group=\"0022\" element=\"1620\" keyword=\"ReferencedSurfaceMeshIdentificationSequence\" vr=\"SQ\" vm=\"1\">Referenced Surface Mesh Identification Sequence</tag>
    <tag group=\"0022\" element=\"1622\" keyword=\"OphthalmicVolumetricPropertiesFlag\" vr=\"CS\" vm=\"1\">Ophthalmic Volumetric Properties Flag</tag>
    <tag group=\"0022\" element=\"1624\" keyword=\"OphthalmicAnatomicReferencePointXCoordinate\" vr=\"FL\" vm=\"1\">Ophthalmic Anatomic Reference Point X-Coordinate</tag>
    <tag group=\"0022\" element=\"1626\" keyword=\"OphthalmicAnatomicReferencePointYCoordinate\" vr=\"FL\" vm=\"1\">Ophthalmic Anatomic Reference Point Y-Coordinate</tag>
    <tag group=\"0022\" element=\"1628\" keyword=\"OphthalmicEnFaceImageQualityRatingSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic En Face Image Quality Rating Sequence</tag>
    <tag group=\"0022\" element=\"1630\" keyword=\"QualityThreshold\" vr=\"DS\" vm=\"1\">Quality Threshold</tag>
    <tag group=\"0022\" element=\"1640\" keyword=\"OCTBscanAnalysisAcquisitionParametersSequence\" vr=\"SQ\" vm=\"1\">OCT B-scan Analysis Acquisition Parameters Sequence</tag>
    <tag group=\"0022\" element=\"1642\" keyword=\"NumberofBscansPerFrame\" vr=\"UL\" vm=\"1\">Number of B-scans Per Frame</tag>
    <tag group=\"0022\" element=\"1643\" keyword=\"BscanSlabThickness\" vr=\"FL\" vm=\"1\">B-scan Slab Thickness</tag>
    <tag group=\"0022\" element=\"1644\" keyword=\"DistanceBetweenBscanSlabs\" vr=\"FL\" vm=\"1\">Distance Between B-scan Slabs</tag>
    <tag group=\"0022\" element=\"1645\" keyword=\"BscanCycleTime\" vr=\"FL\" vm=\"1\">B-scan Cycle Time</tag>
    <tag group=\"0022\" element=\"1646\" keyword=\"BscanCycleTimeVector\" vr=\"FL\" vm=\"1-n\">B-scan Cycle Time Vector</tag>
    <tag group=\"0022\" element=\"1649\" keyword=\"AscanRate\" vr=\"FL\" vm=\"1\">A-scan Rate</tag>
    <tag group=\"0022\" element=\"1650\" keyword=\"BscanRate\" vr=\"FL\" vm=\"1\">B-scan Rate</tag>
    <tag group=\"0022\" element=\"1658\" keyword=\"SurfaceMeshZPixelOffset\" vr=\"UL\" vm=\"1\">Surface Mesh Z-Pixel Offset</tag>
    <tag group=\"0024\" element=\"0010\" keyword=\"VisualFieldHorizontalExtent\" vr=\"FL\" vm=\"1\">Visual Field Horizontal Extent</tag>
    <tag group=\"0024\" element=\"0011\" keyword=\"VisualFieldVerticalExtent\" vr=\"FL\" vm=\"1\">Visual Field Vertical Extent</tag>
    <tag group=\"0024\" element=\"0012\" keyword=\"VisualFieldShape\" vr=\"CS\" vm=\"1\">Visual Field Shape</tag>
    <tag group=\"0024\" element=\"0016\" keyword=\"ScreeningTestModeCodeSequence\" vr=\"SQ\" vm=\"1\">Screening Test Mode Code Sequence</tag>
    <tag group=\"0024\" element=\"0018\" keyword=\"MaximumStimulusLuminance\" vr=\"FL\" vm=\"1\">Maximum Stimulus Luminance</tag>
    <tag group=\"0024\" element=\"0020\" keyword=\"BackgroundLuminance\" vr=\"FL\" vm=\"1\">Background Luminance</tag>
    <tag group=\"0024\" element=\"0021\" keyword=\"StimulusColorCodeSequence\" vr=\"SQ\" vm=\"1\">Stimulus Color Code Sequence</tag>
    <tag group=\"0024\" element=\"0024\" keyword=\"BackgroundIlluminationColorCodeSequence\" vr=\"SQ\" vm=\"1\">Background Illumination Color Code Sequence</tag>
    <tag group=\"0024\" element=\"0025\" keyword=\"StimulusArea\" vr=\"FL\" vm=\"1\">Stimulus Area</tag>
    <tag group=\"0024\" element=\"0028\" keyword=\"StimulusPresentationTime\" vr=\"FL\" vm=\"1\">Stimulus Presentation Time</tag>
    <tag group=\"0024\" element=\"0032\" keyword=\"FixationSequence\" vr=\"SQ\" vm=\"1\">Fixation Sequence</tag>
    <tag group=\"0024\" element=\"0033\" keyword=\"FixationMonitoringCodeSequence\" vr=\"SQ\" vm=\"1\">Fixation Monitoring Code Sequence</tag>
    <tag group=\"0024\" element=\"0034\" keyword=\"VisualFieldCatchTrialSequence\" vr=\"SQ\" vm=\"1\">Visual Field Catch Trial Sequence</tag>
    <tag group=\"0024\" element=\"0035\" keyword=\"FixationCheckedQuantity\" vr=\"US\" vm=\"1\">Fixation Checked Quantity</tag>
    <tag group=\"0024\" element=\"0036\" keyword=\"PatientNotProperlyFixatedQuantity\" vr=\"US\" vm=\"1\">Patient Not Properly Fixated Quantity</tag>
    <tag group=\"0024\" element=\"0037\" keyword=\"PresentedVisualStimuliDataFlag\" vr=\"CS\" vm=\"1\">Presented Visual Stimuli Data Flag</tag>
    <tag group=\"0024\" element=\"0038\" keyword=\"NumberOfVisualStimuli\" vr=\"US\" vm=\"1\">Number of Visual Stimuli</tag>
    <tag group=\"0024\" element=\"0039\" keyword=\"ExcessiveFixationLossesDataFlag\" vr=\"CS\" vm=\"1\">Excessive Fixation Losses Data Flag</tag>
    <tag group=\"0024\" element=\"0040\" keyword=\"ExcessiveFixationLosses\" vr=\"CS\" vm=\"1\">Excessive Fixation Losses</tag>
    <tag group=\"0024\" element=\"0042\" keyword=\"StimuliRetestingQuantity\" vr=\"US\" vm=\"1\">Stimuli Retesting Quantity</tag>
    <tag group=\"0024\" element=\"0044\" keyword=\"CommentsOnPatientPerformanceOfVisualField\" vr=\"LT\" vm=\"1\">Comments on Patient's Performance of Visual Field</tag>
    <tag group=\"0024\" element=\"0045\" keyword=\"FalseNegativesEstimateFlag\" vr=\"CS\" vm=\"1\">False Negatives Estimate Flag</tag>
    <tag group=\"0024\" element=\"0046\" keyword=\"FalseNegativesEstimate\" vr=\"FL\" vm=\"1\">False Negatives Estimate</tag>
    <tag group=\"0024\" element=\"0048\" keyword=\"NegativeCatchTrialsQuantity\" vr=\"US\" vm=\"1\">Negative Catch Trials Quantity</tag>
    <tag group=\"0024\" element=\"0050\" keyword=\"FalseNegativesQuantity\" vr=\"US\" vm=\"1\">False Negatives Quantity</tag>
    <tag group=\"0024\" element=\"0051\" keyword=\"ExcessiveFalseNegativesDataFlag\" vr=\"CS\" vm=\"1\">Excessive False Negatives Data Flag</tag>
    <tag group=\"0024\" element=\"0052\" keyword=\"ExcessiveFalseNegatives\" vr=\"CS\" vm=\"1\">Excessive False Negatives</tag>
    <tag group=\"0024\" element=\"0053\" keyword=\"FalsePositivesEstimateFlag\" vr=\"CS\" vm=\"1\">False Positives Estimate Flag</tag>
    <tag group=\"0024\" element=\"0054\" keyword=\"FalsePositivesEstimate\" vr=\"FL\" vm=\"1\">False Positives Estimate</tag>
    <tag group=\"0024\" element=\"0055\" keyword=\"CatchTrialsDataFlag\" vr=\"CS\" vm=\"1\">Catch Trials Data Flag</tag>
    <tag group=\"0024\" element=\"0056\" keyword=\"PositiveCatchTrialsQuantity\" vr=\"US\" vm=\"1\">Positive Catch Trials Quantity</tag>
    <tag group=\"0024\" element=\"0057\" keyword=\"TestPointNormalsDataFlag\" vr=\"CS\" vm=\"1\">Test Point Normals Data Flag</tag>
    <tag group=\"0024\" element=\"0058\" keyword=\"TestPointNormalsSequence\" vr=\"SQ\" vm=\"1\">Test Point Normals Sequence</tag>
    <tag group=\"0024\" element=\"0059\" keyword=\"GlobalDeviationProbabilityNormalsFlag\" vr=\"CS\" vm=\"1\">Global Deviation Probability Normals Flag</tag>
    <tag group=\"0024\" element=\"0060\" keyword=\"FalsePositivesQuantity\" vr=\"US\" vm=\"1\">False Positives Quantity</tag>
    <tag group=\"0024\" element=\"0061\" keyword=\"ExcessiveFalsePositivesDataFlag\" vr=\"CS\" vm=\"1\">Excessive False Positives Data Flag</tag>
    <tag group=\"0024\" element=\"0062\" keyword=\"ExcessiveFalsePositives\" vr=\"CS\" vm=\"1\">Excessive False Positives</tag>
    <tag group=\"0024\" element=\"0063\" keyword=\"VisualFieldTestNormalsFlag\" vr=\"CS\" vm=\"1\">Visual Field Test Normals Flag</tag>
    <tag group=\"0024\" element=\"0064\" keyword=\"ResultsNormalsSequence\" vr=\"SQ\" vm=\"1\">Results Normals Sequence</tag>
    <tag group=\"0024\" element=\"0065\" keyword=\"AgeCorrectedSensitivityDeviationAlgorithmSequence\" vr=\"SQ\" vm=\"1\">Age Corrected Sensitivity Deviation Algorithm Sequence</tag>
    <tag group=\"0024\" element=\"0066\" keyword=\"GlobalDeviationFromNormal\" vr=\"FL\" vm=\"1\">Global Deviation From Normal</tag>
    <tag group=\"0024\" element=\"0067\" keyword=\"GeneralizedDefectSensitivityDeviationAlgorithmSequence\" vr=\"SQ\" vm=\"1\">Generalized Defect Sensitivity Deviation Algorithm Sequence</tag>
    <tag group=\"0024\" element=\"0068\" keyword=\"LocalizedDeviationFromNormal\" vr=\"FL\" vm=\"1\">Localized Deviation From Normal</tag>
    <tag group=\"0024\" element=\"0069\" keyword=\"PatientReliabilityIndicator\" vr=\"LO\" vm=\"1\">Patient Reliability Indicator</tag>
    <tag group=\"0024\" element=\"0070\" keyword=\"VisualFieldMeanSensitivity\" vr=\"FL\" vm=\"1\">Visual Field Mean Sensitivity</tag>
    <tag group=\"0024\" element=\"0071\" keyword=\"GlobalDeviationProbability\" vr=\"FL\" vm=\"1\">Global Deviation Probability</tag>
    <tag group=\"0024\" element=\"0072\" keyword=\"LocalDeviationProbabilityNormalsFlag\" vr=\"CS\" vm=\"1\">Local Deviation Probability Normals Flag</tag>
    <tag group=\"0024\" element=\"0073\" keyword=\"LocalizedDeviationProbability\" vr=\"FL\" vm=\"1\">Localized Deviation Probability</tag>
    <tag group=\"0024\" element=\"0074\" keyword=\"ShortTermFluctuationCalculated\" vr=\"CS\" vm=\"1\">Short Term Fluctuation Calculated</tag>
    <tag group=\"0024\" element=\"0075\" keyword=\"ShortTermFluctuation\" vr=\"FL\" vm=\"1\">Short Term Fluctuation</tag>
    <tag group=\"0024\" element=\"0076\" keyword=\"ShortTermFluctuationProbabilityCalculated\" vr=\"CS\" vm=\"1\">Short Term Fluctuation Probability Calculated</tag>
    <tag group=\"0024\" element=\"0077\" keyword=\"ShortTermFluctuationProbability\" vr=\"FL\" vm=\"1\">Short Term Fluctuation Probability</tag>
    <tag group=\"0024\" element=\"0078\" keyword=\"CorrectedLocalizedDeviationFromNormalCalculated\" vr=\"CS\" vm=\"1\">Corrected Localized Deviation From Normal Calculated</tag>
    <tag group=\"0024\" element=\"0079\" keyword=\"CorrectedLocalizedDeviationFromNormal\" vr=\"FL\" vm=\"1\">Corrected Localized Deviation From Normal</tag>
    <tag group=\"0024\" element=\"0080\" keyword=\"CorrectedLocalizedDeviationFromNormalProbabilityCalculated\" vr=\"CS\" vm=\"1\">Corrected Localized Deviation From Normal Probability Calculated</tag>
    <tag group=\"0024\" element=\"0081\" keyword=\"CorrectedLocalizedDeviationFromNormalProbability\" vr=\"FL\" vm=\"1\">Corrected Localized Deviation From Normal Probability</tag>
    <tag group=\"0024\" element=\"0083\" keyword=\"GlobalDeviationProbabilitySequence\" vr=\"SQ\" vm=\"1\">Global Deviation Probability Sequence</tag>
    <tag group=\"0024\" element=\"0085\" keyword=\"LocalizedDeviationProbabilitySequence\" vr=\"SQ\" vm=\"1\">Localized Deviation Probability Sequence</tag>
    <tag group=\"0024\" element=\"0086\" keyword=\"FovealSensitivityMeasured\" vr=\"CS\" vm=\"1\">Foveal Sensitivity Measured</tag>
    <tag group=\"0024\" element=\"0087\" keyword=\"FovealSensitivity\" vr=\"FL\" vm=\"1\">Foveal Sensitivity</tag>
    <tag group=\"0024\" element=\"0088\" keyword=\"VisualFieldTestDuration\" vr=\"FL\" vm=\"1\">Visual Field Test Duration</tag>
    <tag group=\"0024\" element=\"0089\" keyword=\"VisualFieldTestPointSequence\" vr=\"SQ\" vm=\"1\">Visual Field Test Point Sequence</tag>
    <tag group=\"0024\" element=\"0090\" keyword=\"VisualFieldTestPointXCoordinate\" vr=\"FL\" vm=\"1\">Visual Field Test Point X-Coordinate</tag>
    <tag group=\"0024\" element=\"0091\" keyword=\"VisualFieldTestPointYCoordinate\" vr=\"FL\" vm=\"1\">Visual Field Test Point Y-Coordinate</tag>
    <tag group=\"0024\" element=\"0092\" keyword=\"AgeCorrectedSensitivityDeviationValue\" vr=\"FL\" vm=\"1\">Age Corrected Sensitivity Deviation Value</tag>
    <tag group=\"0024\" element=\"0093\" keyword=\"StimulusResults\" vr=\"CS\" vm=\"1\">Stimulus Results</tag>
    <tag group=\"0024\" element=\"0094\" keyword=\"SensitivityValue\" vr=\"FL\" vm=\"1\">Sensitivity Value</tag>
    <tag group=\"0024\" element=\"0095\" keyword=\"RetestStimulusSeen\" vr=\"CS\" vm=\"1\">Retest Stimulus Seen</tag>
    <tag group=\"0024\" element=\"0096\" keyword=\"RetestSensitivityValue\" vr=\"FL\" vm=\"1\">Retest Sensitivity Value</tag>
    <tag group=\"0024\" element=\"0097\" keyword=\"VisualFieldTestPointNormalsSequence\" vr=\"SQ\" vm=\"1\">Visual Field Test Point Normals Sequence</tag>
    <tag group=\"0024\" element=\"0098\" keyword=\"QuantifiedDefect\" vr=\"FL\" vm=\"1\">Quantified Defect</tag>
    <tag group=\"0024\" element=\"0100\" keyword=\"AgeCorrectedSensitivityDeviationProbabilityValue\" vr=\"FL\" vm=\"1\">Age Corrected Sensitivity Deviation Probability Value</tag>
    <tag group=\"0024\" element=\"0102\" keyword=\"GeneralizedDefectCorrectedSensitivityDeviationFlag\" vr=\"CS\" vm=\"1\">Generalized Defect Corrected Sensitivity Deviation Flag</tag>
    <tag group=\"0024\" element=\"0103\" keyword=\"GeneralizedDefectCorrectedSensitivityDeviationValue\" vr=\"FL\" vm=\"1\">Generalized Defect Corrected Sensitivity Deviation Value</tag>
    <tag group=\"0024\" element=\"0104\" keyword=\"GeneralizedDefectCorrectedSensitivityDeviationProbabilityValue\" vr=\"FL\" vm=\"1\">Generalized Defect Corrected Sensitivity Deviation Probability Value</tag>
    <tag group=\"0024\" element=\"0105\" keyword=\"MinimumSensitivityValue\" vr=\"FL\" vm=\"1\">Minimum Sensitivity Value</tag>
    <tag group=\"0024\" element=\"0106\" keyword=\"BlindSpotLocalized\" vr=\"CS\" vm=\"1\">Blind Spot Localized</tag>
    <tag group=\"0024\" element=\"0107\" keyword=\"BlindSpotXCoordinate\" vr=\"FL\" vm=\"1\">Blind Spot X-Coordinate</tag>
    <tag group=\"0024\" element=\"0108\" keyword=\"BlindSpotYCoordinate\" vr=\"FL\" vm=\"1\">Blind Spot Y-Coordinate</tag>
    <tag group=\"0024\" element=\"0110\" keyword=\"VisualAcuityMeasurementSequence\" vr=\"SQ\" vm=\"1\">Visual Acuity Measurement Sequence</tag>
    <tag group=\"0024\" element=\"0112\" keyword=\"RefractiveParametersUsedOnPatientSequence\" vr=\"SQ\" vm=\"1\">Refractive Parameters Used on Patient Sequence</tag>
    <tag group=\"0024\" element=\"0113\" keyword=\"MeasurementLaterality\" vr=\"CS\" vm=\"1\">Measurement Laterality</tag>
    <tag group=\"0024\" element=\"0114\" keyword=\"OphthalmicPatientClinicalInformationLeftEyeSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Patient Clinical Information Left Eye Sequence</tag>
    <tag group=\"0024\" element=\"0115\" keyword=\"OphthalmicPatientClinicalInformationRightEyeSequence\" vr=\"SQ\" vm=\"1\">Ophthalmic Patient Clinical Information Right Eye Sequence</tag>
    <tag group=\"0024\" element=\"0117\" keyword=\"FovealPointNormativeDataFlag\" vr=\"CS\" vm=\"1\">Foveal Point Normative Data Flag</tag>
    <tag group=\"0024\" element=\"0118\" keyword=\"FovealPointProbabilityValue\" vr=\"FL\" vm=\"1\">Foveal Point Probability Value</tag>
    <tag group=\"0024\" element=\"0120\" keyword=\"ScreeningBaselineMeasured\" vr=\"CS\" vm=\"1\">Screening Baseline Measured</tag>
    <tag group=\"0024\" element=\"0122\" keyword=\"ScreeningBaselineMeasuredSequence\" vr=\"SQ\" vm=\"1\">Screening Baseline Measured Sequence</tag>
    <tag group=\"0024\" element=\"0124\" keyword=\"ScreeningBaselineType\" vr=\"CS\" vm=\"1\">Screening Baseline Type</tag>
    <tag group=\"0024\" element=\"0126\" keyword=\"ScreeningBaselineValue\" vr=\"FL\" vm=\"1\">Screening Baseline Value</tag>
    <tag group=\"0024\" element=\"0202\" keyword=\"AlgorithmSource\" vr=\"LO\" vm=\"1\">Algorithm Source</tag>
    <tag group=\"0024\" element=\"0306\" keyword=\"DataSetName\" vr=\"LO\" vm=\"1\">Data Set Name</tag>
    <tag group=\"0024\" element=\"0307\" keyword=\"DataSetVersion\" vr=\"LO\" vm=\"1\">Data Set Version</tag>
    <tag group=\"0024\" element=\"0308\" keyword=\"DataSetSource\" vr=\"LO\" vm=\"1\">Data Set Source</tag>
    <tag group=\"0024\" element=\"0309\" keyword=\"DataSetDescription\" vr=\"LO\" vm=\"1\">Data Set Description</tag>
    <tag group=\"0024\" element=\"0317\" keyword=\"VisualFieldTestReliabilityGlobalIndexSequence\" vr=\"SQ\" vm=\"1\">Visual Field Test Reliability Global Index Sequence</tag>
    <tag group=\"0024\" element=\"0320\" keyword=\"VisualFieldGlobalResultsIndexSequence\" vr=\"SQ\" vm=\"1\">Visual Field Global Results Index Sequence</tag>
    <tag group=\"0024\" element=\"0325\" keyword=\"DataObservationSequence\" vr=\"SQ\" vm=\"1\">Data Observation Sequence</tag>
    <tag group=\"0024\" element=\"0338\" keyword=\"IndexNormalsFlag\" vr=\"CS\" vm=\"1\">Index Normals Flag</tag>
    <tag group=\"0024\" element=\"0341\" keyword=\"IndexProbability\" vr=\"FL\" vm=\"1\">Index Probability</tag>
    <tag group=\"0024\" element=\"0344\" keyword=\"IndexProbabilitySequence\" vr=\"SQ\" vm=\"1\">Index Probability Sequence</tag>
    <tag group=\"0028\" element=\"0002\" keyword=\"SamplesPerPixel\" vr=\"US\" vm=\"1\">Samples per Pixel</tag>
    <tag group=\"0028\" element=\"0003\" keyword=\"SamplesPerPixelUsed\" vr=\"US\" vm=\"1\">Samples per Pixel Used</tag>
    <tag group=\"0028\" element=\"0004\" keyword=\"PhotometricInterpretation\" vr=\"CS\" vm=\"1\">Photometric Interpretation</tag>
    <tag group=\"0028\" element=\"0005\" keyword=\"ImageDimensions\" vr=\"US\" vm=\"1\" retired=\"true\">Image Dimensions</tag>
    <tag group=\"0028\" element=\"0006\" keyword=\"PlanarConfiguration\" vr=\"US\" vm=\"1\">Planar Configuration</tag>
    <tag group=\"0028\" element=\"0008\" keyword=\"NumberOfFrames\" vr=\"IS\" vm=\"1\">Number of Frames</tag>
    <tag group=\"0028\" element=\"0009\" keyword=\"FrameIncrementPointer\" vr=\"AT\" vm=\"1-n\">Frame Increment Pointer</tag>
    <tag group=\"0028\" element=\"000A\" keyword=\"FrameDimensionPointer\" vr=\"AT\" vm=\"1-n\">Frame Dimension Pointer</tag>
    <tag group=\"0028\" element=\"0010\" keyword=\"Rows\" vr=\"US\" vm=\"1\">Rows</tag>
    <tag group=\"0028\" element=\"0011\" keyword=\"Columns\" vr=\"US\" vm=\"1\">Columns</tag>
    <tag group=\"0028\" element=\"0012\" keyword=\"Planes\" vr=\"US\" vm=\"1\" retired=\"true\">Planes</tag>
    <tag group=\"0028\" element=\"0014\" keyword=\"UltrasoundColorDataPresent\" vr=\"US\" vm=\"1\">Ultrasound Color Data Present</tag>
    <tag group=\"0028\" element=\"0030\" keyword=\"PixelSpacing\" vr=\"DS\" vm=\"2\">Pixel Spacing</tag>
    <tag group=\"0028\" element=\"0031\" keyword=\"ZoomFactor\" vr=\"DS\" vm=\"2\">Zoom Factor</tag>
    <tag group=\"0028\" element=\"0032\" keyword=\"ZoomCenter\" vr=\"DS\" vm=\"2\">Zoom Center</tag>
    <tag group=\"0028\" element=\"0034\" keyword=\"PixelAspectRatio\" vr=\"IS\" vm=\"2\">Pixel Aspect Ratio</tag>
    <tag group=\"0028\" element=\"0040\" keyword=\"ImageFormat\" vr=\"CS\" vm=\"1\" retired=\"true\">Image Format</tag>
    <tag group=\"0028\" element=\"0050\" keyword=\"ManipulatedImage\" vr=\"LO\" vm=\"1-n\" retired=\"true\">Manipulated Image</tag>
    <tag group=\"0028\" element=\"0051\" keyword=\"CorrectedImage\" vr=\"CS\" vm=\"1-n\">Corrected Image</tag>
    <tag group=\"0028\" element=\"005F\" keyword=\"CompressionRecognitionCode\" vr=\"LO\" vm=\"1\" retired=\"true\">Compression Recognition Code</tag>
    <tag group=\"0028\" element=\"0060\" keyword=\"CompressionCode\" vr=\"CS\" vm=\"1\" retired=\"true\">Compression Code</tag>
    <tag group=\"0028\" element=\"0061\" keyword=\"CompressionOriginator\" vr=\"SH\" vm=\"1\" retired=\"true\">Compression Originator</tag>
    <tag group=\"0028\" element=\"0062\" keyword=\"CompressionLabel\" vr=\"LO\" vm=\"1\" retired=\"true\">Compression Label</tag>
    <tag group=\"0028\" element=\"0063\" keyword=\"CompressionDescription\" vr=\"SH\" vm=\"1\" retired=\"true\">Compression Description</tag>
    <tag group=\"0028\" element=\"0065\" keyword=\"CompressionSequence\" vr=\"CS\" vm=\"1-n\" retired=\"true\">Compression Sequence</tag>
    <tag group=\"0028\" element=\"0066\" keyword=\"CompressionStepPointers\" vr=\"AT\" vm=\"1-n\" retired=\"true\">Compression Step Pointers</tag>
    <tag group=\"0028\" element=\"0068\" keyword=\"RepeatInterval\" vr=\"US\" vm=\"1\" retired=\"true\">Repeat Interval</tag>
    <tag group=\"0028\" element=\"0069\" keyword=\"BitsGrouped\" vr=\"US\" vm=\"1\" retired=\"true\">Bits Grouped</tag>
    <tag group=\"0028\" element=\"0070\" keyword=\"PerimeterTable\" vr=\"US\" vm=\"1-n\" retired=\"true\">Perimeter Table</tag>
    <tag group=\"0028\" element=\"0071\" keyword=\"PerimeterValue\" vr=\"US/SS\" vm=\"1\" retired=\"true\">Perimeter Value</tag>
    <tag group=\"0028\" element=\"0080\" keyword=\"PredictorRows\" vr=\"US\" vm=\"1\" retired=\"true\">Predictor Rows</tag>
    <tag group=\"0028\" element=\"0081\" keyword=\"PredictorColumns\" vr=\"US\" vm=\"1\" retired=\"true\">Predictor Columns</tag>
    <tag group=\"0028\" element=\"0082\" keyword=\"PredictorConstants\" vr=\"US\" vm=\"1-n\" retired=\"true\">Predictor Constants</tag>
    <tag group=\"0028\" element=\"0090\" keyword=\"BlockedPixels\" vr=\"CS\" vm=\"1\" retired=\"true\">Blocked Pixels</tag>
    <tag group=\"0028\" element=\"0091\" keyword=\"BlockRows\" vr=\"US\" vm=\"1\" retired=\"true\">Block Rows</tag>
    <tag group=\"0028\" element=\"0092\" keyword=\"BlockColumns\" vr=\"US\" vm=\"1\" retired=\"true\">Block Columns</tag>
    <tag group=\"0028\" element=\"0093\" keyword=\"RowOverlap\" vr=\"US\" vm=\"1\" retired=\"true\">Row Overlap</tag>
    <tag group=\"0028\" element=\"0094\" keyword=\"ColumnOverlap\" vr=\"US\" vm=\"1\" retired=\"true\">Column Overlap</tag>
    <tag group=\"0028\" element=\"0100\" keyword=\"BitsAllocated\" vr=\"US\" vm=\"1\">Bits Allocated</tag>
    <tag group=\"0028\" element=\"0101\" keyword=\"BitsStored\" vr=\"US\" vm=\"1\">Bits Stored</tag>
    <tag group=\"0028\" element=\"0102\" keyword=\"HighBit\" vr=\"US\" vm=\"1\">High Bit</tag>
    <tag group=\"0028\" element=\"0103\" keyword=\"PixelRepresentation\" vr=\"US\" vm=\"1\">Pixel Representation</tag>
    <tag group=\"0028\" element=\"0104\" keyword=\"SmallestValidPixelValue\" vr=\"US/SS\" vm=\"1\" retired=\"true\">Smallest Valid Pixel Value</tag>
    <tag group=\"0028\" element=\"0105\" keyword=\"LargestValidPixelValue\" vr=\"US/SS\" vm=\"1\" retired=\"true\">Largest Valid Pixel Value</tag>
    <tag group=\"0028\" element=\"0106\" keyword=\"SmallestImagePixelValue\" vr=\"US/SS\" vm=\"1\">Smallest Image Pixel Value</tag>
    <tag group=\"0028\" element=\"0107\" keyword=\"LargestImagePixelValue\" vr=\"US/SS\" vm=\"1\">Largest Image Pixel Value</tag>
    <tag group=\"0028\" element=\"0108\" keyword=\"SmallestPixelValueInSeries\" vr=\"US/SS\" vm=\"1\">Smallest Pixel Value in Series</tag>
    <tag group=\"0028\" element=\"0109\" keyword=\"LargestPixelValueInSeries\" vr=\"US/SS\" vm=\"1\">Largest Pixel Value in Series</tag>
    <tag group=\"0028\" element=\"0110\" keyword=\"SmallestImagePixelValueInPlane\" vr=\"US/SS\" vm=\"1\" retired=\"true\">Smallest Image Pixel Value in Plane</tag>
    <tag group=\"0028\" element=\"0111\" keyword=\"LargestImagePixelValueInPlane\" vr=\"US/SS\" vm=\"1\" retired=\"true\">Largest Image Pixel Value in Plane</tag>
    <tag group=\"0028\" element=\"0120\" keyword=\"PixelPaddingValue\" vr=\"US/SS\" vm=\"1\">Pixel Padding Value</tag>
    <tag group=\"0028\" element=\"0121\" keyword=\"PixelPaddingRangeLimit\" vr=\"US/SS\" vm=\"1\">Pixel Padding Range Limit</tag>
    <tag group=\"0028\" element=\"0122\" keyword=\"FloatPixelPaddingValue\" vr=\"FL\" vm=\"1\">Float Pixel Padding Value</tag>
    <tag group=\"0028\" element=\"0123\" keyword=\"DoubleFloatPixelPaddingValue\" vr=\"FD\" vm=\"1\">Double Float Pixel Padding Value</tag>
    <tag group=\"0028\" element=\"0124\" keyword=\"FloatPixelPaddingRangeLimit\" vr=\"FL\" vm=\"1\">Float Pixel Padding Range Limit</tag>
    <tag group=\"0028\" element=\"0125\" keyword=\"DoubleFloatPixelPaddingRangeLimit\" vr=\"FD\" vm=\"1\">Double Float Pixel Padding Range Limit</tag>
    <tag group=\"0028\" element=\"0200\" keyword=\"ImageLocation\" vr=\"US\" vm=\"1\" retired=\"true\">Image Location</tag>
    <tag group=\"0028\" element=\"0300\" keyword=\"QualityControlImage\" vr=\"CS\" vm=\"1\">Quality Control Image</tag>
    <tag group=\"0028\" element=\"0301\" keyword=\"BurnedInAnnotation\" vr=\"CS\" vm=\"1\">Burned In Annotation</tag>
    <tag group=\"0028\" element=\"0302\" keyword=\"RecognizableVisualFeatures\" vr=\"CS\" vm=\"1\">Recognizable Visual Features</tag>
    <tag group=\"0028\" element=\"0303\" keyword=\"LongitudinalTemporalInformationModified\" vr=\"CS\" vm=\"1\">Longitudinal Temporal Information Modified</tag>
    <tag group=\"0028\" element=\"0304\" keyword=\"ReferencedColorPaletteInstanceUID\" vr=\"UI\" vm=\"1\">Referenced Color Palette Instance UID</tag>
    <tag group=\"0028\" element=\"0400\" keyword=\"TransformLabel\" vr=\"LO\" vm=\"1\" retired=\"true\">Transform Label</tag>
    <tag group=\"0028\" element=\"0401\" keyword=\"TransformVersionNumber\" vr=\"LO\" vm=\"1\" retired=\"true\">Transform Version Number</tag>
    <tag group=\"0028\" element=\"0402\" keyword=\"NumberOfTransformSteps\" vr=\"US\" vm=\"1\" retired=\"true\">Number of Transform Steps</tag>
    <tag group=\"0028\" element=\"0403\" keyword=\"SequenceOfCompressedData\" vr=\"LO\" vm=\"1-n\" retired=\"true\">Sequence of Compressed Data</tag>
    <tag group=\"0028\" element=\"0404\" keyword=\"DetailsOfCoefficients\" vr=\"AT\" vm=\"1-n\" retired=\"true\">Details of Coefficients</tag>
    <tag group=\"0028\" element=\"04x0\" keyword=\"RowsForNthOrderCoefficients\" vr=\"US\" vm=\"1\" retired=\"true\">Rows For Nth Order Coefficients</tag>
    <tag group=\"0028\" element=\"04x1\" keyword=\"ColumnsForNthOrderCoefficients\" vr=\"US\" vm=\"1\" retired=\"true\">Columns For Nth Order Coefficients</tag>
    <tag group=\"0028\" element=\"04x2\" keyword=\"CoefficientCoding\" vr=\"LO\" vm=\"1-n\" retired=\"true\">Coefficient Coding</tag>
    <tag group=\"0028\" element=\"04x3\" keyword=\"CoefficientCodingPointers\" vr=\"AT\" vm=\"1-n\" retired=\"true\">Coefficient Coding Pointers</tag>
    <tag group=\"0028\" element=\"0700\" keyword=\"DCTLabel\" vr=\"LO\" vm=\"1\" retired=\"true\">DCT Label</tag>
    <tag group=\"0028\" element=\"0701\" keyword=\"DataBlockDescription\" vr=\"CS\" vm=\"1-n\" retired=\"true\">Data Block Description</tag>
    <tag group=\"0028\" element=\"0702\" keyword=\"DataBlock\" vr=\"AT\" vm=\"1-n\" retired=\"true\">Data Block</tag>
    <tag group=\"0028\" element=\"0710\" keyword=\"NormalizationFactorFormat\" vr=\"US\" vm=\"1\" retired=\"true\">Normalization Factor Format</tag>
    <tag group=\"0028\" element=\"0720\" keyword=\"ZonalMapNumberFormat\" vr=\"US\" vm=\"1\" retired=\"true\">Zonal Map Number Format</tag>
    <tag group=\"0028\" element=\"0721\" keyword=\"ZonalMapLocation\" vr=\"AT\" vm=\"1-n\" retired=\"true\">Zonal Map Location</tag>
    <tag group=\"0028\" element=\"0722\" keyword=\"ZonalMapFormat\" vr=\"US\" vm=\"1\" retired=\"true\">Zonal Map Format</tag>
    <tag group=\"0028\" element=\"0730\" keyword=\"AdaptiveMapFormat\" vr=\"US\" vm=\"1\" retired=\"true\">Adaptive Map Format</tag>
    <tag group=\"0028\" element=\"0740\" keyword=\"CodeNumberFormat\" vr=\"US\" vm=\"1\" retired=\"true\">Code Number Format</tag>
    <tag group=\"0028\" element=\"08x0\" keyword=\"CodeLabel\" vr=\"CS\" vm=\"1-n\" retired=\"true\">Code Label</tag>
    <tag group=\"0028\" element=\"08x2\" keyword=\"NumberOfTables\" vr=\"US\" vm=\"1\" retired=\"true\">Number of Tables</tag>
    <tag group=\"0028\" element=\"08x3\" keyword=\"CodeTableLocation\" vr=\"AT\" vm=\"1-n\" retired=\"true\">Code Table Location</tag>
    <tag group=\"0028\" element=\"08x4\" keyword=\"BitsForCodeWord\" vr=\"US\" vm=\"1\" retired=\"true\">Bits For Code Word</tag>
    <tag group=\"0028\" element=\"08x8\" keyword=\"ImageDataLocation\" vr=\"AT\" vm=\"1-n\" retired=\"true\">Image Data Location</tag>
    <tag group=\"0028\" element=\"0A02\" keyword=\"PixelSpacingCalibrationType\" vr=\"CS\" vm=\"1\">Pixel Spacing Calibration Type</tag>
    <tag group=\"0028\" element=\"0A04\" keyword=\"PixelSpacingCalibrationDescription\" vr=\"LO\" vm=\"1\">Pixel Spacing Calibration Description</tag>
    <tag group=\"0028\" element=\"1040\" keyword=\"PixelIntensityRelationship\" vr=\"CS\" vm=\"1\">Pixel Intensity Relationship</tag>
    <tag group=\"0028\" element=\"1041\" keyword=\"PixelIntensityRelationshipSign\" vr=\"SS\" vm=\"1\">Pixel Intensity Relationship Sign</tag>
    <tag group=\"0028\" element=\"1050\" keyword=\"WindowCenter\" vr=\"DS\" vm=\"1-n\">Window Center</tag>
    <tag group=\"0028\" element=\"1051\" keyword=\"WindowWidth\" vr=\"DS\" vm=\"1-n\">Window Width</tag>
    <tag group=\"0028\" element=\"1052\" keyword=\"RescaleIntercept\" vr=\"DS\" vm=\"1\">Rescale Intercept</tag>
    <tag group=\"0028\" element=\"1053\" keyword=\"RescaleSlope\" vr=\"DS\" vm=\"1\">Rescale Slope</tag>
    <tag group=\"0028\" element=\"1054\" keyword=\"RescaleType\" vr=\"LO\" vm=\"1\">Rescale Type</tag>
    <tag group=\"0028\" element=\"1055\" keyword=\"WindowCenterWidthExplanation\" vr=\"LO\" vm=\"1-n\">Window Center &amp; Width Explanation</tag>
    <tag group=\"0028\" element=\"1056\" keyword=\"VOILUTFunction\" vr=\"CS\" vm=\"1\">VOI LUT Function</tag>
    <tag group=\"0028\" element=\"1080\" keyword=\"GrayScale\" vr=\"CS\" vm=\"1\" retired=\"true\">Gray Scale</tag>
    <tag group=\"0028\" element=\"1090\" keyword=\"RecommendedViewingMode\" vr=\"CS\" vm=\"1\">Recommended Viewing Mode</tag>
    <tag group=\"0028\" element=\"1100\" keyword=\"GrayLookupTableDescriptor\" vr=\"US/SS\" vm=\"3\" retired=\"true\">Gray Lookup Table Descriptor</tag>
    <tag group=\"0028\" element=\"1101\" keyword=\"RedPaletteColorLookupTableDescriptor\" vr=\"US/SS\" vm=\"3\">Red Palette Color Lookup Table Descriptor</tag>
    <tag group=\"0028\" element=\"1102\" keyword=\"GreenPaletteColorLookupTableDescriptor\" vr=\"US/SS\" vm=\"3\">Green Palette Color Lookup Table Descriptor</tag>
    <tag group=\"0028\" element=\"1103\" keyword=\"BluePaletteColorLookupTableDescriptor\" vr=\"US/SS\" vm=\"3\">Blue Palette Color Lookup Table Descriptor</tag>
    <tag group=\"0028\" element=\"1104\" keyword=\"AlphaPaletteColorLookupTableDescriptor\" vr=\"US\" vm=\"3\">Alpha Palette Color Lookup Table Descriptor</tag>
    <tag group=\"0028\" element=\"1111\" keyword=\"LargeRedPaletteColorLookupTableDescriptor\" vr=\"US/SS\" vm=\"4\" retired=\"true\">Large Red Palette Color Lookup Table Descriptor</tag>
    <tag group=\"0028\" element=\"1112\" keyword=\"LargeGreenPaletteColorLookupTableDescriptor\" vr=\"US/SS\" vm=\"4\" retired=\"true\">Large Green Palette Color Lookup Table Descriptor</tag>
    <tag group=\"0028\" element=\"1113\" keyword=\"LargeBluePaletteColorLookupTableDescriptor\" vr=\"US/SS\" vm=\"4\" retired=\"true\">Large Blue Palette Color Lookup Table Descriptor</tag>
    <tag group=\"0028\" element=\"1199\" keyword=\"PaletteColorLookupTableUID\" vr=\"UI\" vm=\"1\">Palette Color Lookup Table UID</tag>
    <tag group=\"0028\" element=\"1200\" keyword=\"GrayLookupTableData\" vr=\"US/SS/OW\" vm=\"1-n or 1\" retired=\"true\">Gray Lookup Table Data</tag>
    <tag group=\"0028\" element=\"1201\" keyword=\"RedPaletteColorLookupTableData\" vr=\"OW\" vm=\"1\">Red Palette Color Lookup Table Data</tag>
    <tag group=\"0028\" element=\"1202\" keyword=\"GreenPaletteColorLookupTableData\" vr=\"OW\" vm=\"1\">Green Palette Color Lookup Table Data</tag>
    <tag group=\"0028\" element=\"1203\" keyword=\"BluePaletteColorLookupTableData\" vr=\"OW\" vm=\"1\">Blue Palette Color Lookup Table Data</tag>
    <tag group=\"0028\" element=\"1204\" keyword=\"AlphaPaletteColorLookupTableData\" vr=\"OW\" vm=\"1\">Alpha Palette Color Lookup Table Data</tag>
    <tag group=\"0028\" element=\"1211\" keyword=\"LargeRedPaletteColorLookupTableData\" vr=\"OW\" vm=\"1\" retired=\"true\">Large Red Palette Color Lookup Table Data</tag>
    <tag group=\"0028\" element=\"1212\" keyword=\"LargeGreenPaletteColorLookupTableData\" vr=\"OW\" vm=\"1\" retired=\"true\">Large Green Palette Color Lookup Table Data</tag>
    <tag group=\"0028\" element=\"1213\" keyword=\"LargeBluePaletteColorLookupTableData\" vr=\"OW\" vm=\"1\" retired=\"true\">Large Blue Palette Color Lookup Table Data</tag>
    <tag group=\"0028\" element=\"1214\" keyword=\"LargePaletteColorLookupTableUID\" vr=\"UI\" vm=\"1\" retired=\"true\">Large Palette Color Lookup Table UID</tag>
    <tag group=\"0028\" element=\"1221\" keyword=\"SegmentedRedPaletteColorLookupTableData\" vr=\"OW\" vm=\"1\">Segmented Red Palette Color Lookup Table Data</tag>
    <tag group=\"0028\" element=\"1222\" keyword=\"SegmentedGreenPaletteColorLookupTableData\" vr=\"OW\" vm=\"1\">Segmented Green Palette Color Lookup Table Data</tag>
    <tag group=\"0028\" element=\"1223\" keyword=\"SegmentedBluePaletteColorLookupTableData\" vr=\"OW\" vm=\"1\">Segmented Blue Palette Color Lookup Table Data</tag>
    <tag group=\"0028\" element=\"1224\" keyword=\"SegmentedAlphaPaletteColorLookupTableData\" vr=\"OW\" vm=\"1\">Segmented Alpha Palette Color Lookup Table Data</tag>
    <tag group=\"0028\" element=\"1230\" keyword=\"StoredValueColorRangeSequence\" vr=\"SQ\" vm=\"1\">Stored Value Color Range Sequence</tag>
    <tag group=\"0028\" element=\"1231\" keyword=\"MinimumStoredValueMapped\" vr=\"FD\" vm=\"1\">Minimum Stored Value Mapped</tag>
    <tag group=\"0028\" element=\"1232\" keyword=\"MaximumStoredValueMapped\" vr=\"FD\" vm=\"1\">Maximum Stored Value Mapped</tag>
    <tag group=\"0028\" element=\"1300\" keyword=\"BreastImplantPresent\" vr=\"CS\" vm=\"1\">Breast Implant Present</tag>
    <tag group=\"0028\" element=\"1350\" keyword=\"PartialView\" vr=\"CS\" vm=\"1\">Partial View</tag>
    <tag group=\"0028\" element=\"1351\" keyword=\"PartialViewDescription\" vr=\"ST\" vm=\"1\">Partial View Description</tag>
    <tag group=\"0028\" element=\"1352\" keyword=\"PartialViewCodeSequence\" vr=\"SQ\" vm=\"1\">Partial View Code Sequence</tag>
    <tag group=\"0028\" element=\"135A\" keyword=\"SpatialLocationsPreserved\" vr=\"CS\" vm=\"1\">Spatial Locations Preserved</tag>
    <tag group=\"0028\" element=\"1401\" keyword=\"DataFrameAssignmentSequence\" vr=\"SQ\" vm=\"1\">Data Frame Assignment Sequence</tag>
    <tag group=\"0028\" element=\"1402\" keyword=\"DataPathAssignment\" vr=\"CS\" vm=\"1\">Data Path Assignment</tag>
    <tag group=\"0028\" element=\"1403\" keyword=\"BitsMappedToColorLookupTable\" vr=\"US\" vm=\"1\">Bits Mapped to Color Lookup Table</tag>
    <tag group=\"0028\" element=\"1404\" keyword=\"BlendingLUT1Sequence\" vr=\"SQ\" vm=\"1\">Blending LUT 1 Sequence</tag>
    <tag group=\"0028\" element=\"1405\" keyword=\"BlendingLUT1TransferFunction\" vr=\"CS\" vm=\"1\">Blending LUT 1 Transfer Function</tag>
    <tag group=\"0028\" element=\"1406\" keyword=\"BlendingWeightConstant\" vr=\"FD\" vm=\"1\">Blending Weight Constant</tag>
    <tag group=\"0028\" element=\"1407\" keyword=\"BlendingLookupTableDescriptor\" vr=\"US\" vm=\"3\">Blending Lookup Table Descriptor</tag>
    <tag group=\"0028\" element=\"1408\" keyword=\"BlendingLookupTableData\" vr=\"OW\" vm=\"1\">Blending Lookup Table Data</tag>
    <tag group=\"0028\" element=\"140B\" keyword=\"EnhancedPaletteColorLookupTableSequence\" vr=\"SQ\" vm=\"1\">Enhanced Palette Color Lookup Table Sequence</tag>
    <tag group=\"0028\" element=\"140C\" keyword=\"BlendingLUT2Sequence\" vr=\"SQ\" vm=\"1\">Blending LUT 2 Sequence</tag>
    <tag group=\"0028\" element=\"140D\" keyword=\"BlendingLUT2TransferFunction\" vr=\"CS\" vm=\"1\">Blending LUT 2 Transfer Function</tag>
    <tag group=\"0028\" element=\"140E\" keyword=\"DataPathID\" vr=\"CS\" vm=\"1\">Data Path ID</tag>
    <tag group=\"0028\" element=\"140F\" keyword=\"RGBLUTTransferFunction\" vr=\"CS\" vm=\"1\">RGB LUT Transfer Function</tag>
    <tag group=\"0028\" element=\"1410\" keyword=\"AlphaLUTTransferFunction\" vr=\"CS\" vm=\"1\">Alpha LUT Transfer Function</tag>
    <tag group=\"0028\" element=\"2000\" keyword=\"ICCProfile\" vr=\"OB\" vm=\"1\">ICC Profile</tag>
    <tag group=\"0028\" element=\"2002\" keyword=\"ColorSpace\" vr=\"CS\" vm=\"1\">Color Space</tag>
    <tag group=\"0028\" element=\"2110\" keyword=\"LossyImageCompression\" vr=\"CS\" vm=\"1\">Lossy Image Compression</tag>
    <tag group=\"0028\" element=\"2112\" keyword=\"LossyImageCompressionRatio\" vr=\"DS\" vm=\"1-n\">Lossy Image Compression Ratio</tag>
    <tag group=\"0028\" element=\"2114\" keyword=\"LossyImageCompressionMethod\" vr=\"CS\" vm=\"1-n\">Lossy Image Compression Method</tag>
    <tag group=\"0028\" element=\"3000\" keyword=\"ModalityLUTSequence\" vr=\"SQ\" vm=\"1\">Modality LUT Sequence</tag>
    <tag group=\"0028\" element=\"3002\" keyword=\"LUTDescriptor\" vr=\"US/SS\" vm=\"3\">LUT Descriptor</tag>
    <tag group=\"0028\" element=\"3003\" keyword=\"LUTExplanation\" vr=\"LO\" vm=\"1\">LUT Explanation</tag>
    <tag group=\"0028\" element=\"3004\" keyword=\"ModalityLUTType\" vr=\"LO\" vm=\"1\">Modality LUT Type</tag>
    <tag group=\"0028\" element=\"3006\" keyword=\"LUTData\" vr=\"US/OW\" vm=\"1-n or 1\">LUT Data</tag>
    <tag group=\"0028\" element=\"3010\" keyword=\"VOILUTSequence\" vr=\"SQ\" vm=\"1\">VOI LUT Sequence</tag>
    <tag group=\"0028\" element=\"3110\" keyword=\"SoftcopyVOILUTSequence\" vr=\"SQ\" vm=\"1\">Softcopy VOI LUT Sequence</tag>
    <tag group=\"0028\" element=\"4000\" keyword=\"ImagePresentationComments\" vr=\"LT\" vm=\"1\" retired=\"true\">Image Presentation Comments</tag>
    <tag group=\"0028\" element=\"5000\" keyword=\"BiPlaneAcquisitionSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Bi-Plane Acquisition Sequence</tag>
    <tag group=\"0028\" element=\"6010\" keyword=\"RepresentativeFrameNumber\" vr=\"US\" vm=\"1\">Representative Frame Number</tag>
    <tag group=\"0028\" element=\"6020\" keyword=\"FrameNumbersOfInterest\" vr=\"US\" vm=\"1-n\">Frame Numbers of Interest (FOI)</tag>
    <tag group=\"0028\" element=\"6022\" keyword=\"FrameOfInterestDescription\" vr=\"LO\" vm=\"1-n\">Frame of Interest Description</tag>
    <tag group=\"0028\" element=\"6023\" keyword=\"FrameOfInterestType\" vr=\"CS\" vm=\"1-n\">Frame of Interest Type</tag>
    <tag group=\"0028\" element=\"6030\" keyword=\"MaskPointers\" vr=\"US\" vm=\"1-n\" retired=\"true\">Mask Pointer(s)</tag>
    <tag group=\"0028\" element=\"6040\" keyword=\"RWavePointer\" vr=\"US\" vm=\"1-n\">R Wave Pointer</tag>
    <tag group=\"0028\" element=\"6100\" keyword=\"MaskSubtractionSequence\" vr=\"SQ\" vm=\"1\">Mask Subtraction Sequence</tag>
    <tag group=\"0028\" element=\"6101\" keyword=\"MaskOperation\" vr=\"CS\" vm=\"1\">Mask Operation</tag>
    <tag group=\"0028\" element=\"6102\" keyword=\"ApplicableFrameRange\" vr=\"US\" vm=\"2-2n\">Applicable Frame Range</tag>
    <tag group=\"0028\" element=\"6110\" keyword=\"MaskFrameNumbers\" vr=\"US\" vm=\"1-n\">Mask Frame Numbers</tag>
    <tag group=\"0028\" element=\"6112\" keyword=\"ContrastFrameAveraging\" vr=\"US\" vm=\"1\">Contrast Frame Averaging</tag>
    <tag group=\"0028\" element=\"6114\" keyword=\"MaskSubPixelShift\" vr=\"FL\" vm=\"2\">Mask Sub-pixel Shift</tag>
    <tag group=\"0028\" element=\"6120\" keyword=\"TIDOffset\" vr=\"SS\" vm=\"1\">TID Offset</tag>
    <tag group=\"0028\" element=\"6190\" keyword=\"MaskOperationExplanation\" vr=\"ST\" vm=\"1\">Mask Operation Explanation</tag>
    <tag group=\"0028\" element=\"7000\" keyword=\"EquipmentAdministratorSequence\" vr=\"SQ\" vm=\"1\">Equipment Administrator Sequence</tag>
    <tag group=\"0028\" element=\"7001\" keyword=\"NumberOfDisplaySubsystems\" vr=\"US\" vm=\"1\">Number of Display Subsystems</tag>
    <tag group=\"0028\" element=\"7002\" keyword=\"CurrentConfigurationID\" vr=\"US\" vm=\"1\">Current Configuration ID</tag>
    <tag group=\"0028\" element=\"7003\" keyword=\"DisplaySubsystemID\" vr=\"US\" vm=\"1\">Display Subsystem ID</tag>
    <tag group=\"0028\" element=\"7004\" keyword=\"DisplaySubsystemName\" vr=\"SH\" vm=\"1\">Display Subsystem Name</tag>
    <tag group=\"0028\" element=\"7005\" keyword=\"DisplaySubsystemDescription\" vr=\"LO\" vm=\"1\">Display Subsystem Description</tag>
    <tag group=\"0028\" element=\"7006\" keyword=\"SystemStatus\" vr=\"CS\" vm=\"1\">System Status</tag>
    <tag group=\"0028\" element=\"7007\" keyword=\"SystemStatusComment\" vr=\"LO\" vm=\"1\">System Status Comment</tag>
    <tag group=\"0028\" element=\"7008\" keyword=\"TargetLuminanceCharacteristicsSequence\" vr=\"SQ\" vm=\"1\">Target Luminance Characteristics Sequence</tag>
    <tag group=\"0028\" element=\"7009\" keyword=\"LuminanceCharacteristicsID\" vr=\"US\" vm=\"1\">Luminance Characteristics ID</tag>
    <tag group=\"0028\" element=\"700A\" keyword=\"DisplaySubsystemConfigurationSequence\" vr=\"SQ\" vm=\"1\">Display Subsystem Configuration Sequence</tag>
    <tag group=\"0028\" element=\"700B\" keyword=\"ConfigurationID\" vr=\"US\" vm=\"1\">Configuration ID</tag>
    <tag group=\"0028\" element=\"700C\" keyword=\"ConfigurationName\" vr=\"SH\" vm=\"1\">Configuration Name</tag>
    <tag group=\"0028\" element=\"700D\" keyword=\"ConfigurationDescription\" vr=\"LO\" vm=\"1\">Configuration Description</tag>
    <tag group=\"0028\" element=\"700E\" keyword=\"ReferencedTargetLuminanceCharacteristicsID\" vr=\"US\" vm=\"1\">Referenced Target Luminance Characteristics ID</tag>
    <tag group=\"0028\" element=\"700F\" keyword=\"QAResultsSequence\" vr=\"SQ\" vm=\"1\">QA Results Sequence</tag>
    <tag group=\"0028\" element=\"7010\" keyword=\"DisplaySubsystemQAResultsSequence\" vr=\"SQ\" vm=\"1\">Display Subsystem QA Results Sequence</tag>
    <tag group=\"0028\" element=\"7011\" keyword=\"ConfigurationQAResultsSequence\" vr=\"SQ\" vm=\"1\">Configuration QA Results Sequence</tag>
    <tag group=\"0028\" element=\"7012\" keyword=\"MeasurementEquipmentSequence\" vr=\"SQ\" vm=\"1\">Measurement Equipment Sequence</tag>
    <tag group=\"0028\" element=\"7013\" keyword=\"MeasurementFunctions\" vr=\"CS\" vm=\"1-n\">Measurement Functions</tag>
    <tag group=\"0028\" element=\"7014\" keyword=\"MeasurementEquipmentType\" vr=\"CS\" vm=\"1\">Measurement Equipment Type</tag>
    <tag group=\"0028\" element=\"7015\" keyword=\"VisualEvaluationResultSequence\" vr=\"SQ\" vm=\"1\">Visual Evaluation Result Sequence</tag>
    <tag group=\"0028\" element=\"7016\" keyword=\"DisplayCalibrationResultSequence\" vr=\"SQ\" vm=\"1\">Display Calibration Result Sequence</tag>
    <tag group=\"0028\" element=\"7017\" keyword=\"DDLValue\" vr=\"US\" vm=\"1\">DDL Value</tag>
    <tag group=\"0028\" element=\"7018\" keyword=\"CIExyWhitePoint\" vr=\"FL\" vm=\"2\">CIExy White Point</tag>
    <tag group=\"0028\" element=\"7019\" keyword=\"DisplayFunctionType\" vr=\"CS\" vm=\"1\">Display Function Type</tag>
    <tag group=\"0028\" element=\"701A\" keyword=\"GammaValue\" vr=\"FL\" vm=\"1\">Gamma Value</tag>
    <tag group=\"0028\" element=\"701B\" keyword=\"NumberOfLuminancePoints\" vr=\"US\" vm=\"1\">Number of Luminance Points</tag>
    <tag group=\"0028\" element=\"701C\" keyword=\"LuminanceResponseSequence\" vr=\"SQ\" vm=\"1\">Luminance Response Sequence</tag>
    <tag group=\"0028\" element=\"701D\" keyword=\"TargetMinimumLuminance\" vr=\"FL\" vm=\"1\">Target Minimum Luminance</tag>
    <tag group=\"0028\" element=\"701E\" keyword=\"TargetMaximumLuminance\" vr=\"FL\" vm=\"1\">Target Maximum Luminance</tag>
    <tag group=\"0028\" element=\"701F\" keyword=\"LuminanceValue\" vr=\"FL\" vm=\"1\">Luminance Value</tag>
    <tag group=\"0028\" element=\"7020\" keyword=\"LuminanceResponseDescription\" vr=\"LO\" vm=\"1\">Luminance Response Description</tag>
    <tag group=\"0028\" element=\"7021\" keyword=\"WhitePointFlag\" vr=\"CS\" vm=\"1\">White Point Flag</tag>
    <tag group=\"0028\" element=\"7022\" keyword=\"DisplayDeviceTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Display Device Type Code Sequence</tag>
    <tag group=\"0028\" element=\"7023\" keyword=\"DisplaySubsystemSequence\" vr=\"SQ\" vm=\"1\">Display Subsystem Sequence</tag>
    <tag group=\"0028\" element=\"7024\" keyword=\"LuminanceResultSequence\" vr=\"SQ\" vm=\"1\">Luminance Result Sequence</tag>
    <tag group=\"0028\" element=\"7025\" keyword=\"AmbientLightValueSource\" vr=\"CS\" vm=\"1\">Ambient Light Value Source</tag>
    <tag group=\"0028\" element=\"7026\" keyword=\"MeasuredCharacteristics\" vr=\"CS\" vm=\"1-n\">Measured Characteristics</tag>
    <tag group=\"0028\" element=\"7027\" keyword=\"LuminanceUniformityResultSequence\" vr=\"SQ\" vm=\"1\">Luminance Uniformity Result Sequence</tag>
    <tag group=\"0028\" element=\"7028\" keyword=\"VisualEvaluationTestSequence\" vr=\"SQ\" vm=\"1\">Visual Evaluation Test Sequence</tag>
    <tag group=\"0028\" element=\"7029\" keyword=\"TestResult\" vr=\"CS\" vm=\"1\">Test Result</tag>
    <tag group=\"0028\" element=\"702A\" keyword=\"TestResultComment\" vr=\"LO\" vm=\"1\">Test Result Comment</tag>
    <tag group=\"0028\" element=\"702B\" keyword=\"TestImageValidation\" vr=\"CS\" vm=\"1\">Test Image Validation</tag>
    <tag group=\"0028\" element=\"702C\" keyword=\"TestPatternCodeSequence\" vr=\"SQ\" vm=\"1\">Test Pattern Code Sequence</tag>
    <tag group=\"0028\" element=\"702D\" keyword=\"MeasurementPatternCodeSequence\" vr=\"SQ\" vm=\"1\">Measurement Pattern Code Sequence</tag>
    <tag group=\"0028\" element=\"702E\" keyword=\"VisualEvaluationMethodCodeSequence\" vr=\"SQ\" vm=\"1\">Visual Evaluation Method Code Sequence</tag>
    <tag group=\"0028\" element=\"7FE0\" keyword=\"PixelDataProviderURL\" vr=\"UR\" vm=\"1\">Pixel Data Provider URL</tag>
    <tag group=\"0028\" element=\"9001\" keyword=\"DataPointRows\" vr=\"UL\" vm=\"1\">Data Point Rows</tag>
    <tag group=\"0028\" element=\"9002\" keyword=\"DataPointColumns\" vr=\"UL\" vm=\"1\">Data Point Columns</tag>
    <tag group=\"0028\" element=\"9003\" keyword=\"SignalDomainColumns\" vr=\"CS\" vm=\"1\">Signal Domain Columns</tag>
    <tag group=\"0028\" element=\"9099\" keyword=\"LargestMonochromePixelValue\" vr=\"US\" vm=\"1\" retired=\"true\">Largest Monochrome Pixel Value</tag>
    <tag group=\"0028\" element=\"9108\" keyword=\"DataRepresentation\" vr=\"CS\" vm=\"1\">Data Representation</tag>
    <tag group=\"0028\" element=\"9110\" keyword=\"PixelMeasuresSequence\" vr=\"SQ\" vm=\"1\">Pixel Measures Sequence</tag>
    <tag group=\"0028\" element=\"9132\" keyword=\"FrameVOILUTSequence\" vr=\"SQ\" vm=\"1\">Frame VOI LUT Sequence</tag>
    <tag group=\"0028\" element=\"9145\" keyword=\"PixelValueTransformationSequence\" vr=\"SQ\" vm=\"1\">Pixel Value Transformation Sequence</tag>
    <tag group=\"0028\" element=\"9235\" keyword=\"SignalDomainRows\" vr=\"CS\" vm=\"1\">Signal Domain Rows</tag>
    <tag group=\"0028\" element=\"9411\" keyword=\"DisplayFilterPercentage\" vr=\"FL\" vm=\"1\">Display Filter Percentage</tag>
    <tag group=\"0028\" element=\"9415\" keyword=\"FramePixelShiftSequence\" vr=\"SQ\" vm=\"1\">Frame Pixel Shift Sequence</tag>
    <tag group=\"0028\" element=\"9416\" keyword=\"SubtractionItemID\" vr=\"US\" vm=\"1\">Subtraction Item ID</tag>
    <tag group=\"0028\" element=\"9422\" keyword=\"PixelIntensityRelationshipLUTSequence\" vr=\"SQ\" vm=\"1\">Pixel Intensity Relationship LUT Sequence</tag>
    <tag group=\"0028\" element=\"9443\" keyword=\"FramePixelDataPropertiesSequence\" vr=\"SQ\" vm=\"1\">Frame Pixel Data Properties Sequence</tag>
    <tag group=\"0028\" element=\"9444\" keyword=\"GeometricalProperties\" vr=\"CS\" vm=\"1\">Geometrical Properties</tag>
    <tag group=\"0028\" element=\"9445\" keyword=\"GeometricMaximumDistortion\" vr=\"FL\" vm=\"1\">Geometric Maximum Distortion</tag>
    <tag group=\"0028\" element=\"9446\" keyword=\"ImageProcessingApplied\" vr=\"CS\" vm=\"1-n\">Image Processing Applied</tag>
    <tag group=\"0028\" element=\"9454\" keyword=\"MaskSelectionMode\" vr=\"CS\" vm=\"1\">Mask Selection Mode</tag>
    <tag group=\"0028\" element=\"9474\" keyword=\"LUTFunction\" vr=\"CS\" vm=\"1\">LUT Function</tag>
    <tag group=\"0028\" element=\"9478\" keyword=\"MaskVisibilityPercentage\" vr=\"FL\" vm=\"1\">Mask Visibility Percentage</tag>
    <tag group=\"0028\" element=\"9501\" keyword=\"PixelShiftSequence\" vr=\"SQ\" vm=\"1\">Pixel Shift Sequence</tag>
    <tag group=\"0028\" element=\"9502\" keyword=\"RegionPixelShiftSequence\" vr=\"SQ\" vm=\"1\">Region Pixel Shift Sequence</tag>
    <tag group=\"0028\" element=\"9503\" keyword=\"VerticesOfTheRegion\" vr=\"SS\" vm=\"2-2n\">Vertices of the Region</tag>
    <tag group=\"0028\" element=\"9505\" keyword=\"MultiFramePresentationSequence\" vr=\"SQ\" vm=\"1\">Multi-frame Presentation Sequence</tag>
    <tag group=\"0028\" element=\"9506\" keyword=\"PixelShiftFrameRange\" vr=\"US\" vm=\"2-2n\">Pixel Shift Frame Range</tag>
    <tag group=\"0028\" element=\"9507\" keyword=\"LUTFrameRange\" vr=\"US\" vm=\"2-2n\">LUT Frame Range</tag>
    <tag group=\"0028\" element=\"9520\" keyword=\"ImageToEquipmentMappingMatrix\" vr=\"DS\" vm=\"16\">Image to Equipment Mapping Matrix</tag>
    <tag group=\"0028\" element=\"9537\" keyword=\"EquipmentCoordinateSystemIdentification\" vr=\"CS\" vm=\"1\">Equipment Coordinate System Identification</tag>
    <tag group=\"0032\" element=\"000A\" keyword=\"StudyStatusID\" vr=\"CS\" vm=\"1\" retired=\"true\">Study Status ID</tag>
    <tag group=\"0032\" element=\"000C\" keyword=\"StudyPriorityID\" vr=\"CS\" vm=\"1\" retired=\"true\">Study Priority ID</tag>
    <tag group=\"0032\" element=\"0012\" keyword=\"StudyIDIssuer\" vr=\"LO\" vm=\"1\" retired=\"true\">Study ID Issuer</tag>
    <tag group=\"0032\" element=\"0032\" keyword=\"StudyVerifiedDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Study Verified Date</tag>
    <tag group=\"0032\" element=\"0033\" keyword=\"StudyVerifiedTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Study Verified Time</tag>
    <tag group=\"0032\" element=\"0034\" keyword=\"StudyReadDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Study Read Date</tag>
    <tag group=\"0032\" element=\"0035\" keyword=\"StudyReadTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Study Read Time</tag>
    <tag group=\"0032\" element=\"1000\" keyword=\"ScheduledStudyStartDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Scheduled Study Start Date</tag>
    <tag group=\"0032\" element=\"1001\" keyword=\"ScheduledStudyStartTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Scheduled Study Start Time</tag>
    <tag group=\"0032\" element=\"1010\" keyword=\"ScheduledStudyStopDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Scheduled Study Stop Date</tag>
    <tag group=\"0032\" element=\"1011\" keyword=\"ScheduledStudyStopTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Scheduled Study Stop Time</tag>
    <tag group=\"0032\" element=\"1020\" keyword=\"ScheduledStudyLocation\" vr=\"LO\" vm=\"1\" retired=\"true\">Scheduled Study Location</tag>
    <tag group=\"0032\" element=\"1021\" keyword=\"ScheduledStudyLocationAETitle\" vr=\"AE\" vm=\"1-n\" retired=\"true\">Scheduled Study Location AE Title</tag>
    <tag group=\"0032\" element=\"1030\" keyword=\"ReasonForStudy\" vr=\"LO\" vm=\"1\" retired=\"true\">Reason for Study</tag>
    <tag group=\"0032\" element=\"1031\" keyword=\"RequestingPhysicianIdentificationSequence\" vr=\"SQ\" vm=\"1\">Requesting Physician Identification Sequence</tag>
    <tag group=\"0032\" element=\"1032\" keyword=\"RequestingPhysician\" vr=\"PN\" vm=\"1\">Requesting Physician</tag>
    <tag group=\"0032\" element=\"1033\" keyword=\"RequestingService\" vr=\"LO\" vm=\"1\">Requesting Service</tag>
    <tag group=\"0032\" element=\"1034\" keyword=\"RequestingServiceCodeSequence\" vr=\"SQ\" vm=\"1\">Requesting Service Code Sequence</tag>
    <tag group=\"0032\" element=\"1040\" keyword=\"StudyArrivalDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Study Arrival Date</tag>
    <tag group=\"0032\" element=\"1041\" keyword=\"StudyArrivalTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Study Arrival Time</tag>
    <tag group=\"0032\" element=\"1050\" keyword=\"StudyCompletionDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Study Completion Date</tag>
    <tag group=\"0032\" element=\"1051\" keyword=\"StudyCompletionTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Study Completion Time</tag>
    <tag group=\"0032\" element=\"1055\" keyword=\"StudyComponentStatusID\" vr=\"CS\" vm=\"1\" retired=\"true\">Study Component Status ID</tag>
    <tag group=\"0032\" element=\"1060\" keyword=\"RequestedProcedureDescription\" vr=\"LO\" vm=\"1\">Requested Procedure Description</tag>
    <tag group=\"0032\" element=\"1064\" keyword=\"RequestedProcedureCodeSequence\" vr=\"SQ\" vm=\"1\">Requested Procedure Code Sequence</tag>
    <tag group=\"0032\" element=\"1070\" keyword=\"RequestedContrastAgent\" vr=\"LO\" vm=\"1\">Requested Contrast Agent</tag>
    <tag group=\"0032\" element=\"4000\" keyword=\"StudyComments\" vr=\"LT\" vm=\"1\" retired=\"true\">Study Comments</tag>
    <tag group=\"0038\" element=\"0004\" keyword=\"ReferencedPatientAliasSequence\" vr=\"SQ\" vm=\"1\">Referenced Patient Alias Sequence</tag>
    <tag group=\"0038\" element=\"0008\" keyword=\"VisitStatusID\" vr=\"CS\" vm=\"1\">Visit Status ID</tag>
    <tag group=\"0038\" element=\"0010\" keyword=\"AdmissionID\" vr=\"LO\" vm=\"1\">Admission ID</tag>
    <tag group=\"0038\" element=\"0011\" keyword=\"IssuerOfAdmissionID\" vr=\"LO\" vm=\"1\" retired=\"true\">Issuer of Admission ID</tag>
    <tag group=\"0038\" element=\"0014\" keyword=\"IssuerOfAdmissionIDSequence\" vr=\"SQ\" vm=\"1\">Issuer of Admission ID Sequence</tag>
    <tag group=\"0038\" element=\"0016\" keyword=\"RouteOfAdmissions\" vr=\"LO\" vm=\"1\">Route of Admissions</tag>
    <tag group=\"0038\" element=\"001A\" keyword=\"ScheduledAdmissionDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Scheduled Admission Date</tag>
    <tag group=\"0038\" element=\"001B\" keyword=\"ScheduledAdmissionTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Scheduled Admission Time</tag>
    <tag group=\"0038\" element=\"001C\" keyword=\"ScheduledDischargeDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Scheduled Discharge Date</tag>
    <tag group=\"0038\" element=\"001D\" keyword=\"ScheduledDischargeTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Scheduled Discharge Time</tag>
    <tag group=\"0038\" element=\"001E\" keyword=\"ScheduledPatientInstitutionResidence\" vr=\"LO\" vm=\"1\" retired=\"true\">Scheduled Patient Institution Residence</tag>
    <tag group=\"0038\" element=\"0020\" keyword=\"AdmittingDate\" vr=\"DA\" vm=\"1\">Admitting Date</tag>
    <tag group=\"0038\" element=\"0021\" keyword=\"AdmittingTime\" vr=\"TM\" vm=\"1\">Admitting Time</tag>
    <tag group=\"0038\" element=\"0030\" keyword=\"DischargeDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Discharge Date</tag>
    <tag group=\"0038\" element=\"0032\" keyword=\"DischargeTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Discharge Time</tag>
    <tag group=\"0038\" element=\"0040\" keyword=\"DischargeDiagnosisDescription\" vr=\"LO\" vm=\"1\" retired=\"true\">Discharge Diagnosis Description</tag>
    <tag group=\"0038\" element=\"0044\" keyword=\"DischargeDiagnosisCodeSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Discharge Diagnosis Code Sequence</tag>
    <tag group=\"0038\" element=\"0050\" keyword=\"SpecialNeeds\" vr=\"LO\" vm=\"1\">Special Needs</tag>
    <tag group=\"0038\" element=\"0060\" keyword=\"ServiceEpisodeID\" vr=\"LO\" vm=\"1\">Service Episode ID</tag>
    <tag group=\"0038\" element=\"0061\" keyword=\"IssuerOfServiceEpisodeID\" vr=\"LO\" vm=\"1\" retired=\"true\">Issuer of Service Episode ID</tag>
    <tag group=\"0038\" element=\"0062\" keyword=\"ServiceEpisodeDescription\" vr=\"LO\" vm=\"1\">Service Episode Description</tag>
    <tag group=\"0038\" element=\"0064\" keyword=\"IssuerOfServiceEpisodeIDSequence\" vr=\"SQ\" vm=\"1\">Issuer of Service Episode ID Sequence</tag>
    <tag group=\"0038\" element=\"0100\" keyword=\"PertinentDocumentsSequence\" vr=\"SQ\" vm=\"1\">Pertinent Documents Sequence</tag>
    <tag group=\"0038\" element=\"0101\" keyword=\"PertinentResourcesSequence\" vr=\"SQ\" vm=\"1\">Pertinent Resources Sequence</tag>
    <tag group=\"0038\" element=\"0102\" keyword=\"ResourceDescription\" vr=\"LO\" vm=\"1\">Resource Description</tag>
    <tag group=\"0038\" element=\"0300\" keyword=\"CurrentPatientLocation\" vr=\"LO\" vm=\"1\">Current Patient Location</tag>
    <tag group=\"0038\" element=\"0400\" keyword=\"PatientInstitutionResidence\" vr=\"LO\" vm=\"1\">Patient's Institution Residence</tag>
    <tag group=\"0038\" element=\"0500\" keyword=\"PatientState\" vr=\"LO\" vm=\"1\">Patient State</tag>
    <tag group=\"0038\" element=\"0502\" keyword=\"PatientClinicalTrialParticipationSequence\" vr=\"SQ\" vm=\"1\">Patient Clinical Trial Participation Sequence</tag>
    <tag group=\"0038\" element=\"4000\" keyword=\"VisitComments\" vr=\"LT\" vm=\"1\">Visit Comments</tag>
    <tag group=\"003A\" element=\"0004\" keyword=\"WaveformOriginality\" vr=\"CS\" vm=\"1\">Waveform Originality</tag>
    <tag group=\"003A\" element=\"0005\" keyword=\"NumberOfWaveformChannels\" vr=\"US\" vm=\"1\">Number of Waveform Channels</tag>
    <tag group=\"003A\" element=\"0010\" keyword=\"NumberOfWaveformSamples\" vr=\"UL\" vm=\"1\">Number of Waveform Samples</tag>
    <tag group=\"003A\" element=\"001A\" keyword=\"SamplingFrequency\" vr=\"DS\" vm=\"1\">Sampling Frequency</tag>
    <tag group=\"003A\" element=\"0020\" keyword=\"MultiplexGroupLabel\" vr=\"SH\" vm=\"1\">Multiplex Group Label</tag>
    <tag group=\"003A\" element=\"0200\" keyword=\"ChannelDefinitionSequence\" vr=\"SQ\" vm=\"1\">Channel Definition Sequence</tag>
    <tag group=\"003A\" element=\"0202\" keyword=\"WaveformChannelNumber\" vr=\"IS\" vm=\"1\">Waveform Channel Number</tag>
    <tag group=\"003A\" element=\"0203\" keyword=\"ChannelLabel\" vr=\"SH\" vm=\"1\">Channel Label</tag>
    <tag group=\"003A\" element=\"0205\" keyword=\"ChannelStatus\" vr=\"CS\" vm=\"1-n\">Channel Status</tag>
    <tag group=\"003A\" element=\"0208\" keyword=\"ChannelSourceSequence\" vr=\"SQ\" vm=\"1\">Channel Source Sequence</tag>
    <tag group=\"003A\" element=\"0209\" keyword=\"ChannelSourceModifiersSequence\" vr=\"SQ\" vm=\"1\">Channel Source Modifiers Sequence</tag>
    <tag group=\"003A\" element=\"020A\" keyword=\"SourceWaveformSequence\" vr=\"SQ\" vm=\"1\">Source Waveform Sequence</tag>
    <tag group=\"003A\" element=\"020C\" keyword=\"ChannelDerivationDescription\" vr=\"LO\" vm=\"1\">Channel Derivation Description</tag>
    <tag group=\"003A\" element=\"0210\" keyword=\"ChannelSensitivity\" vr=\"DS\" vm=\"1\">Channel Sensitivity</tag>
    <tag group=\"003A\" element=\"0211\" keyword=\"ChannelSensitivityUnitsSequence\" vr=\"SQ\" vm=\"1\">Channel Sensitivity Units Sequence</tag>
    <tag group=\"003A\" element=\"0212\" keyword=\"ChannelSensitivityCorrectionFactor\" vr=\"DS\" vm=\"1\">Channel Sensitivity Correction Factor</tag>
    <tag group=\"003A\" element=\"0213\" keyword=\"ChannelBaseline\" vr=\"DS\" vm=\"1\">Channel Baseline</tag>
    <tag group=\"003A\" element=\"0214\" keyword=\"ChannelTimeSkew\" vr=\"DS\" vm=\"1\">Channel Time Skew</tag>
    <tag group=\"003A\" element=\"0215\" keyword=\"ChannelSampleSkew\" vr=\"DS\" vm=\"1\">Channel Sample Skew</tag>
    <tag group=\"003A\" element=\"0218\" keyword=\"ChannelOffset\" vr=\"DS\" vm=\"1\">Channel Offset</tag>
    <tag group=\"003A\" element=\"021A\" keyword=\"WaveformBitsStored\" vr=\"US\" vm=\"1\">Waveform Bits Stored</tag>
    <tag group=\"003A\" element=\"0220\" keyword=\"FilterLowFrequency\" vr=\"DS\" vm=\"1\">Filter Low Frequency</tag>
    <tag group=\"003A\" element=\"0221\" keyword=\"FilterHighFrequency\" vr=\"DS\" vm=\"1\">Filter High Frequency</tag>
    <tag group=\"003A\" element=\"0222\" keyword=\"NotchFilterFrequency\" vr=\"DS\" vm=\"1\">Notch Filter Frequency</tag>
    <tag group=\"003A\" element=\"0223\" keyword=\"NotchFilterBandwidth\" vr=\"DS\" vm=\"1\">Notch Filter Bandwidth</tag>
    <tag group=\"003A\" element=\"0230\" keyword=\"WaveformDataDisplayScale\" vr=\"FL\" vm=\"1\">Waveform Data Display Scale</tag>
    <tag group=\"003A\" element=\"0231\" keyword=\"WaveformDisplayBackgroundCIELabValue\" vr=\"US\" vm=\"3\">Waveform Display Background CIELab Value</tag>
    <tag group=\"003A\" element=\"0240\" keyword=\"WaveformPresentationGroupSequence\" vr=\"SQ\" vm=\"1\">Waveform Presentation Group Sequence</tag>
    <tag group=\"003A\" element=\"0241\" keyword=\"PresentationGroupNumber\" vr=\"US\" vm=\"1\">Presentation Group Number</tag>
    <tag group=\"003A\" element=\"0242\" keyword=\"ChannelDisplaySequence\" vr=\"SQ\" vm=\"1\">Channel Display Sequence</tag>
    <tag group=\"003A\" element=\"0244\" keyword=\"ChannelRecommendedDisplayCIELabValue\" vr=\"US\" vm=\"3\">Channel Recommended Display CIELab Value</tag>
    <tag group=\"003A\" element=\"0245\" keyword=\"ChannelPosition\" vr=\"FL\" vm=\"1\">Channel Position</tag>
    <tag group=\"003A\" element=\"0246\" keyword=\"DisplayShadingFlag\" vr=\"CS\" vm=\"1\">Display Shading Flag</tag>
    <tag group=\"003A\" element=\"0247\" keyword=\"FractionalChannelDisplayScale\" vr=\"FL\" vm=\"1\">Fractional Channel Display Scale</tag>
    <tag group=\"003A\" element=\"0248\" keyword=\"AbsoluteChannelDisplayScale\" vr=\"FL\" vm=\"1\">Absolute Channel Display Scale</tag>
    <tag group=\"003A\" element=\"0300\" keyword=\"MultiplexedAudioChannelsDescriptionCodeSequence\" vr=\"SQ\" vm=\"1\">Multiplexed Audio Channels Description Code Sequence</tag>
    <tag group=\"003A\" element=\"0301\" keyword=\"ChannelIdentificationCode\" vr=\"IS\" vm=\"1\">Channel Identification Code</tag>
    <tag group=\"003A\" element=\"0302\" keyword=\"ChannelMode\" vr=\"CS\" vm=\"1\">Channel Mode</tag>
    <tag group=\"0040\" element=\"0001\" keyword=\"ScheduledStationAETitle\" vr=\"AE\" vm=\"1-n\">Scheduled Station AE Title</tag>
    <tag group=\"0040\" element=\"0002\" keyword=\"ScheduledProcedureStepStartDate\" vr=\"DA\" vm=\"1\">Scheduled Procedure Step Start Date</tag>
    <tag group=\"0040\" element=\"0003\" keyword=\"ScheduledProcedureStepStartTime\" vr=\"TM\" vm=\"1\">Scheduled Procedure Step Start Time</tag>
    <tag group=\"0040\" element=\"0004\" keyword=\"ScheduledProcedureStepEndDate\" vr=\"DA\" vm=\"1\">Scheduled Procedure Step End Date</tag>
    <tag group=\"0040\" element=\"0005\" keyword=\"ScheduledProcedureStepEndTime\" vr=\"TM\" vm=\"1\">Scheduled Procedure Step End Time</tag>
    <tag group=\"0040\" element=\"0006\" keyword=\"ScheduledPerformingPhysicianName\" vr=\"PN\" vm=\"1\">Scheduled Performing Physician's Name</tag>
    <tag group=\"0040\" element=\"0007\" keyword=\"ScheduledProcedureStepDescription\" vr=\"LO\" vm=\"1\">Scheduled Procedure Step Description</tag>
    <tag group=\"0040\" element=\"0008\" keyword=\"ScheduledProtocolCodeSequence\" vr=\"SQ\" vm=\"1\">Scheduled Protocol Code Sequence</tag>
    <tag group=\"0040\" element=\"0009\" keyword=\"ScheduledProcedureStepID\" vr=\"SH\" vm=\"1\">Scheduled Procedure Step ID</tag>
    <tag group=\"0040\" element=\"000A\" keyword=\"StageCodeSequence\" vr=\"SQ\" vm=\"1\">Stage Code Sequence</tag>
    <tag group=\"0040\" element=\"000B\" keyword=\"ScheduledPerformingPhysicianIdentificationSequence\" vr=\"SQ\" vm=\"1\">Scheduled Performing Physician Identification Sequence</tag>
    <tag group=\"0040\" element=\"0010\" keyword=\"ScheduledStationName\" vr=\"SH\" vm=\"1-n\">Scheduled Station Name</tag>
    <tag group=\"0040\" element=\"0011\" keyword=\"ScheduledProcedureStepLocation\" vr=\"SH\" vm=\"1\">Scheduled Procedure Step Location</tag>
    <tag group=\"0040\" element=\"0012\" keyword=\"PreMedication\" vr=\"LO\" vm=\"1\">Pre-Medication</tag>
    <tag group=\"0040\" element=\"0020\" keyword=\"ScheduledProcedureStepStatus\" vr=\"CS\" vm=\"1\">Scheduled Procedure Step Status</tag>
    <tag group=\"0040\" element=\"0026\" keyword=\"OrderPlacerIdentifierSequence\" vr=\"SQ\" vm=\"1\">Order Placer Identifier Sequence</tag>
    <tag group=\"0040\" element=\"0027\" keyword=\"OrderFillerIdentifierSequence\" vr=\"SQ\" vm=\"1\">Order Filler Identifier Sequence</tag>
    <tag group=\"0040\" element=\"0031\" keyword=\"LocalNamespaceEntityID\" vr=\"UT\" vm=\"1\">Local Namespace Entity ID</tag>
    <tag group=\"0040\" element=\"0032\" keyword=\"UniversalEntityID\" vr=\"UT\" vm=\"1\">Universal Entity ID</tag>
    <tag group=\"0040\" element=\"0033\" keyword=\"UniversalEntityIDType\" vr=\"CS\" vm=\"1\">Universal Entity ID Type</tag>
    <tag group=\"0040\" element=\"0035\" keyword=\"IdentifierTypeCode\" vr=\"CS\" vm=\"1\">Identifier Type Code</tag>
    <tag group=\"0040\" element=\"0036\" keyword=\"AssigningFacilitySequence\" vr=\"SQ\" vm=\"1\">Assigning Facility Sequence</tag>
    <tag group=\"0040\" element=\"0039\" keyword=\"AssigningJurisdictionCodeSequence\" vr=\"SQ\" vm=\"1\">Assigning Jurisdiction Code Sequence</tag>
    <tag group=\"0040\" element=\"003A\" keyword=\"AssigningAgencyOrDepartmentCodeSequence\" vr=\"SQ\" vm=\"1\">Assigning Agency or Department Code Sequence</tag>
    <tag group=\"0040\" element=\"0100\" keyword=\"ScheduledProcedureStepSequence\" vr=\"SQ\" vm=\"1\">Scheduled Procedure Step Sequence</tag>
    <tag group=\"0040\" element=\"0220\" keyword=\"ReferencedNonImageCompositeSOPInstanceSequence\" vr=\"SQ\" vm=\"1\">Referenced Non-Image Composite SOP Instance Sequence</tag>
    <tag group=\"0040\" element=\"0241\" keyword=\"PerformedStationAETitle\" vr=\"AE\" vm=\"1\">Performed Station AE Title</tag>
    <tag group=\"0040\" element=\"0242\" keyword=\"PerformedStationName\" vr=\"SH\" vm=\"1\">Performed Station Name</tag>
    <tag group=\"0040\" element=\"0243\" keyword=\"PerformedLocation\" vr=\"SH\" vm=\"1\">Performed Location</tag>
    <tag group=\"0040\" element=\"0244\" keyword=\"PerformedProcedureStepStartDate\" vr=\"DA\" vm=\"1\">Performed Procedure Step Start Date</tag>
    <tag group=\"0040\" element=\"0245\" keyword=\"PerformedProcedureStepStartTime\" vr=\"TM\" vm=\"1\">Performed Procedure Step Start Time</tag>
    <tag group=\"0040\" element=\"0250\" keyword=\"PerformedProcedureStepEndDate\" vr=\"DA\" vm=\"1\">Performed Procedure Step End Date</tag>
    <tag group=\"0040\" element=\"0251\" keyword=\"PerformedProcedureStepEndTime\" vr=\"TM\" vm=\"1\">Performed Procedure Step End Time</tag>
    <tag group=\"0040\" element=\"0252\" keyword=\"PerformedProcedureStepStatus\" vr=\"CS\" vm=\"1\">Performed Procedure Step Status</tag>
    <tag group=\"0040\" element=\"0253\" keyword=\"PerformedProcedureStepID\" vr=\"SH\" vm=\"1\">Performed Procedure Step ID</tag>
    <tag group=\"0040\" element=\"0254\" keyword=\"PerformedProcedureStepDescription\" vr=\"LO\" vm=\"1\">Performed Procedure Step Description</tag>
    <tag group=\"0040\" element=\"0255\" keyword=\"PerformedProcedureTypeDescription\" vr=\"LO\" vm=\"1\">Performed Procedure Type Description</tag>
    <tag group=\"0040\" element=\"0260\" keyword=\"PerformedProtocolCodeSequence\" vr=\"SQ\" vm=\"1\">Performed Protocol Code Sequence</tag>
    <tag group=\"0040\" element=\"0261\" keyword=\"PerformedProtocolType\" vr=\"CS\" vm=\"1\">Performed Protocol Type</tag>
    <tag group=\"0040\" element=\"0270\" keyword=\"ScheduledStepAttributesSequence\" vr=\"SQ\" vm=\"1\">Scheduled Step Attributes Sequence</tag>
    <tag group=\"0040\" element=\"0275\" keyword=\"RequestAttributesSequence\" vr=\"SQ\" vm=\"1\">Request Attributes Sequence</tag>
    <tag group=\"0040\" element=\"0280\" keyword=\"CommentsOnThePerformedProcedureStep\" vr=\"ST\" vm=\"1\">Comments on the Performed Procedure Step</tag>
    <tag group=\"0040\" element=\"0281\" keyword=\"PerformedProcedureStepDiscontinuationReasonCodeSequence\" vr=\"SQ\" vm=\"1\">Performed Procedure Step Discontinuation Reason Code Sequence</tag>
    <tag group=\"0040\" element=\"0293\" keyword=\"QuantitySequence\" vr=\"SQ\" vm=\"1\">Quantity Sequence</tag>
    <tag group=\"0040\" element=\"0294\" keyword=\"Quantity\" vr=\"DS\" vm=\"1\">Quantity</tag>
    <tag group=\"0040\" element=\"0295\" keyword=\"MeasuringUnitsSequence\" vr=\"SQ\" vm=\"1\">Measuring Units Sequence</tag>
    <tag group=\"0040\" element=\"0296\" keyword=\"BillingItemSequence\" vr=\"SQ\" vm=\"1\">Billing Item Sequence</tag>
    <tag group=\"0040\" element=\"0300\" keyword=\"TotalTimeOfFluoroscopy\" vr=\"US\" vm=\"1\">Total Time of Fluoroscopy</tag>
    <tag group=\"0040\" element=\"0301\" keyword=\"TotalNumberOfExposures\" vr=\"US\" vm=\"1\">Total Number of Exposures</tag>
    <tag group=\"0040\" element=\"0302\" keyword=\"EntranceDose\" vr=\"US\" vm=\"1\">Entrance Dose</tag>
    <tag group=\"0040\" element=\"0303\" keyword=\"ExposedArea\" vr=\"US\" vm=\"1-2\">Exposed Area</tag>
    <tag group=\"0040\" element=\"0306\" keyword=\"DistanceSourceToEntrance\" vr=\"DS\" vm=\"1\">Distance Source to Entrance</tag>
    <tag group=\"0040\" element=\"0307\" keyword=\"DistanceSourceToSupport\" vr=\"DS\" vm=\"1\" retired=\"true\">Distance Source to Support</tag>
    <tag group=\"0040\" element=\"030E\" keyword=\"ExposureDoseSequence\" vr=\"SQ\" vm=\"1\">Exposure Dose Sequence</tag>
    <tag group=\"0040\" element=\"0310\" keyword=\"CommentsOnRadiationDose\" vr=\"ST\" vm=\"1\">Comments on Radiation Dose</tag>
    <tag group=\"0040\" element=\"0312\" keyword=\"XRayOutput\" vr=\"DS\" vm=\"1\">X-Ray Output</tag>
    <tag group=\"0040\" element=\"0314\" keyword=\"HalfValueLayer\" vr=\"DS\" vm=\"1\">Half Value Layer</tag>
    <tag group=\"0040\" element=\"0316\" keyword=\"OrganDose\" vr=\"DS\" vm=\"1\">Organ Dose</tag>
    <tag group=\"0040\" element=\"0318\" keyword=\"OrganExposed\" vr=\"CS\" vm=\"1\">Organ Exposed</tag>
    <tag group=\"0040\" element=\"0320\" keyword=\"BillingProcedureStepSequence\" vr=\"SQ\" vm=\"1\">Billing Procedure Step Sequence</tag>
    <tag group=\"0040\" element=\"0321\" keyword=\"FilmConsumptionSequence\" vr=\"SQ\" vm=\"1\">Film Consumption Sequence</tag>
    <tag group=\"0040\" element=\"0324\" keyword=\"BillingSuppliesAndDevicesSequence\" vr=\"SQ\" vm=\"1\">Billing Supplies and Devices Sequence</tag>
    <tag group=\"0040\" element=\"0330\" keyword=\"ReferencedProcedureStepSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced Procedure Step Sequence</tag>
    <tag group=\"0040\" element=\"0340\" keyword=\"PerformedSeriesSequence\" vr=\"SQ\" vm=\"1\">Performed Series Sequence</tag>
    <tag group=\"0040\" element=\"0400\" keyword=\"CommentsOnTheScheduledProcedureStep\" vr=\"LT\" vm=\"1\">Comments on the Scheduled Procedure Step</tag>
    <tag group=\"0040\" element=\"0440\" keyword=\"ProtocolContextSequence\" vr=\"SQ\" vm=\"1\">Protocol Context Sequence</tag>
    <tag group=\"0040\" element=\"0441\" keyword=\"ContentItemModifierSequence\" vr=\"SQ\" vm=\"1\">Content Item Modifier Sequence</tag>
    <tag group=\"0040\" element=\"0500\" keyword=\"ScheduledSpecimenSequence\" vr=\"SQ\" vm=\"1\">Scheduled Specimen Sequence</tag>
    <tag group=\"0040\" element=\"050A\" keyword=\"SpecimenAccessionNumber\" vr=\"LO\" vm=\"1\" retired=\"true\">Specimen Accession Number</tag>
    <tag group=\"0040\" element=\"0512\" keyword=\"ContainerIdentifier\" vr=\"LO\" vm=\"1\">Container Identifier</tag>
    <tag group=\"0040\" element=\"0513\" keyword=\"IssuerOfTheContainerIdentifierSequence\" vr=\"SQ\" vm=\"1\">Issuer of the Container Identifier Sequence</tag>
    <tag group=\"0040\" element=\"0515\" keyword=\"AlternateContainerIdentifierSequence\" vr=\"SQ\" vm=\"1\">Alternate Container Identifier Sequence</tag>
    <tag group=\"0040\" element=\"0518\" keyword=\"ContainerTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Container Type Code Sequence</tag>
    <tag group=\"0040\" element=\"051A\" keyword=\"ContainerDescription\" vr=\"LO\" vm=\"1\">Container Description</tag>
    <tag group=\"0040\" element=\"0520\" keyword=\"ContainerComponentSequence\" vr=\"SQ\" vm=\"1\">Container Component Sequence</tag>
    <tag group=\"0040\" element=\"0550\" keyword=\"SpecimenSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Specimen Sequence</tag>
    <tag group=\"0040\" element=\"0551\" keyword=\"SpecimenIdentifier\" vr=\"LO\" vm=\"1\">Specimen Identifier</tag>
    <tag group=\"0040\" element=\"0552\" keyword=\"SpecimenDescriptionSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Specimen Description Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"0553\" keyword=\"SpecimenDescriptionTrial\" vr=\"ST\" vm=\"1\" retired=\"true\">Specimen Description (Trial)</tag>
    <tag group=\"0040\" element=\"0554\" keyword=\"SpecimenUID\" vr=\"UI\" vm=\"1\">Specimen UID</tag>
    <tag group=\"0040\" element=\"0555\" keyword=\"AcquisitionContextSequence\" vr=\"SQ\" vm=\"1\">Acquisition Context Sequence</tag>
    <tag group=\"0040\" element=\"0556\" keyword=\"AcquisitionContextDescription\" vr=\"ST\" vm=\"1\">Acquisition Context Description</tag>
    <tag group=\"0040\" element=\"059A\" keyword=\"SpecimenTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Specimen Type Code Sequence</tag>
    <tag group=\"0040\" element=\"0560\" keyword=\"SpecimenDescriptionSequence\" vr=\"SQ\" vm=\"1\">Specimen Description Sequence</tag>
    <tag group=\"0040\" element=\"0562\" keyword=\"IssuerOfTheSpecimenIdentifierSequence\" vr=\"SQ\" vm=\"1\">Issuer of the Specimen Identifier Sequence</tag>
    <tag group=\"0040\" element=\"0600\" keyword=\"SpecimenShortDescription\" vr=\"LO\" vm=\"1\">Specimen Short Description</tag>
    <tag group=\"0040\" element=\"0602\" keyword=\"SpecimenDetailedDescription\" vr=\"UT\" vm=\"1\">Specimen Detailed Description</tag>
    <tag group=\"0040\" element=\"0610\" keyword=\"SpecimenPreparationSequence\" vr=\"SQ\" vm=\"1\">Specimen Preparation Sequence</tag>
    <tag group=\"0040\" element=\"0612\" keyword=\"SpecimenPreparationStepContentItemSequence\" vr=\"SQ\" vm=\"1\">Specimen Preparation Step Content Item Sequence</tag>
    <tag group=\"0040\" element=\"0620\" keyword=\"SpecimenLocalizationContentItemSequence\" vr=\"SQ\" vm=\"1\">Specimen Localization Content Item Sequence</tag>
    <tag group=\"0040\" element=\"06FA\" keyword=\"SlideIdentifier\" vr=\"LO\" vm=\"1\" retired=\"true\">Slide Identifier</tag>
    <tag group=\"0040\" element=\"071A\" keyword=\"ImageCenterPointCoordinatesSequence\" vr=\"SQ\" vm=\"1\">Image Center Point Coordinates Sequence</tag>
    <tag group=\"0040\" element=\"072A\" keyword=\"XOffsetInSlideCoordinateSystem\" vr=\"DS\" vm=\"1\">X Offset in Slide Coordinate System</tag>
    <tag group=\"0040\" element=\"073A\" keyword=\"YOffsetInSlideCoordinateSystem\" vr=\"DS\" vm=\"1\">Y Offset in Slide Coordinate System</tag>
    <tag group=\"0040\" element=\"074A\" keyword=\"ZOffsetInSlideCoordinateSystem\" vr=\"DS\" vm=\"1\">Z Offset in Slide Coordinate System</tag>
    <tag group=\"0040\" element=\"08D8\" keyword=\"PixelSpacingSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Pixel Spacing Sequence</tag>
    <tag group=\"0040\" element=\"08DA\" keyword=\"CoordinateSystemAxisCodeSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Coordinate System Axis Code Sequence</tag>
    <tag group=\"0040\" element=\"08EA\" keyword=\"MeasurementUnitsCodeSequence\" vr=\"SQ\" vm=\"1\">Measurement Units Code Sequence</tag>
    <tag group=\"0040\" element=\"09F8\" keyword=\"VitalStainCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Vital Stain Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"1001\" keyword=\"RequestedProcedureID\" vr=\"SH\" vm=\"1\">Requested Procedure ID</tag>
    <tag group=\"0040\" element=\"1002\" keyword=\"ReasonForTheRequestedProcedure\" vr=\"LO\" vm=\"1\">Reason for the Requested Procedure</tag>
    <tag group=\"0040\" element=\"1003\" keyword=\"RequestedProcedurePriority\" vr=\"SH\" vm=\"1\">Requested Procedure Priority</tag>
    <tag group=\"0040\" element=\"1004\" keyword=\"PatientTransportArrangements\" vr=\"LO\" vm=\"1\">Patient Transport Arrangements</tag>
    <tag group=\"0040\" element=\"1005\" keyword=\"RequestedProcedureLocation\" vr=\"LO\" vm=\"1\">Requested Procedure Location</tag>
    <tag group=\"0040\" element=\"1006\" keyword=\"PlacerOrderNumberProcedure\" vr=\"SH\" vm=\"1\" retired=\"true\">Placer Order Number / Procedure</tag>
    <tag group=\"0040\" element=\"1007\" keyword=\"FillerOrderNumberProcedure\" vr=\"SH\" vm=\"1\" retired=\"true\">Filler Order Number / Procedure</tag>
    <tag group=\"0040\" element=\"1008\" keyword=\"ConfidentialityCode\" vr=\"LO\" vm=\"1\">Confidentiality Code</tag>
    <tag group=\"0040\" element=\"1009\" keyword=\"ReportingPriority\" vr=\"SH\" vm=\"1\">Reporting Priority</tag>
    <tag group=\"0040\" element=\"100A\" keyword=\"ReasonForRequestedProcedureCodeSequence\" vr=\"SQ\" vm=\"1\">Reason for Requested Procedure Code Sequence</tag>
    <tag group=\"0040\" element=\"1010\" keyword=\"NamesOfIntendedRecipientsOfResults\" vr=\"PN\" vm=\"1-n\">Names of Intended Recipients of Results</tag>
    <tag group=\"0040\" element=\"1011\" keyword=\"IntendedRecipientsOfResultsIdentificationSequence\" vr=\"SQ\" vm=\"1\">Intended Recipients of Results Identification Sequence</tag>
    <tag group=\"0040\" element=\"1012\" keyword=\"ReasonForPerformedProcedureCodeSequence\" vr=\"SQ\" vm=\"1\">Reason For Performed Procedure Code Sequence</tag>
    <tag group=\"0040\" element=\"1060\" keyword=\"RequestedProcedureDescriptionTrial\" vr=\"LO\" vm=\"1\" retired=\"true\">Requested Procedure Description (Trial)</tag>
    <tag group=\"0040\" element=\"1101\" keyword=\"PersonIdentificationCodeSequence\" vr=\"SQ\" vm=\"1\">Person Identification Code Sequence</tag>
    <tag group=\"0040\" element=\"1102\" keyword=\"PersonAddress\" vr=\"ST\" vm=\"1\">Person's Address</tag>
    <tag group=\"0040\" element=\"1103\" keyword=\"PersonTelephoneNumbers\" vr=\"LO\" vm=\"1-n\">Person's Telephone Numbers</tag>
    <tag group=\"0040\" element=\"1104\" keyword=\"PersonTelecomInformation\" vr=\"LT\" vm=\"1\">Person's Telecom Information</tag>
    <tag group=\"0040\" element=\"1400\" keyword=\"RequestedProcedureComments\" vr=\"LT\" vm=\"1\">Requested Procedure Comments</tag>
    <tag group=\"0040\" element=\"2001\" keyword=\"ReasonForTheImagingServiceRequest\" vr=\"LO\" vm=\"1\" retired=\"true\">Reason for the Imaging Service Request</tag>
    <tag group=\"0040\" element=\"2004\" keyword=\"IssueDateOfImagingServiceRequest\" vr=\"DA\" vm=\"1\">Issue Date of Imaging Service Request</tag>
    <tag group=\"0040\" element=\"2005\" keyword=\"IssueTimeOfImagingServiceRequest\" vr=\"TM\" vm=\"1\">Issue Time of Imaging Service Request</tag>
    <tag group=\"0040\" element=\"2006\" keyword=\"PlacerOrderNumberImagingServiceRequestRetired\" vr=\"SH\" vm=\"1\" retired=\"true\">Placer Order Number / Imaging Service Request (Retired)</tag>
    <tag group=\"0040\" element=\"2007\" keyword=\"FillerOrderNumberImagingServiceRequestRetired\" vr=\"SH\" vm=\"1\" retired=\"true\">Filler Order Number / Imaging Service Request (Retired)</tag>
    <tag group=\"0040\" element=\"2008\" keyword=\"OrderEnteredBy\" vr=\"PN\" vm=\"1\">Order Entered By</tag>
    <tag group=\"0040\" element=\"2009\" keyword=\"OrderEntererLocation\" vr=\"SH\" vm=\"1\">Order Enterer's Location</tag>
    <tag group=\"0040\" element=\"2010\" keyword=\"OrderCallbackPhoneNumber\" vr=\"SH\" vm=\"1\">Order Callback Phone Number</tag>
    <tag group=\"0040\" element=\"2011\" keyword=\"OrderCallbackTelecomInformation\" vr=\"LT\" vm=\"1\">Order Callback Telecom Information</tag>
    <tag group=\"0040\" element=\"2016\" keyword=\"PlacerOrderNumberImagingServiceRequest\" vr=\"LO\" vm=\"1\">Placer Order Number / Imaging Service Request</tag>
    <tag group=\"0040\" element=\"2017\" keyword=\"FillerOrderNumberImagingServiceRequest\" vr=\"LO\" vm=\"1\">Filler Order Number / Imaging Service Request</tag>
    <tag group=\"0040\" element=\"2400\" keyword=\"ImagingServiceRequestComments\" vr=\"LT\" vm=\"1\">Imaging Service Request Comments</tag>
    <tag group=\"0040\" element=\"3001\" keyword=\"ConfidentialityConstraintOnPatientDataDescription\" vr=\"LO\" vm=\"1\">Confidentiality Constraint on Patient Data Description</tag>
    <tag group=\"0040\" element=\"4001\" keyword=\"GeneralPurposeScheduledProcedureStepStatus\" vr=\"CS\" vm=\"1\" retired=\"true\">General Purpose Scheduled Procedure Step Status</tag>
    <tag group=\"0040\" element=\"4002\" keyword=\"GeneralPurposePerformedProcedureStepStatus\" vr=\"CS\" vm=\"1\" retired=\"true\">General Purpose Performed Procedure Step Status</tag>
    <tag group=\"0040\" element=\"4003\" keyword=\"GeneralPurposeScheduledProcedureStepPriority\" vr=\"CS\" vm=\"1\" retired=\"true\">General Purpose Scheduled Procedure Step Priority</tag>
    <tag group=\"0040\" element=\"4004\" keyword=\"ScheduledProcessingApplicationsCodeSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Scheduled Processing Applications Code Sequence</tag>
    <tag group=\"0040\" element=\"4005\" keyword=\"ScheduledProcedureStepStartDateTime\" vr=\"DT\" vm=\"1\">Scheduled Procedure Step Start DateTime</tag>
    <tag group=\"0040\" element=\"4006\" keyword=\"MultipleCopiesFlag\" vr=\"CS\" vm=\"1\" retired=\"true\">Multiple Copies Flag</tag>
    <tag group=\"0040\" element=\"4007\" keyword=\"PerformedProcessingApplicationsCodeSequence\" vr=\"SQ\" vm=\"1\">Performed Processing Applications Code Sequence</tag>
    <tag group=\"0040\" element=\"4009\" keyword=\"HumanPerformerCodeSequence\" vr=\"SQ\" vm=\"1\">Human Performer Code Sequence</tag>
    <tag group=\"0040\" element=\"4010\" keyword=\"ScheduledProcedureStepModificationDateTime\" vr=\"DT\" vm=\"1\">Scheduled Procedure Step Modification DateTime</tag>
    <tag group=\"0040\" element=\"4011\" keyword=\"ExpectedCompletionDateTime\" vr=\"DT\" vm=\"1\">Expected Completion DateTime</tag>
    <tag group=\"0040\" element=\"4015\" keyword=\"ResultingGeneralPurposePerformedProcedureStepsSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Resulting General Purpose Performed Procedure Steps Sequence</tag>
    <tag group=\"0040\" element=\"4016\" keyword=\"ReferencedGeneralPurposeScheduledProcedureStepSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced General Purpose Scheduled Procedure Step Sequence</tag>
    <tag group=\"0040\" element=\"4018\" keyword=\"ScheduledWorkitemCodeSequence\" vr=\"SQ\" vm=\"1\">Scheduled Workitem Code Sequence</tag>
    <tag group=\"0040\" element=\"4019\" keyword=\"PerformedWorkitemCodeSequence\" vr=\"SQ\" vm=\"1\">Performed Workitem Code Sequence</tag>
    <tag group=\"0040\" element=\"4020\" keyword=\"InputAvailabilityFlag\" vr=\"CS\" vm=\"1\" retired=\"true\">Input Availability Flag</tag>
    <tag group=\"0040\" element=\"4021\" keyword=\"InputInformationSequence\" vr=\"SQ\" vm=\"1\">Input Information Sequence</tag>
    <tag group=\"0040\" element=\"4022\" keyword=\"RelevantInformationSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Relevant Information Sequence</tag>
    <tag group=\"0040\" element=\"4023\" keyword=\"ReferencedGeneralPurposeScheduledProcedureStepTransactionUID\" vr=\"UI\" vm=\"1\" retired=\"true\">Referenced General Purpose Scheduled Procedure Step Transaction UID</tag>
    <tag group=\"0040\" element=\"4025\" keyword=\"ScheduledStationNameCodeSequence\" vr=\"SQ\" vm=\"1\">Scheduled Station Name Code Sequence</tag>
    <tag group=\"0040\" element=\"4026\" keyword=\"ScheduledStationClassCodeSequence\" vr=\"SQ\" vm=\"1\">Scheduled Station Class Code Sequence</tag>
    <tag group=\"0040\" element=\"4027\" keyword=\"ScheduledStationGeographicLocationCodeSequence\" vr=\"SQ\" vm=\"1\">Scheduled Station Geographic Location Code Sequence</tag>
    <tag group=\"0040\" element=\"4028\" keyword=\"PerformedStationNameCodeSequence\" vr=\"SQ\" vm=\"1\">Performed Station Name Code Sequence</tag>
    <tag group=\"0040\" element=\"4029\" keyword=\"PerformedStationClassCodeSequence\" vr=\"SQ\" vm=\"1\">Performed Station Class Code Sequence</tag>
    <tag group=\"0040\" element=\"4030\" keyword=\"PerformedStationGeographicLocationCodeSequence\" vr=\"SQ\" vm=\"1\">Performed Station Geographic Location Code Sequence</tag>
    <tag group=\"0040\" element=\"4031\" keyword=\"RequestedSubsequentWorkitemCodeSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Requested Subsequent Workitem Code Sequence</tag>
    <tag group=\"0040\" element=\"4032\" keyword=\"NonDICOMOutputCodeSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Non-DICOM Output Code Sequence</tag>
    <tag group=\"0040\" element=\"4033\" keyword=\"OutputInformationSequence\" vr=\"SQ\" vm=\"1\">Output Information Sequence</tag>
    <tag group=\"0040\" element=\"4034\" keyword=\"ScheduledHumanPerformersSequence\" vr=\"SQ\" vm=\"1\">Scheduled Human Performers Sequence</tag>
    <tag group=\"0040\" element=\"4035\" keyword=\"ActualHumanPerformersSequence\" vr=\"SQ\" vm=\"1\">Actual Human Performers Sequence</tag>
    <tag group=\"0040\" element=\"4036\" keyword=\"HumanPerformerOrganization\" vr=\"LO\" vm=\"1\">Human Performer's Organization</tag>
    <tag group=\"0040\" element=\"4037\" keyword=\"HumanPerformerName\" vr=\"PN\" vm=\"1\">Human Performer's Name</tag>
    <tag group=\"0040\" element=\"4040\" keyword=\"RawDataHandling\" vr=\"CS\" vm=\"1\">Raw Data Handling</tag>
    <tag group=\"0040\" element=\"4041\" keyword=\"InputReadinessState\" vr=\"CS\" vm=\"1\">Input Readiness State</tag>
    <tag group=\"0040\" element=\"4050\" keyword=\"PerformedProcedureStepStartDateTime\" vr=\"DT\" vm=\"1\">Performed Procedure Step Start DateTime</tag>
    <tag group=\"0040\" element=\"4051\" keyword=\"PerformedProcedureStepEndDateTime\" vr=\"DT\" vm=\"1\">Performed Procedure Step End DateTime</tag>
    <tag group=\"0040\" element=\"4052\" keyword=\"ProcedureStepCancellationDateTime\" vr=\"DT\" vm=\"1\">Procedure Step Cancellation DateTime</tag>
    <tag group=\"0040\" element=\"4070\" keyword=\"OutputDestinationSequence\" vr=\"SQ\" vm=\"1\">Output Destination Sequence</tag>
    <tag group=\"0040\" element=\"4071\" keyword=\"DICOMStorageSequence\" vr=\"SQ\" vm=\"1\">DICOM Storage Sequence</tag>
    <tag group=\"0040\" element=\"4072\" keyword=\"STOWRSStorageSequence\" vr=\"SQ\" vm=\"1\">STOW-RS Storage Sequence</tag>
    <tag group=\"0040\" element=\"4073\" keyword=\"StorageURL\" vr=\"UR\" vm=\"1\">Storage URL</tag>
    <tag group=\"0040\" element=\"4074\" keyword=\"XDSStorageSequence\" vr=\"SQ\" vm=\"1\">XDS Storage Sequence</tag>
    <tag group=\"0040\" element=\"8302\" keyword=\"EntranceDoseInmGy\" vr=\"DS\" vm=\"1\">Entrance Dose in mGy</tag>
    <tag group=\"0040\" element=\"8303\" keyword=\"EntranceDoseDerivation\" vr=\"CS\" vm=\"1\">Entrance Dose Derivation</tag>
    <tag group=\"0040\" element=\"9092\" keyword=\"ParametricMapFrameTypeSequence\" vr=\"SQ\" vm=\"1\">Parametric Map Frame Type Sequence</tag>
    <tag group=\"0040\" element=\"9094\" keyword=\"ReferencedImageRealWorldValueMappingSequence\" vr=\"SQ\" vm=\"1\">Referenced Image Real World Value Mapping Sequence</tag>
    <tag group=\"0040\" element=\"9096\" keyword=\"RealWorldValueMappingSequence\" vr=\"SQ\" vm=\"1\">Real World Value Mapping Sequence</tag>
    <tag group=\"0040\" element=\"9098\" keyword=\"PixelValueMappingCodeSequence\" vr=\"SQ\" vm=\"1\">Pixel Value Mapping Code Sequence</tag>
    <tag group=\"0040\" element=\"9210\" keyword=\"LUTLabel\" vr=\"SH\" vm=\"1\">LUT Label</tag>
    <tag group=\"0040\" element=\"9211\" keyword=\"RealWorldValueLastValueMapped\" vr=\"US/SS\" vm=\"1\">Real World Value Last Value Mapped</tag>
    <tag group=\"0040\" element=\"9212\" keyword=\"RealWorldValueLUTData\" vr=\"FD\" vm=\"1-n\">Real World Value LUT Data</tag>
    <tag group=\"0040\" element=\"9213\" keyword=\"DoubleFloatRealWorldValueLastValueMapped\" vr=\"FD\" vm=\"1\">Double Float Real World Value Last Value Mapped</tag>
    <tag group=\"0040\" element=\"9214\" keyword=\"DoubleFloatRealWorldValueFirstValueMapped\" vr=\"FD\" vm=\"1\">Double Float Real World Value First Value Mapped</tag>
    <tag group=\"0040\" element=\"9216\" keyword=\"RealWorldValueFirstValueMapped\" vr=\"US/SS\" vm=\"1\">Real World Value First Value Mapped</tag>
    <tag group=\"0040\" element=\"9220\" keyword=\"QuantityDefinitionSequence\" vr=\"SQ\" vm=\"1\">Quantity Definition Sequence</tag>
    <tag group=\"0040\" element=\"9224\" keyword=\"RealWorldValueIntercept\" vr=\"FD\" vm=\"1\">Real World Value Intercept</tag>
    <tag group=\"0040\" element=\"9225\" keyword=\"RealWorldValueSlope\" vr=\"FD\" vm=\"1\">Real World Value Slope</tag>
    <tag group=\"0040\" element=\"A007\" keyword=\"FindingsFlagTrial\" vr=\"CS\" vm=\"1\" retired=\"true\">Findings Flag (Trial)</tag>
    <tag group=\"0040\" element=\"A010\" keyword=\"RelationshipType\" vr=\"CS\" vm=\"1\">Relationship Type</tag>
    <tag group=\"0040\" element=\"A020\" keyword=\"FindingsSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Findings Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A021\" keyword=\"FindingsGroupUIDTrial\" vr=\"UI\" vm=\"1\" retired=\"true\">Findings Group UID (Trial)</tag>
    <tag group=\"0040\" element=\"A022\" keyword=\"ReferencedFindingsGroupUIDTrial\" vr=\"UI\" vm=\"1\" retired=\"true\">Referenced Findings Group UID (Trial)</tag>
    <tag group=\"0040\" element=\"A023\" keyword=\"FindingsGroupRecordingDateTrial\" vr=\"DA\" vm=\"1\" retired=\"true\">Findings Group Recording Date (Trial)</tag>
    <tag group=\"0040\" element=\"A024\" keyword=\"FindingsGroupRecordingTimeTrial\" vr=\"TM\" vm=\"1\" retired=\"true\">Findings Group Recording Time (Trial)</tag>
    <tag group=\"0040\" element=\"A026\" keyword=\"FindingsSourceCategoryCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Findings Source Category Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A027\" keyword=\"VerifyingOrganization\" vr=\"LO\" vm=\"1\">Verifying Organization</tag>
    <tag group=\"0040\" element=\"A028\" keyword=\"DocumentingOrganizationIdentifierCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Documenting Organization Identifier Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A030\" keyword=\"VerificationDateTime\" vr=\"DT\" vm=\"1\">Verification DateTime</tag>
    <tag group=\"0040\" element=\"A032\" keyword=\"ObservationDateTime\" vr=\"DT\" vm=\"1\">Observation DateTime</tag>
    <tag group=\"0040\" element=\"A040\" keyword=\"ValueType\" vr=\"CS\" vm=\"1\">Value Type</tag>
    <tag group=\"0040\" element=\"A043\" keyword=\"ConceptNameCodeSequence\" vr=\"SQ\" vm=\"1\">Concept Name Code Sequence</tag>
    <tag group=\"0040\" element=\"A047\" keyword=\"MeasurementPrecisionDescriptionTrial\" vr=\"LO\" vm=\"1\" retired=\"true\">Measurement Precision Description (Trial)</tag>
    <tag group=\"0040\" element=\"A050\" keyword=\"ContinuityOfContent\" vr=\"CS\" vm=\"1\">Continuity Of Content</tag>
    <tag group=\"0040\" element=\"A057\" keyword=\"UrgencyOrPriorityAlertsTrial\" vr=\"CS\" vm=\"1-n\" retired=\"true\">Urgency or Priority Alerts (Trial)</tag>
    <tag group=\"0040\" element=\"A060\" keyword=\"SequencingIndicatorTrial\" vr=\"LO\" vm=\"1\" retired=\"true\">Sequencing Indicator (Trial)</tag>
    <tag group=\"0040\" element=\"A066\" keyword=\"DocumentIdentifierCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Document Identifier Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A067\" keyword=\"DocumentAuthorTrial\" vr=\"PN\" vm=\"1\" retired=\"true\">Document Author (Trial)</tag>
    <tag group=\"0040\" element=\"A068\" keyword=\"DocumentAuthorIdentifierCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Document Author Identifier Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A070\" keyword=\"IdentifierCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Identifier Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A073\" keyword=\"VerifyingObserverSequence\" vr=\"SQ\" vm=\"1\">Verifying Observer Sequence</tag>
    <tag group=\"0040\" element=\"A074\" keyword=\"ObjectBinaryIdentifierTrial\" vr=\"OB\" vm=\"1\" retired=\"true\">Object Binary Identifier (Trial)</tag>
    <tag group=\"0040\" element=\"A075\" keyword=\"VerifyingObserverName\" vr=\"PN\" vm=\"1\">Verifying Observer Name</tag>
    <tag group=\"0040\" element=\"A076\" keyword=\"DocumentingObserverIdentifierCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Documenting Observer Identifier Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A078\" keyword=\"AuthorObserverSequence\" vr=\"SQ\" vm=\"1\">Author Observer Sequence</tag>
    <tag group=\"0040\" element=\"A07A\" keyword=\"ParticipantSequence\" vr=\"SQ\" vm=\"1\">Participant Sequence</tag>
    <tag group=\"0040\" element=\"A07C\" keyword=\"CustodialOrganizationSequence\" vr=\"SQ\" vm=\"1\">Custodial Organization Sequence</tag>
    <tag group=\"0040\" element=\"A080\" keyword=\"ParticipationType\" vr=\"CS\" vm=\"1\">Participation Type</tag>
    <tag group=\"0040\" element=\"A082\" keyword=\"ParticipationDateTime\" vr=\"DT\" vm=\"1\">Participation DateTime</tag>
    <tag group=\"0040\" element=\"A084\" keyword=\"ObserverType\" vr=\"CS\" vm=\"1\">Observer Type</tag>
    <tag group=\"0040\" element=\"A085\" keyword=\"ProcedureIdentifierCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Procedure Identifier Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A088\" keyword=\"VerifyingObserverIdentificationCodeSequence\" vr=\"SQ\" vm=\"1\">Verifying Observer Identification Code Sequence</tag>
    <tag group=\"0040\" element=\"A089\" keyword=\"ObjectDirectoryBinaryIdentifierTrial\" vr=\"OB\" vm=\"1\" retired=\"true\">Object Directory Binary Identifier (Trial)</tag>
    <tag group=\"0040\" element=\"A090\" keyword=\"EquivalentCDADocumentSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Equivalent CDA Document Sequence</tag>
    <tag group=\"0040\" element=\"A0B0\" keyword=\"ReferencedWaveformChannels\" vr=\"US\" vm=\"2-2n\">Referenced Waveform Channels</tag>
    <tag group=\"0040\" element=\"A110\" keyword=\"DateOfDocumentOrVerbalTransactionTrial\" vr=\"DA\" vm=\"1\" retired=\"true\">Date of Document or Verbal Transaction (Trial)</tag>
    <tag group=\"0040\" element=\"A112\" keyword=\"TimeOfDocumentCreationOrVerbalTransactionTrial\" vr=\"TM\" vm=\"1\" retired=\"true\">Time of Document Creation or Verbal Transaction (Trial)</tag>
    <tag group=\"0040\" element=\"A120\" keyword=\"DateTime\" vr=\"DT\" vm=\"1\">DateTime</tag>
    <tag group=\"0040\" element=\"A121\" keyword=\"Date\" vr=\"DA\" vm=\"1\">Date</tag>
    <tag group=\"0040\" element=\"A122\" keyword=\"Time\" vr=\"TM\" vm=\"1\">Time</tag>
    <tag group=\"0040\" element=\"A123\" keyword=\"PersonName\" vr=\"PN\" vm=\"1\">Person Name</tag>
    <tag group=\"0040\" element=\"A124\" keyword=\"UID\" vr=\"UI\" vm=\"1\">UID</tag>
    <tag group=\"0040\" element=\"A125\" keyword=\"ReportStatusIDTrial\" vr=\"CS\" vm=\"2\" retired=\"true\">Report Status ID (Trial)</tag>
    <tag group=\"0040\" element=\"A130\" keyword=\"TemporalRangeType\" vr=\"CS\" vm=\"1\">Temporal Range Type</tag>
    <tag group=\"0040\" element=\"A132\" keyword=\"ReferencedSamplePositions\" vr=\"UL\" vm=\"1-n\">Referenced Sample Positions</tag>
    <tag group=\"0040\" element=\"A136\" keyword=\"ReferencedFrameNumbers\" vr=\"US\" vm=\"1-n\">Referenced Frame Numbers</tag>
    <tag group=\"0040\" element=\"A138\" keyword=\"ReferencedTimeOffsets\" vr=\"DS\" vm=\"1-n\">Referenced Time Offsets</tag>
    <tag group=\"0040\" element=\"A13A\" keyword=\"ReferencedDateTime\" vr=\"DT\" vm=\"1-n\">Referenced DateTime</tag>
    <tag group=\"0040\" element=\"A160\" keyword=\"TextValue\" vr=\"UT\" vm=\"1\">Text Value</tag>
    <tag group=\"0040\" element=\"A161\" keyword=\"FloatingPointValue\" vr=\"FD\" vm=\"1-n\">Floating Point Value</tag>
    <tag group=\"0040\" element=\"A162\" keyword=\"RationalNumeratorValue\" vr=\"SL\" vm=\"1-n\">Rational Numerator Value</tag>
    <tag group=\"0040\" element=\"A163\" keyword=\"RationalDenominatorValue\" vr=\"UL\" vm=\"1-n\">Rational Denominator Value</tag>
    <tag group=\"0040\" element=\"A167\" keyword=\"ObservationCategoryCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Observation Category Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A168\" keyword=\"ConceptCodeSequence\" vr=\"SQ\" vm=\"1\">Concept Code Sequence</tag>
    <tag group=\"0040\" element=\"A16A\" keyword=\"BibliographicCitationTrial\" vr=\"ST\" vm=\"1\" retired=\"true\">Bibliographic Citation (Trial)</tag>
    <tag group=\"0040\" element=\"A170\" keyword=\"PurposeOfReferenceCodeSequence\" vr=\"SQ\" vm=\"1\">Purpose of Reference Code Sequence</tag>
    <tag group=\"0040\" element=\"A171\" keyword=\"ObservationUID\" vr=\"UI\" vm=\"1\">Observation UID</tag>
    <tag group=\"0040\" element=\"A172\" keyword=\"ReferencedObservationUIDTrial\" vr=\"UI\" vm=\"1\" retired=\"true\">Referenced Observation UID (Trial)</tag>
    <tag group=\"0040\" element=\"A173\" keyword=\"ReferencedObservationClassTrial\" vr=\"CS\" vm=\"1\" retired=\"true\">Referenced Observation Class (Trial)</tag>
    <tag group=\"0040\" element=\"A174\" keyword=\"ReferencedObjectObservationClassTrial\" vr=\"CS\" vm=\"1\" retired=\"true\">Referenced Object Observation Class (Trial)</tag>
    <tag group=\"0040\" element=\"A180\" keyword=\"AnnotationGroupNumber\" vr=\"US\" vm=\"1\">Annotation Group Number</tag>
    <tag group=\"0040\" element=\"A192\" keyword=\"ObservationDateTrial\" vr=\"DA\" vm=\"1\" retired=\"true\">Observation Date (Trial)</tag>
    <tag group=\"0040\" element=\"A193\" keyword=\"ObservationTimeTrial\" vr=\"TM\" vm=\"1\" retired=\"true\">Observation Time (Trial)</tag>
    <tag group=\"0040\" element=\"A194\" keyword=\"MeasurementAutomationTrial\" vr=\"CS\" vm=\"1\" retired=\"true\">Measurement Automation (Trial)</tag>
    <tag group=\"0040\" element=\"A195\" keyword=\"ModifierCodeSequence\" vr=\"SQ\" vm=\"1\">Modifier Code Sequence</tag>
    <tag group=\"0040\" element=\"A224\" keyword=\"IdentificationDescriptionTrial\" vr=\"ST\" vm=\"1\" retired=\"true\">Identification Description (Trial)</tag>
    <tag group=\"0040\" element=\"A290\" keyword=\"CoordinatesSetGeometricTypeTrial\" vr=\"CS\" vm=\"1\" retired=\"true\">Coordinates Set Geometric Type (Trial)</tag>
    <tag group=\"0040\" element=\"A296\" keyword=\"AlgorithmCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Algorithm Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A297\" keyword=\"AlgorithmDescriptionTrial\" vr=\"ST\" vm=\"1\" retired=\"true\">Algorithm Description (Trial)</tag>
    <tag group=\"0040\" element=\"A29A\" keyword=\"PixelCoordinatesSetTrial\" vr=\"SL\" vm=\"2-2n\" retired=\"true\">Pixel Coordinates Set (Trial)</tag>
    <tag group=\"0040\" element=\"A300\" keyword=\"MeasuredValueSequence\" vr=\"SQ\" vm=\"1\">Measured Value Sequence</tag>
    <tag group=\"0040\" element=\"A301\" keyword=\"NumericValueQualifierCodeSequence\" vr=\"SQ\" vm=\"1\">Numeric Value Qualifier Code Sequence</tag>
    <tag group=\"0040\" element=\"A307\" keyword=\"CurrentObserverTrial\" vr=\"PN\" vm=\"1\" retired=\"true\">Current Observer (Trial)</tag>
    <tag group=\"0040\" element=\"A30A\" keyword=\"NumericValue\" vr=\"DS\" vm=\"1-n\">Numeric Value</tag>
    <tag group=\"0040\" element=\"A313\" keyword=\"ReferencedAccessionSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced Accession Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A33A\" keyword=\"ReportStatusCommentTrial\" vr=\"ST\" vm=\"1\" retired=\"true\">Report Status Comment (Trial)</tag>
    <tag group=\"0040\" element=\"A340\" keyword=\"ProcedureContextSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Procedure Context Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A352\" keyword=\"VerbalSourceTrial\" vr=\"PN\" vm=\"1\" retired=\"true\">Verbal Source (Trial)</tag>
    <tag group=\"0040\" element=\"A353\" keyword=\"AddressTrial\" vr=\"ST\" vm=\"1\" retired=\"true\">Address (Trial)</tag>
    <tag group=\"0040\" element=\"A354\" keyword=\"TelephoneNumberTrial\" vr=\"LO\" vm=\"1\" retired=\"true\">Telephone Number (Trial)</tag>
    <tag group=\"0040\" element=\"A358\" keyword=\"VerbalSourceIdentifierCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Verbal Source Identifier Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A360\" keyword=\"PredecessorDocumentsSequence\" vr=\"SQ\" vm=\"1\">Predecessor Documents Sequence</tag>
    <tag group=\"0040\" element=\"A370\" keyword=\"ReferencedRequestSequence\" vr=\"SQ\" vm=\"1\">Referenced Request Sequence</tag>
    <tag group=\"0040\" element=\"A372\" keyword=\"PerformedProcedureCodeSequence\" vr=\"SQ\" vm=\"1\">Performed Procedure Code Sequence</tag>
    <tag group=\"0040\" element=\"A375\" keyword=\"CurrentRequestedProcedureEvidenceSequence\" vr=\"SQ\" vm=\"1\">Current Requested Procedure Evidence Sequence</tag>
    <tag group=\"0040\" element=\"A380\" keyword=\"ReportDetailSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Report Detail Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A385\" keyword=\"PertinentOtherEvidenceSequence\" vr=\"SQ\" vm=\"1\">Pertinent Other Evidence Sequence</tag>
    <tag group=\"0040\" element=\"A390\" keyword=\"HL7StructuredDocumentReferenceSequence\" vr=\"SQ\" vm=\"1\">HL7 Structured Document Reference Sequence</tag>
    <tag group=\"0040\" element=\"A402\" keyword=\"ObservationSubjectUIDTrial\" vr=\"UI\" vm=\"1\" retired=\"true\">Observation Subject UID (Trial)</tag>
    <tag group=\"0040\" element=\"A403\" keyword=\"ObservationSubjectClassTrial\" vr=\"CS\" vm=\"1\" retired=\"true\">Observation Subject Class (Trial)</tag>
    <tag group=\"0040\" element=\"A404\" keyword=\"ObservationSubjectTypeCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Observation Subject Type Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A491\" keyword=\"CompletionFlag\" vr=\"CS\" vm=\"1\">Completion Flag</tag>
    <tag group=\"0040\" element=\"A492\" keyword=\"CompletionFlagDescription\" vr=\"LO\" vm=\"1\">Completion Flag Description</tag>
    <tag group=\"0040\" element=\"A493\" keyword=\"VerificationFlag\" vr=\"CS\" vm=\"1\">Verification Flag</tag>
    <tag group=\"0040\" element=\"A494\" keyword=\"ArchiveRequested\" vr=\"CS\" vm=\"1\">Archive Requested</tag>
    <tag group=\"0040\" element=\"A496\" keyword=\"PreliminaryFlag\" vr=\"CS\" vm=\"1\">Preliminary Flag</tag>
    <tag group=\"0040\" element=\"A504\" keyword=\"ContentTemplateSequence\" vr=\"SQ\" vm=\"1\">Content Template Sequence</tag>
    <tag group=\"0040\" element=\"A525\" keyword=\"IdenticalDocumentsSequence\" vr=\"SQ\" vm=\"1\">Identical Documents Sequence</tag>
    <tag group=\"0040\" element=\"A600\" keyword=\"ObservationSubjectContextFlagTrial\" vr=\"CS\" vm=\"1\" retired=\"true\">Observation Subject Context Flag (Trial)</tag>
    <tag group=\"0040\" element=\"A601\" keyword=\"ObserverContextFlagTrial\" vr=\"CS\" vm=\"1\" retired=\"true\">Observer Context Flag (Trial)</tag>
    <tag group=\"0040\" element=\"A603\" keyword=\"ProcedureContextFlagTrial\" vr=\"CS\" vm=\"1\" retired=\"true\">Procedure Context Flag (Trial)</tag>
    <tag group=\"0040\" element=\"A730\" keyword=\"ContentSequence\" vr=\"SQ\" vm=\"1\">Content Sequence</tag>
    <tag group=\"0040\" element=\"A731\" keyword=\"RelationshipSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Relationship Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A732\" keyword=\"RelationshipTypeCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Relationship Type Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A744\" keyword=\"LanguageCodeSequenceTrial\" vr=\"SQ\" vm=\"1\" retired=\"true\">Language Code Sequence (Trial)</tag>
    <tag group=\"0040\" element=\"A992\" keyword=\"UniformResourceLocatorTrial\" vr=\"ST\" vm=\"1\" retired=\"true\">Uniform Resource Locator (Trial)</tag>
    <tag group=\"0040\" element=\"B020\" keyword=\"WaveformAnnotationSequence\" vr=\"SQ\" vm=\"1\">Waveform Annotation Sequence</tag>
    <tag group=\"0040\" element=\"DB00\" keyword=\"TemplateIdentifier\" vr=\"CS\" vm=\"1\">Template Identifier</tag>
    <tag group=\"0040\" element=\"DB06\" keyword=\"TemplateVersion\" vr=\"DT\" vm=\"1\" retired=\"true\">Template Version</tag>
    <tag group=\"0040\" element=\"DB07\" keyword=\"TemplateLocalVersion\" vr=\"DT\" vm=\"1\" retired=\"true\">Template Local Version</tag>
    <tag group=\"0040\" element=\"DB0B\" keyword=\"TemplateExtensionFlag\" vr=\"CS\" vm=\"1\" retired=\"true\">Template Extension Flag</tag>
    <tag group=\"0040\" element=\"DB0C\" keyword=\"TemplateExtensionOrganizationUID\" vr=\"UI\" vm=\"1\" retired=\"true\">Template Extension Organization UID</tag>
    <tag group=\"0040\" element=\"DB0D\" keyword=\"TemplateExtensionCreatorUID\" vr=\"UI\" vm=\"1\" retired=\"true\">Template Extension Creator UID</tag>
    <tag group=\"0040\" element=\"DB73\" keyword=\"ReferencedContentItemIdentifier\" vr=\"UL\" vm=\"1-n\">Referenced Content Item Identifier</tag>
    <tag group=\"0040\" element=\"E001\" keyword=\"HL7InstanceIdentifier\" vr=\"ST\" vm=\"1\">HL7 Instance Identifier</tag>
    <tag group=\"0040\" element=\"E004\" keyword=\"HL7DocumentEffectiveTime\" vr=\"DT\" vm=\"1\">HL7 Document Effective Time</tag>
    <tag group=\"0040\" element=\"E006\" keyword=\"HL7DocumentTypeCodeSequence\" vr=\"SQ\" vm=\"1\">HL7 Document Type Code Sequence</tag>
    <tag group=\"0040\" element=\"E008\" keyword=\"DocumentClassCodeSequence\" vr=\"SQ\" vm=\"1\">Document Class Code Sequence</tag>
    <tag group=\"0040\" element=\"E010\" keyword=\"RetrieveURI\" vr=\"UR\" vm=\"1\">Retrieve URI</tag>
    <tag group=\"0040\" element=\"E011\" keyword=\"RetrieveLocationUID\" vr=\"UI\" vm=\"1\">Retrieve Location UID</tag>
    <tag group=\"0040\" element=\"E020\" keyword=\"TypeOfInstances\" vr=\"CS\" vm=\"1\">Type of Instances</tag>
    <tag group=\"0040\" element=\"E021\" keyword=\"DICOMRetrievalSequence\" vr=\"SQ\" vm=\"1\">DICOM Retrieval Sequence</tag>
    <tag group=\"0040\" element=\"E022\" keyword=\"DICOMMediaRetrievalSequence\" vr=\"SQ\" vm=\"1\">DICOM Media Retrieval Sequence</tag>
    <tag group=\"0040\" element=\"E023\" keyword=\"WADORetrievalSequence\" vr=\"SQ\" vm=\"1\">WADO Retrieval Sequence</tag>
    <tag group=\"0040\" element=\"E024\" keyword=\"XDSRetrievalSequence\" vr=\"SQ\" vm=\"1\">XDS Retrieval Sequence</tag>
    <tag group=\"0040\" element=\"E025\" keyword=\"WADORSRetrievalSequence\" vr=\"SQ\" vm=\"1\">WADO-RS Retrieval Sequence</tag>
    <tag group=\"0040\" element=\"E030\" keyword=\"RepositoryUniqueID\" vr=\"UI\" vm=\"1\">Repository Unique ID</tag>
    <tag group=\"0040\" element=\"E031\" keyword=\"HomeCommunityID\" vr=\"UI\" vm=\"1\">Home Community ID</tag>
    <tag group=\"0042\" element=\"0010\" keyword=\"DocumentTitle\" vr=\"ST\" vm=\"1\">Document Title</tag>
    <tag group=\"0042\" element=\"0011\" keyword=\"EncapsulatedDocument\" vr=\"OB\" vm=\"1\">Encapsulated Document</tag>
    <tag group=\"0042\" element=\"0012\" keyword=\"MIMETypeOfEncapsulatedDocument\" vr=\"LO\" vm=\"1\">MIME Type of Encapsulated Document</tag>
    <tag group=\"0042\" element=\"0013\" keyword=\"SourceInstanceSequence\" vr=\"SQ\" vm=\"1\">Source Instance Sequence</tag>
    <tag group=\"0042\" element=\"0014\" keyword=\"ListOfMIMETypes\" vr=\"LO\" vm=\"1-n\">List of MIME Types</tag>
    <tag group=\"0044\" element=\"0001\" keyword=\"ProductPackageIdentifier\" vr=\"ST\" vm=\"1\">Product Package Identifier</tag>
    <tag group=\"0044\" element=\"0002\" keyword=\"SubstanceAdministrationApproval\" vr=\"CS\" vm=\"1\">Substance Administration Approval</tag>
    <tag group=\"0044\" element=\"0003\" keyword=\"ApprovalStatusFurtherDescription\" vr=\"LT\" vm=\"1\">Approval Status Further Description</tag>
    <tag group=\"0044\" element=\"0004\" keyword=\"ApprovalStatusDateTime\" vr=\"DT\" vm=\"1\">Approval Status DateTime</tag>
    <tag group=\"0044\" element=\"0007\" keyword=\"ProductTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Product Type Code Sequence</tag>
    <tag group=\"0044\" element=\"0008\" keyword=\"ProductName\" vr=\"LO\" vm=\"1-n\">Product Name</tag>
    <tag group=\"0044\" element=\"0009\" keyword=\"ProductDescription\" vr=\"LT\" vm=\"1\">Product Description</tag>
    <tag group=\"0044\" element=\"000A\" keyword=\"ProductLotIdentifier\" vr=\"LO\" vm=\"1\">Product Lot Identifier</tag>
    <tag group=\"0044\" element=\"000B\" keyword=\"ProductExpirationDateTime\" vr=\"DT\" vm=\"1\">Product Expiration DateTime</tag>
    <tag group=\"0044\" element=\"0010\" keyword=\"SubstanceAdministrationDateTime\" vr=\"DT\" vm=\"1\">Substance Administration DateTime</tag>
    <tag group=\"0044\" element=\"0011\" keyword=\"SubstanceAdministrationNotes\" vr=\"LO\" vm=\"1\">Substance Administration Notes</tag>
    <tag group=\"0044\" element=\"0012\" keyword=\"SubstanceAdministrationDeviceID\" vr=\"LO\" vm=\"1\">Substance Administration Device ID</tag>
    <tag group=\"0044\" element=\"0013\" keyword=\"ProductParameterSequence\" vr=\"SQ\" vm=\"1\">Product Parameter Sequence</tag>
    <tag group=\"0044\" element=\"0019\" keyword=\"SubstanceAdministrationParameterSequence\" vr=\"SQ\" vm=\"1\">Substance Administration Parameter Sequence</tag>
    <tag group=\"0044\" element=\"0100\" keyword=\"ApprovalSequence\" vr=\"SQ\" vm=\"1\">Approval Sequence</tag>
    <tag group=\"0044\" element=\"0101\" keyword=\"AssertionCodeSequence\" vr=\"SQ\" vm=\"1\">Assertion Code Sequence</tag>
    <tag group=\"0044\" element=\"0102\" keyword=\"AssertionUID\" vr=\"UI\" vm=\"1\">Assertion UID</tag>
    <tag group=\"0044\" element=\"0103\" keyword=\"AsserterIdentificationSequence\" vr=\"SQ\" vm=\"1\">Asserter Identification Sequence</tag>
    <tag group=\"0044\" element=\"0104\" keyword=\"AssertionDateTime\" vr=\"DT\" vm=\"1\">Assertion DateTime</tag>
    <tag group=\"0044\" element=\"0105\" keyword=\"AssertionExpirationDateTime\" vr=\"DT\" vm=\"1\">Assertion Expiration DateTime</tag>
    <tag group=\"0044\" element=\"0106\" keyword=\"AssertionComments\" vr=\"UT\" vm=\"1\">Assertion Comments</tag>
    <tag group=\"0044\" element=\"0107\" keyword=\"RelatedAssertionSequence\" vr=\"SQ\" vm=\"1\">Related Assertion Sequence</tag>
    <tag group=\"0044\" element=\"0108\" keyword=\"ReferencedAssertionUID\" vr=\"UI\" vm=\"1\">Referenced Assertion UID</tag>
    <tag group=\"0044\" element=\"0109\" keyword=\"ApprovalSubjectSequence\" vr=\"SQ\" vm=\"1\">Approval Subject Sequence</tag>
    <tag group=\"0044\" element=\"010A\" keyword=\"OrganizationalRoleCodeSequence\" vr=\"SQ\" vm=\"1\">Organizational Role Code Sequence</tag>
    <tag group=\"0046\" element=\"0012\" keyword=\"LensDescription\" vr=\"LO\" vm=\"1\">Lens Description</tag>
    <tag group=\"0046\" element=\"0014\" keyword=\"RightLensSequence\" vr=\"SQ\" vm=\"1\">Right Lens Sequence</tag>
    <tag group=\"0046\" element=\"0015\" keyword=\"LeftLensSequence\" vr=\"SQ\" vm=\"1\">Left Lens Sequence</tag>
    <tag group=\"0046\" element=\"0016\" keyword=\"UnspecifiedLateralityLensSequence\" vr=\"SQ\" vm=\"1\">Unspecified Laterality Lens Sequence</tag>
    <tag group=\"0046\" element=\"0018\" keyword=\"CylinderSequence\" vr=\"SQ\" vm=\"1\">Cylinder Sequence</tag>
    <tag group=\"0046\" element=\"0028\" keyword=\"PrismSequence\" vr=\"SQ\" vm=\"1\">Prism Sequence</tag>
    <tag group=\"0046\" element=\"0030\" keyword=\"HorizontalPrismPower\" vr=\"FD\" vm=\"1\">Horizontal Prism Power</tag>
    <tag group=\"0046\" element=\"0032\" keyword=\"HorizontalPrismBase\" vr=\"CS\" vm=\"1\">Horizontal Prism Base</tag>
    <tag group=\"0046\" element=\"0034\" keyword=\"VerticalPrismPower\" vr=\"FD\" vm=\"1\">Vertical Prism Power</tag>
    <tag group=\"0046\" element=\"0036\" keyword=\"VerticalPrismBase\" vr=\"CS\" vm=\"1\">Vertical Prism Base</tag>
    <tag group=\"0046\" element=\"0038\" keyword=\"LensSegmentType\" vr=\"CS\" vm=\"1\">Lens Segment Type</tag>
    <tag group=\"0046\" element=\"0040\" keyword=\"OpticalTransmittance\" vr=\"FD\" vm=\"1\">Optical Transmittance</tag>
    <tag group=\"0046\" element=\"0042\" keyword=\"ChannelWidth\" vr=\"FD\" vm=\"1\">Channel Width</tag>
    <tag group=\"0046\" element=\"0044\" keyword=\"PupilSize\" vr=\"FD\" vm=\"1\">Pupil Size</tag>
    <tag group=\"0046\" element=\"0046\" keyword=\"CornealSize\" vr=\"FD\" vm=\"1\">Corneal Size</tag>
    <tag group=\"0046\" element=\"0050\" keyword=\"AutorefractionRightEyeSequence\" vr=\"SQ\" vm=\"1\">Autorefraction Right Eye Sequence</tag>
    <tag group=\"0046\" element=\"0052\" keyword=\"AutorefractionLeftEyeSequence\" vr=\"SQ\" vm=\"1\">Autorefraction Left Eye Sequence</tag>
    <tag group=\"0046\" element=\"0060\" keyword=\"DistancePupillaryDistance\" vr=\"FD\" vm=\"1\">Distance Pupillary Distance</tag>
    <tag group=\"0046\" element=\"0062\" keyword=\"NearPupillaryDistance\" vr=\"FD\" vm=\"1\">Near Pupillary Distance</tag>
    <tag group=\"0046\" element=\"0063\" keyword=\"IntermediatePupillaryDistance\" vr=\"FD\" vm=\"1\">Intermediate Pupillary Distance</tag>
    <tag group=\"0046\" element=\"0064\" keyword=\"OtherPupillaryDistance\" vr=\"FD\" vm=\"1\">Other Pupillary Distance</tag>
    <tag group=\"0046\" element=\"0070\" keyword=\"KeratometryRightEyeSequence\" vr=\"SQ\" vm=\"1\">Keratometry Right Eye Sequence</tag>
    <tag group=\"0046\" element=\"0071\" keyword=\"KeratometryLeftEyeSequence\" vr=\"SQ\" vm=\"1\">Keratometry Left Eye Sequence</tag>
    <tag group=\"0046\" element=\"0074\" keyword=\"SteepKeratometricAxisSequence\" vr=\"SQ\" vm=\"1\">Steep Keratometric Axis Sequence</tag>
    <tag group=\"0046\" element=\"0075\" keyword=\"RadiusOfCurvature\" vr=\"FD\" vm=\"1\">Radius of Curvature</tag>
    <tag group=\"0046\" element=\"0076\" keyword=\"KeratometricPower\" vr=\"FD\" vm=\"1\">Keratometric Power</tag>
    <tag group=\"0046\" element=\"0077\" keyword=\"KeratometricAxis\" vr=\"FD\" vm=\"1\">Keratometric Axis</tag>
    <tag group=\"0046\" element=\"0080\" keyword=\"FlatKeratometricAxisSequence\" vr=\"SQ\" vm=\"1\">Flat Keratometric Axis Sequence</tag>
    <tag group=\"0046\" element=\"0092\" keyword=\"BackgroundColor\" vr=\"CS\" vm=\"1\">Background Color</tag>
    <tag group=\"0046\" element=\"0094\" keyword=\"Optotype\" vr=\"CS\" vm=\"1\">Optotype</tag>
    <tag group=\"0046\" element=\"0095\" keyword=\"OptotypePresentation\" vr=\"CS\" vm=\"1\">Optotype Presentation</tag>
    <tag group=\"0046\" element=\"0097\" keyword=\"SubjectiveRefractionRightEyeSequence\" vr=\"SQ\" vm=\"1\">Subjective Refraction Right Eye Sequence</tag>
    <tag group=\"0046\" element=\"0098\" keyword=\"SubjectiveRefractionLeftEyeSequence\" vr=\"SQ\" vm=\"1\">Subjective Refraction Left Eye Sequence</tag>
    <tag group=\"0046\" element=\"0100\" keyword=\"AddNearSequence\" vr=\"SQ\" vm=\"1\">Add Near Sequence</tag>
    <tag group=\"0046\" element=\"0101\" keyword=\"AddIntermediateSequence\" vr=\"SQ\" vm=\"1\">Add Intermediate Sequence</tag>
    <tag group=\"0046\" element=\"0102\" keyword=\"AddOtherSequence\" vr=\"SQ\" vm=\"1\">Add Other Sequence</tag>
    <tag group=\"0046\" element=\"0104\" keyword=\"AddPower\" vr=\"FD\" vm=\"1\">Add Power</tag>
    <tag group=\"0046\" element=\"0106\" keyword=\"ViewingDistance\" vr=\"FD\" vm=\"1\">Viewing Distance</tag>
    <tag group=\"0046\" element=\"0121\" keyword=\"VisualAcuityTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Visual Acuity Type Code Sequence</tag>
    <tag group=\"0046\" element=\"0122\" keyword=\"VisualAcuityRightEyeSequence\" vr=\"SQ\" vm=\"1\">Visual Acuity Right Eye Sequence</tag>
    <tag group=\"0046\" element=\"0123\" keyword=\"VisualAcuityLeftEyeSequence\" vr=\"SQ\" vm=\"1\">Visual Acuity Left Eye Sequence</tag>
    <tag group=\"0046\" element=\"0124\" keyword=\"VisualAcuityBothEyesOpenSequence\" vr=\"SQ\" vm=\"1\">Visual Acuity Both Eyes Open Sequence</tag>
    <tag group=\"0046\" element=\"0125\" keyword=\"ViewingDistanceType\" vr=\"CS\" vm=\"1\">Viewing Distance Type</tag>
    <tag group=\"0046\" element=\"0135\" keyword=\"VisualAcuityModifiers\" vr=\"SS\" vm=\"2\">Visual Acuity Modifiers</tag>
    <tag group=\"0046\" element=\"0137\" keyword=\"DecimalVisualAcuity\" vr=\"FD\" vm=\"1\">Decimal Visual Acuity</tag>
    <tag group=\"0046\" element=\"0139\" keyword=\"OptotypeDetailedDefinition\" vr=\"LO\" vm=\"1\">Optotype Detailed Definition</tag>
    <tag group=\"0046\" element=\"0145\" keyword=\"ReferencedRefractiveMeasurementsSequence\" vr=\"SQ\" vm=\"1\">Referenced Refractive Measurements Sequence</tag>
    <tag group=\"0046\" element=\"0146\" keyword=\"SpherePower\" vr=\"FD\" vm=\"1\">Sphere Power</tag>
    <tag group=\"0046\" element=\"0147\" keyword=\"CylinderPower\" vr=\"FD\" vm=\"1\">Cylinder Power</tag>
    <tag group=\"0046\" element=\"0201\" keyword=\"CornealTopographySurface\" vr=\"CS\" vm=\"1\">Corneal Topography Surface</tag>
    <tag group=\"0046\" element=\"0202\" keyword=\"CornealVertexLocation\" vr=\"FL\" vm=\"2\">Corneal Vertex Location</tag>
    <tag group=\"0046\" element=\"0203\" keyword=\"PupilCentroidXCoordinate\" vr=\"FL\" vm=\"1\">Pupil Centroid X-Coordinate</tag>
    <tag group=\"0046\" element=\"0204\" keyword=\"PupilCentroidYCoordinate\" vr=\"FL\" vm=\"1\">Pupil Centroid Y-Coordinate</tag>
    <tag group=\"0046\" element=\"0205\" keyword=\"EquivalentPupilRadius\" vr=\"FL\" vm=\"1\">Equivalent Pupil Radius</tag>
    <tag group=\"0046\" element=\"0207\" keyword=\"CornealTopographyMapTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Corneal Topography Map Type Code Sequence</tag>
    <tag group=\"0046\" element=\"0208\" keyword=\"VerticesOfTheOutlineOfPupil\" vr=\"IS\" vm=\"2-2n\">Vertices of the Outline of Pupil</tag>
    <tag group=\"0046\" element=\"0210\" keyword=\"CornealTopographyMappingNormalsSequence\" vr=\"SQ\" vm=\"1\">Corneal Topography Mapping Normals Sequence</tag>
    <tag group=\"0046\" element=\"0211\" keyword=\"MaximumCornealCurvatureSequence\" vr=\"SQ\" vm=\"1\">Maximum Corneal Curvature Sequence</tag>
    <tag group=\"0046\" element=\"0212\" keyword=\"MaximumCornealCurvature\" vr=\"FL\" vm=\"1\">Maximum Corneal Curvature</tag>
    <tag group=\"0046\" element=\"0213\" keyword=\"MaximumCornealCurvatureLocation\" vr=\"FL\" vm=\"2\">Maximum Corneal Curvature Location</tag>
    <tag group=\"0046\" element=\"0215\" keyword=\"MinimumKeratometricSequence\" vr=\"SQ\" vm=\"1\">Minimum Keratometric Sequence</tag>
    <tag group=\"0046\" element=\"0218\" keyword=\"SimulatedKeratometricCylinderSequence\" vr=\"SQ\" vm=\"1\">Simulated Keratometric Cylinder Sequence</tag>
    <tag group=\"0046\" element=\"0220\" keyword=\"AverageCornealPower\" vr=\"FL\" vm=\"1\">Average Corneal Power</tag>
    <tag group=\"0046\" element=\"0224\" keyword=\"CornealISValue\" vr=\"FL\" vm=\"1\">Corneal I-S Value</tag>
    <tag group=\"0046\" element=\"0227\" keyword=\"AnalyzedArea\" vr=\"FL\" vm=\"1\">Analyzed Area</tag>
    <tag group=\"0046\" element=\"0230\" keyword=\"SurfaceRegularityIndex\" vr=\"FL\" vm=\"1\">Surface Regularity Index</tag>
    <tag group=\"0046\" element=\"0232\" keyword=\"SurfaceAsymmetryIndex\" vr=\"FL\" vm=\"1\">Surface Asymmetry Index</tag>
    <tag group=\"0046\" element=\"0234\" keyword=\"CornealEccentricityIndex\" vr=\"FL\" vm=\"1\">Corneal Eccentricity Index</tag>
    <tag group=\"0046\" element=\"0236\" keyword=\"KeratoconusPredictionIndex\" vr=\"FL\" vm=\"1\">Keratoconus Prediction Index</tag>
    <tag group=\"0046\" element=\"0238\" keyword=\"DecimalPotentialVisualAcuity\" vr=\"FL\" vm=\"1\">Decimal Potential Visual Acuity</tag>
    <tag group=\"0046\" element=\"0242\" keyword=\"CornealTopographyMapQualityEvaluation\" vr=\"CS\" vm=\"1\">Corneal Topography Map Quality Evaluation</tag>
    <tag group=\"0046\" element=\"0244\" keyword=\"SourceImageCornealProcessedDataSequence\" vr=\"SQ\" vm=\"1\">Source Image Corneal Processed Data Sequence</tag>
    <tag group=\"0046\" element=\"0247\" keyword=\"CornealPointLocation\" vr=\"FL\" vm=\"3\">Corneal Point Location</tag>
    <tag group=\"0046\" element=\"0248\" keyword=\"CornealPointEstimated\" vr=\"CS\" vm=\"1\">Corneal Point Estimated</tag>
    <tag group=\"0046\" element=\"0249\" keyword=\"AxialPower\" vr=\"FL\" vm=\"1\">Axial Power</tag>
    <tag group=\"0046\" element=\"0250\" keyword=\"TangentialPower\" vr=\"FL\" vm=\"1\">Tangential Power</tag>
    <tag group=\"0046\" element=\"0251\" keyword=\"RefractivePower\" vr=\"FL\" vm=\"1\">Refractive Power</tag>
    <tag group=\"0046\" element=\"0252\" keyword=\"RelativeElevation\" vr=\"FL\" vm=\"1\">Relative Elevation</tag>
    <tag group=\"0046\" element=\"0253\" keyword=\"CornealWavefront\" vr=\"FL\" vm=\"1\">Corneal Wavefront</tag>
    <tag group=\"0048\" element=\"0001\" keyword=\"ImagedVolumeWidth\" vr=\"FL\" vm=\"1\">Imaged Volume Width</tag>
    <tag group=\"0048\" element=\"0002\" keyword=\"ImagedVolumeHeight\" vr=\"FL\" vm=\"1\">Imaged Volume Height</tag>
    <tag group=\"0048\" element=\"0003\" keyword=\"ImagedVolumeDepth\" vr=\"FL\" vm=\"1\">Imaged Volume Depth</tag>
    <tag group=\"0048\" element=\"0006\" keyword=\"TotalPixelMatrixColumns\" vr=\"UL\" vm=\"1\">Total Pixel Matrix Columns</tag>
    <tag group=\"0048\" element=\"0007\" keyword=\"TotalPixelMatrixRows\" vr=\"UL\" vm=\"1\">Total Pixel Matrix Rows</tag>
    <tag group=\"0048\" element=\"0008\" keyword=\"TotalPixelMatrixOriginSequence\" vr=\"SQ\" vm=\"1\">Total Pixel Matrix Origin Sequence</tag>
    <tag group=\"0048\" element=\"0010\" keyword=\"SpecimenLabelInImage\" vr=\"CS\" vm=\"1\">Specimen Label in Image</tag>
    <tag group=\"0048\" element=\"0011\" keyword=\"FocusMethod\" vr=\"CS\" vm=\"1\">Focus Method</tag>
    <tag group=\"0048\" element=\"0012\" keyword=\"ExtendedDepthOfField\" vr=\"CS\" vm=\"1\">Extended Depth of Field</tag>
    <tag group=\"0048\" element=\"0013\" keyword=\"NumberOfFocalPlanes\" vr=\"US\" vm=\"1\">Number of Focal Planes</tag>
    <tag group=\"0048\" element=\"0014\" keyword=\"DistanceBetweenFocalPlanes\" vr=\"FL\" vm=\"1\">Distance Between Focal Planes</tag>
    <tag group=\"0048\" element=\"0015\" keyword=\"RecommendedAbsentPixelCIELabValue\" vr=\"US\" vm=\"3\">Recommended Absent Pixel CIELab Value</tag>
    <tag group=\"0048\" element=\"0100\" keyword=\"IlluminatorTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Illuminator Type Code Sequence</tag>
    <tag group=\"0048\" element=\"0102\" keyword=\"ImageOrientationSlide\" vr=\"DS\" vm=\"6\">Image Orientation (Slide)</tag>
    <tag group=\"0048\" element=\"0105\" keyword=\"OpticalPathSequence\" vr=\"SQ\" vm=\"1\">Optical Path Sequence</tag>
    <tag group=\"0048\" element=\"0106\" keyword=\"OpticalPathIdentifier\" vr=\"SH\" vm=\"1\">Optical Path Identifier</tag>
    <tag group=\"0048\" element=\"0107\" keyword=\"OpticalPathDescription\" vr=\"ST\" vm=\"1\">Optical Path Description</tag>
    <tag group=\"0048\" element=\"0108\" keyword=\"IlluminationColorCodeSequence\" vr=\"SQ\" vm=\"1\">Illumination Color Code Sequence</tag>
    <tag group=\"0048\" element=\"0110\" keyword=\"SpecimenReferenceSequence\" vr=\"SQ\" vm=\"1\">Specimen Reference Sequence</tag>
    <tag group=\"0048\" element=\"0111\" keyword=\"CondenserLensPower\" vr=\"DS\" vm=\"1\">Condenser Lens Power</tag>
    <tag group=\"0048\" element=\"0112\" keyword=\"ObjectiveLensPower\" vr=\"DS\" vm=\"1\">Objective Lens Power</tag>
    <tag group=\"0048\" element=\"0113\" keyword=\"ObjectiveLensNumericalAperture\" vr=\"DS\" vm=\"1\">Objective Lens Numerical Aperture</tag>
    <tag group=\"0048\" element=\"0120\" keyword=\"PaletteColorLookupTableSequence\" vr=\"SQ\" vm=\"1\">Palette Color Lookup Table Sequence</tag>
    <tag group=\"0048\" element=\"0200\" keyword=\"ReferencedImageNavigationSequence\" vr=\"SQ\" vm=\"1\">Referenced Image Navigation Sequence</tag>
    <tag group=\"0048\" element=\"0201\" keyword=\"TopLeftHandCornerOfLocalizerArea\" vr=\"US\" vm=\"2\">Top Left Hand Corner of Localizer Area</tag>
    <tag group=\"0048\" element=\"0202\" keyword=\"BottomRightHandCornerOfLocalizerArea\" vr=\"US\" vm=\"2\">Bottom Right Hand Corner of Localizer Area</tag>
    <tag group=\"0048\" element=\"0207\" keyword=\"OpticalPathIdentificationSequence\" vr=\"SQ\" vm=\"1\">Optical Path Identification Sequence</tag>
    <tag group=\"0048\" element=\"021A\" keyword=\"PlanePositionSlideSequence\" vr=\"SQ\" vm=\"1\">Plane Position (Slide) Sequence</tag>
    <tag group=\"0048\" element=\"021E\" keyword=\"ColumnPositionInTotalImagePixelMatrix\" vr=\"SL\" vm=\"1\">Column Position In Total Image Pixel Matrix</tag>
    <tag group=\"0048\" element=\"021F\" keyword=\"RowPositionInTotalImagePixelMatrix\" vr=\"SL\" vm=\"1\">Row Position In Total Image Pixel Matrix</tag>
    <tag group=\"0048\" element=\"0301\" keyword=\"PixelOriginInterpretation\" vr=\"CS\" vm=\"1\">Pixel Origin Interpretation</tag>
    <tag group=\"0050\" element=\"0004\" keyword=\"CalibrationImage\" vr=\"CS\" vm=\"1\">Calibration Image</tag>
    <tag group=\"0050\" element=\"0010\" keyword=\"DeviceSequence\" vr=\"SQ\" vm=\"1\">Device Sequence</tag>
    <tag group=\"0050\" element=\"0012\" keyword=\"ContainerComponentTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Container Component Type Code Sequence</tag>
    <tag group=\"0050\" element=\"0013\" keyword=\"ContainerComponentThickness\" vr=\"FD\" vm=\"1\">Container Component Thickness</tag>
    <tag group=\"0050\" element=\"0014\" keyword=\"DeviceLength\" vr=\"DS\" vm=\"1\">Device Length</tag>
    <tag group=\"0050\" element=\"0015\" keyword=\"ContainerComponentWidth\" vr=\"FD\" vm=\"1\">Container Component Width</tag>
    <tag group=\"0050\" element=\"0016\" keyword=\"DeviceDiameter\" vr=\"DS\" vm=\"1\">Device Diameter</tag>
    <tag group=\"0050\" element=\"0017\" keyword=\"DeviceDiameterUnits\" vr=\"CS\" vm=\"1\">Device Diameter Units</tag>
    <tag group=\"0050\" element=\"0018\" keyword=\"DeviceVolume\" vr=\"DS\" vm=\"1\">Device Volume</tag>
    <tag group=\"0050\" element=\"0019\" keyword=\"InterMarkerDistance\" vr=\"DS\" vm=\"1\">Inter-Marker Distance</tag>
    <tag group=\"0050\" element=\"001A\" keyword=\"ContainerComponentMaterial\" vr=\"CS\" vm=\"1\">Container Component Material</tag>
    <tag group=\"0050\" element=\"001B\" keyword=\"ContainerComponentID\" vr=\"LO\" vm=\"1\">Container Component ID</tag>
    <tag group=\"0050\" element=\"001C\" keyword=\"ContainerComponentLength\" vr=\"FD\" vm=\"1\">Container Component Length</tag>
    <tag group=\"0050\" element=\"001D\" keyword=\"ContainerComponentDiameter\" vr=\"FD\" vm=\"1\">Container Component Diameter</tag>
    <tag group=\"0050\" element=\"001E\" keyword=\"ContainerComponentDescription\" vr=\"LO\" vm=\"1\">Container Component Description</tag>
    <tag group=\"0050\" element=\"0020\" keyword=\"DeviceDescription\" vr=\"LO\" vm=\"1\">Device Description</tag>
    <tag group=\"0052\" element=\"0001\" keyword=\"ContrastBolusIngredientPercentByVolume\" vr=\"FL\" vm=\"1\">Contrast/Bolus Ingredient Percent by Volume</tag>
    <tag group=\"0052\" element=\"0002\" keyword=\"OCTFocalDistance\" vr=\"FD\" vm=\"1\">OCT Focal Distance</tag>
    <tag group=\"0052\" element=\"0003\" keyword=\"BeamSpotSize\" vr=\"FD\" vm=\"1\">Beam Spot Size</tag>
    <tag group=\"0052\" element=\"0004\" keyword=\"EffectiveRefractiveIndex\" vr=\"FD\" vm=\"1\">Effective Refractive Index</tag>
    <tag group=\"0052\" element=\"0006\" keyword=\"OCTAcquisitionDomain\" vr=\"CS\" vm=\"1\">OCT Acquisition Domain</tag>
    <tag group=\"0052\" element=\"0007\" keyword=\"OCTOpticalCenterWavelength\" vr=\"FD\" vm=\"1\">OCT Optical Center Wavelength</tag>
    <tag group=\"0052\" element=\"0008\" keyword=\"AxialResolution\" vr=\"FD\" vm=\"1\">Axial Resolution</tag>
    <tag group=\"0052\" element=\"0009\" keyword=\"RangingDepth\" vr=\"FD\" vm=\"1\">Ranging Depth</tag>
    <tag group=\"0052\" element=\"0011\" keyword=\"ALineRate\" vr=\"FD\" vm=\"1\">A-line Rate</tag>
    <tag group=\"0052\" element=\"0012\" keyword=\"ALinesPerFrame\" vr=\"US\" vm=\"1\">A-lines Per Frame</tag>
    <tag group=\"0052\" element=\"0013\" keyword=\"CatheterRotationalRate\" vr=\"FD\" vm=\"1\">Catheter Rotational Rate</tag>
    <tag group=\"0052\" element=\"0014\" keyword=\"ALinePixelSpacing\" vr=\"FD\" vm=\"1\">A-line Pixel Spacing</tag>
    <tag group=\"0052\" element=\"0016\" keyword=\"ModeOfPercutaneousAccessSequence\" vr=\"SQ\" vm=\"1\">Mode of Percutaneous Access Sequence</tag>
    <tag group=\"0052\" element=\"0025\" keyword=\"IntravascularOCTFrameTypeSequence\" vr=\"SQ\" vm=\"1\">Intravascular OCT Frame Type Sequence</tag>
    <tag group=\"0052\" element=\"0026\" keyword=\"OCTZOffsetApplied\" vr=\"CS\" vm=\"1\">OCT Z Offset Applied</tag>
    <tag group=\"0052\" element=\"0027\" keyword=\"IntravascularFrameContentSequence\" vr=\"SQ\" vm=\"1\">Intravascular Frame Content Sequence</tag>
    <tag group=\"0052\" element=\"0028\" keyword=\"IntravascularLongitudinalDistance\" vr=\"FD\" vm=\"1\">Intravascular Longitudinal Distance</tag>
    <tag group=\"0052\" element=\"0029\" keyword=\"IntravascularOCTFrameContentSequence\" vr=\"SQ\" vm=\"1\">Intravascular OCT Frame Content Sequence</tag>
    <tag group=\"0052\" element=\"0030\" keyword=\"OCTZOffsetCorrection\" vr=\"SS\" vm=\"1\">OCT Z Offset Correction</tag>
    <tag group=\"0052\" element=\"0031\" keyword=\"CatheterDirectionOfRotation\" vr=\"CS\" vm=\"1\">Catheter Direction of Rotation</tag>
    <tag group=\"0052\" element=\"0033\" keyword=\"SeamLineLocation\" vr=\"FD\" vm=\"1\">Seam Line Location</tag>
    <tag group=\"0052\" element=\"0034\" keyword=\"FirstALineLocation\" vr=\"FD\" vm=\"1\">First A-line Location</tag>
    <tag group=\"0052\" element=\"0036\" keyword=\"SeamLineIndex\" vr=\"US\" vm=\"1\">Seam Line Index</tag>
    <tag group=\"0052\" element=\"0038\" keyword=\"NumberOfPaddedALines\" vr=\"US\" vm=\"1\">Number of Padded A-lines</tag>
    <tag group=\"0052\" element=\"0039\" keyword=\"InterpolationType\" vr=\"CS\" vm=\"1\">Interpolation Type</tag>
    <tag group=\"0052\" element=\"003A\" keyword=\"RefractiveIndexApplied\" vr=\"CS\" vm=\"1\">Refractive Index Applied</tag>
    <tag group=\"0054\" element=\"0010\" keyword=\"EnergyWindowVector\" vr=\"US\" vm=\"1-n\">Energy Window Vector</tag>
    <tag group=\"0054\" element=\"0011\" keyword=\"NumberOfEnergyWindows\" vr=\"US\" vm=\"1\">Number of Energy Windows</tag>
    <tag group=\"0054\" element=\"0012\" keyword=\"EnergyWindowInformationSequence\" vr=\"SQ\" vm=\"1\">Energy Window Information Sequence</tag>
    <tag group=\"0054\" element=\"0013\" keyword=\"EnergyWindowRangeSequence\" vr=\"SQ\" vm=\"1\">Energy Window Range Sequence</tag>
    <tag group=\"0054\" element=\"0014\" keyword=\"EnergyWindowLowerLimit\" vr=\"DS\" vm=\"1\">Energy Window Lower Limit</tag>
    <tag group=\"0054\" element=\"0015\" keyword=\"EnergyWindowUpperLimit\" vr=\"DS\" vm=\"1\">Energy Window Upper Limit</tag>
    <tag group=\"0054\" element=\"0016\" keyword=\"RadiopharmaceuticalInformationSequence\" vr=\"SQ\" vm=\"1\">Radiopharmaceutical Information Sequence</tag>
    <tag group=\"0054\" element=\"0017\" keyword=\"ResidualSyringeCounts\" vr=\"IS\" vm=\"1\">Residual Syringe Counts</tag>
    <tag group=\"0054\" element=\"0018\" keyword=\"EnergyWindowName\" vr=\"SH\" vm=\"1\">Energy Window Name</tag>
    <tag group=\"0054\" element=\"0020\" keyword=\"DetectorVector\" vr=\"US\" vm=\"1-n\">Detector Vector</tag>
    <tag group=\"0054\" element=\"0021\" keyword=\"NumberOfDetectors\" vr=\"US\" vm=\"1\">Number of Detectors</tag>
    <tag group=\"0054\" element=\"0022\" keyword=\"DetectorInformationSequence\" vr=\"SQ\" vm=\"1\">Detector Information Sequence</tag>
    <tag group=\"0054\" element=\"0030\" keyword=\"PhaseVector\" vr=\"US\" vm=\"1-n\">Phase Vector</tag>
    <tag group=\"0054\" element=\"0031\" keyword=\"NumberOfPhases\" vr=\"US\" vm=\"1\">Number of Phases</tag>
    <tag group=\"0054\" element=\"0032\" keyword=\"PhaseInformationSequence\" vr=\"SQ\" vm=\"1\">Phase Information Sequence</tag>
    <tag group=\"0054\" element=\"0033\" keyword=\"NumberOfFramesInPhase\" vr=\"US\" vm=\"1\">Number of Frames in Phase</tag>
    <tag group=\"0054\" element=\"0036\" keyword=\"PhaseDelay\" vr=\"IS\" vm=\"1\">Phase Delay</tag>
    <tag group=\"0054\" element=\"0038\" keyword=\"PauseBetweenFrames\" vr=\"IS\" vm=\"1\">Pause Between Frames</tag>
    <tag group=\"0054\" element=\"0039\" keyword=\"PhaseDescription\" vr=\"CS\" vm=\"1\">Phase Description</tag>
    <tag group=\"0054\" element=\"0050\" keyword=\"RotationVector\" vr=\"US\" vm=\"1-n\">Rotation Vector</tag>
    <tag group=\"0054\" element=\"0051\" keyword=\"NumberOfRotations\" vr=\"US\" vm=\"1\">Number of Rotations</tag>
    <tag group=\"0054\" element=\"0052\" keyword=\"RotationInformationSequence\" vr=\"SQ\" vm=\"1\">Rotation Information Sequence</tag>
    <tag group=\"0054\" element=\"0053\" keyword=\"NumberOfFramesInRotation\" vr=\"US\" vm=\"1\">Number of Frames in Rotation</tag>
    <tag group=\"0054\" element=\"0060\" keyword=\"RRIntervalVector\" vr=\"US\" vm=\"1-n\">R-R Interval Vector</tag>
    <tag group=\"0054\" element=\"0061\" keyword=\"NumberOfRRIntervals\" vr=\"US\" vm=\"1\">Number of R-R Intervals</tag>
    <tag group=\"0054\" element=\"0062\" keyword=\"GatedInformationSequence\" vr=\"SQ\" vm=\"1\">Gated Information Sequence</tag>
    <tag group=\"0054\" element=\"0063\" keyword=\"DataInformationSequence\" vr=\"SQ\" vm=\"1\">Data Information Sequence</tag>
    <tag group=\"0054\" element=\"0070\" keyword=\"TimeSlotVector\" vr=\"US\" vm=\"1-n\">Time Slot Vector</tag>
    <tag group=\"0054\" element=\"0071\" keyword=\"NumberOfTimeSlots\" vr=\"US\" vm=\"1\">Number of Time Slots</tag>
    <tag group=\"0054\" element=\"0072\" keyword=\"TimeSlotInformationSequence\" vr=\"SQ\" vm=\"1\">Time Slot Information Sequence</tag>
    <tag group=\"0054\" element=\"0073\" keyword=\"TimeSlotTime\" vr=\"DS\" vm=\"1\">Time Slot Time</tag>
    <tag group=\"0054\" element=\"0080\" keyword=\"SliceVector\" vr=\"US\" vm=\"1-n\">Slice Vector</tag>
    <tag group=\"0054\" element=\"0081\" keyword=\"NumberOfSlices\" vr=\"US\" vm=\"1\">Number of Slices</tag>
    <tag group=\"0054\" element=\"0090\" keyword=\"AngularViewVector\" vr=\"US\" vm=\"1-n\">Angular View Vector</tag>
    <tag group=\"0054\" element=\"0100\" keyword=\"TimeSliceVector\" vr=\"US\" vm=\"1-n\">Time Slice Vector</tag>
    <tag group=\"0054\" element=\"0101\" keyword=\"NumberOfTimeSlices\" vr=\"US\" vm=\"1\">Number of Time Slices</tag>
    <tag group=\"0054\" element=\"0200\" keyword=\"StartAngle\" vr=\"DS\" vm=\"1\">Start Angle</tag>
    <tag group=\"0054\" element=\"0202\" keyword=\"TypeOfDetectorMotion\" vr=\"CS\" vm=\"1\">Type of Detector Motion</tag>
    <tag group=\"0054\" element=\"0210\" keyword=\"TriggerVector\" vr=\"IS\" vm=\"1-n\">Trigger Vector</tag>
    <tag group=\"0054\" element=\"0211\" keyword=\"NumberOfTriggersInPhase\" vr=\"US\" vm=\"1\">Number of Triggers in Phase</tag>
    <tag group=\"0054\" element=\"0220\" keyword=\"ViewCodeSequence\" vr=\"SQ\" vm=\"1\">View Code Sequence</tag>
    <tag group=\"0054\" element=\"0222\" keyword=\"ViewModifierCodeSequence\" vr=\"SQ\" vm=\"1\">View Modifier Code Sequence</tag>
    <tag group=\"0054\" element=\"0300\" keyword=\"RadionuclideCodeSequence\" vr=\"SQ\" vm=\"1\">Radionuclide Code Sequence</tag>
    <tag group=\"0054\" element=\"0302\" keyword=\"AdministrationRouteCodeSequence\" vr=\"SQ\" vm=\"1\">Administration Route Code Sequence</tag>
    <tag group=\"0054\" element=\"0304\" keyword=\"RadiopharmaceuticalCodeSequence\" vr=\"SQ\" vm=\"1\">Radiopharmaceutical Code Sequence</tag>
    <tag group=\"0054\" element=\"0306\" keyword=\"CalibrationDataSequence\" vr=\"SQ\" vm=\"1\">Calibration Data Sequence</tag>
    <tag group=\"0054\" element=\"0308\" keyword=\"EnergyWindowNumber\" vr=\"US\" vm=\"1\">Energy Window Number</tag>
    <tag group=\"0054\" element=\"0400\" keyword=\"ImageID\" vr=\"SH\" vm=\"1\">Image ID</tag>
    <tag group=\"0054\" element=\"0410\" keyword=\"PatientOrientationCodeSequence\" vr=\"SQ\" vm=\"1\">Patient Orientation Code Sequence</tag>
    <tag group=\"0054\" element=\"0412\" keyword=\"PatientOrientationModifierCodeSequence\" vr=\"SQ\" vm=\"1\">Patient Orientation Modifier Code Sequence</tag>
    <tag group=\"0054\" element=\"0414\" keyword=\"PatientGantryRelationshipCodeSequence\" vr=\"SQ\" vm=\"1\">Patient Gantry Relationship Code Sequence</tag>
    <tag group=\"0054\" element=\"0500\" keyword=\"SliceProgressionDirection\" vr=\"CS\" vm=\"1\">Slice Progression Direction</tag>
    <tag group=\"0054\" element=\"0501\" keyword=\"ScanProgressionDirection\" vr=\"CS\" vm=\"1\">Scan Progression Direction</tag>
    <tag group=\"0054\" element=\"1000\" keyword=\"SeriesType\" vr=\"CS\" vm=\"2\">Series Type</tag>
    <tag group=\"0054\" element=\"1001\" keyword=\"Units\" vr=\"CS\" vm=\"1\">Units</tag>
    <tag group=\"0054\" element=\"1002\" keyword=\"CountsSource\" vr=\"CS\" vm=\"1\">Counts Source</tag>
    <tag group=\"0054\" element=\"1004\" keyword=\"ReprojectionMethod\" vr=\"CS\" vm=\"1\">Reprojection Method</tag>
    <tag group=\"0054\" element=\"1006\" keyword=\"SUVType\" vr=\"CS\" vm=\"1\">SUV Type</tag>
    <tag group=\"0054\" element=\"1100\" keyword=\"RandomsCorrectionMethod\" vr=\"CS\" vm=\"1\">Randoms Correction Method</tag>
    <tag group=\"0054\" element=\"1101\" keyword=\"AttenuationCorrectionMethod\" vr=\"LO\" vm=\"1\">Attenuation Correction Method</tag>
    <tag group=\"0054\" element=\"1102\" keyword=\"DecayCorrection\" vr=\"CS\" vm=\"1\">Decay Correction</tag>
    <tag group=\"0054\" element=\"1103\" keyword=\"ReconstructionMethod\" vr=\"LO\" vm=\"1\">Reconstruction Method</tag>
    <tag group=\"0054\" element=\"1104\" keyword=\"DetectorLinesOfResponseUsed\" vr=\"LO\" vm=\"1\">Detector Lines of Response Used</tag>
    <tag group=\"0054\" element=\"1105\" keyword=\"ScatterCorrectionMethod\" vr=\"LO\" vm=\"1\">Scatter Correction Method</tag>
    <tag group=\"0054\" element=\"1200\" keyword=\"AxialAcceptance\" vr=\"DS\" vm=\"1\">Axial Acceptance</tag>
    <tag group=\"0054\" element=\"1201\" keyword=\"AxialMash\" vr=\"IS\" vm=\"2\">Axial Mash</tag>
    <tag group=\"0054\" element=\"1202\" keyword=\"TransverseMash\" vr=\"IS\" vm=\"1\">Transverse Mash</tag>
    <tag group=\"0054\" element=\"1203\" keyword=\"DetectorElementSize\" vr=\"DS\" vm=\"2\">Detector Element Size</tag>
    <tag group=\"0054\" element=\"1210\" keyword=\"CoincidenceWindowWidth\" vr=\"DS\" vm=\"1\">Coincidence Window Width</tag>
    <tag group=\"0054\" element=\"1220\" keyword=\"SecondaryCountsType\" vr=\"CS\" vm=\"1-n\">Secondary Counts Type</tag>
    <tag group=\"0054\" element=\"1300\" keyword=\"FrameReferenceTime\" vr=\"DS\" vm=\"1\">Frame Reference Time</tag>
    <tag group=\"0054\" element=\"1310\" keyword=\"PrimaryPromptsCountsAccumulated\" vr=\"IS\" vm=\"1\">Primary (Prompts) Counts Accumulated</tag>
    <tag group=\"0054\" element=\"1311\" keyword=\"SecondaryCountsAccumulated\" vr=\"IS\" vm=\"1-n\">Secondary Counts Accumulated</tag>
    <tag group=\"0054\" element=\"1320\" keyword=\"SliceSensitivityFactor\" vr=\"DS\" vm=\"1\">Slice Sensitivity Factor</tag>
    <tag group=\"0054\" element=\"1321\" keyword=\"DecayFactor\" vr=\"DS\" vm=\"1\">Decay Factor</tag>
    <tag group=\"0054\" element=\"1322\" keyword=\"DoseCalibrationFactor\" vr=\"DS\" vm=\"1\">Dose Calibration Factor</tag>
    <tag group=\"0054\" element=\"1323\" keyword=\"ScatterFractionFactor\" vr=\"DS\" vm=\"1\">Scatter Fraction Factor</tag>
    <tag group=\"0054\" element=\"1324\" keyword=\"DeadTimeFactor\" vr=\"DS\" vm=\"1\">Dead Time Factor</tag>
    <tag group=\"0054\" element=\"1330\" keyword=\"ImageIndex\" vr=\"US\" vm=\"1\">Image Index</tag>
    <tag group=\"0054\" element=\"1400\" keyword=\"CountsIncluded\" vr=\"CS\" vm=\"1-n\" retired=\"true\">Counts Included</tag>
    <tag group=\"0054\" element=\"1401\" keyword=\"DeadTimeCorrectionFlag\" vr=\"CS\" vm=\"1\" retired=\"true\">Dead Time Correction Flag</tag>
    <tag group=\"0060\" element=\"3000\" keyword=\"HistogramSequence\" vr=\"SQ\" vm=\"1\">Histogram Sequence</tag>
    <tag group=\"0060\" element=\"3002\" keyword=\"HistogramNumberOfBins\" vr=\"US\" vm=\"1\">Histogram Number of Bins</tag>
    <tag group=\"0060\" element=\"3004\" keyword=\"HistogramFirstBinValue\" vr=\"US/SS\" vm=\"1\">Histogram First Bin Value</tag>
    <tag group=\"0060\" element=\"3006\" keyword=\"HistogramLastBinValue\" vr=\"US/SS\" vm=\"1\">Histogram Last Bin Value</tag>
    <tag group=\"0060\" element=\"3008\" keyword=\"HistogramBinWidth\" vr=\"US\" vm=\"1\">Histogram Bin Width</tag>
    <tag group=\"0060\" element=\"3010\" keyword=\"HistogramExplanation\" vr=\"LO\" vm=\"1\">Histogram Explanation</tag>
    <tag group=\"0060\" element=\"3020\" keyword=\"HistogramData\" vr=\"UL\" vm=\"1-n\">Histogram Data</tag>
    <tag group=\"0062\" element=\"0001\" keyword=\"SegmentationType\" vr=\"CS\" vm=\"1\">Segmentation Type</tag>
    <tag group=\"0062\" element=\"0002\" keyword=\"SegmentSequence\" vr=\"SQ\" vm=\"1\">Segment Sequence</tag>
    <tag group=\"0062\" element=\"0003\" keyword=\"SegmentedPropertyCategoryCodeSequence\" vr=\"SQ\" vm=\"1\">Segmented Property Category Code Sequence</tag>
    <tag group=\"0062\" element=\"0004\" keyword=\"SegmentNumber\" vr=\"US\" vm=\"1\">Segment Number</tag>
    <tag group=\"0062\" element=\"0005\" keyword=\"SegmentLabel\" vr=\"LO\" vm=\"1\">Segment Label</tag>
    <tag group=\"0062\" element=\"0006\" keyword=\"SegmentDescription\" vr=\"ST\" vm=\"1\">Segment Description</tag>
    <tag group=\"0062\" element=\"0007\" keyword=\"SegmentationAlgorithmIdentificationSequence\" vr=\"SQ\" vm=\"1\">Segmentation Algorithm Identification Sequence</tag>
    <tag group=\"0062\" element=\"0008\" keyword=\"SegmentAlgorithmType\" vr=\"CS\" vm=\"1\">Segment Algorithm Type</tag>
    <tag group=\"0062\" element=\"0009\" keyword=\"SegmentAlgorithmName\" vr=\"LO\" vm=\"1\">Segment Algorithm Name</tag>
    <tag group=\"0062\" element=\"000A\" keyword=\"SegmentIdentificationSequence\" vr=\"SQ\" vm=\"1\">Segment Identification Sequence</tag>
    <tag group=\"0062\" element=\"000B\" keyword=\"ReferencedSegmentNumber\" vr=\"US\" vm=\"1-n\">Referenced Segment Number</tag>
    <tag group=\"0062\" element=\"000C\" keyword=\"RecommendedDisplayGrayscaleValue\" vr=\"US\" vm=\"1\">Recommended Display Grayscale Value</tag>
    <tag group=\"0062\" element=\"000D\" keyword=\"RecommendedDisplayCIELabValue\" vr=\"US\" vm=\"3\">Recommended Display CIELab Value</tag>
    <tag group=\"0062\" element=\"000E\" keyword=\"MaximumFractionalValue\" vr=\"US\" vm=\"1\">Maximum Fractional Value</tag>
    <tag group=\"0062\" element=\"000F\" keyword=\"SegmentedPropertyTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Segmented Property Type Code Sequence</tag>
    <tag group=\"0062\" element=\"0010\" keyword=\"SegmentationFractionalType\" vr=\"CS\" vm=\"1\">Segmentation Fractional Type</tag>
    <tag group=\"0062\" element=\"0011\" keyword=\"SegmentedPropertyTypeModifierCodeSequence\" vr=\"SQ\" vm=\"1\">Segmented Property Type Modifier Code Sequence</tag>
    <tag group=\"0062\" element=\"0012\" keyword=\"UsedSegmentsSequence\" vr=\"SQ\" vm=\"1\">Used Segments Sequence</tag>
    <tag group=\"0062\" element=\"0020\" keyword=\"TrackingID\" vr=\"UT\" vm=\"1\">Tracking ID</tag>
    <tag group=\"0062\" element=\"0021\" keyword=\"TrackingUID\" vr=\"UI\" vm=\"1\">Tracking UID</tag>
    <tag group=\"0064\" element=\"0002\" keyword=\"DeformableRegistrationSequence\" vr=\"SQ\" vm=\"1\">Deformable Registration Sequence</tag>
    <tag group=\"0064\" element=\"0003\" keyword=\"SourceFrameOfReferenceUID\" vr=\"UI\" vm=\"1\">Source Frame of Reference UID</tag>
    <tag group=\"0064\" element=\"0005\" keyword=\"DeformableRegistrationGridSequence\" vr=\"SQ\" vm=\"1\">Deformable Registration Grid Sequence</tag>
    <tag group=\"0064\" element=\"0007\" keyword=\"GridDimensions\" vr=\"UL\" vm=\"3\">Grid Dimensions</tag>
    <tag group=\"0064\" element=\"0008\" keyword=\"GridResolution\" vr=\"FD\" vm=\"3\">Grid Resolution</tag>
    <tag group=\"0064\" element=\"0009\" keyword=\"VectorGridData\" vr=\"OF\" vm=\"1\">Vector Grid Data</tag>
    <tag group=\"0064\" element=\"000F\" keyword=\"PreDeformationMatrixRegistrationSequence\" vr=\"SQ\" vm=\"1\">Pre Deformation Matrix Registration Sequence</tag>
    <tag group=\"0064\" element=\"0010\" keyword=\"PostDeformationMatrixRegistrationSequence\" vr=\"SQ\" vm=\"1\">Post Deformation Matrix Registration Sequence</tag>
    <tag group=\"0066\" element=\"0001\" keyword=\"NumberOfSurfaces\" vr=\"UL\" vm=\"1\">Number of Surfaces</tag>
    <tag group=\"0066\" element=\"0002\" keyword=\"SurfaceSequence\" vr=\"SQ\" vm=\"1\">Surface Sequence</tag>
    <tag group=\"0066\" element=\"0003\" keyword=\"SurfaceNumber\" vr=\"UL\" vm=\"1\">Surface Number</tag>
    <tag group=\"0066\" element=\"0004\" keyword=\"SurfaceComments\" vr=\"LT\" vm=\"1\">Surface Comments</tag>
    <tag group=\"0066\" element=\"0009\" keyword=\"SurfaceProcessing\" vr=\"CS\" vm=\"1\">Surface Processing</tag>
    <tag group=\"0066\" element=\"000A\" keyword=\"SurfaceProcessingRatio\" vr=\"FL\" vm=\"1\">Surface Processing Ratio</tag>
    <tag group=\"0066\" element=\"000B\" keyword=\"SurfaceProcessingDescription\" vr=\"LO\" vm=\"1\">Surface Processing Description</tag>
    <tag group=\"0066\" element=\"000C\" keyword=\"RecommendedPresentationOpacity\" vr=\"FL\" vm=\"1\">Recommended Presentation Opacity</tag>
    <tag group=\"0066\" element=\"000D\" keyword=\"RecommendedPresentationType\" vr=\"CS\" vm=\"1\">Recommended Presentation Type</tag>
    <tag group=\"0066\" element=\"000E\" keyword=\"FiniteVolume\" vr=\"CS\" vm=\"1\">Finite Volume</tag>
    <tag group=\"0066\" element=\"0010\" keyword=\"Manifold\" vr=\"CS\" vm=\"1\">Manifold</tag>
    <tag group=\"0066\" element=\"0011\" keyword=\"SurfacePointsSequence\" vr=\"SQ\" vm=\"1\">Surface Points Sequence</tag>
    <tag group=\"0066\" element=\"0012\" keyword=\"SurfacePointsNormalsSequence\" vr=\"SQ\" vm=\"1\">Surface Points Normals Sequence</tag>
    <tag group=\"0066\" element=\"0013\" keyword=\"SurfaceMeshPrimitivesSequence\" vr=\"SQ\" vm=\"1\">Surface Mesh Primitives Sequence</tag>
    <tag group=\"0066\" element=\"0015\" keyword=\"NumberOfSurfacePoints\" vr=\"UL\" vm=\"1\">Number of Surface Points</tag>
    <tag group=\"0066\" element=\"0016\" keyword=\"PointCoordinatesData\" vr=\"OF\" vm=\"1\">Point Coordinates Data</tag>
    <tag group=\"0066\" element=\"0017\" keyword=\"PointPositionAccuracy\" vr=\"FL\" vm=\"3\">Point Position Accuracy</tag>
    <tag group=\"0066\" element=\"0018\" keyword=\"MeanPointDistance\" vr=\"FL\" vm=\"1\">Mean Point Distance</tag>
    <tag group=\"0066\" element=\"0019\" keyword=\"MaximumPointDistance\" vr=\"FL\" vm=\"1\">Maximum Point Distance</tag>
    <tag group=\"0066\" element=\"001A\" keyword=\"PointsBoundingBoxCoordinates\" vr=\"FL\" vm=\"6\">Points Bounding Box Coordinates</tag>
    <tag group=\"0066\" element=\"001B\" keyword=\"AxisOfRotation\" vr=\"FL\" vm=\"3\">Axis of Rotation</tag>
    <tag group=\"0066\" element=\"001C\" keyword=\"CenterOfRotation\" vr=\"FL\" vm=\"3\">Center of Rotation</tag>
    <tag group=\"0066\" element=\"001E\" keyword=\"NumberOfVectors\" vr=\"UL\" vm=\"1\">Number of Vectors</tag>
    <tag group=\"0066\" element=\"001F\" keyword=\"VectorDimensionality\" vr=\"US\" vm=\"1\">Vector Dimensionality</tag>
    <tag group=\"0066\" element=\"0020\" keyword=\"VectorAccuracy\" vr=\"FL\" vm=\"1-n\">Vector Accuracy</tag>
    <tag group=\"0066\" element=\"0021\" keyword=\"VectorCoordinateData\" vr=\"OF\" vm=\"1\">Vector Coordinate Data</tag>
    <tag group=\"0066\" element=\"0023\" keyword=\"TrianglePointIndexList\" vr=\"OW\" vm=\"1\" retired=\"true\">Triangle Point Index List</tag>
    <tag group=\"0066\" element=\"0024\" keyword=\"EdgePointIndexList\" vr=\"OW\" vm=\"1\" retired=\"true\">Edge Point Index List</tag>
    <tag group=\"0066\" element=\"0025\" keyword=\"VertexPointIndexList\" vr=\"OW\" vm=\"1\" retired=\"true\">Vertex Point Index List</tag>
    <tag group=\"0066\" element=\"0026\" keyword=\"TriangleStripSequence\" vr=\"SQ\" vm=\"1\">Triangle Strip Sequence</tag>
    <tag group=\"0066\" element=\"0027\" keyword=\"TriangleFanSequence\" vr=\"SQ\" vm=\"1\">Triangle Fan Sequence</tag>
    <tag group=\"0066\" element=\"0028\" keyword=\"LineSequence\" vr=\"SQ\" vm=\"1\">Line Sequence</tag>
    <tag group=\"0066\" element=\"0029\" keyword=\"PrimitivePointIndexList\" vr=\"OW\" vm=\"1\" retired=\"true\">Primitive Point Index List</tag>
    <tag group=\"0066\" element=\"002A\" keyword=\"SurfaceCount\" vr=\"UL\" vm=\"1\">Surface Count</tag>
    <tag group=\"0066\" element=\"002B\" keyword=\"ReferencedSurfaceSequence\" vr=\"SQ\" vm=\"1\">Referenced Surface Sequence</tag>
    <tag group=\"0066\" element=\"002C\" keyword=\"ReferencedSurfaceNumber\" vr=\"UL\" vm=\"1\">Referenced Surface Number</tag>
    <tag group=\"0066\" element=\"002D\" keyword=\"SegmentSurfaceGenerationAlgorithmIdentificationSequence\" vr=\"SQ\" vm=\"1\">Segment Surface Generation Algorithm Identification Sequence</tag>
    <tag group=\"0066\" element=\"002E\" keyword=\"SegmentSurfaceSourceInstanceSequence\" vr=\"SQ\" vm=\"1\">Segment Surface Source Instance Sequence</tag>
    <tag group=\"0066\" element=\"002F\" keyword=\"AlgorithmFamilyCodeSequence\" vr=\"SQ\" vm=\"1\">Algorithm Family Code Sequence</tag>
    <tag group=\"0066\" element=\"0030\" keyword=\"AlgorithmNameCodeSequence\" vr=\"SQ\" vm=\"1\">Algorithm Name Code Sequence</tag>
    <tag group=\"0066\" element=\"0031\" keyword=\"AlgorithmVersion\" vr=\"LO\" vm=\"1\">Algorithm Version</tag>
    <tag group=\"0066\" element=\"0032\" keyword=\"AlgorithmParameters\" vr=\"LT\" vm=\"1\">Algorithm Parameters</tag>
    <tag group=\"0066\" element=\"0034\" keyword=\"FacetSequence\" vr=\"SQ\" vm=\"1\">Facet Sequence</tag>
    <tag group=\"0066\" element=\"0035\" keyword=\"SurfaceProcessingAlgorithmIdentificationSequence\" vr=\"SQ\" vm=\"1\">Surface Processing Algorithm Identification Sequence</tag>
    <tag group=\"0066\" element=\"0036\" keyword=\"AlgorithmName\" vr=\"LO\" vm=\"1\">Algorithm Name</tag>
    <tag group=\"0066\" element=\"0037\" keyword=\"RecommendedPointRadius\" vr=\"FL\" vm=\"1\">Recommended Point Radius</tag>
    <tag group=\"0066\" element=\"0038\" keyword=\"RecommendedLineThickness\" vr=\"FL\" vm=\"1\">Recommended Line Thickness</tag>
    <tag group=\"0066\" element=\"0040\" keyword=\"LongPrimitivePointIndexList\" vr=\"OL\" vm=\"1\">Long Primitive Point Index List</tag>
    <tag group=\"0066\" element=\"0041\" keyword=\"LongTrianglePointIndexList\" vr=\"OL\" vm=\"1\">Long Triangle Point Index List</tag>
    <tag group=\"0066\" element=\"0042\" keyword=\"LongEdgePointIndexList\" vr=\"OL\" vm=\"1\">Long Edge Point Index List</tag>
    <tag group=\"0066\" element=\"0043\" keyword=\"LongVertexPointIndexList\" vr=\"OL\" vm=\"1\">Long Vertex Point Index List</tag>
    <tag group=\"0066\" element=\"0101\" keyword=\"TrackSetSequence\" vr=\"SQ\" vm=\"1\">Track Set Sequence</tag>
    <tag group=\"0066\" element=\"0102\" keyword=\"TrackSequence\" vr=\"SQ\" vm=\"1\">Track Sequence</tag>
    <tag group=\"0066\" element=\"0103\" keyword=\"RecommendedDisplayCIELabValueList\" vr=\"OW\" vm=\"1\">Recommended Display CIELab Value List</tag>
    <tag group=\"0066\" element=\"0104\" keyword=\"TrackingAlgorithmIdentificationSequence\" vr=\"SQ\" vm=\"1\">Tracking Algorithm Identification Sequence</tag>
    <tag group=\"0066\" element=\"0105\" keyword=\"TrackSetNumber\" vr=\"UL\" vm=\"1\">Track Set Number</tag>
    <tag group=\"0066\" element=\"0106\" keyword=\"TrackSetLabel\" vr=\"LO\" vm=\"1\">Track Set Label</tag>
    <tag group=\"0066\" element=\"0107\" keyword=\"TrackSetDescription\" vr=\"UT\" vm=\"1\">Track Set Description</tag>
    <tag group=\"0066\" element=\"0108\" keyword=\"TrackSetAnatomicalTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Track Set Anatomical Type Code Sequence</tag>
    <tag group=\"0066\" element=\"0121\" keyword=\"MeasurementsSequence\" vr=\"SQ\" vm=\"1\">Measurements Sequence</tag>
    <tag group=\"0066\" element=\"0124\" keyword=\"TrackSetStatisticsSequence\" vr=\"SQ\" vm=\"1\">Track Set Statistics Sequence</tag>
    <tag group=\"0066\" element=\"0125\" keyword=\"FloatingPointValues\" vr=\"OF\" vm=\"1\">Floating Point Values</tag>
    <tag group=\"0066\" element=\"0129\" keyword=\"TrackPointIndexList\" vr=\"OL\" vm=\"1\">Track Point Index List</tag>
    <tag group=\"0066\" element=\"0130\" keyword=\"TrackStatisticsSequence\" vr=\"SQ\" vm=\"1\">Track Statistics Sequence</tag>
    <tag group=\"0066\" element=\"0132\" keyword=\"MeasurementValuesSequence\" vr=\"SQ\" vm=\"1\">Measurement Values Sequence</tag>
    <tag group=\"0066\" element=\"0133\" keyword=\"DiffusionAcquisitionCodeSequence\" vr=\"SQ\" vm=\"1\">Diffusion Acquisition Code Sequence</tag>
    <tag group=\"0066\" element=\"0134\" keyword=\"DiffusionModelCodeSequence\" vr=\"SQ\" vm=\"1\">Diffusion Model Code Sequence</tag>
    <tag group=\"0068\" element=\"6210\" keyword=\"ImplantSize\" vr=\"LO\" vm=\"1\">Implant Size</tag>
    <tag group=\"0068\" element=\"6221\" keyword=\"ImplantTemplateVersion\" vr=\"LO\" vm=\"1\">Implant Template Version</tag>
    <tag group=\"0068\" element=\"6222\" keyword=\"ReplacedImplantTemplateSequence\" vr=\"SQ\" vm=\"1\">Replaced Implant Template Sequence</tag>
    <tag group=\"0068\" element=\"6223\" keyword=\"ImplantType\" vr=\"CS\" vm=\"1\">Implant Type</tag>
    <tag group=\"0068\" element=\"6224\" keyword=\"DerivationImplantTemplateSequence\" vr=\"SQ\" vm=\"1\">Derivation Implant Template Sequence</tag>
    <tag group=\"0068\" element=\"6225\" keyword=\"OriginalImplantTemplateSequence\" vr=\"SQ\" vm=\"1\">Original Implant Template Sequence</tag>
    <tag group=\"0068\" element=\"6226\" keyword=\"EffectiveDateTime\" vr=\"DT\" vm=\"1\">Effective DateTime</tag>
    <tag group=\"0068\" element=\"6230\" keyword=\"ImplantTargetAnatomySequence\" vr=\"SQ\" vm=\"1\">Implant Target Anatomy Sequence</tag>
    <tag group=\"0068\" element=\"6260\" keyword=\"InformationFromManufacturerSequence\" vr=\"SQ\" vm=\"1\">Information From Manufacturer Sequence</tag>
    <tag group=\"0068\" element=\"6265\" keyword=\"NotificationFromManufacturerSequence\" vr=\"SQ\" vm=\"1\">Notification From Manufacturer Sequence</tag>
    <tag group=\"0068\" element=\"6270\" keyword=\"InformationIssueDateTime\" vr=\"DT\" vm=\"1\">Information Issue DateTime</tag>
    <tag group=\"0068\" element=\"6280\" keyword=\"InformationSummary\" vr=\"ST\" vm=\"1\">Information Summary</tag>
    <tag group=\"0068\" element=\"62A0\" keyword=\"ImplantRegulatoryDisapprovalCodeSequence\" vr=\"SQ\" vm=\"1\">Implant Regulatory Disapproval Code Sequence</tag>
    <tag group=\"0068\" element=\"62A5\" keyword=\"OverallTemplateSpatialTolerance\" vr=\"FD\" vm=\"1\">Overall Template Spatial Tolerance</tag>
    <tag group=\"0068\" element=\"62C0\" keyword=\"HPGLDocumentSequence\" vr=\"SQ\" vm=\"1\">HPGL Document Sequence</tag>
    <tag group=\"0068\" element=\"62D0\" keyword=\"HPGLDocumentID\" vr=\"US\" vm=\"1\">HPGL Document ID</tag>
    <tag group=\"0068\" element=\"62D5\" keyword=\"HPGLDocumentLabel\" vr=\"LO\" vm=\"1\">HPGL Document Label</tag>
    <tag group=\"0068\" element=\"62E0\" keyword=\"ViewOrientationCodeSequence\" vr=\"SQ\" vm=\"1\">View Orientation Code Sequence</tag>
    <tag group=\"0068\" element=\"62F0\" keyword=\"ViewOrientationModifierCodeSequence\" vr=\"SQ\" vm=\"1\">View Orientation Modifier Code Sequence</tag>
    <tag group=\"0068\" element=\"62F2\" keyword=\"HPGLDocumentScaling\" vr=\"FD\" vm=\"1\">HPGL Document Scaling</tag>
    <tag group=\"0068\" element=\"6300\" keyword=\"HPGLDocument\" vr=\"OB\" vm=\"1\">HPGL Document</tag>
    <tag group=\"0068\" element=\"6310\" keyword=\"HPGLContourPenNumber\" vr=\"US\" vm=\"1\">HPGL Contour Pen Number</tag>
    <tag group=\"0068\" element=\"6320\" keyword=\"HPGLPenSequence\" vr=\"SQ\" vm=\"1\">HPGL Pen Sequence</tag>
    <tag group=\"0068\" element=\"6330\" keyword=\"HPGLPenNumber\" vr=\"US\" vm=\"1\">HPGL Pen Number</tag>
    <tag group=\"0068\" element=\"6340\" keyword=\"HPGLPenLabel\" vr=\"LO\" vm=\"1\">HPGL Pen Label</tag>
    <tag group=\"0068\" element=\"6345\" keyword=\"HPGLPenDescription\" vr=\"ST\" vm=\"1\">HPGL Pen Description</tag>
    <tag group=\"0068\" element=\"6346\" keyword=\"RecommendedRotationPoint\" vr=\"FD\" vm=\"2\">Recommended Rotation Point</tag>
    <tag group=\"0068\" element=\"6347\" keyword=\"BoundingRectangle\" vr=\"FD\" vm=\"4\">Bounding Rectangle</tag>
    <tag group=\"0068\" element=\"6350\" keyword=\"ImplantTemplate3DModelSurfaceNumber\" vr=\"US\" vm=\"1-n\">Implant Template 3D Model Surface Number</tag>
    <tag group=\"0068\" element=\"6360\" keyword=\"SurfaceModelDescriptionSequence\" vr=\"SQ\" vm=\"1\">Surface Model Description Sequence</tag>
    <tag group=\"0068\" element=\"6380\" keyword=\"SurfaceModelLabel\" vr=\"LO\" vm=\"1\">Surface Model Label</tag>
    <tag group=\"0068\" element=\"6390\" keyword=\"SurfaceModelScalingFactor\" vr=\"FD\" vm=\"1\">Surface Model Scaling Factor</tag>
    <tag group=\"0068\" element=\"63A0\" keyword=\"MaterialsCodeSequence\" vr=\"SQ\" vm=\"1\">Materials Code Sequence</tag>
    <tag group=\"0068\" element=\"63A4\" keyword=\"CoatingMaterialsCodeSequence\" vr=\"SQ\" vm=\"1\">Coating Materials Code Sequence</tag>
    <tag group=\"0068\" element=\"63A8\" keyword=\"ImplantTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Implant Type Code Sequence</tag>
    <tag group=\"0068\" element=\"63AC\" keyword=\"FixationMethodCodeSequence\" vr=\"SQ\" vm=\"1\">Fixation Method Code Sequence</tag>
    <tag group=\"0068\" element=\"63B0\" keyword=\"MatingFeatureSetsSequence\" vr=\"SQ\" vm=\"1\">Mating Feature Sets Sequence</tag>
    <tag group=\"0068\" element=\"63C0\" keyword=\"MatingFeatureSetID\" vr=\"US\" vm=\"1\">Mating Feature Set ID</tag>
    <tag group=\"0068\" element=\"63D0\" keyword=\"MatingFeatureSetLabel\" vr=\"LO\" vm=\"1\">Mating Feature Set Label</tag>
    <tag group=\"0068\" element=\"63E0\" keyword=\"MatingFeatureSequence\" vr=\"SQ\" vm=\"1\">Mating Feature Sequence</tag>
    <tag group=\"0068\" element=\"63F0\" keyword=\"MatingFeatureID\" vr=\"US\" vm=\"1\">Mating Feature ID</tag>
    <tag group=\"0068\" element=\"6400\" keyword=\"MatingFeatureDegreeOfFreedomSequence\" vr=\"SQ\" vm=\"1\">Mating Feature Degree of Freedom Sequence</tag>
    <tag group=\"0068\" element=\"6410\" keyword=\"DegreeOfFreedomID\" vr=\"US\" vm=\"1\">Degree of Freedom ID</tag>
    <tag group=\"0068\" element=\"6420\" keyword=\"DegreeOfFreedomType\" vr=\"CS\" vm=\"1\">Degree of Freedom Type</tag>
    <tag group=\"0068\" element=\"6430\" keyword=\"TwoDMatingFeatureCoordinatesSequence\" vr=\"SQ\" vm=\"1\">2D Mating Feature Coordinates Sequence</tag>
    <tag group=\"0068\" element=\"6440\" keyword=\"ReferencedHPGLDocumentID\" vr=\"US\" vm=\"1\">Referenced HPGL Document ID</tag>
    <tag group=\"0068\" element=\"6450\" keyword=\"TwoDMatingPoint\" vr=\"FD\" vm=\"2\">2D Mating Point</tag>
    <tag group=\"0068\" element=\"6460\" keyword=\"TwoDMatingAxes\" vr=\"FD\" vm=\"4\">2D Mating Axes</tag>
    <tag group=\"0068\" element=\"6470\" keyword=\"TwoDDegreeOfFreedomSequence\" vr=\"SQ\" vm=\"1\">2D Degree of Freedom Sequence</tag>
    <tag group=\"0068\" element=\"6490\" keyword=\"ThreeDDegreeOfFreedomAxis\" vr=\"FD\" vm=\"3\">3D Degree of Freedom Axis</tag>
    <tag group=\"0068\" element=\"64A0\" keyword=\"RangeOfFreedom\" vr=\"FD\" vm=\"2\">Range of Freedom</tag>
    <tag group=\"0068\" element=\"64C0\" keyword=\"ThreeDMatingPoint\" vr=\"FD\" vm=\"3\">3D Mating Point</tag>
    <tag group=\"0068\" element=\"64D0\" keyword=\"ThreeDMatingAxes\" vr=\"FD\" vm=\"9\">3D Mating Axes</tag>
    <tag group=\"0068\" element=\"64F0\" keyword=\"TwoDDegreeOfFreedomAxis\" vr=\"FD\" vm=\"3\">2D Degree of Freedom Axis</tag>
    <tag group=\"0068\" element=\"6500\" keyword=\"PlanningLandmarkPointSequence\" vr=\"SQ\" vm=\"1\">Planning Landmark Point Sequence</tag>
    <tag group=\"0068\" element=\"6510\" keyword=\"PlanningLandmarkLineSequence\" vr=\"SQ\" vm=\"1\">Planning Landmark Line Sequence</tag>
    <tag group=\"0068\" element=\"6520\" keyword=\"PlanningLandmarkPlaneSequence\" vr=\"SQ\" vm=\"1\">Planning Landmark Plane Sequence</tag>
    <tag group=\"0068\" element=\"6530\" keyword=\"PlanningLandmarkID\" vr=\"US\" vm=\"1\">Planning Landmark ID</tag>
    <tag group=\"0068\" element=\"6540\" keyword=\"PlanningLandmarkDescription\" vr=\"LO\" vm=\"1\">Planning Landmark Description</tag>
    <tag group=\"0068\" element=\"6545\" keyword=\"PlanningLandmarkIdentificationCodeSequence\" vr=\"SQ\" vm=\"1\">Planning Landmark Identification Code Sequence</tag>
    <tag group=\"0068\" element=\"6550\" keyword=\"TwoDPointCoordinatesSequence\" vr=\"SQ\" vm=\"1\">2D Point Coordinates Sequence</tag>
    <tag group=\"0068\" element=\"6560\" keyword=\"TwoDPointCoordinates\" vr=\"FD\" vm=\"2\">2D Point Coordinates</tag>
    <tag group=\"0068\" element=\"6590\" keyword=\"ThreeDPointCoordinates\" vr=\"FD\" vm=\"3\">3D Point Coordinates</tag>
    <tag group=\"0068\" element=\"65A0\" keyword=\"TwoDLineCoordinatesSequence\" vr=\"SQ\" vm=\"1\">2D Line Coordinates Sequence</tag>
    <tag group=\"0068\" element=\"65B0\" keyword=\"TwoDLineCoordinates\" vr=\"FD\" vm=\"4\">2D Line Coordinates</tag>
    <tag group=\"0068\" element=\"65D0\" keyword=\"ThreeDLineCoordinates\" vr=\"FD\" vm=\"6\">3D Line Coordinates</tag>
    <tag group=\"0068\" element=\"65E0\" keyword=\"TwoDPlaneCoordinatesSequence\" vr=\"SQ\" vm=\"1\">2D Plane Coordinates Sequence</tag>
    <tag group=\"0068\" element=\"65F0\" keyword=\"TwoDPlaneIntersection\" vr=\"FD\" vm=\"4\">2D Plane Intersection</tag>
    <tag group=\"0068\" element=\"6610\" keyword=\"ThreeDPlaneOrigin\" vr=\"FD\" vm=\"3\">3D Plane Origin</tag>
    <tag group=\"0068\" element=\"6620\" keyword=\"ThreeDPlaneNormal\" vr=\"FD\" vm=\"3\">3D Plane Normal</tag>
    <tag group=\"0070\" element=\"0001\" keyword=\"GraphicAnnotationSequence\" vr=\"SQ\" vm=\"1\">Graphic Annotation Sequence</tag>
    <tag group=\"0070\" element=\"0002\" keyword=\"GraphicLayer\" vr=\"CS\" vm=\"1\">Graphic Layer</tag>
    <tag group=\"0070\" element=\"0003\" keyword=\"BoundingBoxAnnotationUnits\" vr=\"CS\" vm=\"1\">Bounding Box Annotation Units</tag>
    <tag group=\"0070\" element=\"0004\" keyword=\"AnchorPointAnnotationUnits\" vr=\"CS\" vm=\"1\">Anchor Point Annotation Units</tag>
    <tag group=\"0070\" element=\"0005\" keyword=\"GraphicAnnotationUnits\" vr=\"CS\" vm=\"1\">Graphic Annotation Units</tag>
    <tag group=\"0070\" element=\"0006\" keyword=\"UnformattedTextValue\" vr=\"ST\" vm=\"1\">Unformatted Text Value</tag>
    <tag group=\"0070\" element=\"0008\" keyword=\"TextObjectSequence\" vr=\"SQ\" vm=\"1\">Text Object Sequence</tag>
    <tag group=\"0070\" element=\"0009\" keyword=\"GraphicObjectSequence\" vr=\"SQ\" vm=\"1\">Graphic Object Sequence</tag>
    <tag group=\"0070\" element=\"0010\" keyword=\"BoundingBoxTopLeftHandCorner\" vr=\"FL\" vm=\"2\">Bounding Box Top Left Hand Corner</tag>
    <tag group=\"0070\" element=\"0011\" keyword=\"BoundingBoxBottomRightHandCorner\" vr=\"FL\" vm=\"2\">Bounding Box Bottom Right Hand Corner</tag>
    <tag group=\"0070\" element=\"0012\" keyword=\"BoundingBoxTextHorizontalJustification\" vr=\"CS\" vm=\"1\">Bounding Box Text Horizontal Justification</tag>
    <tag group=\"0070\" element=\"0014\" keyword=\"AnchorPoint\" vr=\"FL\" vm=\"2\">Anchor Point</tag>
    <tag group=\"0070\" element=\"0015\" keyword=\"AnchorPointVisibility\" vr=\"CS\" vm=\"1\">Anchor Point Visibility</tag>
    <tag group=\"0070\" element=\"0020\" keyword=\"GraphicDimensions\" vr=\"US\" vm=\"1\">Graphic Dimensions</tag>
    <tag group=\"0070\" element=\"0021\" keyword=\"NumberOfGraphicPoints\" vr=\"US\" vm=\"1\">Number of Graphic Points</tag>
    <tag group=\"0070\" element=\"0022\" keyword=\"GraphicData\" vr=\"FL\" vm=\"2-n\">Graphic Data</tag>
    <tag group=\"0070\" element=\"0023\" keyword=\"GraphicType\" vr=\"CS\" vm=\"1\">Graphic Type</tag>
    <tag group=\"0070\" element=\"0024\" keyword=\"GraphicFilled\" vr=\"CS\" vm=\"1\">Graphic Filled</tag>
    <tag group=\"0070\" element=\"0040\" keyword=\"ImageRotationRetired\" vr=\"IS\" vm=\"1\" retired=\"true\">Image Rotation (Retired)</tag>
    <tag group=\"0070\" element=\"0041\" keyword=\"ImageHorizontalFlip\" vr=\"CS\" vm=\"1\">Image Horizontal Flip</tag>
    <tag group=\"0070\" element=\"0042\" keyword=\"ImageRotation\" vr=\"US\" vm=\"1\">Image Rotation</tag>
    <tag group=\"0070\" element=\"0050\" keyword=\"DisplayedAreaTopLeftHandCornerTrial\" vr=\"US\" vm=\"2\" retired=\"true\">Displayed Area Top Left Hand Corner (Trial)</tag>
    <tag group=\"0070\" element=\"0051\" keyword=\"DisplayedAreaBottomRightHandCornerTrial\" vr=\"US\" vm=\"2\" retired=\"true\">Displayed Area Bottom Right Hand Corner (Trial)</tag>
    <tag group=\"0070\" element=\"0052\" keyword=\"DisplayedAreaTopLeftHandCorner\" vr=\"SL\" vm=\"2\">Displayed Area Top Left Hand Corner</tag>
    <tag group=\"0070\" element=\"0053\" keyword=\"DisplayedAreaBottomRightHandCorner\" vr=\"SL\" vm=\"2\">Displayed Area Bottom Right Hand Corner</tag>
    <tag group=\"0070\" element=\"005A\" keyword=\"DisplayedAreaSelectionSequence\" vr=\"SQ\" vm=\"1\">Displayed Area Selection Sequence</tag>
    <tag group=\"0070\" element=\"0060\" keyword=\"GraphicLayerSequence\" vr=\"SQ\" vm=\"1\">Graphic Layer Sequence</tag>
    <tag group=\"0070\" element=\"0062\" keyword=\"GraphicLayerOrder\" vr=\"IS\" vm=\"1\">Graphic Layer Order</tag>
    <tag group=\"0070\" element=\"0066\" keyword=\"GraphicLayerRecommendedDisplayGrayscaleValue\" vr=\"US\" vm=\"1\">Graphic Layer Recommended Display Grayscale Value</tag>
    <tag group=\"0070\" element=\"0067\" keyword=\"GraphicLayerRecommendedDisplayRGBValue\" vr=\"US\" vm=\"3\" retired=\"true\">Graphic Layer Recommended Display RGB Value</tag>
    <tag group=\"0070\" element=\"0068\" keyword=\"GraphicLayerDescription\" vr=\"LO\" vm=\"1\">Graphic Layer Description</tag>
    <tag group=\"0070\" element=\"0080\" keyword=\"ContentLabel\" vr=\"CS\" vm=\"1\">Content Label</tag>
    <tag group=\"0070\" element=\"0081\" keyword=\"ContentDescription\" vr=\"LO\" vm=\"1\">Content Description</tag>
    <tag group=\"0070\" element=\"0082\" keyword=\"PresentationCreationDate\" vr=\"DA\" vm=\"1\">Presentation Creation Date</tag>
    <tag group=\"0070\" element=\"0083\" keyword=\"PresentationCreationTime\" vr=\"TM\" vm=\"1\">Presentation Creation Time</tag>
    <tag group=\"0070\" element=\"0084\" keyword=\"ContentCreatorName\" vr=\"PN\" vm=\"1\">Content Creator's Name</tag>
    <tag group=\"0070\" element=\"0086\" keyword=\"ContentCreatorIdentificationCodeSequence\" vr=\"SQ\" vm=\"1\">Content Creator's Identification Code Sequence</tag>
    <tag group=\"0070\" element=\"0087\" keyword=\"AlternateContentDescriptionSequence\" vr=\"SQ\" vm=\"1\">Alternate Content Description Sequence</tag>
    <tag group=\"0070\" element=\"0100\" keyword=\"PresentationSizeMode\" vr=\"CS\" vm=\"1\">Presentation Size Mode</tag>
    <tag group=\"0070\" element=\"0101\" keyword=\"PresentationPixelSpacing\" vr=\"DS\" vm=\"2\">Presentation Pixel Spacing</tag>
    <tag group=\"0070\" element=\"0102\" keyword=\"PresentationPixelAspectRatio\" vr=\"IS\" vm=\"2\">Presentation Pixel Aspect Ratio</tag>
    <tag group=\"0070\" element=\"0103\" keyword=\"PresentationPixelMagnificationRatio\" vr=\"FL\" vm=\"1\">Presentation Pixel Magnification Ratio</tag>
    <tag group=\"0070\" element=\"0207\" keyword=\"GraphicGroupLabel\" vr=\"LO\" vm=\"1\">Graphic Group Label</tag>
    <tag group=\"0070\" element=\"0208\" keyword=\"GraphicGroupDescription\" vr=\"ST\" vm=\"1\">Graphic Group Description</tag>
    <tag group=\"0070\" element=\"0209\" keyword=\"CompoundGraphicSequence\" vr=\"SQ\" vm=\"1\">Compound Graphic Sequence</tag>
    <tag group=\"0070\" element=\"0226\" keyword=\"CompoundGraphicInstanceID\" vr=\"UL\" vm=\"1\">Compound Graphic Instance ID</tag>
    <tag group=\"0070\" element=\"0227\" keyword=\"FontName\" vr=\"LO\" vm=\"1\">Font Name</tag>
    <tag group=\"0070\" element=\"0228\" keyword=\"FontNameType\" vr=\"CS\" vm=\"1\">Font Name Type</tag>
    <tag group=\"0070\" element=\"0229\" keyword=\"CSSFontName\" vr=\"LO\" vm=\"1\">CSS Font Name</tag>
    <tag group=\"0070\" element=\"0230\" keyword=\"RotationAngle\" vr=\"FD\" vm=\"1\">Rotation Angle</tag>
    <tag group=\"0070\" element=\"0231\" keyword=\"TextStyleSequence\" vr=\"SQ\" vm=\"1\">Text Style Sequence</tag>
    <tag group=\"0070\" element=\"0232\" keyword=\"LineStyleSequence\" vr=\"SQ\" vm=\"1\">Line Style Sequence</tag>
    <tag group=\"0070\" element=\"0233\" keyword=\"FillStyleSequence\" vr=\"SQ\" vm=\"1\">Fill Style Sequence</tag>
    <tag group=\"0070\" element=\"0234\" keyword=\"GraphicGroupSequence\" vr=\"SQ\" vm=\"1\">Graphic Group Sequence</tag>
    <tag group=\"0070\" element=\"0241\" keyword=\"TextColorCIELabValue\" vr=\"US\" vm=\"3\">Text Color CIELab Value</tag>
    <tag group=\"0070\" element=\"0242\" keyword=\"HorizontalAlignment\" vr=\"CS\" vm=\"1\">Horizontal Alignment</tag>
    <tag group=\"0070\" element=\"0243\" keyword=\"VerticalAlignment\" vr=\"CS\" vm=\"1\">Vertical Alignment</tag>
    <tag group=\"0070\" element=\"0244\" keyword=\"ShadowStyle\" vr=\"CS\" vm=\"1\">Shadow Style</tag>
    <tag group=\"0070\" element=\"0245\" keyword=\"ShadowOffsetX\" vr=\"FL\" vm=\"1\">Shadow Offset X</tag>
    <tag group=\"0070\" element=\"0246\" keyword=\"ShadowOffsetY\" vr=\"FL\" vm=\"1\">Shadow Offset Y</tag>
    <tag group=\"0070\" element=\"0247\" keyword=\"ShadowColorCIELabValue\" vr=\"US\" vm=\"3\">Shadow Color CIELab Value</tag>
    <tag group=\"0070\" element=\"0248\" keyword=\"Underlined\" vr=\"CS\" vm=\"1\">Underlined</tag>
    <tag group=\"0070\" element=\"0249\" keyword=\"Bold\" vr=\"CS\" vm=\"1\">Bold</tag>
    <tag group=\"0070\" element=\"0250\" keyword=\"Italic\" vr=\"CS\" vm=\"1\">Italic</tag>
    <tag group=\"0070\" element=\"0251\" keyword=\"PatternOnColorCIELabValue\" vr=\"US\" vm=\"3\">Pattern On Color CIELab Value</tag>
    <tag group=\"0070\" element=\"0252\" keyword=\"PatternOffColorCIELabValue\" vr=\"US\" vm=\"3\">Pattern Off Color CIELab Value</tag>
    <tag group=\"0070\" element=\"0253\" keyword=\"LineThickness\" vr=\"FL\" vm=\"1\">Line Thickness</tag>
    <tag group=\"0070\" element=\"0254\" keyword=\"LineDashingStyle\" vr=\"CS\" vm=\"1\">Line Dashing Style</tag>
    <tag group=\"0070\" element=\"0255\" keyword=\"LinePattern\" vr=\"UL\" vm=\"1\">Line Pattern</tag>
    <tag group=\"0070\" element=\"0256\" keyword=\"FillPattern\" vr=\"OB\" vm=\"1\">Fill Pattern</tag>
    <tag group=\"0070\" element=\"0257\" keyword=\"FillMode\" vr=\"CS\" vm=\"1\">Fill Mode</tag>
    <tag group=\"0070\" element=\"0258\" keyword=\"ShadowOpacity\" vr=\"FL\" vm=\"1\">Shadow Opacity</tag>
    <tag group=\"0070\" element=\"0261\" keyword=\"GapLength\" vr=\"FL\" vm=\"1\">Gap Length</tag>
    <tag group=\"0070\" element=\"0262\" keyword=\"DiameterOfVisibility\" vr=\"FL\" vm=\"1\">Diameter of Visibility</tag>
    <tag group=\"0070\" element=\"0273\" keyword=\"RotationPoint\" vr=\"FL\" vm=\"2\">Rotation Point</tag>
    <tag group=\"0070\" element=\"0274\" keyword=\"TickAlignment\" vr=\"CS\" vm=\"1\">Tick Alignment</tag>
    <tag group=\"0070\" element=\"0278\" keyword=\"ShowTickLabel\" vr=\"CS\" vm=\"1\">Show Tick Label</tag>
    <tag group=\"0070\" element=\"0279\" keyword=\"TickLabelAlignment\" vr=\"CS\" vm=\"1\">Tick Label Alignment</tag>
    <tag group=\"0070\" element=\"0282\" keyword=\"CompoundGraphicUnits\" vr=\"CS\" vm=\"1\">Compound Graphic Units</tag>
    <tag group=\"0070\" element=\"0284\" keyword=\"PatternOnOpacity\" vr=\"FL\" vm=\"1\">Pattern On Opacity</tag>
    <tag group=\"0070\" element=\"0285\" keyword=\"PatternOffOpacity\" vr=\"FL\" vm=\"1\">Pattern Off Opacity</tag>
    <tag group=\"0070\" element=\"0287\" keyword=\"MajorTicksSequence\" vr=\"SQ\" vm=\"1\">Major Ticks Sequence</tag>
    <tag group=\"0070\" element=\"0288\" keyword=\"TickPosition\" vr=\"FL\" vm=\"1\">Tick Position</tag>
    <tag group=\"0070\" element=\"0289\" keyword=\"TickLabel\" vr=\"SH\" vm=\"1\">Tick Label</tag>
    <tag group=\"0070\" element=\"0294\" keyword=\"CompoundGraphicType\" vr=\"CS\" vm=\"1\">Compound Graphic Type</tag>
    <tag group=\"0070\" element=\"0295\" keyword=\"GraphicGroupID\" vr=\"UL\" vm=\"1\">Graphic Group ID</tag>
    <tag group=\"0070\" element=\"0306\" keyword=\"ShapeType\" vr=\"CS\" vm=\"1\">Shape Type</tag>
    <tag group=\"0070\" element=\"0308\" keyword=\"RegistrationSequence\" vr=\"SQ\" vm=\"1\">Registration Sequence</tag>
    <tag group=\"0070\" element=\"0309\" keyword=\"MatrixRegistrationSequence\" vr=\"SQ\" vm=\"1\">Matrix Registration Sequence</tag>
    <tag group=\"0070\" element=\"030A\" keyword=\"MatrixSequence\" vr=\"SQ\" vm=\"1\">Matrix Sequence</tag>
    <tag group=\"0070\" element=\"030B\" keyword=\"FrameOfReferenceToDisplayedCoordinateSystemTransformationMatrix\" vr=\"FD\" vm=\"16\">Frame of Reference to Displayed Coordinate System Transformation Matrix</tag>
    <tag group=\"0070\" element=\"030C\" keyword=\"FrameOfReferenceTransformationMatrixType\" vr=\"CS\" vm=\"1\">Frame of Reference Transformation Matrix Type</tag>
    <tag group=\"0070\" element=\"030D\" keyword=\"RegistrationTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Registration Type Code Sequence</tag>
    <tag group=\"0070\" element=\"030F\" keyword=\"FiducialDescription\" vr=\"ST\" vm=\"1\">Fiducial Description</tag>
    <tag group=\"0070\" element=\"0310\" keyword=\"FiducialIdentifier\" vr=\"SH\" vm=\"1\">Fiducial Identifier</tag>
    <tag group=\"0070\" element=\"0311\" keyword=\"FiducialIdentifierCodeSequence\" vr=\"SQ\" vm=\"1\">Fiducial Identifier Code Sequence</tag>
    <tag group=\"0070\" element=\"0312\" keyword=\"ContourUncertaintyRadius\" vr=\"FD\" vm=\"1\">Contour Uncertainty Radius</tag>
    <tag group=\"0070\" element=\"0314\" keyword=\"UsedFiducialsSequence\" vr=\"SQ\" vm=\"1\">Used Fiducials Sequence</tag>
    <tag group=\"0070\" element=\"0318\" keyword=\"GraphicCoordinatesDataSequence\" vr=\"SQ\" vm=\"1\">Graphic Coordinates Data Sequence</tag>
    <tag group=\"0070\" element=\"031A\" keyword=\"FiducialUID\" vr=\"UI\" vm=\"1\">Fiducial UID</tag>
    <tag group=\"0070\" element=\"031C\" keyword=\"FiducialSetSequence\" vr=\"SQ\" vm=\"1\">Fiducial Set Sequence</tag>
    <tag group=\"0070\" element=\"031E\" keyword=\"FiducialSequence\" vr=\"SQ\" vm=\"1\">Fiducial Sequence</tag>
    <tag group=\"0070\" element=\"031F\" keyword=\"FiducialsPropertyCategoryCodeSequence\" vr=\"SQ\" vm=\"1\">Fiducials Property Category Code Sequence</tag>
    <tag group=\"0070\" element=\"0401\" keyword=\"GraphicLayerRecommendedDisplayCIELabValue\" vr=\"US\" vm=\"3\">Graphic Layer Recommended Display CIELab Value</tag>
    <tag group=\"0070\" element=\"0402\" keyword=\"BlendingSequence\" vr=\"SQ\" vm=\"1\">Blending Sequence</tag>
    <tag group=\"0070\" element=\"0403\" keyword=\"RelativeOpacity\" vr=\"FL\" vm=\"1\">Relative Opacity</tag>
    <tag group=\"0070\" element=\"0404\" keyword=\"ReferencedSpatialRegistrationSequence\" vr=\"SQ\" vm=\"1\">Referenced Spatial Registration Sequence</tag>
    <tag group=\"0070\" element=\"0405\" keyword=\"BlendingPosition\" vr=\"CS\" vm=\"1\">Blending Position</tag>
    <tag group=\"0070\" element=\"1101\" keyword=\"PresentationDisplayCollectionUID\" vr=\"UI\" vm=\"1\">Presentation Display Collection UID</tag>
    <tag group=\"0070\" element=\"1102\" keyword=\"PresentationSequenceCollectionUID\" vr=\"UI\" vm=\"1\">Presentation Sequence Collection UID</tag>
    <tag group=\"0070\" element=\"1103\" keyword=\"PresentationSequencePositionIndex\" vr=\"US\" vm=\"1\">Presentation Sequence Position Index</tag>
    <tag group=\"0070\" element=\"1104\" keyword=\"RenderedImageReferenceSequence\" vr=\"SQ\" vm=\"1\">Rendered Image Reference Sequence</tag>
    <tag group=\"0070\" element=\"1201\" keyword=\"VolumetricPresentationStateInputSequence\" vr=\"SQ\" vm=\"1\">Volumetric Presentation State Input Sequence</tag>
    <tag group=\"0070\" element=\"1202\" keyword=\"PresentationInputType\" vr=\"CS\" vm=\"1\">Presentation Input Type</tag>
    <tag group=\"0070\" element=\"1203\" keyword=\"InputSequencePositionIndex\" vr=\"US\" vm=\"1\">Input Sequence Position Index</tag>
    <tag group=\"0070\" element=\"1204\" keyword=\"Crop\" vr=\"CS\" vm=\"1\">Crop</tag>
    <tag group=\"0070\" element=\"1205\" keyword=\"CroppingSpecificationIndex\" vr=\"US\" vm=\"1-n\">Cropping Specification Index</tag>
    <tag group=\"0070\" element=\"1206\" keyword=\"CompositingMethod\" vr=\"CS\" vm=\"1\" retired=\"true\">Compositing Method</tag>
    <tag group=\"0070\" element=\"1207\" keyword=\"VolumetricPresentationInputNumber\" vr=\"US\" vm=\"1\">Volumetric Presentation Input Number</tag>
    <tag group=\"0070\" element=\"1208\" keyword=\"ImageVolumeGeometry\" vr=\"CS\" vm=\"1\">Image Volume Geometry</tag>
    <tag group=\"0070\" element=\"1209\" keyword=\"VolumetricPresentationInputSetUID\" vr=\"UI\" vm=\"1\">Volumetric Presentation Input Set UID</tag>
    <tag group=\"0070\" element=\"120A\" keyword=\"VolumetricPresentationInputSetSequence\" vr=\"SQ\" vm=\"1\">Volumetric Presentation Input Set Sequence</tag>
    <tag group=\"0070\" element=\"120B\" keyword=\"GlobalCrop\" vr=\"CS\" vm=\"1\">Global Crop</tag>
    <tag group=\"0070\" element=\"120C\" keyword=\"GlobalCroppingSpecificationIndex\" vr=\"US\" vm=\"1-n\">Global Cropping Specification Index</tag>
    <tag group=\"0070\" element=\"120D\" keyword=\"RenderingMethod\" vr=\"CS\" vm=\"1\">Rendering Method</tag>
    <tag group=\"0070\" element=\"1301\" keyword=\"VolumeCroppingSequence\" vr=\"SQ\" vm=\"1\">Volume Cropping Sequence</tag>
    <tag group=\"0070\" element=\"1302\" keyword=\"VolumeCroppingMethod\" vr=\"CS\" vm=\"1\">Volume Cropping Method</tag>
    <tag group=\"0070\" element=\"1303\" keyword=\"BoundingBoxCrop\" vr=\"FD\" vm=\"6\">Bounding Box Crop</tag>
    <tag group=\"0070\" element=\"1304\" keyword=\"ObliqueCroppingPlaneSequence\" vr=\"SQ\" vm=\"1\">Oblique Cropping Plane Sequence</tag>
    <tag group=\"0070\" element=\"1305\" keyword=\"Plane\" vr=\"FD\" vm=\"4\">Plane</tag>
    <tag group=\"0070\" element=\"1306\" keyword=\"PlaneNormal\" vr=\"FD\" vm=\"3\">Plane Normal</tag>
    <tag group=\"0070\" element=\"1309\" keyword=\"CroppingSpecificationNumber\" vr=\"US\" vm=\"1\">Cropping Specification Number</tag>
    <tag group=\"0070\" element=\"1501\" keyword=\"MultiPlanarReconstructionStyle\" vr=\"CS\" vm=\"1\">Multi-Planar Reconstruction Style</tag>
    <tag group=\"0070\" element=\"1502\" keyword=\"MPRThicknessType\" vr=\"CS\" vm=\"1\">MPR Thickness Type</tag>
    <tag group=\"0070\" element=\"1503\" keyword=\"MPRSlabThickness\" vr=\"FD\" vm=\"1\">MPR Slab Thickness</tag>
    <tag group=\"0070\" element=\"1505\" keyword=\"MPRTopLeftHandCorner\" vr=\"FD\" vm=\"3\">MPR Top Left Hand Corner</tag>
    <tag group=\"0070\" element=\"1507\" keyword=\"MPRViewWidthDirection\" vr=\"FD\" vm=\"3\">MPR View Width Direction</tag>
    <tag group=\"0070\" element=\"1508\" keyword=\"MPRViewWidth\" vr=\"FD\" vm=\"1\">MPR View Width</tag>
    <tag group=\"0070\" element=\"150C\" keyword=\"NumberOfVolumetricCurvePoints\" vr=\"UL\" vm=\"1\">Number of Volumetric Curve Points</tag>
    <tag group=\"0070\" element=\"150D\" keyword=\"VolumetricCurvePoints\" vr=\"OD\" vm=\"1\">Volumetric Curve Points</tag>
    <tag group=\"0070\" element=\"1511\" keyword=\"MPRViewHeightDirection\" vr=\"FD\" vm=\"3\">MPR View Height Direction</tag>
    <tag group=\"0070\" element=\"1512\" keyword=\"MPRViewHeight\" vr=\"FD\" vm=\"1\">MPR View Height</tag>
    <tag group=\"0070\" element=\"1602\" keyword=\"RenderProjection\" vr=\"CS\" vm=\"1\">Render Projection</tag>
    <tag group=\"0070\" element=\"1603\" keyword=\"ViewpointPosition\" vr=\"FD\" vm=\"3\">Viewpoint Position</tag>
    <tag group=\"0070\" element=\"1604\" keyword=\"ViewpointLookAtPoint\" vr=\"FD\" vm=\"3\">Viewpoint LookAt Point</tag>
    <tag group=\"0070\" element=\"1605\" keyword=\"ViewpointUpDirection\" vr=\"FD\" vm=\"3\">Viewpoint Up Direction</tag>
    <tag group=\"0070\" element=\"1606\" keyword=\"RenderFieldOfView\" vr=\"FD\" vm=\"6\">Render Field of View</tag>
    <tag group=\"0070\" element=\"1607\" keyword=\"SamplingStepSize\" vr=\"FD\" vm=\"1\">Sampling Step Size</tag>
    <tag group=\"0070\" element=\"1701\" keyword=\"ShadingStyle\" vr=\"CS\" vm=\"1\">Shading Style</tag>
    <tag group=\"0070\" element=\"1702\" keyword=\"AmbientReflectionIntensity\" vr=\"FD\" vm=\"1\">Ambient Reflection Intensity</tag>
    <tag group=\"0070\" element=\"1703\" keyword=\"LightDirection\" vr=\"FD\" vm=\"3\">Light Direction</tag>
    <tag group=\"0070\" element=\"1704\" keyword=\"DiffuseReflectionIntensity\" vr=\"FD\" vm=\"1\">Diffuse Reflection Intensity</tag>
    <tag group=\"0070\" element=\"1705\" keyword=\"SpecularReflectionIntensity\" vr=\"FD\" vm=\"1\">Specular Reflection Intensity</tag>
    <tag group=\"0070\" element=\"1706\" keyword=\"Shininess\" vr=\"FD\" vm=\"1\">Shininess</tag>
    <tag group=\"0070\" element=\"1801\" keyword=\"PresentationStateClassificationComponentSequence\" vr=\"SQ\" vm=\"1\">Presentation State Classification Component Sequence</tag>
    <tag group=\"0070\" element=\"1802\" keyword=\"ComponentType\" vr=\"CS\" vm=\"1\">Component Type</tag>
    <tag group=\"0070\" element=\"1803\" keyword=\"ComponentInputSequence\" vr=\"SQ\" vm=\"1\">Component Input Sequence</tag>
    <tag group=\"0070\" element=\"1804\" keyword=\"VolumetricPresentationInputIndex\" vr=\"US\" vm=\"1\">Volumetric Presentation Input Index</tag>
    <tag group=\"0070\" element=\"1805\" keyword=\"PresentationStateCompositorComponentSequence\" vr=\"SQ\" vm=\"1\">Presentation State Compositor Component Sequence</tag>
    <tag group=\"0070\" element=\"1806\" keyword=\"WeightingTransferFunctionSequence\" vr=\"SQ\" vm=\"1\">Weighting Transfer Function Sequence</tag>
    <tag group=\"0070\" element=\"1807\" keyword=\"WeightingLookupTableDescriptor\" vr=\"US\" vm=\"3\">Weighting Lookup Table Descriptor</tag>
    <tag group=\"0070\" element=\"1808\" keyword=\"WeightingLookupTableData\" vr=\"OB\" vm=\"1\">Weighting Lookup Table Data</tag>
    <tag group=\"0070\" element=\"1901\" keyword=\"VolumetricAnnotationSequence\" vr=\"SQ\" vm=\"1\">Volumetric Annotation Sequence</tag>
    <tag group=\"0070\" element=\"1903\" keyword=\"ReferencedStructuredContextSequence\" vr=\"SQ\" vm=\"1\">Referenced Structured Context Sequence</tag>
    <tag group=\"0070\" element=\"1904\" keyword=\"ReferencedContentItem\" vr=\"UI\" vm=\"1\">Referenced Content Item</tag>
    <tag group=\"0070\" element=\"1905\" keyword=\"VolumetricPresentationInputAnnotationSequence\" vr=\"SQ\" vm=\"1\">Volumetric Presentation Input Annotation Sequence</tag>
    <tag group=\"0070\" element=\"1907\" keyword=\"AnnotationClipping\" vr=\"CS\" vm=\"1\">Annotation Clipping</tag>
    <tag group=\"0070\" element=\"1A01\" keyword=\"PresentationAnimationStyle\" vr=\"CS\" vm=\"1\">Presentation Animation Style</tag>
    <tag group=\"0070\" element=\"1A03\" keyword=\"RecommendedAnimationRate\" vr=\"FD\" vm=\"1\">Recommended Animation Rate</tag>
    <tag group=\"0070\" element=\"1A04\" keyword=\"AnimationCurveSequence\" vr=\"SQ\" vm=\"1\">Animation Curve Sequence</tag>
    <tag group=\"0070\" element=\"1A05\" keyword=\"AnimationStepSize\" vr=\"FD\" vm=\"1\">Animation Step Size</tag>
    <tag group=\"0070\" element=\"1A06\" keyword=\"SwivelRange\" vr=\"FD\" vm=\"1\">Swivel Range</tag>
    <tag group=\"0070\" element=\"1A07\" keyword=\"VolumetricCurveUpDirections\" vr=\"OD\" vm=\"1\">Volumetric Curve Up Directions</tag>
    <tag group=\"0070\" element=\"1A08\" keyword=\"VolumeStreamSequence\" vr=\"SQ\" vm=\"1\">Volume Stream Sequence</tag>
    <tag group=\"0070\" element=\"1A09\" keyword=\"RGBATransferFunctionDescription\" vr=\"LO\" vm=\"1\">RGBA Transfer Function Description</tag>
    <tag group=\"0070\" element=\"1B01\" keyword=\"AdvancedBlendingSequence\" vr=\"SQ\" vm=\"1\">Advanced Blending Sequence</tag>
    <tag group=\"0070\" element=\"1B02\" keyword=\"BlendingInputNumber\" vr=\"US\" vm=\"1\">Blending Input Number</tag>
    <tag group=\"0070\" element=\"1B03\" keyword=\"BlendingDisplayInputSequence\" vr=\"SQ\" vm=\"1\">Blending Display Input Sequence</tag>
    <tag group=\"0070\" element=\"1B04\" keyword=\"BlendingDisplaySequence\" vr=\"SQ\" vm=\"1\">Blending Display Sequence</tag>
    <tag group=\"0070\" element=\"1B06\" keyword=\"BlendingMode\" vr=\"CS\" vm=\"1\">Blending Mode</tag>
    <tag group=\"0070\" element=\"1B07\" keyword=\"TimeSeriesBlending\" vr=\"CS\" vm=\"1\">Time Series Blending</tag>
    <tag group=\"0070\" element=\"1B08\" keyword=\"GeometryForDisplay\" vr=\"CS\" vm=\"1\">Geometry for Display</tag>
    <tag group=\"0070\" element=\"1B11\" keyword=\"ThresholdSequence\" vr=\"SQ\" vm=\"1\">Threshold Sequence</tag>
    <tag group=\"0070\" element=\"1B12\" keyword=\"ThresholdValueSequence\" vr=\"SQ\" vm=\"1\">Threshold Value Sequence</tag>
    <tag group=\"0070\" element=\"1B13\" keyword=\"ThresholdType\" vr=\"CS\" vm=\"1\">Threshold Type</tag>
    <tag group=\"0070\" element=\"1B14\" keyword=\"ThresholdValue\" vr=\"FD\" vm=\"1\">Threshold Value</tag>
    <tag group=\"0072\" element=\"0002\" keyword=\"HangingProtocolName\" vr=\"SH\" vm=\"1\">Hanging Protocol Name</tag>
    <tag group=\"0072\" element=\"0004\" keyword=\"HangingProtocolDescription\" vr=\"LO\" vm=\"1\">Hanging Protocol Description</tag>
    <tag group=\"0072\" element=\"0006\" keyword=\"HangingProtocolLevel\" vr=\"CS\" vm=\"1\">Hanging Protocol Level</tag>
    <tag group=\"0072\" element=\"0008\" keyword=\"HangingProtocolCreator\" vr=\"LO\" vm=\"1\">Hanging Protocol Creator</tag>
    <tag group=\"0072\" element=\"000A\" keyword=\"HangingProtocolCreationDateTime\" vr=\"DT\" vm=\"1\">Hanging Protocol Creation DateTime</tag>
    <tag group=\"0072\" element=\"000C\" keyword=\"HangingProtocolDefinitionSequence\" vr=\"SQ\" vm=\"1\">Hanging Protocol Definition Sequence</tag>
    <tag group=\"0072\" element=\"000E\" keyword=\"HangingProtocolUserIdentificationCodeSequence\" vr=\"SQ\" vm=\"1\">Hanging Protocol User Identification Code Sequence</tag>
    <tag group=\"0072\" element=\"0010\" keyword=\"HangingProtocolUserGroupName\" vr=\"LO\" vm=\"1\">Hanging Protocol User Group Name</tag>
    <tag group=\"0072\" element=\"0012\" keyword=\"SourceHangingProtocolSequence\" vr=\"SQ\" vm=\"1\">Source Hanging Protocol Sequence</tag>
    <tag group=\"0072\" element=\"0014\" keyword=\"NumberOfPriorsReferenced\" vr=\"US\" vm=\"1\">Number of Priors Referenced</tag>
    <tag group=\"0072\" element=\"0020\" keyword=\"ImageSetsSequence\" vr=\"SQ\" vm=\"1\">Image Sets Sequence</tag>
    <tag group=\"0072\" element=\"0022\" keyword=\"ImageSetSelectorSequence\" vr=\"SQ\" vm=\"1\">Image Set Selector Sequence</tag>
    <tag group=\"0072\" element=\"0024\" keyword=\"ImageSetSelectorUsageFlag\" vr=\"CS\" vm=\"1\">Image Set Selector Usage Flag</tag>
    <tag group=\"0072\" element=\"0026\" keyword=\"SelectorAttribute\" vr=\"AT\" vm=\"1\">Selector Attribute</tag>
    <tag group=\"0072\" element=\"0028\" keyword=\"SelectorValueNumber\" vr=\"US\" vm=\"1\">Selector Value Number</tag>
    <tag group=\"0072\" element=\"0030\" keyword=\"TimeBasedImageSetsSequence\" vr=\"SQ\" vm=\"1\">Time Based Image Sets Sequence</tag>
    <tag group=\"0072\" element=\"0032\" keyword=\"ImageSetNumber\" vr=\"US\" vm=\"1\">Image Set Number</tag>
    <tag group=\"0072\" element=\"0034\" keyword=\"ImageSetSelectorCategory\" vr=\"CS\" vm=\"1\">Image Set Selector Category</tag>
    <tag group=\"0072\" element=\"0038\" keyword=\"RelativeTime\" vr=\"US\" vm=\"2\">Relative Time</tag>
    <tag group=\"0072\" element=\"003A\" keyword=\"RelativeTimeUnits\" vr=\"CS\" vm=\"1\">Relative Time Units</tag>
    <tag group=\"0072\" element=\"003C\" keyword=\"AbstractPriorValue\" vr=\"SS\" vm=\"2\">Abstract Prior Value</tag>
    <tag group=\"0072\" element=\"003E\" keyword=\"AbstractPriorCodeSequence\" vr=\"SQ\" vm=\"1\">Abstract Prior Code Sequence</tag>
    <tag group=\"0072\" element=\"0040\" keyword=\"ImageSetLabel\" vr=\"LO\" vm=\"1\">Image Set Label</tag>
    <tag group=\"0072\" element=\"0050\" keyword=\"SelectorAttributeVR\" vr=\"CS\" vm=\"1\">Selector Attribute VR</tag>
    <tag group=\"0072\" element=\"0052\" keyword=\"SelectorSequencePointer\" vr=\"AT\" vm=\"1-n\">Selector Sequence Pointer</tag>
    <tag group=\"0072\" element=\"0054\" keyword=\"SelectorSequencePointerPrivateCreator\" vr=\"LO\" vm=\"1-n\">Selector Sequence Pointer Private Creator</tag>
    <tag group=\"0072\" element=\"0056\" keyword=\"SelectorAttributePrivateCreator\" vr=\"LO\" vm=\"1\">Selector Attribute Private Creator</tag>
    <tag group=\"0072\" element=\"005E\" keyword=\"SelectorAEValue\" vr=\"AE\" vm=\"1-n\">Selector AE Value</tag>
    <tag group=\"0072\" element=\"005F\" keyword=\"SelectorASValue\" vr=\"AS\" vm=\"1-n\">Selector AS Value</tag>
    <tag group=\"0072\" element=\"0060\" keyword=\"SelectorATValue\" vr=\"AT\" vm=\"1-n\">Selector AT Value</tag>
    <tag group=\"0072\" element=\"0061\" keyword=\"SelectorDAValue\" vr=\"DA\" vm=\"1-n\">Selector DA Value</tag>
    <tag group=\"0072\" element=\"0062\" keyword=\"SelectorCSValue\" vr=\"CS\" vm=\"1-n\">Selector CS Value</tag>
    <tag group=\"0072\" element=\"0063\" keyword=\"SelectorDTValue\" vr=\"DT\" vm=\"1-n\">Selector DT Value</tag>
    <tag group=\"0072\" element=\"0064\" keyword=\"SelectorISValue\" vr=\"IS\" vm=\"1-n\">Selector IS Value</tag>
    <tag group=\"0072\" element=\"0065\" keyword=\"SelectorOBValue\" vr=\"OB\" vm=\"1\">Selector OB Value</tag>
    <tag group=\"0072\" element=\"0066\" keyword=\"SelectorLOValue\" vr=\"LO\" vm=\"1-n\">Selector LO Value</tag>
    <tag group=\"0072\" element=\"0067\" keyword=\"SelectorOFValue\" vr=\"OF\" vm=\"1\">Selector OF Value</tag>
    <tag group=\"0072\" element=\"0068\" keyword=\"SelectorLTValue\" vr=\"LT\" vm=\"1\">Selector LT Value</tag>
    <tag group=\"0072\" element=\"0069\" keyword=\"SelectorOWValue\" vr=\"OW\" vm=\"1\">Selector OW Value</tag>
    <tag group=\"0072\" element=\"006A\" keyword=\"SelectorPNValue\" vr=\"PN\" vm=\"1-n\">Selector PN Value</tag>
    <tag group=\"0072\" element=\"006B\" keyword=\"SelectorTMValue\" vr=\"TM\" vm=\"1-n\">Selector TM Value</tag>
    <tag group=\"0072\" element=\"006C\" keyword=\"SelectorSHValue\" vr=\"SH\" vm=\"1-n\">Selector SH Value</tag>
    <tag group=\"0072\" element=\"006D\" keyword=\"SelectorUNValue\" vr=\"UN\" vm=\"1\">Selector UN Value</tag>
    <tag group=\"0072\" element=\"006E\" keyword=\"SelectorSTValue\" vr=\"ST\" vm=\"1\">Selector ST Value</tag>
    <tag group=\"0072\" element=\"006F\" keyword=\"SelectorUCValue\" vr=\"UC\" vm=\"1-n\">Selector UC Value</tag>
    <tag group=\"0072\" element=\"0070\" keyword=\"SelectorUTValue\" vr=\"UT\" vm=\"1\">Selector UT Value</tag>
    <tag group=\"0072\" element=\"0071\" keyword=\"SelectorURValue\" vr=\"UR\" vm=\"1\">Selector UR Value</tag>
    <tag group=\"0072\" element=\"0072\" keyword=\"SelectorDSValue\" vr=\"DS\" vm=\"1-n\">Selector DS Value</tag>
    <tag group=\"0072\" element=\"0073\" keyword=\"SelectorODValue\" vr=\"OD\" vm=\"1\">Selector OD Value</tag>
    <tag group=\"0072\" element=\"0074\" keyword=\"SelectorFDValue\" vr=\"FD\" vm=\"1-n\">Selector FD Value</tag>
    <tag group=\"0072\" element=\"0075\" keyword=\"SelectorOLValue\" vr=\"OL\" vm=\"1\">Selector OL Value</tag>
    <tag group=\"0072\" element=\"0076\" keyword=\"SelectorFLValue\" vr=\"FL\" vm=\"1-n\">Selector FL Value</tag>
    <tag group=\"0072\" element=\"0078\" keyword=\"SelectorULValue\" vr=\"UL\" vm=\"1-n\">Selector UL Value</tag>
    <tag group=\"0072\" element=\"007A\" keyword=\"SelectorUSValue\" vr=\"US\" vm=\"1-n\">Selector US Value</tag>
    <tag group=\"0072\" element=\"007C\" keyword=\"SelectorSLValue\" vr=\"SL\" vm=\"1-n\">Selector SL Value</tag>
    <tag group=\"0072\" element=\"007E\" keyword=\"SelectorSSValue\" vr=\"SS\" vm=\"1-n\">Selector SS Value</tag>
    <tag group=\"0072\" element=\"007F\" keyword=\"SelectorUIValue\" vr=\"UI\" vm=\"1-n\">Selector UI Value</tag>
    <tag group=\"0072\" element=\"0080\" keyword=\"SelectorCodeSequenceValue\" vr=\"SQ\" vm=\"1\">Selector Code Sequence Value</tag>
    <tag group=\"0072\" element=\"0100\" keyword=\"NumberOfScreens\" vr=\"US\" vm=\"1\">Number of Screens</tag>
    <tag group=\"0072\" element=\"0102\" keyword=\"NominalScreenDefinitionSequence\" vr=\"SQ\" vm=\"1\">Nominal Screen Definition Sequence</tag>
    <tag group=\"0072\" element=\"0104\" keyword=\"NumberOfVerticalPixels\" vr=\"US\" vm=\"1\">Number of Vertical Pixels</tag>
    <tag group=\"0072\" element=\"0106\" keyword=\"NumberOfHorizontalPixels\" vr=\"US\" vm=\"1\">Number of Horizontal Pixels</tag>
    <tag group=\"0072\" element=\"0108\" keyword=\"DisplayEnvironmentSpatialPosition\" vr=\"FD\" vm=\"4\">Display Environment Spatial Position</tag>
    <tag group=\"0072\" element=\"010A\" keyword=\"ScreenMinimumGrayscaleBitDepth\" vr=\"US\" vm=\"1\">Screen Minimum Grayscale Bit Depth</tag>
    <tag group=\"0072\" element=\"010C\" keyword=\"ScreenMinimumColorBitDepth\" vr=\"US\" vm=\"1\">Screen Minimum Color Bit Depth</tag>
    <tag group=\"0072\" element=\"010E\" keyword=\"ApplicationMaximumRepaintTime\" vr=\"US\" vm=\"1\">Application Maximum Repaint Time</tag>
    <tag group=\"0072\" element=\"0200\" keyword=\"DisplaySetsSequence\" vr=\"SQ\" vm=\"1\">Display Sets Sequence</tag>
    <tag group=\"0072\" element=\"0202\" keyword=\"DisplaySetNumber\" vr=\"US\" vm=\"1\">Display Set Number</tag>
    <tag group=\"0072\" element=\"0203\" keyword=\"DisplaySetLabel\" vr=\"LO\" vm=\"1\">Display Set Label</tag>
    <tag group=\"0072\" element=\"0204\" keyword=\"DisplaySetPresentationGroup\" vr=\"US\" vm=\"1\">Display Set Presentation Group</tag>
    <tag group=\"0072\" element=\"0206\" keyword=\"DisplaySetPresentationGroupDescription\" vr=\"LO\" vm=\"1\">Display Set Presentation Group Description</tag>
    <tag group=\"0072\" element=\"0208\" keyword=\"PartialDataDisplayHandling\" vr=\"CS\" vm=\"1\">Partial Data Display Handling</tag>
    <tag group=\"0072\" element=\"0210\" keyword=\"SynchronizedScrollingSequence\" vr=\"SQ\" vm=\"1\">Synchronized Scrolling Sequence</tag>
    <tag group=\"0072\" element=\"0212\" keyword=\"DisplaySetScrollingGroup\" vr=\"US\" vm=\"2-n\">Display Set Scrolling Group</tag>
    <tag group=\"0072\" element=\"0214\" keyword=\"NavigationIndicatorSequence\" vr=\"SQ\" vm=\"1\">Navigation Indicator Sequence</tag>
    <tag group=\"0072\" element=\"0216\" keyword=\"NavigationDisplaySet\" vr=\"US\" vm=\"1\">Navigation Display Set</tag>
    <tag group=\"0072\" element=\"0218\" keyword=\"ReferenceDisplaySets\" vr=\"US\" vm=\"1-n\">Reference Display Sets</tag>
    <tag group=\"0072\" element=\"0300\" keyword=\"ImageBoxesSequence\" vr=\"SQ\" vm=\"1\">Image Boxes Sequence</tag>
    <tag group=\"0072\" element=\"0302\" keyword=\"ImageBoxNumber\" vr=\"US\" vm=\"1\">Image Box Number</tag>
    <tag group=\"0072\" element=\"0304\" keyword=\"ImageBoxLayoutType\" vr=\"CS\" vm=\"1\">Image Box Layout Type</tag>
    <tag group=\"0072\" element=\"0306\" keyword=\"ImageBoxTileHorizontalDimension\" vr=\"US\" vm=\"1\">Image Box Tile Horizontal Dimension</tag>
    <tag group=\"0072\" element=\"0308\" keyword=\"ImageBoxTileVerticalDimension\" vr=\"US\" vm=\"1\">Image Box Tile Vertical Dimension</tag>
    <tag group=\"0072\" element=\"0310\" keyword=\"ImageBoxScrollDirection\" vr=\"CS\" vm=\"1\">Image Box Scroll Direction</tag>
    <tag group=\"0072\" element=\"0312\" keyword=\"ImageBoxSmallScrollType\" vr=\"CS\" vm=\"1\">Image Box Small Scroll Type</tag>
    <tag group=\"0072\" element=\"0314\" keyword=\"ImageBoxSmallScrollAmount\" vr=\"US\" vm=\"1\">Image Box Small Scroll Amount</tag>
    <tag group=\"0072\" element=\"0316\" keyword=\"ImageBoxLargeScrollType\" vr=\"CS\" vm=\"1\">Image Box Large Scroll Type</tag>
    <tag group=\"0072\" element=\"0318\" keyword=\"ImageBoxLargeScrollAmount\" vr=\"US\" vm=\"1\">Image Box Large Scroll Amount</tag>
    <tag group=\"0072\" element=\"0320\" keyword=\"ImageBoxOverlapPriority\" vr=\"US\" vm=\"1\">Image Box Overlap Priority</tag>
    <tag group=\"0072\" element=\"0330\" keyword=\"CineRelativeToRealTime\" vr=\"FD\" vm=\"1\">Cine Relative to Real-Time</tag>
    <tag group=\"0072\" element=\"0400\" keyword=\"FilterOperationsSequence\" vr=\"SQ\" vm=\"1\">Filter Operations Sequence</tag>
    <tag group=\"0072\" element=\"0402\" keyword=\"FilterByCategory\" vr=\"CS\" vm=\"1\">Filter-by Category</tag>
    <tag group=\"0072\" element=\"0404\" keyword=\"FilterByAttributePresence\" vr=\"CS\" vm=\"1\">Filter-by Attribute Presence</tag>
    <tag group=\"0072\" element=\"0406\" keyword=\"FilterByOperator\" vr=\"CS\" vm=\"1\">Filter-by Operator</tag>
    <tag group=\"0072\" element=\"0420\" keyword=\"StructuredDisplayBackgroundCIELabValue\" vr=\"US\" vm=\"3\">Structured Display Background CIELab Value</tag>
    <tag group=\"0072\" element=\"0421\" keyword=\"EmptyImageBoxCIELabValue\" vr=\"US\" vm=\"3\">Empty Image Box CIELab Value</tag>
    <tag group=\"0072\" element=\"0422\" keyword=\"StructuredDisplayImageBoxSequence\" vr=\"SQ\" vm=\"1\">Structured Display Image Box Sequence</tag>
    <tag group=\"0072\" element=\"0424\" keyword=\"StructuredDisplayTextBoxSequence\" vr=\"SQ\" vm=\"1\">Structured Display Text Box Sequence</tag>
    <tag group=\"0072\" element=\"0427\" keyword=\"ReferencedFirstFrameSequence\" vr=\"SQ\" vm=\"1\">Referenced First Frame Sequence</tag>
    <tag group=\"0072\" element=\"0430\" keyword=\"ImageBoxSynchronizationSequence\" vr=\"SQ\" vm=\"1\">Image Box Synchronization Sequence</tag>
    <tag group=\"0072\" element=\"0432\" keyword=\"SynchronizedImageBoxList\" vr=\"US\" vm=\"2-n\">Synchronized Image Box List</tag>
    <tag group=\"0072\" element=\"0434\" keyword=\"TypeOfSynchronization\" vr=\"CS\" vm=\"1\">Type of Synchronization</tag>
    <tag group=\"0072\" element=\"0500\" keyword=\"BlendingOperationType\" vr=\"CS\" vm=\"1\">Blending Operation Type</tag>
    <tag group=\"0072\" element=\"0510\" keyword=\"ReformattingOperationType\" vr=\"CS\" vm=\"1\">Reformatting Operation Type</tag>
    <tag group=\"0072\" element=\"0512\" keyword=\"ReformattingThickness\" vr=\"FD\" vm=\"1\">Reformatting Thickness</tag>
    <tag group=\"0072\" element=\"0514\" keyword=\"ReformattingInterval\" vr=\"FD\" vm=\"1\">Reformatting Interval</tag>
    <tag group=\"0072\" element=\"0516\" keyword=\"ReformattingOperationInitialViewDirection\" vr=\"CS\" vm=\"1\">Reformatting Operation Initial View Direction</tag>
    <tag group=\"0072\" element=\"0520\" keyword=\"ThreeDRenderingType\" vr=\"CS\" vm=\"1-n\">3D Rendering Type</tag>
    <tag group=\"0072\" element=\"0600\" keyword=\"SortingOperationsSequence\" vr=\"SQ\" vm=\"1\">Sorting Operations Sequence</tag>
    <tag group=\"0072\" element=\"0602\" keyword=\"SortByCategory\" vr=\"CS\" vm=\"1\">Sort-by Category</tag>
    <tag group=\"0072\" element=\"0604\" keyword=\"SortingDirection\" vr=\"CS\" vm=\"1\">Sorting Direction</tag>
    <tag group=\"0072\" element=\"0700\" keyword=\"DisplaySetPatientOrientation\" vr=\"CS\" vm=\"2\">Display Set Patient Orientation</tag>
    <tag group=\"0072\" element=\"0702\" keyword=\"VOIType\" vr=\"CS\" vm=\"1\">VOI Type</tag>
    <tag group=\"0072\" element=\"0704\" keyword=\"PseudoColorType\" vr=\"CS\" vm=\"1\">Pseudo-Color Type</tag>
    <tag group=\"0072\" element=\"0705\" keyword=\"PseudoColorPaletteInstanceReferenceSequence\" vr=\"SQ\" vm=\"1\">Pseudo-Color Palette Instance Reference Sequence</tag>
    <tag group=\"0072\" element=\"0706\" keyword=\"ShowGrayscaleInverted\" vr=\"CS\" vm=\"1\">Show Grayscale Inverted</tag>
    <tag group=\"0072\" element=\"0710\" keyword=\"ShowImageTrueSizeFlag\" vr=\"CS\" vm=\"1\">Show Image True Size Flag</tag>
    <tag group=\"0072\" element=\"0712\" keyword=\"ShowGraphicAnnotationFlag\" vr=\"CS\" vm=\"1\">Show Graphic Annotation Flag</tag>
    <tag group=\"0072\" element=\"0714\" keyword=\"ShowPatientDemographicsFlag\" vr=\"CS\" vm=\"1\">Show Patient Demographics Flag</tag>
    <tag group=\"0072\" element=\"0716\" keyword=\"ShowAcquisitionTechniquesFlag\" vr=\"CS\" vm=\"1\">Show Acquisition Techniques Flag</tag>
    <tag group=\"0072\" element=\"0717\" keyword=\"DisplaySetHorizontalJustification\" vr=\"CS\" vm=\"1\">Display Set Horizontal Justification</tag>
    <tag group=\"0072\" element=\"0718\" keyword=\"DisplaySetVerticalJustification\" vr=\"CS\" vm=\"1\">Display Set Vertical Justification</tag>
    <tag group=\"0074\" element=\"0120\" keyword=\"ContinuationStartMeterset\" vr=\"FD\" vm=\"1\">Continuation Start Meterset</tag>
    <tag group=\"0074\" element=\"0121\" keyword=\"ContinuationEndMeterset\" vr=\"FD\" vm=\"1\">Continuation End Meterset</tag>
    <tag group=\"0074\" element=\"1000\" keyword=\"ProcedureStepState\" vr=\"CS\" vm=\"1\">Procedure Step State</tag>
    <tag group=\"0074\" element=\"1002\" keyword=\"ProcedureStepProgressInformationSequence\" vr=\"SQ\" vm=\"1\">Procedure Step Progress Information Sequence</tag>
    <tag group=\"0074\" element=\"1004\" keyword=\"ProcedureStepProgress\" vr=\"DS\" vm=\"1\">Procedure Step Progress</tag>
    <tag group=\"0074\" element=\"1006\" keyword=\"ProcedureStepProgressDescription\" vr=\"ST\" vm=\"1\">Procedure Step Progress Description</tag>
    <tag group=\"0074\" element=\"1008\" keyword=\"ProcedureStepCommunicationsURISequence\" vr=\"SQ\" vm=\"1\">Procedure Step Communications URI Sequence</tag>
    <tag group=\"0074\" element=\"100A\" keyword=\"ContactURI\" vr=\"UR\" vm=\"1\">Contact URI</tag>
    <tag group=\"0074\" element=\"100C\" keyword=\"ContactDisplayName\" vr=\"LO\" vm=\"1\">Contact Display Name</tag>
    <tag group=\"0074\" element=\"100E\" keyword=\"ProcedureStepDiscontinuationReasonCodeSequence\" vr=\"SQ\" vm=\"1\">Procedure Step Discontinuation Reason Code Sequence</tag>
    <tag group=\"0074\" element=\"1020\" keyword=\"BeamTaskSequence\" vr=\"SQ\" vm=\"1\">Beam Task Sequence</tag>
    <tag group=\"0074\" element=\"1022\" keyword=\"BeamTaskType\" vr=\"CS\" vm=\"1\">Beam Task Type</tag>
    <tag group=\"0074\" element=\"1024\" keyword=\"BeamOrderIndexTrial\" vr=\"IS\" vm=\"1\" retired=\"true\">Beam Order Index (Trial)</tag>
    <tag group=\"0074\" element=\"1025\" keyword=\"AutosequenceFlag\" vr=\"CS\" vm=\"1\">Autosequence Flag</tag>
    <tag group=\"0074\" element=\"1026\" keyword=\"TableTopVerticalAdjustedPosition\" vr=\"FD\" vm=\"1\">Table Top Vertical Adjusted Position</tag>
    <tag group=\"0074\" element=\"1027\" keyword=\"TableTopLongitudinalAdjustedPosition\" vr=\"FD\" vm=\"1\">Table Top Longitudinal Adjusted Position</tag>
    <tag group=\"0074\" element=\"1028\" keyword=\"TableTopLateralAdjustedPosition\" vr=\"FD\" vm=\"1\">Table Top Lateral Adjusted Position</tag>
    <tag group=\"0074\" element=\"102A\" keyword=\"PatientSupportAdjustedAngle\" vr=\"FD\" vm=\"1\">Patient Support Adjusted Angle</tag>
    <tag group=\"0074\" element=\"102B\" keyword=\"TableTopEccentricAdjustedAngle\" vr=\"FD\" vm=\"1\">Table Top Eccentric Adjusted Angle</tag>
    <tag group=\"0074\" element=\"102C\" keyword=\"TableTopPitchAdjustedAngle\" vr=\"FD\" vm=\"1\">Table Top Pitch Adjusted Angle</tag>
    <tag group=\"0074\" element=\"102D\" keyword=\"TableTopRollAdjustedAngle\" vr=\"FD\" vm=\"1\">Table Top Roll Adjusted Angle</tag>
    <tag group=\"0074\" element=\"1030\" keyword=\"DeliveryVerificationImageSequence\" vr=\"SQ\" vm=\"1\">Delivery Verification Image Sequence</tag>
    <tag group=\"0074\" element=\"1032\" keyword=\"VerificationImageTiming\" vr=\"CS\" vm=\"1\">Verification Image Timing</tag>
    <tag group=\"0074\" element=\"1034\" keyword=\"DoubleExposureFlag\" vr=\"CS\" vm=\"1\">Double Exposure Flag</tag>
    <tag group=\"0074\" element=\"1036\" keyword=\"DoubleExposureOrdering\" vr=\"CS\" vm=\"1\">Double Exposure Ordering</tag>
    <tag group=\"0074\" element=\"1038\" keyword=\"DoubleExposureMetersetTrial\" vr=\"DS\" vm=\"1\" retired=\"true\">Double Exposure Meterset (Trial)</tag>
    <tag group=\"0074\" element=\"103A\" keyword=\"DoubleExposureFieldDeltaTrial\" vr=\"DS\" vm=\"4\" retired=\"true\">Double Exposure Field Delta (Trial)</tag>
    <tag group=\"0074\" element=\"1040\" keyword=\"RelatedReferenceRTImageSequence\" vr=\"SQ\" vm=\"1\">Related Reference RT Image Sequence</tag>
    <tag group=\"0074\" element=\"1042\" keyword=\"GeneralMachineVerificationSequence\" vr=\"SQ\" vm=\"1\">General Machine Verification Sequence</tag>
    <tag group=\"0074\" element=\"1044\" keyword=\"ConventionalMachineVerificationSequence\" vr=\"SQ\" vm=\"1\">Conventional Machine Verification Sequence</tag>
    <tag group=\"0074\" element=\"1046\" keyword=\"IonMachineVerificationSequence\" vr=\"SQ\" vm=\"1\">Ion Machine Verification Sequence</tag>
    <tag group=\"0074\" element=\"1048\" keyword=\"FailedAttributesSequence\" vr=\"SQ\" vm=\"1\">Failed Attributes Sequence</tag>
    <tag group=\"0074\" element=\"104A\" keyword=\"OverriddenAttributesSequence\" vr=\"SQ\" vm=\"1\">Overridden Attributes Sequence</tag>
    <tag group=\"0074\" element=\"104C\" keyword=\"ConventionalControlPointVerificationSequence\" vr=\"SQ\" vm=\"1\">Conventional Control Point Verification Sequence</tag>
    <tag group=\"0074\" element=\"104E\" keyword=\"IonControlPointVerificationSequence\" vr=\"SQ\" vm=\"1\">Ion Control Point Verification Sequence</tag>
    <tag group=\"0074\" element=\"1050\" keyword=\"AttributeOccurrenceSequence\" vr=\"SQ\" vm=\"1\">Attribute Occurrence Sequence</tag>
    <tag group=\"0074\" element=\"1052\" keyword=\"AttributeOccurrencePointer\" vr=\"AT\" vm=\"1\">Attribute Occurrence Pointer</tag>
    <tag group=\"0074\" element=\"1054\" keyword=\"AttributeItemSelector\" vr=\"UL\" vm=\"1\">Attribute Item Selector</tag>
    <tag group=\"0074\" element=\"1056\" keyword=\"AttributeOccurrencePrivateCreator\" vr=\"LO\" vm=\"1\">Attribute Occurrence Private Creator</tag>
    <tag group=\"0074\" element=\"1057\" keyword=\"SelectorSequencePointerItems\" vr=\"IS\" vm=\"1-n\">Selector Sequence Pointer Items</tag>
    <tag group=\"0074\" element=\"1200\" keyword=\"ScheduledProcedureStepPriority\" vr=\"CS\" vm=\"1\">Scheduled Procedure Step Priority</tag>
    <tag group=\"0074\" element=\"1202\" keyword=\"WorklistLabel\" vr=\"LO\" vm=\"1\">Worklist Label</tag>
    <tag group=\"0074\" element=\"1204\" keyword=\"ProcedureStepLabel\" vr=\"LO\" vm=\"1\">Procedure Step Label</tag>
    <tag group=\"0074\" element=\"1210\" keyword=\"ScheduledProcessingParametersSequence\" vr=\"SQ\" vm=\"1\">Scheduled Processing Parameters Sequence</tag>
    <tag group=\"0074\" element=\"1212\" keyword=\"PerformedProcessingParametersSequence\" vr=\"SQ\" vm=\"1\">Performed Processing Parameters Sequence</tag>
    <tag group=\"0074\" element=\"1216\" keyword=\"UnifiedProcedureStepPerformedProcedureSequence\" vr=\"SQ\" vm=\"1\">Unified Procedure Step Performed Procedure Sequence</tag>
    <tag group=\"0074\" element=\"1220\" keyword=\"RelatedProcedureStepSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Related Procedure Step Sequence</tag>
    <tag group=\"0074\" element=\"1222\" keyword=\"ProcedureStepRelationshipType\" vr=\"LO\" vm=\"1\" retired=\"true\">Procedure Step Relationship Type</tag>
    <tag group=\"0074\" element=\"1224\" keyword=\"ReplacedProcedureStepSequence\" vr=\"SQ\" vm=\"1\">Replaced Procedure Step Sequence</tag>
    <tag group=\"0074\" element=\"1230\" keyword=\"DeletionLock\" vr=\"LO\" vm=\"1\">Deletion Lock</tag>
    <tag group=\"0074\" element=\"1234\" keyword=\"ReceivingAE\" vr=\"AE\" vm=\"1\">Receiving AE</tag>
    <tag group=\"0074\" element=\"1236\" keyword=\"RequestingAE\" vr=\"AE\" vm=\"1\">Requesting AE</tag>
    <tag group=\"0074\" element=\"1238\" keyword=\"ReasonForCancellation\" vr=\"LT\" vm=\"1\">Reason for Cancellation</tag>
    <tag group=\"0074\" element=\"1242\" keyword=\"SCPStatus\" vr=\"CS\" vm=\"1\">SCP Status</tag>
    <tag group=\"0074\" element=\"1244\" keyword=\"SubscriptionListStatus\" vr=\"CS\" vm=\"1\">Subscription List Status</tag>
    <tag group=\"0074\" element=\"1246\" keyword=\"UnifiedProcedureStepListStatus\" vr=\"CS\" vm=\"1\">Unified Procedure Step List Status</tag>
    <tag group=\"0074\" element=\"1324\" keyword=\"BeamOrderIndex\" vr=\"UL\" vm=\"1\">Beam Order Index</tag>
    <tag group=\"0074\" element=\"1338\" keyword=\"DoubleExposureMeterset\" vr=\"FD\" vm=\"1\">Double Exposure Meterset</tag>
    <tag group=\"0074\" element=\"133A\" keyword=\"DoubleExposureFieldDelta\" vr=\"FD\" vm=\"4\">Double Exposure Field Delta</tag>
    <tag group=\"0074\" element=\"1401\" keyword=\"BrachyTaskSequence\" vr=\"SQ\" vm=\"1\">Brachy Task Sequence</tag>
    <tag group=\"0074\" element=\"1402\" keyword=\"ContinuationStartTotalReferenceAirKerma\" vr=\"DS\" vm=\"1\">Continuation Start Total Reference Air Kerma</tag>
    <tag group=\"0074\" element=\"1403\" keyword=\"ContinuationEndTotalReferenceAirKerma\" vr=\"DS\" vm=\"1\">Continuation End Total Reference Air Kerma</tag>
    <tag group=\"0074\" element=\"1404\" keyword=\"ContinuationPulseNumber\" vr=\"IS\" vm=\"1\">Continuation Pulse Number</tag>
    <tag group=\"0074\" element=\"1405\" keyword=\"ChannelDeliveryOrderSequence\" vr=\"SQ\" vm=\"1\">Channel Delivery Order Sequence</tag>
    <tag group=\"0074\" element=\"1406\" keyword=\"ReferencedChannelNumber\" vr=\"IS\" vm=\"1\">Referenced Channel Number</tag>
    <tag group=\"0074\" element=\"1407\" keyword=\"StartCumulativeTimeWeight\" vr=\"DS\" vm=\"1\">Start Cumulative Time Weight</tag>
    <tag group=\"0074\" element=\"1408\" keyword=\"EndCumulativeTimeWeight\" vr=\"DS\" vm=\"1\">End Cumulative Time Weight</tag>
    <tag group=\"0074\" element=\"1409\" keyword=\"OmittedChannelSequence\" vr=\"SQ\" vm=\"1\">Omitted Channel Sequence</tag>
    <tag group=\"0074\" element=\"140A\" keyword=\"ReasonForChannelOmission\" vr=\"CS\" vm=\"1\">Reason for Channel Omission</tag>
    <tag group=\"0074\" element=\"140B\" keyword=\"ReasonForChannelOmissionDescription\" vr=\"LO\" vm=\"1\">Reason for Channel Omission Description</tag>
    <tag group=\"0074\" element=\"140C\" keyword=\"ChannelDeliveryOrderIndex\" vr=\"IS\" vm=\"1\">Channel Delivery Order Index</tag>
    <tag group=\"0074\" element=\"140D\" keyword=\"ChannelDeliveryContinuationSequence\" vr=\"SQ\" vm=\"1\">Channel Delivery Continuation Sequence</tag>
    <tag group=\"0074\" element=\"140E\" keyword=\"OmittedApplicationSetupSequence\" vr=\"SQ\" vm=\"1\">Omitted Application Setup Sequence</tag>
    <tag group=\"0076\" element=\"0001\" keyword=\"ImplantAssemblyTemplateName\" vr=\"LO\" vm=\"1\">Implant Assembly Template Name</tag>
    <tag group=\"0076\" element=\"0003\" keyword=\"ImplantAssemblyTemplateIssuer\" vr=\"LO\" vm=\"1\">Implant Assembly Template Issuer</tag>
    <tag group=\"0076\" element=\"0006\" keyword=\"ImplantAssemblyTemplateVersion\" vr=\"LO\" vm=\"1\">Implant Assembly Template Version</tag>
    <tag group=\"0076\" element=\"0008\" keyword=\"ReplacedImplantAssemblyTemplateSequence\" vr=\"SQ\" vm=\"1\">Replaced Implant Assembly Template Sequence</tag>
    <tag group=\"0076\" element=\"000A\" keyword=\"ImplantAssemblyTemplateType\" vr=\"CS\" vm=\"1\">Implant Assembly Template Type</tag>
    <tag group=\"0076\" element=\"000C\" keyword=\"OriginalImplantAssemblyTemplateSequence\" vr=\"SQ\" vm=\"1\">Original Implant Assembly Template Sequence</tag>
    <tag group=\"0076\" element=\"000E\" keyword=\"DerivationImplantAssemblyTemplateSequence\" vr=\"SQ\" vm=\"1\">Derivation Implant Assembly Template Sequence</tag>
    <tag group=\"0076\" element=\"0010\" keyword=\"ImplantAssemblyTemplateTargetAnatomySequence\" vr=\"SQ\" vm=\"1\">Implant Assembly Template Target Anatomy Sequence</tag>
    <tag group=\"0076\" element=\"0020\" keyword=\"ProcedureTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Procedure Type Code Sequence</tag>
    <tag group=\"0076\" element=\"0030\" keyword=\"SurgicalTechnique\" vr=\"LO\" vm=\"1\">Surgical Technique</tag>
    <tag group=\"0076\" element=\"0032\" keyword=\"ComponentTypesSequence\" vr=\"SQ\" vm=\"1\">Component Types Sequence</tag>
    <tag group=\"0076\" element=\"0034\" keyword=\"ComponentTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Component Type Code Sequence</tag>
    <tag group=\"0076\" element=\"0036\" keyword=\"ExclusiveComponentType\" vr=\"CS\" vm=\"1\">Exclusive Component Type</tag>
    <tag group=\"0076\" element=\"0038\" keyword=\"MandatoryComponentType\" vr=\"CS\" vm=\"1\">Mandatory Component Type</tag>
    <tag group=\"0076\" element=\"0040\" keyword=\"ComponentSequence\" vr=\"SQ\" vm=\"1\">Component Sequence</tag>
    <tag group=\"0076\" element=\"0055\" keyword=\"ComponentID\" vr=\"US\" vm=\"1\">Component ID</tag>
    <tag group=\"0076\" element=\"0060\" keyword=\"ComponentAssemblySequence\" vr=\"SQ\" vm=\"1\">Component Assembly Sequence</tag>
    <tag group=\"0076\" element=\"0070\" keyword=\"Component1ReferencedID\" vr=\"US\" vm=\"1\">Component 1 Referenced ID</tag>
    <tag group=\"0076\" element=\"0080\" keyword=\"Component1ReferencedMatingFeatureSetID\" vr=\"US\" vm=\"1\">Component 1 Referenced Mating Feature Set ID</tag>
    <tag group=\"0076\" element=\"0090\" keyword=\"Component1ReferencedMatingFeatureID\" vr=\"US\" vm=\"1\">Component 1 Referenced Mating Feature ID</tag>
    <tag group=\"0076\" element=\"00A0\" keyword=\"Component2ReferencedID\" vr=\"US\" vm=\"1\">Component 2 Referenced ID</tag>
    <tag group=\"0076\" element=\"00B0\" keyword=\"Component2ReferencedMatingFeatureSetID\" vr=\"US\" vm=\"1\">Component 2 Referenced Mating Feature Set ID</tag>
    <tag group=\"0076\" element=\"00C0\" keyword=\"Component2ReferencedMatingFeatureID\" vr=\"US\" vm=\"1\">Component 2 Referenced Mating Feature ID</tag>
    <tag group=\"0078\" element=\"0001\" keyword=\"ImplantTemplateGroupName\" vr=\"LO\" vm=\"1\">Implant Template Group Name</tag>
    <tag group=\"0078\" element=\"0010\" keyword=\"ImplantTemplateGroupDescription\" vr=\"ST\" vm=\"1\">Implant Template Group Description</tag>
    <tag group=\"0078\" element=\"0020\" keyword=\"ImplantTemplateGroupIssuer\" vr=\"LO\" vm=\"1\">Implant Template Group Issuer</tag>
    <tag group=\"0078\" element=\"0024\" keyword=\"ImplantTemplateGroupVersion\" vr=\"LO\" vm=\"1\">Implant Template Group Version</tag>
    <tag group=\"0078\" element=\"0026\" keyword=\"ReplacedImplantTemplateGroupSequence\" vr=\"SQ\" vm=\"1\">Replaced Implant Template Group Sequence</tag>
    <tag group=\"0078\" element=\"0028\" keyword=\"ImplantTemplateGroupTargetAnatomySequence\" vr=\"SQ\" vm=\"1\">Implant Template Group Target Anatomy Sequence</tag>
    <tag group=\"0078\" element=\"002A\" keyword=\"ImplantTemplateGroupMembersSequence\" vr=\"SQ\" vm=\"1\">Implant Template Group Members Sequence</tag>
    <tag group=\"0078\" element=\"002E\" keyword=\"ImplantTemplateGroupMemberID\" vr=\"US\" vm=\"1\">Implant Template Group Member ID</tag>
    <tag group=\"0078\" element=\"0050\" keyword=\"ThreeDImplantTemplateGroupMemberMatchingPoint\" vr=\"FD\" vm=\"3\">3D Implant Template Group Member Matching Point</tag>
    <tag group=\"0078\" element=\"0060\" keyword=\"ThreeDImplantTemplateGroupMemberMatchingAxes\" vr=\"FD\" vm=\"9\">3D Implant Template Group Member Matching Axes</tag>
    <tag group=\"0078\" element=\"0070\" keyword=\"ImplantTemplateGroupMemberMatching2DCoordinatesSequence\" vr=\"SQ\" vm=\"1\">Implant Template Group Member Matching 2D Coordinates Sequence</tag>
    <tag group=\"0078\" element=\"0090\" keyword=\"TwoDImplantTemplateGroupMemberMatchingPoint\" vr=\"FD\" vm=\"2\">2D Implant Template Group Member Matching Point</tag>
    <tag group=\"0078\" element=\"00A0\" keyword=\"TwoDImplantTemplateGroupMemberMatchingAxes\" vr=\"FD\" vm=\"4\">2D Implant Template Group Member Matching Axes</tag>
    <tag group=\"0078\" element=\"00B0\" keyword=\"ImplantTemplateGroupVariationDimensionSequence\" vr=\"SQ\" vm=\"1\">Implant Template Group Variation Dimension Sequence</tag>
    <tag group=\"0078\" element=\"00B2\" keyword=\"ImplantTemplateGroupVariationDimensionName\" vr=\"LO\" vm=\"1\">Implant Template Group Variation Dimension Name</tag>
    <tag group=\"0078\" element=\"00B4\" keyword=\"ImplantTemplateGroupVariationDimensionRankSequence\" vr=\"SQ\" vm=\"1\">Implant Template Group Variation Dimension Rank Sequence</tag>
    <tag group=\"0078\" element=\"00B6\" keyword=\"ReferencedImplantTemplateGroupMemberID\" vr=\"US\" vm=\"1\">Referenced Implant Template Group Member ID</tag>
    <tag group=\"0078\" element=\"00B8\" keyword=\"ImplantTemplateGroupVariationDimensionRank\" vr=\"US\" vm=\"1\">Implant Template Group Variation Dimension Rank</tag>
    <tag group=\"0080\" element=\"0001\" keyword=\"SurfaceScanAcquisitionTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Surface Scan Acquisition Type Code Sequence</tag>
    <tag group=\"0080\" element=\"0002\" keyword=\"SurfaceScanModeCodeSequence\" vr=\"SQ\" vm=\"1\">Surface Scan Mode Code Sequence</tag>
    <tag group=\"0080\" element=\"0003\" keyword=\"RegistrationMethodCodeSequence\" vr=\"SQ\" vm=\"1\">Registration Method Code Sequence</tag>
    <tag group=\"0080\" element=\"0004\" keyword=\"ShotDurationTime\" vr=\"FD\" vm=\"1\">Shot Duration Time</tag>
    <tag group=\"0080\" element=\"0005\" keyword=\"ShotOffsetTime\" vr=\"FD\" vm=\"1\">Shot Offset Time</tag>
    <tag group=\"0080\" element=\"0006\" keyword=\"SurfacePointPresentationValueData\" vr=\"US\" vm=\"1-n\">Surface Point Presentation Value Data</tag>
    <tag group=\"0080\" element=\"0007\" keyword=\"SurfacePointColorCIELabValueData\" vr=\"US\" vm=\"3-3n\">Surface Point Color CIELab Value Data</tag>
    <tag group=\"0080\" element=\"0008\" keyword=\"UVMappingSequence\" vr=\"SQ\" vm=\"1\">UV Mapping Sequence</tag>
    <tag group=\"0080\" element=\"0009\" keyword=\"TextureLabel\" vr=\"SH\" vm=\"1\">Texture Label</tag>
    <tag group=\"0080\" element=\"0010\" keyword=\"UValueData\" vr=\"OF\" vm=\"1-n\">U Value Data</tag>
    <tag group=\"0080\" element=\"0011\" keyword=\"VValueData\" vr=\"OF\" vm=\"1-n\">V Value Data</tag>
    <tag group=\"0080\" element=\"0012\" keyword=\"ReferencedTextureSequence\" vr=\"SQ\" vm=\"1\">Referenced Texture Sequence</tag>
    <tag group=\"0080\" element=\"0013\" keyword=\"ReferencedSurfaceDataSequence\" vr=\"SQ\" vm=\"1\">Referenced Surface Data Sequence</tag>
    <tag group=\"0082\" element=\"0001\" keyword=\"AssessmentSummary\" vr=\"CS\" vm=\"1\">Assessment Summary</tag>
    <tag group=\"0082\" element=\"0003\" keyword=\"AssessmentSummaryDescription\" vr=\"UT\" vm=\"1\">Assessment Summary Description</tag>
    <tag group=\"0082\" element=\"0004\" keyword=\"AssessedSOPInstanceSequence\" vr=\"SQ\" vm=\"1\">Assessed SOP Instance Sequence</tag>
    <tag group=\"0082\" element=\"0005\" keyword=\"ReferencedComparisonSOPInstanceSequence\" vr=\"SQ\" vm=\"1\">Referenced Comparison SOP Instance Sequence</tag>
    <tag group=\"0082\" element=\"0006\" keyword=\"NumberOfAssessmentObservations\" vr=\"UL\" vm=\"1\">Number of Assessment Observations</tag>
    <tag group=\"0082\" element=\"0007\" keyword=\"AssessmentObservationsSequence\" vr=\"SQ\" vm=\"1\">Assessment Observations Sequence</tag>
    <tag group=\"0082\" element=\"0008\" keyword=\"ObservationSignificance\" vr=\"CS\" vm=\"1\">Observation Significance</tag>
    <tag group=\"0082\" element=\"000A\" keyword=\"ObservationDescription\" vr=\"UT\" vm=\"1\">Observation Description</tag>
    <tag group=\"0082\" element=\"000C\" keyword=\"StructuredConstraintObservationSequence\" vr=\"SQ\" vm=\"1\">Structured Constraint Observation Sequence</tag>
    <tag group=\"0082\" element=\"0010\" keyword=\"AssessedAttributeValueSequence\" vr=\"SQ\" vm=\"1\">Assessed Attribute Value Sequence</tag>
    <tag group=\"0082\" element=\"0016\" keyword=\"AssessmentSetID\" vr=\"LO\" vm=\"1\">Assessment Set ID</tag>
    <tag group=\"0082\" element=\"0017\" keyword=\"AssessmentRequesterSequence\" vr=\"SQ\" vm=\"1\">Assessment Requester Sequence</tag>
    <tag group=\"0082\" element=\"0018\" keyword=\"SelectorAttributeName\" vr=\"LO\" vm=\"1\">Selector Attribute Name</tag>
    <tag group=\"0082\" element=\"0019\" keyword=\"SelectorAttributeKeyword\" vr=\"LO\" vm=\"1\">Selector Attribute Keyword</tag>
    <tag group=\"0082\" element=\"0021\" keyword=\"AssessmentTypeCodeSequence\" vr=\"SQ\" vm=\"1\">Assessment Type Code Sequence</tag>
    <tag group=\"0082\" element=\"0022\" keyword=\"ObservationBasisCodeSequence\" vr=\"SQ\" vm=\"1\">Observation Basis Code Sequence</tag>
    <tag group=\"0082\" element=\"0023\" keyword=\"AssessmentLabel\" vr=\"LO\" vm=\"1\">Assessment Label</tag>
    <tag group=\"0082\" element=\"0032\" keyword=\"ConstraintType\" vr=\"CS\" vm=\"1\">Constraint Type</tag>
    <tag group=\"0082\" element=\"0033\" keyword=\"SpecificationSelectionGuidance\" vr=\"UT\" vm=\"1\">Specification Selection Guidance</tag>
    <tag group=\"0082\" element=\"0034\" keyword=\"ConstraintValueSequence\" vr=\"SQ\" vm=\"1\">Constraint Value Sequence</tag>
    <tag group=\"0082\" element=\"0035\" keyword=\"RecommendedDefaultValueSequence\" vr=\"SQ\" vm=\"1\">Recommended Default Value Sequence</tag>
    <tag group=\"0082\" element=\"0036\" keyword=\"ConstraintViolationSignificance\" vr=\"CS\" vm=\"1\">Constraint Violation Significance</tag>
    <tag group=\"0082\" element=\"0037\" keyword=\"ConstraintViolationCondition\" vr=\"UT\" vm=\"1\">Constraint Violation Condition</tag>
    <tag group=\"0082\" element=\"0038\" keyword=\"ModifiableConstraintFlag\" vr=\"CS\" vm=\"1\">Modifiable Constraint Flag</tag>
    <tag group=\"0088\" element=\"0130\" keyword=\"StorageMediaFileSetID\" vr=\"SH\" vm=\"1\">Storage Media File-set ID</tag>
    <tag group=\"0088\" element=\"0140\" keyword=\"StorageMediaFileSetUID\" vr=\"UI\" vm=\"1\">Storage Media File-set UID</tag>
    <tag group=\"0088\" element=\"0200\" keyword=\"IconImageSequence\" vr=\"SQ\" vm=\"1\">Icon Image Sequence</tag>
    <tag group=\"0088\" element=\"0904\" keyword=\"TopicTitle\" vr=\"LO\" vm=\"1\" retired=\"true\">Topic Title</tag>
    <tag group=\"0088\" element=\"0906\" keyword=\"TopicSubject\" vr=\"ST\" vm=\"1\" retired=\"true\">Topic Subject</tag>
    <tag group=\"0088\" element=\"0910\" keyword=\"TopicAuthor\" vr=\"LO\" vm=\"1\" retired=\"true\">Topic Author</tag>
    <tag group=\"0088\" element=\"0912\" keyword=\"TopicKeywords\" vr=\"LO\" vm=\"1-32\" retired=\"true\">Topic Keywords</tag>
    <tag group=\"0100\" element=\"0410\" keyword=\"SOPInstanceStatus\" vr=\"CS\" vm=\"1\">SOP Instance Status</tag>
    <tag group=\"0100\" element=\"0420\" keyword=\"SOPAuthorizationDateTime\" vr=\"DT\" vm=\"1\">SOP Authorization DateTime</tag>
    <tag group=\"0100\" element=\"0424\" keyword=\"SOPAuthorizationComment\" vr=\"LT\" vm=\"1\">SOP Authorization Comment</tag>
    <tag group=\"0100\" element=\"0426\" keyword=\"AuthorizationEquipmentCertificationNumber\" vr=\"LO\" vm=\"1\">Authorization Equipment Certification Number</tag>
    <tag group=\"0400\" element=\"0005\" keyword=\"MACIDNumber\" vr=\"US\" vm=\"1\">MAC ID Number</tag>
    <tag group=\"0400\" element=\"0010\" keyword=\"MACCalculationTransferSyntaxUID\" vr=\"UI\" vm=\"1\">MAC Calculation Transfer Syntax UID</tag>
    <tag group=\"0400\" element=\"0015\" keyword=\"MACAlgorithm\" vr=\"CS\" vm=\"1\">MAC Algorithm</tag>
    <tag group=\"0400\" element=\"0020\" keyword=\"DataElementsSigned\" vr=\"AT\" vm=\"1-n\">Data Elements Signed</tag>
    <tag group=\"0400\" element=\"0100\" keyword=\"DigitalSignatureUID\" vr=\"UI\" vm=\"1\">Digital Signature UID</tag>
    <tag group=\"0400\" element=\"0105\" keyword=\"DigitalSignatureDateTime\" vr=\"DT\" vm=\"1\">Digital Signature DateTime</tag>
    <tag group=\"0400\" element=\"0110\" keyword=\"CertificateType\" vr=\"CS\" vm=\"1\">Certificate Type</tag>
    <tag group=\"0400\" element=\"0115\" keyword=\"CertificateOfSigner\" vr=\"OB\" vm=\"1\">Certificate of Signer</tag>
    <tag group=\"0400\" element=\"0120\" keyword=\"Signature\" vr=\"OB\" vm=\"1\">Signature</tag>
    <tag group=\"0400\" element=\"0305\" keyword=\"CertifiedTimestampType\" vr=\"CS\" vm=\"1\">Certified Timestamp Type</tag>
    <tag group=\"0400\" element=\"0310\" keyword=\"CertifiedTimestamp\" vr=\"OB\" vm=\"1\">Certified Timestamp</tag>
    <tag group=\"0400\" element=\"0401\" keyword=\"DigitalSignaturePurposeCodeSequence\" vr=\"SQ\" vm=\"1\">Digital Signature Purpose Code Sequence</tag>
    <tag group=\"0400\" element=\"0402\" keyword=\"ReferencedDigitalSignatureSequence\" vr=\"SQ\" vm=\"1\">Referenced Digital Signature Sequence</tag>
    <tag group=\"0400\" element=\"0403\" keyword=\"ReferencedSOPInstanceMACSequence\" vr=\"SQ\" vm=\"1\">Referenced SOP Instance MAC Sequence</tag>
    <tag group=\"0400\" element=\"0404\" keyword=\"MAC\" vr=\"OB\" vm=\"1\">MAC</tag>
    <tag group=\"0400\" element=\"0500\" keyword=\"EncryptedAttributesSequence\" vr=\"SQ\" vm=\"1\">Encrypted Attributes Sequence</tag>
    <tag group=\"0400\" element=\"0510\" keyword=\"EncryptedContentTransferSyntaxUID\" vr=\"UI\" vm=\"1\">Encrypted Content Transfer Syntax UID</tag>
    <tag group=\"0400\" element=\"0520\" keyword=\"EncryptedContent\" vr=\"OB\" vm=\"1\">Encrypted Content</tag>
    <tag group=\"0400\" element=\"0550\" keyword=\"ModifiedAttributesSequence\" vr=\"SQ\" vm=\"1\">Modified Attributes Sequence</tag>
    <tag group=\"0400\" element=\"0561\" keyword=\"OriginalAttributesSequence\" vr=\"SQ\" vm=\"1\">Original Attributes Sequence</tag>
    <tag group=\"0400\" element=\"0562\" keyword=\"AttributeModificationDateTime\" vr=\"DT\" vm=\"1\">Attribute Modification DateTime</tag>
    <tag group=\"0400\" element=\"0563\" keyword=\"ModifyingSystem\" vr=\"LO\" vm=\"1\">Modifying System</tag>
    <tag group=\"0400\" element=\"0564\" keyword=\"SourceOfPreviousValues\" vr=\"LO\" vm=\"1\">Source of Previous Values</tag>
    <tag group=\"0400\" element=\"0565\" keyword=\"ReasonForTheAttributeModification\" vr=\"CS\" vm=\"1\">Reason for the Attribute Modification</tag>
    <tag group=\"1000\" element=\"xxx0\" keyword=\"EscapeTriplet\" vr=\"US\" vm=\"3\" retired=\"true\">Escape Triplet</tag>
    <tag group=\"1000\" element=\"xxx1\" keyword=\"RunLengthTriplet\" vr=\"US\" vm=\"3\" retired=\"true\">Run Length Triplet</tag>
    <tag group=\"1000\" element=\"xxx2\" keyword=\"HuffmanTableSize\" vr=\"US\" vm=\"1\" retired=\"true\">Huffman Table Size</tag>
    <tag group=\"1000\" element=\"xxx3\" keyword=\"HuffmanTableTriplet\" vr=\"US\" vm=\"3\" retired=\"true\">Huffman Table Triplet</tag>
    <tag group=\"1000\" element=\"xxx4\" keyword=\"ShiftTableSize\" vr=\"US\" vm=\"1\" retired=\"true\">Shift Table Size</tag>
    <tag group=\"1000\" element=\"xxx5\" keyword=\"ShiftTableTriplet\" vr=\"US\" vm=\"3\" retired=\"true\">Shift Table Triplet</tag>
    <tag group=\"1010\" element=\"xxxx\" keyword=\"ZonalMap\" vr=\"US\" vm=\"1-n\" retired=\"true\">Zonal Map</tag>
    <tag group=\"2000\" element=\"0010\" keyword=\"NumberOfCopies\" vr=\"IS\" vm=\"1\">Number of Copies</tag>
    <tag group=\"2000\" element=\"001E\" keyword=\"PrinterConfigurationSequence\" vr=\"SQ\" vm=\"1\">Printer Configuration Sequence</tag>
    <tag group=\"2000\" element=\"0020\" keyword=\"PrintPriority\" vr=\"CS\" vm=\"1\">Print Priority</tag>
    <tag group=\"2000\" element=\"0030\" keyword=\"MediumType\" vr=\"CS\" vm=\"1\">Medium Type</tag>
    <tag group=\"2000\" element=\"0040\" keyword=\"FilmDestination\" vr=\"CS\" vm=\"1\">Film Destination</tag>
    <tag group=\"2000\" element=\"0050\" keyword=\"FilmSessionLabel\" vr=\"LO\" vm=\"1\">Film Session Label</tag>
    <tag group=\"2000\" element=\"0060\" keyword=\"MemoryAllocation\" vr=\"IS\" vm=\"1\">Memory Allocation</tag>
    <tag group=\"2000\" element=\"0061\" keyword=\"MaximumMemoryAllocation\" vr=\"IS\" vm=\"1\">Maximum Memory Allocation</tag>
    <tag group=\"2000\" element=\"0062\" keyword=\"ColorImagePrintingFlag\" vr=\"CS\" vm=\"1\" retired=\"true\">Color Image Printing Flag</tag>
    <tag group=\"2000\" element=\"0063\" keyword=\"CollationFlag\" vr=\"CS\" vm=\"1\" retired=\"true\">Collation Flag</tag>
    <tag group=\"2000\" element=\"0065\" keyword=\"AnnotationFlag\" vr=\"CS\" vm=\"1\" retired=\"true\">Annotation Flag</tag>
    <tag group=\"2000\" element=\"0067\" keyword=\"ImageOverlayFlag\" vr=\"CS\" vm=\"1\" retired=\"true\">Image Overlay Flag</tag>
    <tag group=\"2000\" element=\"0069\" keyword=\"PresentationLUTFlag\" vr=\"CS\" vm=\"1\" retired=\"true\">Presentation LUT Flag</tag>
    <tag group=\"2000\" element=\"006A\" keyword=\"ImageBoxPresentationLUTFlag\" vr=\"CS\" vm=\"1\" retired=\"true\">Image Box Presentation LUT Flag</tag>
    <tag group=\"2000\" element=\"00A0\" keyword=\"MemoryBitDepth\" vr=\"US\" vm=\"1\">Memory Bit Depth</tag>
    <tag group=\"2000\" element=\"00A1\" keyword=\"PrintingBitDepth\" vr=\"US\" vm=\"1\">Printing Bit Depth</tag>
    <tag group=\"2000\" element=\"00A2\" keyword=\"MediaInstalledSequence\" vr=\"SQ\" vm=\"1\">Media Installed Sequence</tag>
    <tag group=\"2000\" element=\"00A4\" keyword=\"OtherMediaAvailableSequence\" vr=\"SQ\" vm=\"1\">Other Media Available Sequence</tag>
    <tag group=\"2000\" element=\"00A8\" keyword=\"SupportedImageDisplayFormatsSequence\" vr=\"SQ\" vm=\"1\">Supported Image Display Formats Sequence</tag>
    <tag group=\"2000\" element=\"0500\" keyword=\"ReferencedFilmBoxSequence\" vr=\"SQ\" vm=\"1\">Referenced Film Box Sequence</tag>
    <tag group=\"2000\" element=\"0510\" keyword=\"ReferencedStoredPrintSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced Stored Print Sequence</tag>
    <tag group=\"2010\" element=\"0010\" keyword=\"ImageDisplayFormat\" vr=\"ST\" vm=\"1\">Image Display Format</tag>
    <tag group=\"2010\" element=\"0030\" keyword=\"AnnotationDisplayFormatID\" vr=\"CS\" vm=\"1\">Annotation Display Format ID</tag>
    <tag group=\"2010\" element=\"0040\" keyword=\"FilmOrientation\" vr=\"CS\" vm=\"1\">Film Orientation</tag>
    <tag group=\"2010\" element=\"0050\" keyword=\"FilmSizeID\" vr=\"CS\" vm=\"1\">Film Size ID</tag>
    <tag group=\"2010\" element=\"0052\" keyword=\"PrinterResolutionID\" vr=\"CS\" vm=\"1\">Printer Resolution ID</tag>
    <tag group=\"2010\" element=\"0054\" keyword=\"DefaultPrinterResolutionID\" vr=\"CS\" vm=\"1\">Default Printer Resolution ID</tag>
    <tag group=\"2010\" element=\"0060\" keyword=\"MagnificationType\" vr=\"CS\" vm=\"1\">Magnification Type</tag>
    <tag group=\"2010\" element=\"0080\" keyword=\"SmoothingType\" vr=\"CS\" vm=\"1\">Smoothing Type</tag>
    <tag group=\"2010\" element=\"00A6\" keyword=\"DefaultMagnificationType\" vr=\"CS\" vm=\"1\">Default Magnification Type</tag>
    <tag group=\"2010\" element=\"00A7\" keyword=\"OtherMagnificationTypesAvailable\" vr=\"CS\" vm=\"1-n\">Other Magnification Types Available</tag>
    <tag group=\"2010\" element=\"00A8\" keyword=\"DefaultSmoothingType\" vr=\"CS\" vm=\"1\">Default Smoothing Type</tag>
    <tag group=\"2010\" element=\"00A9\" keyword=\"OtherSmoothingTypesAvailable\" vr=\"CS\" vm=\"1-n\">Other Smoothing Types Available</tag>
    <tag group=\"2010\" element=\"0100\" keyword=\"BorderDensity\" vr=\"CS\" vm=\"1\">Border Density</tag>
    <tag group=\"2010\" element=\"0110\" keyword=\"EmptyImageDensity\" vr=\"CS\" vm=\"1\">Empty Image Density</tag>
    <tag group=\"2010\" element=\"0120\" keyword=\"MinDensity\" vr=\"US\" vm=\"1\">Min Density</tag>
    <tag group=\"2010\" element=\"0130\" keyword=\"MaxDensity\" vr=\"US\" vm=\"1\">Max Density</tag>
    <tag group=\"2010\" element=\"0140\" keyword=\"Trim\" vr=\"CS\" vm=\"1\">Trim</tag>
    <tag group=\"2010\" element=\"0150\" keyword=\"ConfigurationInformation\" vr=\"ST\" vm=\"1\">Configuration Information</tag>
    <tag group=\"2010\" element=\"0152\" keyword=\"ConfigurationInformationDescription\" vr=\"LT\" vm=\"1\">Configuration Information Description</tag>
    <tag group=\"2010\" element=\"0154\" keyword=\"MaximumCollatedFilms\" vr=\"IS\" vm=\"1\">Maximum Collated Films</tag>
    <tag group=\"2010\" element=\"015E\" keyword=\"Illumination\" vr=\"US\" vm=\"1\">Illumination</tag>
    <tag group=\"2010\" element=\"0160\" keyword=\"ReflectedAmbientLight\" vr=\"US\" vm=\"1\">Reflected Ambient Light</tag>
    <tag group=\"2010\" element=\"0376\" keyword=\"PrinterPixelSpacing\" vr=\"DS\" vm=\"2\">Printer Pixel Spacing</tag>
    <tag group=\"2010\" element=\"0500\" keyword=\"ReferencedFilmSessionSequence\" vr=\"SQ\" vm=\"1\">Referenced Film Session Sequence</tag>
    <tag group=\"2010\" element=\"0510\" keyword=\"ReferencedImageBoxSequence\" vr=\"SQ\" vm=\"1\">Referenced Image Box Sequence</tag>
    <tag group=\"2010\" element=\"0520\" keyword=\"ReferencedBasicAnnotationBoxSequence\" vr=\"SQ\" vm=\"1\">Referenced Basic Annotation Box Sequence</tag>
    <tag group=\"2020\" element=\"0010\" keyword=\"ImageBoxPosition\" vr=\"US\" vm=\"1\">Image Box Position</tag>
    <tag group=\"2020\" element=\"0020\" keyword=\"Polarity\" vr=\"CS\" vm=\"1\">Polarity</tag>
    <tag group=\"2020\" element=\"0030\" keyword=\"RequestedImageSize\" vr=\"DS\" vm=\"1\">Requested Image Size</tag>
    <tag group=\"2020\" element=\"0040\" keyword=\"RequestedDecimateCropBehavior\" vr=\"CS\" vm=\"1\">Requested Decimate/Crop Behavior</tag>
    <tag group=\"2020\" element=\"0050\" keyword=\"RequestedResolutionID\" vr=\"CS\" vm=\"1\">Requested Resolution ID</tag>
    <tag group=\"2020\" element=\"00A0\" keyword=\"RequestedImageSizeFlag\" vr=\"CS\" vm=\"1\">Requested Image Size Flag</tag>
    <tag group=\"2020\" element=\"00A2\" keyword=\"DecimateCropResult\" vr=\"CS\" vm=\"1\">Decimate/Crop Result</tag>
    <tag group=\"2020\" element=\"0110\" keyword=\"BasicGrayscaleImageSequence\" vr=\"SQ\" vm=\"1\">Basic Grayscale Image Sequence</tag>
    <tag group=\"2020\" element=\"0111\" keyword=\"BasicColorImageSequence\" vr=\"SQ\" vm=\"1\">Basic Color Image Sequence</tag>
    <tag group=\"2020\" element=\"0130\" keyword=\"ReferencedImageOverlayBoxSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced Image Overlay Box Sequence</tag>
    <tag group=\"2020\" element=\"0140\" keyword=\"ReferencedVOILUTBoxSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced VOI LUT Box Sequence</tag>
    <tag group=\"2030\" element=\"0010\" keyword=\"AnnotationPosition\" vr=\"US\" vm=\"1\">Annotation Position</tag>
    <tag group=\"2030\" element=\"0020\" keyword=\"TextString\" vr=\"LO\" vm=\"1\">Text String</tag>
    <tag group=\"2040\" element=\"0010\" keyword=\"ReferencedOverlayPlaneSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced Overlay Plane Sequence</tag>
    <tag group=\"2040\" element=\"0011\" keyword=\"ReferencedOverlayPlaneGroups\" vr=\"US\" vm=\"1-99\" retired=\"true\">Referenced Overlay Plane Groups</tag>
    <tag group=\"2040\" element=\"0020\" keyword=\"OverlayPixelDataSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Overlay Pixel Data Sequence</tag>
    <tag group=\"2040\" element=\"0060\" keyword=\"OverlayMagnificationType\" vr=\"CS\" vm=\"1\" retired=\"true\">Overlay Magnification Type</tag>
    <tag group=\"2040\" element=\"0070\" keyword=\"OverlaySmoothingType\" vr=\"CS\" vm=\"1\" retired=\"true\">Overlay Smoothing Type</tag>
    <tag group=\"2040\" element=\"0072\" keyword=\"OverlayOrImageMagnification\" vr=\"CS\" vm=\"1\" retired=\"true\">Overlay or Image Magnification</tag>
    <tag group=\"2040\" element=\"0074\" keyword=\"MagnifyToNumberOfColumns\" vr=\"US\" vm=\"1\" retired=\"true\">Magnify to Number of Columns</tag>
    <tag group=\"2040\" element=\"0080\" keyword=\"OverlayForegroundDensity\" vr=\"CS\" vm=\"1\" retired=\"true\">Overlay Foreground Density</tag>
    <tag group=\"2040\" element=\"0082\" keyword=\"OverlayBackgroundDensity\" vr=\"CS\" vm=\"1\" retired=\"true\">Overlay Background Density</tag>
    <tag group=\"2040\" element=\"0090\" keyword=\"OverlayMode\" vr=\"CS\" vm=\"1\" retired=\"true\">Overlay Mode</tag>
    <tag group=\"2040\" element=\"0100\" keyword=\"ThresholdDensity\" vr=\"CS\" vm=\"1\" retired=\"true\">Threshold Density</tag>
    <tag group=\"2040\" element=\"0500\" keyword=\"ReferencedImageBoxSequenceRetired\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced Image Box Sequence (Retired)</tag>
    <tag group=\"2050\" element=\"0010\" keyword=\"PresentationLUTSequence\" vr=\"SQ\" vm=\"1\">Presentation LUT Sequence</tag>
    <tag group=\"2050\" element=\"0020\" keyword=\"PresentationLUTShape\" vr=\"CS\" vm=\"1\">Presentation LUT Shape</tag>
    <tag group=\"2050\" element=\"0500\" keyword=\"ReferencedPresentationLUTSequence\" vr=\"SQ\" vm=\"1\">Referenced Presentation LUT Sequence</tag>
    <tag group=\"2100\" element=\"0010\" keyword=\"PrintJobID\" vr=\"SH\" vm=\"1\" retired=\"true\">Print Job ID</tag>
    <tag group=\"2100\" element=\"0020\" keyword=\"ExecutionStatus\" vr=\"CS\" vm=\"1\">Execution Status</tag>
    <tag group=\"2100\" element=\"0030\" keyword=\"ExecutionStatusInfo\" vr=\"CS\" vm=\"1\">Execution Status Info</tag>
    <tag group=\"2100\" element=\"0040\" keyword=\"CreationDate\" vr=\"DA\" vm=\"1\">Creation Date</tag>
    <tag group=\"2100\" element=\"0050\" keyword=\"CreationTime\" vr=\"TM\" vm=\"1\">Creation Time</tag>
    <tag group=\"2100\" element=\"0070\" keyword=\"Originator\" vr=\"AE\" vm=\"1\">Originator</tag>
    <tag group=\"2100\" element=\"0140\" keyword=\"DestinationAE\" vr=\"AE\" vm=\"1\">Destination AE</tag>
    <tag group=\"2100\" element=\"0160\" keyword=\"OwnerID\" vr=\"SH\" vm=\"1\">Owner ID</tag>
    <tag group=\"2100\" element=\"0170\" keyword=\"NumberOfFilms\" vr=\"IS\" vm=\"1\">Number of Films</tag>
    <tag group=\"2100\" element=\"0500\" keyword=\"ReferencedPrintJobSequencePullStoredPrint\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced Print Job Sequence (Pull Stored Print)</tag>
    <tag group=\"2110\" element=\"0010\" keyword=\"PrinterStatus\" vr=\"CS\" vm=\"1\">Printer Status</tag>
    <tag group=\"2110\" element=\"0020\" keyword=\"PrinterStatusInfo\" vr=\"CS\" vm=\"1\">Printer Status Info</tag>
    <tag group=\"2110\" element=\"0030\" keyword=\"PrinterName\" vr=\"LO\" vm=\"1\">Printer Name</tag>
    <tag group=\"2110\" element=\"0099\" keyword=\"PrintQueueID\" vr=\"SH\" vm=\"1\" retired=\"true\">Print Queue ID</tag>
    <tag group=\"2120\" element=\"0010\" keyword=\"QueueStatus\" vr=\"CS\" vm=\"1\" retired=\"true\">Queue Status</tag>
    <tag group=\"2120\" element=\"0050\" keyword=\"PrintJobDescriptionSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Print Job Description Sequence</tag>
    <tag group=\"2120\" element=\"0070\" keyword=\"ReferencedPrintJobSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced Print Job Sequence</tag>
    <tag group=\"2130\" element=\"0010\" keyword=\"PrintManagementCapabilitiesSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Print Management Capabilities Sequence</tag>
    <tag group=\"2130\" element=\"0015\" keyword=\"PrinterCharacteristicsSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Printer Characteristics Sequence</tag>
    <tag group=\"2130\" element=\"0030\" keyword=\"FilmBoxContentSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Film Box Content Sequence</tag>
    <tag group=\"2130\" element=\"0040\" keyword=\"ImageBoxContentSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Image Box Content Sequence</tag>
    <tag group=\"2130\" element=\"0050\" keyword=\"AnnotationContentSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Annotation Content Sequence</tag>
    <tag group=\"2130\" element=\"0060\" keyword=\"ImageOverlayBoxContentSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Image Overlay Box Content Sequence</tag>
    <tag group=\"2130\" element=\"0080\" keyword=\"PresentationLUTContentSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Presentation LUT Content Sequence</tag>
    <tag group=\"2130\" element=\"00A0\" keyword=\"ProposedStudySequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Proposed Study Sequence</tag>
    <tag group=\"2130\" element=\"00C0\" keyword=\"OriginalImageSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Original Image Sequence</tag>
    <tag group=\"2200\" element=\"0001\" keyword=\"LabelUsingInformationExtractedFromInstances\" vr=\"CS\" vm=\"1\">Label Using Information Extracted From Instances</tag>
    <tag group=\"2200\" element=\"0002\" keyword=\"LabelText\" vr=\"UT\" vm=\"1\">Label Text</tag>
    <tag group=\"2200\" element=\"0003\" keyword=\"LabelStyleSelection\" vr=\"CS\" vm=\"1\">Label Style Selection</tag>
    <tag group=\"2200\" element=\"0004\" keyword=\"MediaDisposition\" vr=\"LT\" vm=\"1\">Media Disposition</tag>
    <tag group=\"2200\" element=\"0005\" keyword=\"BarcodeValue\" vr=\"LT\" vm=\"1\">Barcode Value</tag>
    <tag group=\"2200\" element=\"0006\" keyword=\"BarcodeSymbology\" vr=\"CS\" vm=\"1\">Barcode Symbology</tag>
    <tag group=\"2200\" element=\"0007\" keyword=\"AllowMediaSplitting\" vr=\"CS\" vm=\"1\">Allow Media Splitting</tag>
    <tag group=\"2200\" element=\"0008\" keyword=\"IncludeNonDICOMObjects\" vr=\"CS\" vm=\"1\">Include Non-DICOM Objects</tag>
    <tag group=\"2200\" element=\"0009\" keyword=\"IncludeDisplayApplication\" vr=\"CS\" vm=\"1\">Include Display Application</tag>
    <tag group=\"2200\" element=\"000A\" keyword=\"PreserveCompositeInstancesAfterMediaCreation\" vr=\"CS\" vm=\"1\">Preserve Composite Instances After Media Creation</tag>
    <tag group=\"2200\" element=\"000B\" keyword=\"TotalNumberOfPiecesOfMediaCreated\" vr=\"US\" vm=\"1\">Total Number of Pieces of Media Created</tag>
    <tag group=\"2200\" element=\"000C\" keyword=\"RequestedMediaApplicationProfile\" vr=\"LO\" vm=\"1\">Requested Media Application Profile</tag>
    <tag group=\"2200\" element=\"000D\" keyword=\"ReferencedStorageMediaSequence\" vr=\"SQ\" vm=\"1\">Referenced Storage Media Sequence</tag>
    <tag group=\"2200\" element=\"000E\" keyword=\"FailureAttributes\" vr=\"AT\" vm=\"1-n\">Failure Attributes</tag>
    <tag group=\"2200\" element=\"000F\" keyword=\"AllowLossyCompression\" vr=\"CS\" vm=\"1\">Allow Lossy Compression</tag>
    <tag group=\"2200\" element=\"0020\" keyword=\"RequestPriority\" vr=\"CS\" vm=\"1\">Request Priority</tag>
    <tag group=\"3002\" element=\"0002\" keyword=\"RTImageLabel\" vr=\"SH\" vm=\"1\">RT Image Label</tag>
    <tag group=\"3002\" element=\"0003\" keyword=\"RTImageName\" vr=\"LO\" vm=\"1\">RT Image Name</tag>
    <tag group=\"3002\" element=\"0004\" keyword=\"RTImageDescription\" vr=\"ST\" vm=\"1\">RT Image Description</tag>
    <tag group=\"3002\" element=\"000A\" keyword=\"ReportedValuesOrigin\" vr=\"CS\" vm=\"1\">Reported Values Origin</tag>
    <tag group=\"3002\" element=\"000C\" keyword=\"RTImagePlane\" vr=\"CS\" vm=\"1\">RT Image Plane</tag>
    <tag group=\"3002\" element=\"000D\" keyword=\"XRayImageReceptorTranslation\" vr=\"DS\" vm=\"3\">X-Ray Image Receptor Translation</tag>
    <tag group=\"3002\" element=\"000E\" keyword=\"XRayImageReceptorAngle\" vr=\"DS\" vm=\"1\">X-Ray Image Receptor Angle</tag>
    <tag group=\"3002\" element=\"0010\" keyword=\"RTImageOrientation\" vr=\"DS\" vm=\"6\">RT Image Orientation</tag>
    <tag group=\"3002\" element=\"0011\" keyword=\"ImagePlanePixelSpacing\" vr=\"DS\" vm=\"2\">Image Plane Pixel Spacing</tag>
    <tag group=\"3002\" element=\"0012\" keyword=\"RTImagePosition\" vr=\"DS\" vm=\"2\">RT Image Position</tag>
    <tag group=\"3002\" element=\"0020\" keyword=\"RadiationMachineName\" vr=\"SH\" vm=\"1\">Radiation Machine Name</tag>
    <tag group=\"3002\" element=\"0022\" keyword=\"RadiationMachineSAD\" vr=\"DS\" vm=\"1\">Radiation Machine SAD</tag>
    <tag group=\"3002\" element=\"0024\" keyword=\"RadiationMachineSSD\" vr=\"DS\" vm=\"1\">Radiation Machine SSD</tag>
    <tag group=\"3002\" element=\"0026\" keyword=\"RTImageSID\" vr=\"DS\" vm=\"1\">RT Image SID</tag>
    <tag group=\"3002\" element=\"0028\" keyword=\"SourceToReferenceObjectDistance\" vr=\"DS\" vm=\"1\">Source to Reference Object Distance</tag>
    <tag group=\"3002\" element=\"0029\" keyword=\"FractionNumber\" vr=\"IS\" vm=\"1\">Fraction Number</tag>
    <tag group=\"3002\" element=\"0030\" keyword=\"ExposureSequence\" vr=\"SQ\" vm=\"1\">Exposure Sequence</tag>
    <tag group=\"3002\" element=\"0032\" keyword=\"MetersetExposure\" vr=\"DS\" vm=\"1\">Meterset Exposure</tag>
    <tag group=\"3002\" element=\"0034\" keyword=\"DiaphragmPosition\" vr=\"DS\" vm=\"4\">Diaphragm Position</tag>
    <tag group=\"3002\" element=\"0040\" keyword=\"FluenceMapSequence\" vr=\"SQ\" vm=\"1\">Fluence Map Sequence</tag>
    <tag group=\"3002\" element=\"0041\" keyword=\"FluenceDataSource\" vr=\"CS\" vm=\"1\">Fluence Data Source</tag>
    <tag group=\"3002\" element=\"0042\" keyword=\"FluenceDataScale\" vr=\"DS\" vm=\"1\">Fluence Data Scale</tag>
    <tag group=\"3002\" element=\"0050\" keyword=\"PrimaryFluenceModeSequence\" vr=\"SQ\" vm=\"1\">Primary Fluence Mode Sequence</tag>
    <tag group=\"3002\" element=\"0051\" keyword=\"FluenceMode\" vr=\"CS\" vm=\"1\">Fluence Mode</tag>
    <tag group=\"3002\" element=\"0052\" keyword=\"FluenceModeID\" vr=\"SH\" vm=\"1\">Fluence Mode ID</tag>
    <tag group=\"3004\" element=\"0001\" keyword=\"DVHType\" vr=\"CS\" vm=\"1\">DVH Type</tag>
    <tag group=\"3004\" element=\"0002\" keyword=\"DoseUnits\" vr=\"CS\" vm=\"1\">Dose Units</tag>
    <tag group=\"3004\" element=\"0004\" keyword=\"DoseType\" vr=\"CS\" vm=\"1\">Dose Type</tag>
    <tag group=\"3004\" element=\"0005\" keyword=\"SpatialTransformOfDose\" vr=\"CS\" vm=\"1\">Spatial Transform of Dose</tag>
    <tag group=\"3004\" element=\"0006\" keyword=\"DoseComment\" vr=\"LO\" vm=\"1\">Dose Comment</tag>
    <tag group=\"3004\" element=\"0008\" keyword=\"NormalizationPoint\" vr=\"DS\" vm=\"3\">Normalization Point</tag>
    <tag group=\"3004\" element=\"000A\" keyword=\"DoseSummationType\" vr=\"CS\" vm=\"1\">Dose Summation Type</tag>
    <tag group=\"3004\" element=\"000C\" keyword=\"GridFrameOffsetVector\" vr=\"DS\" vm=\"2-n\">Grid Frame Offset Vector</tag>
    <tag group=\"3004\" element=\"000E\" keyword=\"DoseGridScaling\" vr=\"DS\" vm=\"1\">Dose Grid Scaling</tag>
    <tag group=\"3004\" element=\"0010\" keyword=\"RTDoseROISequence\" vr=\"SQ\" vm=\"1\">RT Dose ROI Sequence</tag>
    <tag group=\"3004\" element=\"0012\" keyword=\"DoseValue\" vr=\"DS\" vm=\"1\">Dose Value</tag>
    <tag group=\"3004\" element=\"0014\" keyword=\"TissueHeterogeneityCorrection\" vr=\"CS\" vm=\"1-3\">Tissue Heterogeneity Correction</tag>
    <tag group=\"3004\" element=\"0040\" keyword=\"DVHNormalizationPoint\" vr=\"DS\" vm=\"3\">DVH Normalization Point</tag>
    <tag group=\"3004\" element=\"0042\" keyword=\"DVHNormalizationDoseValue\" vr=\"DS\" vm=\"1\">DVH Normalization Dose Value</tag>
    <tag group=\"3004\" element=\"0050\" keyword=\"DVHSequence\" vr=\"SQ\" vm=\"1\">DVH Sequence</tag>
    <tag group=\"3004\" element=\"0052\" keyword=\"DVHDoseScaling\" vr=\"DS\" vm=\"1\">DVH Dose Scaling</tag>
    <tag group=\"3004\" element=\"0054\" keyword=\"DVHVolumeUnits\" vr=\"CS\" vm=\"1\">DVH Volume Units</tag>
    <tag group=\"3004\" element=\"0056\" keyword=\"DVHNumberOfBins\" vr=\"IS\" vm=\"1\">DVH Number of Bins</tag>
    <tag group=\"3004\" element=\"0058\" keyword=\"DVHData\" vr=\"DS\" vm=\"2-2n\">DVH Data</tag>
    <tag group=\"3004\" element=\"0060\" keyword=\"DVHReferencedROISequence\" vr=\"SQ\" vm=\"1\">DVH Referenced ROI Sequence</tag>
    <tag group=\"3004\" element=\"0062\" keyword=\"DVHROIContributionType\" vr=\"CS\" vm=\"1\">DVH ROI Contribution Type</tag>
    <tag group=\"3004\" element=\"0070\" keyword=\"DVHMinimumDose\" vr=\"DS\" vm=\"1\">DVH Minimum Dose</tag>
    <tag group=\"3004\" element=\"0072\" keyword=\"DVHMaximumDose\" vr=\"DS\" vm=\"1\">DVH Maximum Dose</tag>
    <tag group=\"3004\" element=\"0074\" keyword=\"DVHMeanDose\" vr=\"DS\" vm=\"1\">DVH Mean Dose</tag>
    <tag group=\"3006\" element=\"0002\" keyword=\"StructureSetLabel\" vr=\"SH\" vm=\"1\">Structure Set Label</tag>
    <tag group=\"3006\" element=\"0004\" keyword=\"StructureSetName\" vr=\"LO\" vm=\"1\">Structure Set Name</tag>
    <tag group=\"3006\" element=\"0006\" keyword=\"StructureSetDescription\" vr=\"ST\" vm=\"1\">Structure Set Description</tag>
    <tag group=\"3006\" element=\"0008\" keyword=\"StructureSetDate\" vr=\"DA\" vm=\"1\">Structure Set Date</tag>
    <tag group=\"3006\" element=\"0009\" keyword=\"StructureSetTime\" vr=\"TM\" vm=\"1\">Structure Set Time</tag>
    <tag group=\"3006\" element=\"0010\" keyword=\"ReferencedFrameOfReferenceSequence\" vr=\"SQ\" vm=\"1\">Referenced Frame of Reference Sequence</tag>
    <tag group=\"3006\" element=\"0012\" keyword=\"RTReferencedStudySequence\" vr=\"SQ\" vm=\"1\">RT Referenced Study Sequence</tag>
    <tag group=\"3006\" element=\"0014\" keyword=\"RTReferencedSeriesSequence\" vr=\"SQ\" vm=\"1\">RT Referenced Series Sequence</tag>
    <tag group=\"3006\" element=\"0016\" keyword=\"ContourImageSequence\" vr=\"SQ\" vm=\"1\">Contour Image Sequence</tag>
    <tag group=\"3006\" element=\"0018\" keyword=\"PredecessorStructureSetSequence\" vr=\"SQ\" vm=\"1\">Predecessor Structure Set Sequence</tag>
    <tag group=\"3006\" element=\"0020\" keyword=\"StructureSetROISequence\" vr=\"SQ\" vm=\"1\">Structure Set ROI Sequence</tag>
    <tag group=\"3006\" element=\"0022\" keyword=\"ROINumber\" vr=\"IS\" vm=\"1\">ROI Number</tag>
    <tag group=\"3006\" element=\"0024\" keyword=\"ReferencedFrameOfReferenceUID\" vr=\"UI\" vm=\"1\">Referenced Frame of Reference UID</tag>
    <tag group=\"3006\" element=\"0026\" keyword=\"ROIName\" vr=\"LO\" vm=\"1\">ROI Name</tag>
    <tag group=\"3006\" element=\"0028\" keyword=\"ROIDescription\" vr=\"ST\" vm=\"1\">ROI Description</tag>
    <tag group=\"3006\" element=\"002A\" keyword=\"ROIDisplayColor\" vr=\"IS\" vm=\"3\">ROI Display Color</tag>
    <tag group=\"3006\" element=\"002C\" keyword=\"ROIVolume\" vr=\"DS\" vm=\"1\">ROI Volume</tag>
    <tag group=\"3006\" element=\"0030\" keyword=\"RTRelatedROISequence\" vr=\"SQ\" vm=\"1\">RT Related ROI Sequence</tag>
    <tag group=\"3006\" element=\"0033\" keyword=\"RTROIRelationship\" vr=\"CS\" vm=\"1\">RT ROI Relationship</tag>
    <tag group=\"3006\" element=\"0036\" keyword=\"ROIGenerationAlgorithm\" vr=\"CS\" vm=\"1\">ROI Generation Algorithm</tag>
    <tag group=\"3006\" element=\"0038\" keyword=\"ROIGenerationDescription\" vr=\"LO\" vm=\"1\">ROI Generation Description</tag>
    <tag group=\"3006\" element=\"0039\" keyword=\"ROIContourSequence\" vr=\"SQ\" vm=\"1\">ROI Contour Sequence</tag>
    <tag group=\"3006\" element=\"0040\" keyword=\"ContourSequence\" vr=\"SQ\" vm=\"1\">Contour Sequence</tag>
    <tag group=\"3006\" element=\"0042\" keyword=\"ContourGeometricType\" vr=\"CS\" vm=\"1\">Contour Geometric Type</tag>
    <tag group=\"3006\" element=\"0044\" keyword=\"ContourSlabThickness\" vr=\"DS\" vm=\"1\">Contour Slab Thickness</tag>
    <tag group=\"3006\" element=\"0045\" keyword=\"ContourOffsetVector\" vr=\"DS\" vm=\"3\">Contour Offset Vector</tag>
    <tag group=\"3006\" element=\"0046\" keyword=\"NumberOfContourPoints\" vr=\"IS\" vm=\"1\">Number of Contour Points</tag>
    <tag group=\"3006\" element=\"0048\" keyword=\"ContourNumber\" vr=\"IS\" vm=\"1\">Contour Number</tag>
    <tag group=\"3006\" element=\"0049\" keyword=\"AttachedContours\" vr=\"IS\" vm=\"1-n\">Attached Contours</tag>
    <tag group=\"3006\" element=\"0050\" keyword=\"ContourData\" vr=\"DS\" vm=\"3-3n\">Contour Data</tag>
    <tag group=\"3006\" element=\"0080\" keyword=\"RTROIObservationsSequence\" vr=\"SQ\" vm=\"1\">RT ROI Observations Sequence</tag>
    <tag group=\"3006\" element=\"0082\" keyword=\"ObservationNumber\" vr=\"IS\" vm=\"1\">Observation Number</tag>
    <tag group=\"3006\" element=\"0084\" keyword=\"ReferencedROINumber\" vr=\"IS\" vm=\"1\">Referenced ROI Number</tag>
    <tag group=\"3006\" element=\"0085\" keyword=\"ROIObservationLabel\" vr=\"SH\" vm=\"1\">ROI Observation Label</tag>
    <tag group=\"3006\" element=\"0086\" keyword=\"RTROIIdentificationCodeSequence\" vr=\"SQ\" vm=\"1\">RT ROI Identification Code Sequence</tag>
    <tag group=\"3006\" element=\"0088\" keyword=\"ROIObservationDescription\" vr=\"ST\" vm=\"1\">ROI Observation Description</tag>
    <tag group=\"3006\" element=\"00A0\" keyword=\"RelatedRTROIObservationsSequence\" vr=\"SQ\" vm=\"1\">Related RT ROI Observations Sequence</tag>
    <tag group=\"3006\" element=\"00A4\" keyword=\"RTROIInterpretedType\" vr=\"CS\" vm=\"1\">RT ROI Interpreted Type</tag>
    <tag group=\"3006\" element=\"00A6\" keyword=\"ROIInterpreter\" vr=\"PN\" vm=\"1\">ROI Interpreter</tag>
    <tag group=\"3006\" element=\"00B0\" keyword=\"ROIPhysicalPropertiesSequence\" vr=\"SQ\" vm=\"1\">ROI Physical Properties Sequence</tag>
    <tag group=\"3006\" element=\"00B2\" keyword=\"ROIPhysicalProperty\" vr=\"CS\" vm=\"1\">ROI Physical Property</tag>
    <tag group=\"3006\" element=\"00B4\" keyword=\"ROIPhysicalPropertyValue\" vr=\"DS\" vm=\"1\">ROI Physical Property Value</tag>
    <tag group=\"3006\" element=\"00B6\" keyword=\"ROIElementalCompositionSequence\" vr=\"SQ\" vm=\"1\">ROI Elemental Composition Sequence</tag>
    <tag group=\"3006\" element=\"00B7\" keyword=\"ROIElementalCompositionAtomicNumber\" vr=\"US\" vm=\"1\">ROI Elemental Composition Atomic Number</tag>
    <tag group=\"3006\" element=\"00B8\" keyword=\"ROIElementalCompositionAtomicMassFraction\" vr=\"FL\" vm=\"1\">ROI Elemental Composition Atomic Mass Fraction</tag>
    <tag group=\"3006\" element=\"00B9\" keyword=\"AdditionalRTROIIdentificationCodeSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Additional RT ROI Identification Code Sequence</tag>
    <tag group=\"3006\" element=\"00C0\" keyword=\"FrameOfReferenceRelationshipSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Frame of Reference Relationship Sequence</tag>
    <tag group=\"3006\" element=\"00C2\" keyword=\"RelatedFrameOfReferenceUID\" vr=\"UI\" vm=\"1\" retired=\"true\">Related Frame of Reference UID</tag>
    <tag group=\"3006\" element=\"00C4\" keyword=\"FrameOfReferenceTransformationType\" vr=\"CS\" vm=\"1\" retired=\"true\">Frame of Reference Transformation Type</tag>
    <tag group=\"3006\" element=\"00C6\" keyword=\"FrameOfReferenceTransformationMatrix\" vr=\"DS\" vm=\"16\">Frame of Reference Transformation Matrix</tag>
    <tag group=\"3006\" element=\"00C8\" keyword=\"FrameOfReferenceTransformationComment\" vr=\"LO\" vm=\"1\">Frame of Reference Transformation Comment</tag>
    <tag group=\"3008\" element=\"0010\" keyword=\"MeasuredDoseReferenceSequence\" vr=\"SQ\" vm=\"1\">Measured Dose Reference Sequence</tag>
    <tag group=\"3008\" element=\"0012\" keyword=\"MeasuredDoseDescription\" vr=\"ST\" vm=\"1\">Measured Dose Description</tag>
    <tag group=\"3008\" element=\"0014\" keyword=\"MeasuredDoseType\" vr=\"CS\" vm=\"1\">Measured Dose Type</tag>
    <tag group=\"3008\" element=\"0016\" keyword=\"MeasuredDoseValue\" vr=\"DS\" vm=\"1\">Measured Dose Value</tag>
    <tag group=\"3008\" element=\"0020\" keyword=\"TreatmentSessionBeamSequence\" vr=\"SQ\" vm=\"1\">Treatment Session Beam Sequence</tag>
    <tag group=\"3008\" element=\"0021\" keyword=\"TreatmentSessionIonBeamSequence\" vr=\"SQ\" vm=\"1\">Treatment Session Ion Beam Sequence</tag>
    <tag group=\"3008\" element=\"0022\" keyword=\"CurrentFractionNumber\" vr=\"IS\" vm=\"1\">Current Fraction Number</tag>
    <tag group=\"3008\" element=\"0024\" keyword=\"TreatmentControlPointDate\" vr=\"DA\" vm=\"1\">Treatment Control Point Date</tag>
    <tag group=\"3008\" element=\"0025\" keyword=\"TreatmentControlPointTime\" vr=\"TM\" vm=\"1\">Treatment Control Point Time</tag>
    <tag group=\"3008\" element=\"002A\" keyword=\"TreatmentTerminationStatus\" vr=\"CS\" vm=\"1\">Treatment Termination Status</tag>
    <tag group=\"3008\" element=\"002B\" keyword=\"TreatmentTerminationCode\" vr=\"SH\" vm=\"1\">Treatment Termination Code</tag>
    <tag group=\"3008\" element=\"002C\" keyword=\"TreatmentVerificationStatus\" vr=\"CS\" vm=\"1\">Treatment Verification Status</tag>
    <tag group=\"3008\" element=\"0030\" keyword=\"ReferencedTreatmentRecordSequence\" vr=\"SQ\" vm=\"1\">Referenced Treatment Record Sequence</tag>
    <tag group=\"3008\" element=\"0032\" keyword=\"SpecifiedPrimaryMeterset\" vr=\"DS\" vm=\"1\">Specified Primary Meterset</tag>
    <tag group=\"3008\" element=\"0033\" keyword=\"SpecifiedSecondaryMeterset\" vr=\"DS\" vm=\"1\">Specified Secondary Meterset</tag>
    <tag group=\"3008\" element=\"0036\" keyword=\"DeliveredPrimaryMeterset\" vr=\"DS\" vm=\"1\">Delivered Primary Meterset</tag>
    <tag group=\"3008\" element=\"0037\" keyword=\"DeliveredSecondaryMeterset\" vr=\"DS\" vm=\"1\">Delivered Secondary Meterset</tag>
    <tag group=\"3008\" element=\"003A\" keyword=\"SpecifiedTreatmentTime\" vr=\"DS\" vm=\"1\">Specified Treatment Time</tag>
    <tag group=\"3008\" element=\"003B\" keyword=\"DeliveredTreatmentTime\" vr=\"DS\" vm=\"1\">Delivered Treatment Time</tag>
    <tag group=\"3008\" element=\"0040\" keyword=\"ControlPointDeliverySequence\" vr=\"SQ\" vm=\"1\">Control Point Delivery Sequence</tag>
    <tag group=\"3008\" element=\"0041\" keyword=\"IonControlPointDeliverySequence\" vr=\"SQ\" vm=\"1\">Ion Control Point Delivery Sequence</tag>
    <tag group=\"3008\" element=\"0042\" keyword=\"SpecifiedMeterset\" vr=\"DS\" vm=\"1\">Specified Meterset</tag>
    <tag group=\"3008\" element=\"0044\" keyword=\"DeliveredMeterset\" vr=\"DS\" vm=\"1\">Delivered Meterset</tag>
    <tag group=\"3008\" element=\"0045\" keyword=\"MetersetRateSet\" vr=\"FL\" vm=\"1\">Meterset Rate Set</tag>
    <tag group=\"3008\" element=\"0046\" keyword=\"MetersetRateDelivered\" vr=\"FL\" vm=\"1\">Meterset Rate Delivered</tag>
    <tag group=\"3008\" element=\"0047\" keyword=\"ScanSpotMetersetsDelivered\" vr=\"FL\" vm=\"1-n\">Scan Spot Metersets Delivered</tag>
    <tag group=\"3008\" element=\"0048\" keyword=\"DoseRateDelivered\" vr=\"DS\" vm=\"1\">Dose Rate Delivered</tag>
    <tag group=\"3008\" element=\"0050\" keyword=\"TreatmentSummaryCalculatedDoseReferenceSequence\" vr=\"SQ\" vm=\"1\">Treatment Summary Calculated Dose Reference Sequence</tag>
    <tag group=\"3008\" element=\"0052\" keyword=\"CumulativeDoseToDoseReference\" vr=\"DS\" vm=\"1\">Cumulative Dose to Dose Reference</tag>
    <tag group=\"3008\" element=\"0054\" keyword=\"FirstTreatmentDate\" vr=\"DA\" vm=\"1\">First Treatment Date</tag>
    <tag group=\"3008\" element=\"0056\" keyword=\"MostRecentTreatmentDate\" vr=\"DA\" vm=\"1\">Most Recent Treatment Date</tag>
    <tag group=\"3008\" element=\"005A\" keyword=\"NumberOfFractionsDelivered\" vr=\"IS\" vm=\"1\">Number of Fractions Delivered</tag>
    <tag group=\"3008\" element=\"0060\" keyword=\"OverrideSequence\" vr=\"SQ\" vm=\"1\">Override Sequence</tag>
    <tag group=\"3008\" element=\"0061\" keyword=\"ParameterSequencePointer\" vr=\"AT\" vm=\"1\">Parameter Sequence Pointer</tag>
    <tag group=\"3008\" element=\"0062\" keyword=\"OverrideParameterPointer\" vr=\"AT\" vm=\"1\">Override Parameter Pointer</tag>
    <tag group=\"3008\" element=\"0063\" keyword=\"ParameterItemIndex\" vr=\"IS\" vm=\"1\">Parameter Item Index</tag>
    <tag group=\"3008\" element=\"0064\" keyword=\"MeasuredDoseReferenceNumber\" vr=\"IS\" vm=\"1\">Measured Dose Reference Number</tag>
    <tag group=\"3008\" element=\"0065\" keyword=\"ParameterPointer\" vr=\"AT\" vm=\"1\">Parameter Pointer</tag>
    <tag group=\"3008\" element=\"0066\" keyword=\"OverrideReason\" vr=\"ST\" vm=\"1\">Override Reason</tag>
    <tag group=\"3008\" element=\"0067\" keyword=\"ParameterValueNumber\" vr=\"US\" vm=\"1\">Parameter Value Number</tag>
    <tag group=\"3008\" element=\"0068\" keyword=\"CorrectedParameterSequence\" vr=\"SQ\" vm=\"1\">Corrected Parameter Sequence</tag>
    <tag group=\"3008\" element=\"006A\" keyword=\"CorrectionValue\" vr=\"FL\" vm=\"1\">Correction Value</tag>
    <tag group=\"3008\" element=\"0070\" keyword=\"CalculatedDoseReferenceSequence\" vr=\"SQ\" vm=\"1\">Calculated Dose Reference Sequence</tag>
    <tag group=\"3008\" element=\"0072\" keyword=\"CalculatedDoseReferenceNumber\" vr=\"IS\" vm=\"1\">Calculated Dose Reference Number</tag>
    <tag group=\"3008\" element=\"0074\" keyword=\"CalculatedDoseReferenceDescription\" vr=\"ST\" vm=\"1\">Calculated Dose Reference Description</tag>
    <tag group=\"3008\" element=\"0076\" keyword=\"CalculatedDoseReferenceDoseValue\" vr=\"DS\" vm=\"1\">Calculated Dose Reference Dose Value</tag>
    <tag group=\"3008\" element=\"0078\" keyword=\"StartMeterset\" vr=\"DS\" vm=\"1\">Start Meterset</tag>
    <tag group=\"3008\" element=\"007A\" keyword=\"EndMeterset\" vr=\"DS\" vm=\"1\">End Meterset</tag>
    <tag group=\"3008\" element=\"0080\" keyword=\"ReferencedMeasuredDoseReferenceSequence\" vr=\"SQ\" vm=\"1\">Referenced Measured Dose Reference Sequence</tag>
    <tag group=\"3008\" element=\"0082\" keyword=\"ReferencedMeasuredDoseReferenceNumber\" vr=\"IS\" vm=\"1\">Referenced Measured Dose Reference Number</tag>
    <tag group=\"3008\" element=\"0090\" keyword=\"ReferencedCalculatedDoseReferenceSequence\" vr=\"SQ\" vm=\"1\">Referenced Calculated Dose Reference Sequence</tag>
    <tag group=\"3008\" element=\"0092\" keyword=\"ReferencedCalculatedDoseReferenceNumber\" vr=\"IS\" vm=\"1\">Referenced Calculated Dose Reference Number</tag>
    <tag group=\"3008\" element=\"00A0\" keyword=\"BeamLimitingDeviceLeafPairsSequence\" vr=\"SQ\" vm=\"1\">Beam Limiting Device Leaf Pairs Sequence</tag>
    <tag group=\"3008\" element=\"00B0\" keyword=\"RecordedWedgeSequence\" vr=\"SQ\" vm=\"1\">Recorded Wedge Sequence</tag>
    <tag group=\"3008\" element=\"00C0\" keyword=\"RecordedCompensatorSequence\" vr=\"SQ\" vm=\"1\">Recorded Compensator Sequence</tag>
    <tag group=\"3008\" element=\"00D0\" keyword=\"RecordedBlockSequence\" vr=\"SQ\" vm=\"1\">Recorded Block Sequence</tag>
    <tag group=\"3008\" element=\"00E0\" keyword=\"TreatmentSummaryMeasuredDoseReferenceSequence\" vr=\"SQ\" vm=\"1\">Treatment Summary Measured Dose Reference Sequence</tag>
    <tag group=\"3008\" element=\"00F0\" keyword=\"RecordedSnoutSequence\" vr=\"SQ\" vm=\"1\">Recorded Snout Sequence</tag>
    <tag group=\"3008\" element=\"00F2\" keyword=\"RecordedRangeShifterSequence\" vr=\"SQ\" vm=\"1\">Recorded Range Shifter Sequence</tag>
    <tag group=\"3008\" element=\"00F4\" keyword=\"RecordedLateralSpreadingDeviceSequence\" vr=\"SQ\" vm=\"1\">Recorded Lateral Spreading Device Sequence</tag>
    <tag group=\"3008\" element=\"00F6\" keyword=\"RecordedRangeModulatorSequence\" vr=\"SQ\" vm=\"1\">Recorded Range Modulator Sequence</tag>
    <tag group=\"3008\" element=\"0100\" keyword=\"RecordedSourceSequence\" vr=\"SQ\" vm=\"1\">Recorded Source Sequence</tag>
    <tag group=\"3008\" element=\"0105\" keyword=\"SourceSerialNumber\" vr=\"LO\" vm=\"1\">Source Serial Number</tag>
    <tag group=\"3008\" element=\"0110\" keyword=\"TreatmentSessionApplicationSetupSequence\" vr=\"SQ\" vm=\"1\">Treatment Session Application Setup Sequence</tag>
    <tag group=\"3008\" element=\"0116\" keyword=\"ApplicationSetupCheck\" vr=\"CS\" vm=\"1\">Application Setup Check</tag>
    <tag group=\"3008\" element=\"0120\" keyword=\"RecordedBrachyAccessoryDeviceSequence\" vr=\"SQ\" vm=\"1\">Recorded Brachy Accessory Device Sequence</tag>
    <tag group=\"3008\" element=\"0122\" keyword=\"ReferencedBrachyAccessoryDeviceNumber\" vr=\"IS\" vm=\"1\">Referenced Brachy Accessory Device Number</tag>
    <tag group=\"3008\" element=\"0130\" keyword=\"RecordedChannelSequence\" vr=\"SQ\" vm=\"1\">Recorded Channel Sequence</tag>
    <tag group=\"3008\" element=\"0132\" keyword=\"SpecifiedChannelTotalTime\" vr=\"DS\" vm=\"1\">Specified Channel Total Time</tag>
    <tag group=\"3008\" element=\"0134\" keyword=\"DeliveredChannelTotalTime\" vr=\"DS\" vm=\"1\">Delivered Channel Total Time</tag>
    <tag group=\"3008\" element=\"0136\" keyword=\"SpecifiedNumberOfPulses\" vr=\"IS\" vm=\"1\">Specified Number of Pulses</tag>
    <tag group=\"3008\" element=\"0138\" keyword=\"DeliveredNumberOfPulses\" vr=\"IS\" vm=\"1\">Delivered Number of Pulses</tag>
    <tag group=\"3008\" element=\"013A\" keyword=\"SpecifiedPulseRepetitionInterval\" vr=\"DS\" vm=\"1\">Specified Pulse Repetition Interval</tag>
    <tag group=\"3008\" element=\"013C\" keyword=\"DeliveredPulseRepetitionInterval\" vr=\"DS\" vm=\"1\">Delivered Pulse Repetition Interval</tag>
    <tag group=\"3008\" element=\"0140\" keyword=\"RecordedSourceApplicatorSequence\" vr=\"SQ\" vm=\"1\">Recorded Source Applicator Sequence</tag>
    <tag group=\"3008\" element=\"0142\" keyword=\"ReferencedSourceApplicatorNumber\" vr=\"IS\" vm=\"1\">Referenced Source Applicator Number</tag>
    <tag group=\"3008\" element=\"0150\" keyword=\"RecordedChannelShieldSequence\" vr=\"SQ\" vm=\"1\">Recorded Channel Shield Sequence</tag>
    <tag group=\"3008\" element=\"0152\" keyword=\"ReferencedChannelShieldNumber\" vr=\"IS\" vm=\"1\">Referenced Channel Shield Number</tag>
    <tag group=\"3008\" element=\"0160\" keyword=\"BrachyControlPointDeliveredSequence\" vr=\"SQ\" vm=\"1\">Brachy Control Point Delivered Sequence</tag>
    <tag group=\"3008\" element=\"0162\" keyword=\"SafePositionExitDate\" vr=\"DA\" vm=\"1\">Safe Position Exit Date</tag>
    <tag group=\"3008\" element=\"0164\" keyword=\"SafePositionExitTime\" vr=\"TM\" vm=\"1\">Safe Position Exit Time</tag>
    <tag group=\"3008\" element=\"0166\" keyword=\"SafePositionReturnDate\" vr=\"DA\" vm=\"1\">Safe Position Return Date</tag>
    <tag group=\"3008\" element=\"0168\" keyword=\"SafePositionReturnTime\" vr=\"TM\" vm=\"1\">Safe Position Return Time</tag>
    <tag group=\"3008\" element=\"0171\" keyword=\"PulseSpecificBrachyControlPointDeliveredSequence\" vr=\"SQ\" vm=\"1\">Pulse Specific Brachy Control Point Delivered Sequence</tag>
    <tag group=\"3008\" element=\"0172\" keyword=\"PulseNumber\" vr=\"US\" vm=\"1\">Pulse Number</tag>
    <tag group=\"3008\" element=\"0173\" keyword=\"BrachyPulseControlPointDeliveredSequence\" vr=\"SQ\" vm=\"1\">Brachy Pulse Control Point Delivered Sequence</tag>
    <tag group=\"3008\" element=\"0200\" keyword=\"CurrentTreatmentStatus\" vr=\"CS\" vm=\"1\">Current Treatment Status</tag>
    <tag group=\"3008\" element=\"0202\" keyword=\"TreatmentStatusComment\" vr=\"ST\" vm=\"1\">Treatment Status Comment</tag>
    <tag group=\"3008\" element=\"0220\" keyword=\"FractionGroupSummarySequence\" vr=\"SQ\" vm=\"1\">Fraction Group Summary Sequence</tag>
    <tag group=\"3008\" element=\"0223\" keyword=\"ReferencedFractionNumber\" vr=\"IS\" vm=\"1\">Referenced Fraction Number</tag>
    <tag group=\"3008\" element=\"0224\" keyword=\"FractionGroupType\" vr=\"CS\" vm=\"1\">Fraction Group Type</tag>
    <tag group=\"3008\" element=\"0230\" keyword=\"BeamStopperPosition\" vr=\"CS\" vm=\"1\">Beam Stopper Position</tag>
    <tag group=\"3008\" element=\"0240\" keyword=\"FractionStatusSummarySequence\" vr=\"SQ\" vm=\"1\">Fraction Status Summary Sequence</tag>
    <tag group=\"3008\" element=\"0250\" keyword=\"TreatmentDate\" vr=\"DA\" vm=\"1\">Treatment Date</tag>
    <tag group=\"3008\" element=\"0251\" keyword=\"TreatmentTime\" vr=\"TM\" vm=\"1\">Treatment Time</tag>
    <tag group=\"300A\" element=\"0002\" keyword=\"RTPlanLabel\" vr=\"SH\" vm=\"1\">RT Plan Label</tag>
    <tag group=\"300A\" element=\"0003\" keyword=\"RTPlanName\" vr=\"LO\" vm=\"1\">RT Plan Name</tag>
    <tag group=\"300A\" element=\"0004\" keyword=\"RTPlanDescription\" vr=\"ST\" vm=\"1\">RT Plan Description</tag>
    <tag group=\"300A\" element=\"0006\" keyword=\"RTPlanDate\" vr=\"DA\" vm=\"1\">RT Plan Date</tag>
    <tag group=\"300A\" element=\"0007\" keyword=\"RTPlanTime\" vr=\"TM\" vm=\"1\">RT Plan Time</tag>
    <tag group=\"300A\" element=\"0009\" keyword=\"TreatmentProtocols\" vr=\"LO\" vm=\"1-n\">Treatment Protocols</tag>
    <tag group=\"300A\" element=\"000A\" keyword=\"PlanIntent\" vr=\"CS\" vm=\"1\">Plan Intent</tag>
    <tag group=\"300A\" element=\"000B\" keyword=\"TreatmentSites\" vr=\"LO\" vm=\"1-n\">Treatment Sites</tag>
    <tag group=\"300A\" element=\"000C\" keyword=\"RTPlanGeometry\" vr=\"CS\" vm=\"1\">RT Plan Geometry</tag>
    <tag group=\"300A\" element=\"000E\" keyword=\"PrescriptionDescription\" vr=\"ST\" vm=\"1\">Prescription Description</tag>
    <tag group=\"300A\" element=\"0010\" keyword=\"DoseReferenceSequence\" vr=\"SQ\" vm=\"1\">Dose Reference Sequence</tag>
    <tag group=\"300A\" element=\"0012\" keyword=\"DoseReferenceNumber\" vr=\"IS\" vm=\"1\">Dose Reference Number</tag>
    <tag group=\"300A\" element=\"0013\" keyword=\"DoseReferenceUID\" vr=\"UI\" vm=\"1\">Dose Reference UID</tag>
    <tag group=\"300A\" element=\"0014\" keyword=\"DoseReferenceStructureType\" vr=\"CS\" vm=\"1\">Dose Reference Structure Type</tag>
    <tag group=\"300A\" element=\"0015\" keyword=\"NominalBeamEnergyUnit\" vr=\"CS\" vm=\"1\">Nominal Beam Energy Unit</tag>
    <tag group=\"300A\" element=\"0016\" keyword=\"DoseReferenceDescription\" vr=\"LO\" vm=\"1\">Dose Reference Description</tag>
    <tag group=\"300A\" element=\"0018\" keyword=\"DoseReferencePointCoordinates\" vr=\"DS\" vm=\"3\">Dose Reference Point Coordinates</tag>
    <tag group=\"300A\" element=\"001A\" keyword=\"NominalPriorDose\" vr=\"DS\" vm=\"1\">Nominal Prior Dose</tag>
    <tag group=\"300A\" element=\"0020\" keyword=\"DoseReferenceType\" vr=\"CS\" vm=\"1\">Dose Reference Type</tag>
    <tag group=\"300A\" element=\"0021\" keyword=\"ConstraintWeight\" vr=\"DS\" vm=\"1\">Constraint Weight</tag>
    <tag group=\"300A\" element=\"0022\" keyword=\"DeliveryWarningDose\" vr=\"DS\" vm=\"1\">Delivery Warning Dose</tag>
    <tag group=\"300A\" element=\"0023\" keyword=\"DeliveryMaximumDose\" vr=\"DS\" vm=\"1\">Delivery Maximum Dose</tag>
    <tag group=\"300A\" element=\"0025\" keyword=\"TargetMinimumDose\" vr=\"DS\" vm=\"1\">Target Minimum Dose</tag>
    <tag group=\"300A\" element=\"0026\" keyword=\"TargetPrescriptionDose\" vr=\"DS\" vm=\"1\">Target Prescription Dose</tag>
    <tag group=\"300A\" element=\"0027\" keyword=\"TargetMaximumDose\" vr=\"DS\" vm=\"1\">Target Maximum Dose</tag>
    <tag group=\"300A\" element=\"0028\" keyword=\"TargetUnderdoseVolumeFraction\" vr=\"DS\" vm=\"1\">Target Underdose Volume Fraction</tag>
    <tag group=\"300A\" element=\"002A\" keyword=\"OrganAtRiskFullVolumeDose\" vr=\"DS\" vm=\"1\">Organ at Risk Full-volume Dose</tag>
    <tag group=\"300A\" element=\"002B\" keyword=\"OrganAtRiskLimitDose\" vr=\"DS\" vm=\"1\">Organ at Risk Limit Dose</tag>
    <tag group=\"300A\" element=\"002C\" keyword=\"OrganAtRiskMaximumDose\" vr=\"DS\" vm=\"1\">Organ at Risk Maximum Dose</tag>
    <tag group=\"300A\" element=\"002D\" keyword=\"OrganAtRiskOverdoseVolumeFraction\" vr=\"DS\" vm=\"1\">Organ at Risk Overdose Volume Fraction</tag>
    <tag group=\"300A\" element=\"0040\" keyword=\"ToleranceTableSequence\" vr=\"SQ\" vm=\"1\">Tolerance Table Sequence</tag>
    <tag group=\"300A\" element=\"0042\" keyword=\"ToleranceTableNumber\" vr=\"IS\" vm=\"1\">Tolerance Table Number</tag>
    <tag group=\"300A\" element=\"0043\" keyword=\"ToleranceTableLabel\" vr=\"SH\" vm=\"1\">Tolerance Table Label</tag>
    <tag group=\"300A\" element=\"0044\" keyword=\"GantryAngleTolerance\" vr=\"DS\" vm=\"1\">Gantry Angle Tolerance</tag>
    <tag group=\"300A\" element=\"0046\" keyword=\"BeamLimitingDeviceAngleTolerance\" vr=\"DS\" vm=\"1\">Beam Limiting Device Angle Tolerance</tag>
    <tag group=\"300A\" element=\"0048\" keyword=\"BeamLimitingDeviceToleranceSequence\" vr=\"SQ\" vm=\"1\">Beam Limiting Device Tolerance Sequence</tag>
    <tag group=\"300A\" element=\"004A\" keyword=\"BeamLimitingDevicePositionTolerance\" vr=\"DS\" vm=\"1\">Beam Limiting Device Position Tolerance</tag>
    <tag group=\"300A\" element=\"004B\" keyword=\"SnoutPositionTolerance\" vr=\"FL\" vm=\"1\">Snout Position Tolerance</tag>
    <tag group=\"300A\" element=\"004C\" keyword=\"PatientSupportAngleTolerance\" vr=\"DS\" vm=\"1\">Patient Support Angle Tolerance</tag>
    <tag group=\"300A\" element=\"004E\" keyword=\"TableTopEccentricAngleTolerance\" vr=\"DS\" vm=\"1\">Table Top Eccentric Angle Tolerance</tag>
    <tag group=\"300A\" element=\"004F\" keyword=\"TableTopPitchAngleTolerance\" vr=\"FL\" vm=\"1\">Table Top Pitch Angle Tolerance</tag>
    <tag group=\"300A\" element=\"0050\" keyword=\"TableTopRollAngleTolerance\" vr=\"FL\" vm=\"1\">Table Top Roll Angle Tolerance</tag>
    <tag group=\"300A\" element=\"0051\" keyword=\"TableTopVerticalPositionTolerance\" vr=\"DS\" vm=\"1\">Table Top Vertical Position Tolerance</tag>
    <tag group=\"300A\" element=\"0052\" keyword=\"TableTopLongitudinalPositionTolerance\" vr=\"DS\" vm=\"1\">Table Top Longitudinal Position Tolerance</tag>
    <tag group=\"300A\" element=\"0053\" keyword=\"TableTopLateralPositionTolerance\" vr=\"DS\" vm=\"1\">Table Top Lateral Position Tolerance</tag>
    <tag group=\"300A\" element=\"0055\" keyword=\"RTPlanRelationship\" vr=\"CS\" vm=\"1\">RT Plan Relationship</tag>
    <tag group=\"300A\" element=\"0070\" keyword=\"FractionGroupSequence\" vr=\"SQ\" vm=\"1\">Fraction Group Sequence</tag>
    <tag group=\"300A\" element=\"0071\" keyword=\"FractionGroupNumber\" vr=\"IS\" vm=\"1\">Fraction Group Number</tag>
    <tag group=\"300A\" element=\"0072\" keyword=\"FractionGroupDescription\" vr=\"LO\" vm=\"1\">Fraction Group Description</tag>
    <tag group=\"300A\" element=\"0078\" keyword=\"NumberOfFractionsPlanned\" vr=\"IS\" vm=\"1\">Number of Fractions Planned</tag>
    <tag group=\"300A\" element=\"0079\" keyword=\"NumberOfFractionPatternDigitsPerDay\" vr=\"IS\" vm=\"1\">Number of Fraction Pattern Digits Per Day</tag>
    <tag group=\"300A\" element=\"007A\" keyword=\"RepeatFractionCycleLength\" vr=\"IS\" vm=\"1\">Repeat Fraction Cycle Length</tag>
    <tag group=\"300A\" element=\"007B\" keyword=\"FractionPattern\" vr=\"LT\" vm=\"1\">Fraction Pattern</tag>
    <tag group=\"300A\" element=\"0080\" keyword=\"NumberOfBeams\" vr=\"IS\" vm=\"1\">Number of Beams</tag>
    <tag group=\"300A\" element=\"0082\" keyword=\"BeamDoseSpecificationPoint\" vr=\"DS\" vm=\"3\">Beam Dose Specification Point</tag>
    <tag group=\"300A\" element=\"0083\" keyword=\"ReferencedDoseReferenceUID\" vr=\"UI\" vm=\"1\">Referenced Dose Reference UID</tag>
    <tag group=\"300A\" element=\"0084\" keyword=\"BeamDose\" vr=\"DS\" vm=\"1\">Beam Dose</tag>
    <tag group=\"300A\" element=\"0086\" keyword=\"BeamMeterset\" vr=\"DS\" vm=\"1\">Beam Meterset</tag>
    <tag group=\"300A\" element=\"0088\" keyword=\"BeamDosePointDepth\" vr=\"FL\" vm=\"1\" retired=\"true\">Beam Dose Point Depth</tag>
    <tag group=\"300A\" element=\"0089\" keyword=\"BeamDosePointEquivalentDepth\" vr=\"FL\" vm=\"1\" retired=\"true\">Beam Dose Point Equivalent Depth</tag>
    <tag group=\"300A\" element=\"008A\" keyword=\"BeamDosePointSSD\" vr=\"FL\" vm=\"1\" retired=\"true\">Beam Dose Point SSD</tag>
    <tag group=\"300A\" element=\"008B\" keyword=\"BeamDoseMeaning\" vr=\"CS\" vm=\"1\">Beam Dose Meaning</tag>
    <tag group=\"300A\" element=\"008C\" keyword=\"BeamDoseVerificationControlPointSequence\" vr=\"SQ\" vm=\"1\">Beam Dose Verification Control Point Sequence</tag>
    <tag group=\"300A\" element=\"008D\" keyword=\"AverageBeamDosePointDepth\" vr=\"FL\" vm=\"1\">Average Beam Dose Point Depth</tag>
    <tag group=\"300A\" element=\"008E\" keyword=\"AverageBeamDosePointEquivalentDepth\" vr=\"FL\" vm=\"1\">Average Beam Dose Point Equivalent Depth</tag>
    <tag group=\"300A\" element=\"008F\" keyword=\"AverageBeamDosePointSSD\" vr=\"FL\" vm=\"1\">Average Beam Dose Point SSD</tag>
    <tag group=\"300A\" element=\"0090\" keyword=\"BeamDoseType\" vr=\"CS\" vm=\"1\">Beam Dose Type</tag>
    <tag group=\"300A\" element=\"0091\" keyword=\"AlternateBeamDose\" vr=\"DS\" vm=\"1\">Alternate Beam Dose</tag>
    <tag group=\"300A\" element=\"0092\" keyword=\"AlternateBeamDoseType\" vr=\"CS\" vm=\"1\">Alternate Beam Dose Type</tag>
    <tag group=\"300A\" element=\"00A0\" keyword=\"NumberOfBrachyApplicationSetups\" vr=\"IS\" vm=\"1\">Number of Brachy Application Setups</tag>
    <tag group=\"300A\" element=\"00A2\" keyword=\"BrachyApplicationSetupDoseSpecificationPoint\" vr=\"DS\" vm=\"3\">Brachy Application Setup Dose Specification Point</tag>
    <tag group=\"300A\" element=\"00A4\" keyword=\"BrachyApplicationSetupDose\" vr=\"DS\" vm=\"1\">Brachy Application Setup Dose</tag>
    <tag group=\"300A\" element=\"00B0\" keyword=\"BeamSequence\" vr=\"SQ\" vm=\"1\">Beam Sequence</tag>
    <tag group=\"300A\" element=\"00B2\" keyword=\"TreatmentMachineName\" vr=\"SH\" vm=\"1\">Treatment Machine Name</tag>
    <tag group=\"300A\" element=\"00B3\" keyword=\"PrimaryDosimeterUnit\" vr=\"CS\" vm=\"1\">Primary Dosimeter Unit</tag>
    <tag group=\"300A\" element=\"00B4\" keyword=\"SourceAxisDistance\" vr=\"DS\" vm=\"1\">Source-Axis Distance</tag>
    <tag group=\"300A\" element=\"00B6\" keyword=\"BeamLimitingDeviceSequence\" vr=\"SQ\" vm=\"1\">Beam Limiting Device Sequence</tag>
    <tag group=\"300A\" element=\"00B8\" keyword=\"RTBeamLimitingDeviceType\" vr=\"CS\" vm=\"1\">RT Beam Limiting Device Type</tag>
    <tag group=\"300A\" element=\"00BA\" keyword=\"SourceToBeamLimitingDeviceDistance\" vr=\"DS\" vm=\"1\">Source to Beam Limiting Device Distance</tag>
    <tag group=\"300A\" element=\"00BB\" keyword=\"IsocenterToBeamLimitingDeviceDistance\" vr=\"FL\" vm=\"1\">Isocenter to Beam Limiting Device Distance</tag>
    <tag group=\"300A\" element=\"00BC\" keyword=\"NumberOfLeafJawPairs\" vr=\"IS\" vm=\"1\">Number of Leaf/Jaw Pairs</tag>
    <tag group=\"300A\" element=\"00BE\" keyword=\"LeafPositionBoundaries\" vr=\"DS\" vm=\"3-n\">Leaf Position Boundaries</tag>
    <tag group=\"300A\" element=\"00C0\" keyword=\"BeamNumber\" vr=\"IS\" vm=\"1\">Beam Number</tag>
    <tag group=\"300A\" element=\"00C2\" keyword=\"BeamName\" vr=\"LO\" vm=\"1\">Beam Name</tag>
    <tag group=\"300A\" element=\"00C3\" keyword=\"BeamDescription\" vr=\"ST\" vm=\"1\">Beam Description</tag>
    <tag group=\"300A\" element=\"00C4\" keyword=\"BeamType\" vr=\"CS\" vm=\"1\">Beam Type</tag>
    <tag group=\"300A\" element=\"00C5\" keyword=\"BeamDeliveryDurationLimit\" vr=\"FD\" vm=\"1\">Beam Delivery Duration Limit</tag>
    <tag group=\"300A\" element=\"00C6\" keyword=\"RadiationType\" vr=\"CS\" vm=\"1\">Radiation Type</tag>
    <tag group=\"300A\" element=\"00C7\" keyword=\"HighDoseTechniqueType\" vr=\"CS\" vm=\"1\">High-Dose Technique Type</tag>
    <tag group=\"300A\" element=\"00C8\" keyword=\"ReferenceImageNumber\" vr=\"IS\" vm=\"1\">Reference Image Number</tag>
    <tag group=\"300A\" element=\"00CA\" keyword=\"PlannedVerificationImageSequence\" vr=\"SQ\" vm=\"1\">Planned Verification Image Sequence</tag>
    <tag group=\"300A\" element=\"00CC\" keyword=\"ImagingDeviceSpecificAcquisitionParameters\" vr=\"LO\" vm=\"1-n\">Imaging Device-Specific Acquisition Parameters</tag>
    <tag group=\"300A\" element=\"00CE\" keyword=\"TreatmentDeliveryType\" vr=\"CS\" vm=\"1\">Treatment Delivery Type</tag>
    <tag group=\"300A\" element=\"00D0\" keyword=\"NumberOfWedges\" vr=\"IS\" vm=\"1\">Number of Wedges</tag>
    <tag group=\"300A\" element=\"00D1\" keyword=\"WedgeSequence\" vr=\"SQ\" vm=\"1\">Wedge Sequence</tag>
    <tag group=\"300A\" element=\"00D2\" keyword=\"WedgeNumber\" vr=\"IS\" vm=\"1\">Wedge Number</tag>
    <tag group=\"300A\" element=\"00D3\" keyword=\"WedgeType\" vr=\"CS\" vm=\"1\">Wedge Type</tag>
    <tag group=\"300A\" element=\"00D4\" keyword=\"WedgeID\" vr=\"SH\" vm=\"1\">Wedge ID</tag>
    <tag group=\"300A\" element=\"00D5\" keyword=\"WedgeAngle\" vr=\"IS\" vm=\"1\">Wedge Angle</tag>
    <tag group=\"300A\" element=\"00D6\" keyword=\"WedgeFactor\" vr=\"DS\" vm=\"1\">Wedge Factor</tag>
    <tag group=\"300A\" element=\"00D7\" keyword=\"TotalWedgeTrayWaterEquivalentThickness\" vr=\"FL\" vm=\"1\">Total Wedge Tray Water-Equivalent Thickness</tag>
    <tag group=\"300A\" element=\"00D8\" keyword=\"WedgeOrientation\" vr=\"DS\" vm=\"1\">Wedge Orientation</tag>
    <tag group=\"300A\" element=\"00D9\" keyword=\"IsocenterToWedgeTrayDistance\" vr=\"FL\" vm=\"1\">Isocenter to Wedge Tray Distance</tag>
    <tag group=\"300A\" element=\"00DA\" keyword=\"SourceToWedgeTrayDistance\" vr=\"DS\" vm=\"1\">Source to Wedge Tray Distance</tag>
    <tag group=\"300A\" element=\"00DB\" keyword=\"WedgeThinEdgePosition\" vr=\"FL\" vm=\"1\">Wedge Thin Edge Position</tag>
    <tag group=\"300A\" element=\"00DC\" keyword=\"BolusID\" vr=\"SH\" vm=\"1\">Bolus ID</tag>
    <tag group=\"300A\" element=\"00DD\" keyword=\"BolusDescription\" vr=\"ST\" vm=\"1\">Bolus Description</tag>
    <tag group=\"300A\" element=\"00DE\" keyword=\"EffectiveWedgeAngle\" vr=\"DS\" vm=\"1\">Effective Wedge Angle</tag>
    <tag group=\"300A\" element=\"00E0\" keyword=\"NumberOfCompensators\" vr=\"IS\" vm=\"1\">Number of Compensators</tag>
    <tag group=\"300A\" element=\"00E1\" keyword=\"MaterialID\" vr=\"SH\" vm=\"1\">Material ID</tag>
    <tag group=\"300A\" element=\"00E2\" keyword=\"TotalCompensatorTrayFactor\" vr=\"DS\" vm=\"1\">Total Compensator Tray Factor</tag>
    <tag group=\"300A\" element=\"00E3\" keyword=\"CompensatorSequence\" vr=\"SQ\" vm=\"1\">Compensator Sequence</tag>
    <tag group=\"300A\" element=\"00E4\" keyword=\"CompensatorNumber\" vr=\"IS\" vm=\"1\">Compensator Number</tag>
    <tag group=\"300A\" element=\"00E5\" keyword=\"CompensatorID\" vr=\"SH\" vm=\"1\">Compensator ID</tag>
    <tag group=\"300A\" element=\"00E6\" keyword=\"SourceToCompensatorTrayDistance\" vr=\"DS\" vm=\"1\">Source to Compensator Tray Distance</tag>
    <tag group=\"300A\" element=\"00E7\" keyword=\"CompensatorRows\" vr=\"IS\" vm=\"1\">Compensator Rows</tag>
    <tag group=\"300A\" element=\"00E8\" keyword=\"CompensatorColumns\" vr=\"IS\" vm=\"1\">Compensator Columns</tag>
    <tag group=\"300A\" element=\"00E9\" keyword=\"CompensatorPixelSpacing\" vr=\"DS\" vm=\"2\">Compensator Pixel Spacing</tag>
    <tag group=\"300A\" element=\"00EA\" keyword=\"CompensatorPosition\" vr=\"DS\" vm=\"2\">Compensator Position</tag>
    <tag group=\"300A\" element=\"00EB\" keyword=\"CompensatorTransmissionData\" vr=\"DS\" vm=\"1-n\">Compensator Transmission Data</tag>
    <tag group=\"300A\" element=\"00EC\" keyword=\"CompensatorThicknessData\" vr=\"DS\" vm=\"1-n\">Compensator Thickness Data</tag>
    <tag group=\"300A\" element=\"00ED\" keyword=\"NumberOfBoli\" vr=\"IS\" vm=\"1\">Number of Boli</tag>
    <tag group=\"300A\" element=\"00EE\" keyword=\"CompensatorType\" vr=\"CS\" vm=\"1\">Compensator Type</tag>
    <tag group=\"300A\" element=\"00EF\" keyword=\"CompensatorTrayID\" vr=\"SH\" vm=\"1\">Compensator Tray ID</tag>
    <tag group=\"300A\" element=\"00F0\" keyword=\"NumberOfBlocks\" vr=\"IS\" vm=\"1\">Number of Blocks</tag>
    <tag group=\"300A\" element=\"00F2\" keyword=\"TotalBlockTrayFactor\" vr=\"DS\" vm=\"1\">Total Block Tray Factor</tag>
    <tag group=\"300A\" element=\"00F3\" keyword=\"TotalBlockTrayWaterEquivalentThickness\" vr=\"FL\" vm=\"1\">Total Block Tray Water-Equivalent Thickness</tag>
    <tag group=\"300A\" element=\"00F4\" keyword=\"BlockSequence\" vr=\"SQ\" vm=\"1\">Block Sequence</tag>
    <tag group=\"300A\" element=\"00F5\" keyword=\"BlockTrayID\" vr=\"SH\" vm=\"1\">Block Tray ID</tag>
    <tag group=\"300A\" element=\"00F6\" keyword=\"SourceToBlockTrayDistance\" vr=\"DS\" vm=\"1\">Source to Block Tray Distance</tag>
    <tag group=\"300A\" element=\"00F7\" keyword=\"IsocenterToBlockTrayDistance\" vr=\"FL\" vm=\"1\">Isocenter to Block Tray Distance</tag>
    <tag group=\"300A\" element=\"00F8\" keyword=\"BlockType\" vr=\"CS\" vm=\"1\">Block Type</tag>
    <tag group=\"300A\" element=\"00F9\" keyword=\"AccessoryCode\" vr=\"LO\" vm=\"1\">Accessory Code</tag>
    <tag group=\"300A\" element=\"00FA\" keyword=\"BlockDivergence\" vr=\"CS\" vm=\"1\">Block Divergence</tag>
    <tag group=\"300A\" element=\"00FB\" keyword=\"BlockMountingPosition\" vr=\"CS\" vm=\"1\">Block Mounting Position</tag>
    <tag group=\"300A\" element=\"00FC\" keyword=\"BlockNumber\" vr=\"IS\" vm=\"1\">Block Number</tag>
    <tag group=\"300A\" element=\"00FE\" keyword=\"BlockName\" vr=\"LO\" vm=\"1\">Block Name</tag>
    <tag group=\"300A\" element=\"0100\" keyword=\"BlockThickness\" vr=\"DS\" vm=\"1\">Block Thickness</tag>
    <tag group=\"300A\" element=\"0102\" keyword=\"BlockTransmission\" vr=\"DS\" vm=\"1\">Block Transmission</tag>
    <tag group=\"300A\" element=\"0104\" keyword=\"BlockNumberOfPoints\" vr=\"IS\" vm=\"1\">Block Number of Points</tag>
    <tag group=\"300A\" element=\"0106\" keyword=\"BlockData\" vr=\"DS\" vm=\"2-2n\">Block Data</tag>
    <tag group=\"300A\" element=\"0107\" keyword=\"ApplicatorSequence\" vr=\"SQ\" vm=\"1\">Applicator Sequence</tag>
    <tag group=\"300A\" element=\"0108\" keyword=\"ApplicatorID\" vr=\"SH\" vm=\"1\">Applicator ID</tag>
    <tag group=\"300A\" element=\"0109\" keyword=\"ApplicatorType\" vr=\"CS\" vm=\"1\">Applicator Type</tag>
    <tag group=\"300A\" element=\"010A\" keyword=\"ApplicatorDescription\" vr=\"LO\" vm=\"1\">Applicator Description</tag>
    <tag group=\"300A\" element=\"010C\" keyword=\"CumulativeDoseReferenceCoefficient\" vr=\"DS\" vm=\"1\">Cumulative Dose Reference Coefficient</tag>
    <tag group=\"300A\" element=\"010E\" keyword=\"FinalCumulativeMetersetWeight\" vr=\"DS\" vm=\"1\">Final Cumulative Meterset Weight</tag>
    <tag group=\"300A\" element=\"0110\" keyword=\"NumberOfControlPoints\" vr=\"IS\" vm=\"1\">Number of Control Points</tag>
    <tag group=\"300A\" element=\"0111\" keyword=\"ControlPointSequence\" vr=\"SQ\" vm=\"1\">Control Point Sequence</tag>
    <tag group=\"300A\" element=\"0112\" keyword=\"ControlPointIndex\" vr=\"IS\" vm=\"1\">Control Point Index</tag>
    <tag group=\"300A\" element=\"0114\" keyword=\"NominalBeamEnergy\" vr=\"DS\" vm=\"1\">Nominal Beam Energy</tag>
    <tag group=\"300A\" element=\"0115\" keyword=\"DoseRateSet\" vr=\"DS\" vm=\"1\">Dose Rate Set</tag>
    <tag group=\"300A\" element=\"0116\" keyword=\"WedgePositionSequence\" vr=\"SQ\" vm=\"1\">Wedge Position Sequence</tag>
    <tag group=\"300A\" element=\"0118\" keyword=\"WedgePosition\" vr=\"CS\" vm=\"1\">Wedge Position</tag>
    <tag group=\"300A\" element=\"011A\" keyword=\"BeamLimitingDevicePositionSequence\" vr=\"SQ\" vm=\"1\">Beam Limiting Device Position Sequence</tag>
    <tag group=\"300A\" element=\"011C\" keyword=\"LeafJawPositions\" vr=\"DS\" vm=\"2-2n\">Leaf/Jaw Positions</tag>
    <tag group=\"300A\" element=\"011E\" keyword=\"GantryAngle\" vr=\"DS\" vm=\"1\">Gantry Angle</tag>
    <tag group=\"300A\" element=\"011F\" keyword=\"GantryRotationDirection\" vr=\"CS\" vm=\"1\">Gantry Rotation Direction</tag>
    <tag group=\"300A\" element=\"0120\" keyword=\"BeamLimitingDeviceAngle\" vr=\"DS\" vm=\"1\">Beam Limiting Device Angle</tag>
    <tag group=\"300A\" element=\"0121\" keyword=\"BeamLimitingDeviceRotationDirection\" vr=\"CS\" vm=\"1\">Beam Limiting Device Rotation Direction</tag>
    <tag group=\"300A\" element=\"0122\" keyword=\"PatientSupportAngle\" vr=\"DS\" vm=\"1\">Patient Support Angle</tag>
    <tag group=\"300A\" element=\"0123\" keyword=\"PatientSupportRotationDirection\" vr=\"CS\" vm=\"1\">Patient Support Rotation Direction</tag>
    <tag group=\"300A\" element=\"0124\" keyword=\"TableTopEccentricAxisDistance\" vr=\"DS\" vm=\"1\">Table Top Eccentric Axis Distance</tag>
    <tag group=\"300A\" element=\"0125\" keyword=\"TableTopEccentricAngle\" vr=\"DS\" vm=\"1\">Table Top Eccentric Angle</tag>
    <tag group=\"300A\" element=\"0126\" keyword=\"TableTopEccentricRotationDirection\" vr=\"CS\" vm=\"1\">Table Top Eccentric Rotation Direction</tag>
    <tag group=\"300A\" element=\"0128\" keyword=\"TableTopVerticalPosition\" vr=\"DS\" vm=\"1\">Table Top Vertical Position</tag>
    <tag group=\"300A\" element=\"0129\" keyword=\"TableTopLongitudinalPosition\" vr=\"DS\" vm=\"1\">Table Top Longitudinal Position</tag>
    <tag group=\"300A\" element=\"012A\" keyword=\"TableTopLateralPosition\" vr=\"DS\" vm=\"1\">Table Top Lateral Position</tag>
    <tag group=\"300A\" element=\"012C\" keyword=\"IsocenterPosition\" vr=\"DS\" vm=\"3\">Isocenter Position</tag>
    <tag group=\"300A\" element=\"012E\" keyword=\"SurfaceEntryPoint\" vr=\"DS\" vm=\"3\">Surface Entry Point</tag>
    <tag group=\"300A\" element=\"0130\" keyword=\"SourceToSurfaceDistance\" vr=\"DS\" vm=\"1\">Source to Surface Distance</tag>
    <tag group=\"300A\" element=\"0131\" keyword=\"AverageBeamDosePointSourceToExternalContourDistance\" vr=\"FL\" vm=\"1\">Average Beam Dose Point Source to External Contour Distance</tag>
    <tag group=\"300A\" element=\"0132\" keyword=\"SourceToExternalContourDistance\" vr=\"FL\" vm=\"1\">Source to External Contour Distance</tag>
    <tag group=\"300A\" element=\"0133\" keyword=\"ExternalContourEntryPoint\" vr=\"FL\" vm=\"3\">External Contour Entry Point</tag>
    <tag group=\"300A\" element=\"0134\" keyword=\"CumulativeMetersetWeight\" vr=\"DS\" vm=\"1\">Cumulative Meterset Weight</tag>
    <tag group=\"300A\" element=\"0140\" keyword=\"TableTopPitchAngle\" vr=\"FL\" vm=\"1\">Table Top Pitch Angle</tag>
    <tag group=\"300A\" element=\"0142\" keyword=\"TableTopPitchRotationDirection\" vr=\"CS\" vm=\"1\">Table Top Pitch Rotation Direction</tag>
    <tag group=\"300A\" element=\"0144\" keyword=\"TableTopRollAngle\" vr=\"FL\" vm=\"1\">Table Top Roll Angle</tag>
    <tag group=\"300A\" element=\"0146\" keyword=\"TableTopRollRotationDirection\" vr=\"CS\" vm=\"1\">Table Top Roll Rotation Direction</tag>
    <tag group=\"300A\" element=\"0148\" keyword=\"HeadFixationAngle\" vr=\"FL\" vm=\"1\">Head Fixation Angle</tag>
    <tag group=\"300A\" element=\"014A\" keyword=\"GantryPitchAngle\" vr=\"FL\" vm=\"1\">Gantry Pitch Angle</tag>
    <tag group=\"300A\" element=\"014C\" keyword=\"GantryPitchRotationDirection\" vr=\"CS\" vm=\"1\">Gantry Pitch Rotation Direction</tag>
    <tag group=\"300A\" element=\"014E\" keyword=\"GantryPitchAngleTolerance\" vr=\"FL\" vm=\"1\">Gantry Pitch Angle Tolerance</tag>
    <tag group=\"300A\" element=\"0150\" keyword=\"FixationEye\" vr=\"CS\" vm=\"1\">Fixation Eye</tag>
    <tag group=\"300A\" element=\"0151\" keyword=\"ChairHeadFramePosition\" vr=\"DS\" vm=\"1\">Chair Head Frame Position</tag>
    <tag group=\"300A\" element=\"0152\" keyword=\"HeadFixationAngleTolerance\" vr=\"DS\" vm=\"1\">Head Fixation Angle Tolerance</tag>
    <tag group=\"300A\" element=\"0153\" keyword=\"ChairHeadFramePositionTolerance\" vr=\"DS\" vm=\"1\">Chair Head Frame Position Tolerance</tag>
    <tag group=\"300A\" element=\"0154\" keyword=\"FixationLightAzimuthalAngleTolerance\" vr=\"DS\" vm=\"1\">Fixation Light Azimuthal Angle Tolerance</tag>
    <tag group=\"300A\" element=\"0155\" keyword=\"FixationLightPolarAngleTolerance\" vr=\"DS\" vm=\"1\">Fixation Light Polar Angle Tolerance</tag>
    <tag group=\"300A\" element=\"0180\" keyword=\"PatientSetupSequence\" vr=\"SQ\" vm=\"1\">Patient Setup Sequence</tag>
    <tag group=\"300A\" element=\"0182\" keyword=\"PatientSetupNumber\" vr=\"IS\" vm=\"1\">Patient Setup Number</tag>
    <tag group=\"300A\" element=\"0183\" keyword=\"PatientSetupLabel\" vr=\"LO\" vm=\"1\">Patient Setup Label</tag>
    <tag group=\"300A\" element=\"0184\" keyword=\"PatientAdditionalPosition\" vr=\"LO\" vm=\"1\">Patient Additional Position</tag>
    <tag group=\"300A\" element=\"0190\" keyword=\"FixationDeviceSequence\" vr=\"SQ\" vm=\"1\">Fixation Device Sequence</tag>
    <tag group=\"300A\" element=\"0192\" keyword=\"FixationDeviceType\" vr=\"CS\" vm=\"1\">Fixation Device Type</tag>
    <tag group=\"300A\" element=\"0194\" keyword=\"FixationDeviceLabel\" vr=\"SH\" vm=\"1\">Fixation Device Label</tag>
    <tag group=\"300A\" element=\"0196\" keyword=\"FixationDeviceDescription\" vr=\"ST\" vm=\"1\">Fixation Device Description</tag>
    <tag group=\"300A\" element=\"0198\" keyword=\"FixationDevicePosition\" vr=\"SH\" vm=\"1\">Fixation Device Position</tag>
    <tag group=\"300A\" element=\"0199\" keyword=\"FixationDevicePitchAngle\" vr=\"FL\" vm=\"1\">Fixation Device Pitch Angle</tag>
    <tag group=\"300A\" element=\"019A\" keyword=\"FixationDeviceRollAngle\" vr=\"FL\" vm=\"1\">Fixation Device Roll Angle</tag>
    <tag group=\"300A\" element=\"01A0\" keyword=\"ShieldingDeviceSequence\" vr=\"SQ\" vm=\"1\">Shielding Device Sequence</tag>
    <tag group=\"300A\" element=\"01A2\" keyword=\"ShieldingDeviceType\" vr=\"CS\" vm=\"1\">Shielding Device Type</tag>
    <tag group=\"300A\" element=\"01A4\" keyword=\"ShieldingDeviceLabel\" vr=\"SH\" vm=\"1\">Shielding Device Label</tag>
    <tag group=\"300A\" element=\"01A6\" keyword=\"ShieldingDeviceDescription\" vr=\"ST\" vm=\"1\">Shielding Device Description</tag>
    <tag group=\"300A\" element=\"01A8\" keyword=\"ShieldingDevicePosition\" vr=\"SH\" vm=\"1\">Shielding Device Position</tag>
    <tag group=\"300A\" element=\"01B0\" keyword=\"SetupTechnique\" vr=\"CS\" vm=\"1\">Setup Technique</tag>
    <tag group=\"300A\" element=\"01B2\" keyword=\"SetupTechniqueDescription\" vr=\"ST\" vm=\"1\">Setup Technique Description</tag>
    <tag group=\"300A\" element=\"01B4\" keyword=\"SetupDeviceSequence\" vr=\"SQ\" vm=\"1\">Setup Device Sequence</tag>
    <tag group=\"300A\" element=\"01B6\" keyword=\"SetupDeviceType\" vr=\"CS\" vm=\"1\">Setup Device Type</tag>
    <tag group=\"300A\" element=\"01B8\" keyword=\"SetupDeviceLabel\" vr=\"SH\" vm=\"1\">Setup Device Label</tag>
    <tag group=\"300A\" element=\"01BA\" keyword=\"SetupDeviceDescription\" vr=\"ST\" vm=\"1\">Setup Device Description</tag>
    <tag group=\"300A\" element=\"01BC\" keyword=\"SetupDeviceParameter\" vr=\"DS\" vm=\"1\">Setup Device Parameter</tag>
    <tag group=\"300A\" element=\"01D0\" keyword=\"SetupReferenceDescription\" vr=\"ST\" vm=\"1\">Setup Reference Description</tag>
    <tag group=\"300A\" element=\"01D2\" keyword=\"TableTopVerticalSetupDisplacement\" vr=\"DS\" vm=\"1\">Table Top Vertical Setup Displacement</tag>
    <tag group=\"300A\" element=\"01D4\" keyword=\"TableTopLongitudinalSetupDisplacement\" vr=\"DS\" vm=\"1\">Table Top Longitudinal Setup Displacement</tag>
    <tag group=\"300A\" element=\"01D6\" keyword=\"TableTopLateralSetupDisplacement\" vr=\"DS\" vm=\"1\">Table Top Lateral Setup Displacement</tag>
    <tag group=\"300A\" element=\"0200\" keyword=\"BrachyTreatmentTechnique\" vr=\"CS\" vm=\"1\">Brachy Treatment Technique</tag>
    <tag group=\"300A\" element=\"0202\" keyword=\"BrachyTreatmentType\" vr=\"CS\" vm=\"1\">Brachy Treatment Type</tag>
    <tag group=\"300A\" element=\"0206\" keyword=\"TreatmentMachineSequence\" vr=\"SQ\" vm=\"1\">Treatment Machine Sequence</tag>
    <tag group=\"300A\" element=\"0210\" keyword=\"SourceSequence\" vr=\"SQ\" vm=\"1\">Source Sequence</tag>
    <tag group=\"300A\" element=\"0212\" keyword=\"SourceNumber\" vr=\"IS\" vm=\"1\">Source Number</tag>
    <tag group=\"300A\" element=\"0214\" keyword=\"SourceType\" vr=\"CS\" vm=\"1\">Source Type</tag>
    <tag group=\"300A\" element=\"0216\" keyword=\"SourceManufacturer\" vr=\"LO\" vm=\"1\">Source Manufacturer</tag>
    <tag group=\"300A\" element=\"0218\" keyword=\"ActiveSourceDiameter\" vr=\"DS\" vm=\"1\">Active Source Diameter</tag>
    <tag group=\"300A\" element=\"021A\" keyword=\"ActiveSourceLength\" vr=\"DS\" vm=\"1\">Active Source Length</tag>
    <tag group=\"300A\" element=\"021B\" keyword=\"SourceModelID\" vr=\"SH\" vm=\"1\">Source Model ID</tag>
    <tag group=\"300A\" element=\"021C\" keyword=\"SourceDescription\" vr=\"LO\" vm=\"1\">Source Description</tag>
    <tag group=\"300A\" element=\"0222\" keyword=\"SourceEncapsulationNominalThickness\" vr=\"DS\" vm=\"1\">Source Encapsulation Nominal Thickness</tag>
    <tag group=\"300A\" element=\"0224\" keyword=\"SourceEncapsulationNominalTransmission\" vr=\"DS\" vm=\"1\">Source Encapsulation Nominal Transmission</tag>
    <tag group=\"300A\" element=\"0226\" keyword=\"SourceIsotopeName\" vr=\"LO\" vm=\"1\">Source Isotope Name</tag>
    <tag group=\"300A\" element=\"0228\" keyword=\"SourceIsotopeHalfLife\" vr=\"DS\" vm=\"1\">Source Isotope Half Life</tag>
    <tag group=\"300A\" element=\"0229\" keyword=\"SourceStrengthUnits\" vr=\"CS\" vm=\"1\">Source Strength Units</tag>
    <tag group=\"300A\" element=\"022A\" keyword=\"ReferenceAirKermaRate\" vr=\"DS\" vm=\"1\">Reference Air Kerma Rate</tag>
    <tag group=\"300A\" element=\"022B\" keyword=\"SourceStrength\" vr=\"DS\" vm=\"1\">Source Strength</tag>
    <tag group=\"300A\" element=\"022C\" keyword=\"SourceStrengthReferenceDate\" vr=\"DA\" vm=\"1\">Source Strength Reference Date</tag>
    <tag group=\"300A\" element=\"022E\" keyword=\"SourceStrengthReferenceTime\" vr=\"TM\" vm=\"1\">Source Strength Reference Time</tag>
    <tag group=\"300A\" element=\"0230\" keyword=\"ApplicationSetupSequence\" vr=\"SQ\" vm=\"1\">Application Setup Sequence</tag>
    <tag group=\"300A\" element=\"0232\" keyword=\"ApplicationSetupType\" vr=\"CS\" vm=\"1\">Application Setup Type</tag>
    <tag group=\"300A\" element=\"0234\" keyword=\"ApplicationSetupNumber\" vr=\"IS\" vm=\"1\">Application Setup Number</tag>
    <tag group=\"300A\" element=\"0236\" keyword=\"ApplicationSetupName\" vr=\"LO\" vm=\"1\">Application Setup Name</tag>
    <tag group=\"300A\" element=\"0238\" keyword=\"ApplicationSetupManufacturer\" vr=\"LO\" vm=\"1\">Application Setup Manufacturer</tag>
    <tag group=\"300A\" element=\"0240\" keyword=\"TemplateNumber\" vr=\"IS\" vm=\"1\">Template Number</tag>
    <tag group=\"300A\" element=\"0242\" keyword=\"TemplateType\" vr=\"SH\" vm=\"1\">Template Type</tag>
    <tag group=\"300A\" element=\"0244\" keyword=\"TemplateName\" vr=\"LO\" vm=\"1\">Template Name</tag>
    <tag group=\"300A\" element=\"0250\" keyword=\"TotalReferenceAirKerma\" vr=\"DS\" vm=\"1\">Total Reference Air Kerma</tag>
    <tag group=\"300A\" element=\"0260\" keyword=\"BrachyAccessoryDeviceSequence\" vr=\"SQ\" vm=\"1\">Brachy Accessory Device Sequence</tag>
    <tag group=\"300A\" element=\"0262\" keyword=\"BrachyAccessoryDeviceNumber\" vr=\"IS\" vm=\"1\">Brachy Accessory Device Number</tag>
    <tag group=\"300A\" element=\"0263\" keyword=\"BrachyAccessoryDeviceID\" vr=\"SH\" vm=\"1\">Brachy Accessory Device ID</tag>
    <tag group=\"300A\" element=\"0264\" keyword=\"BrachyAccessoryDeviceType\" vr=\"CS\" vm=\"1\">Brachy Accessory Device Type</tag>
    <tag group=\"300A\" element=\"0266\" keyword=\"BrachyAccessoryDeviceName\" vr=\"LO\" vm=\"1\">Brachy Accessory Device Name</tag>
    <tag group=\"300A\" element=\"026A\" keyword=\"BrachyAccessoryDeviceNominalThickness\" vr=\"DS\" vm=\"1\">Brachy Accessory Device Nominal Thickness</tag>
    <tag group=\"300A\" element=\"026C\" keyword=\"BrachyAccessoryDeviceNominalTransmission\" vr=\"DS\" vm=\"1\">Brachy Accessory Device Nominal Transmission</tag>
    <tag group=\"300A\" element=\"0280\" keyword=\"ChannelSequence\" vr=\"SQ\" vm=\"1\">Channel Sequence</tag>
    <tag group=\"300A\" element=\"0282\" keyword=\"ChannelNumber\" vr=\"IS\" vm=\"1\">Channel Number</tag>
    <tag group=\"300A\" element=\"0284\" keyword=\"ChannelLength\" vr=\"DS\" vm=\"1\">Channel Length</tag>
    <tag group=\"300A\" element=\"0286\" keyword=\"ChannelTotalTime\" vr=\"DS\" vm=\"1\">Channel Total Time</tag>
    <tag group=\"300A\" element=\"0288\" keyword=\"SourceMovementType\" vr=\"CS\" vm=\"1\">Source Movement Type</tag>
    <tag group=\"300A\" element=\"028A\" keyword=\"NumberOfPulses\" vr=\"IS\" vm=\"1\">Number of Pulses</tag>
    <tag group=\"300A\" element=\"028C\" keyword=\"PulseRepetitionInterval\" vr=\"DS\" vm=\"1\">Pulse Repetition Interval</tag>
    <tag group=\"300A\" element=\"0290\" keyword=\"SourceApplicatorNumber\" vr=\"IS\" vm=\"1\">Source Applicator Number</tag>
    <tag group=\"300A\" element=\"0291\" keyword=\"SourceApplicatorID\" vr=\"SH\" vm=\"1\">Source Applicator ID</tag>
    <tag group=\"300A\" element=\"0292\" keyword=\"SourceApplicatorType\" vr=\"CS\" vm=\"1\">Source Applicator Type</tag>
    <tag group=\"300A\" element=\"0294\" keyword=\"SourceApplicatorName\" vr=\"LO\" vm=\"1\">Source Applicator Name</tag>
    <tag group=\"300A\" element=\"0296\" keyword=\"SourceApplicatorLength\" vr=\"DS\" vm=\"1\">Source Applicator Length</tag>
    <tag group=\"300A\" element=\"0298\" keyword=\"SourceApplicatorManufacturer\" vr=\"LO\" vm=\"1\">Source Applicator Manufacturer</tag>
    <tag group=\"300A\" element=\"029C\" keyword=\"SourceApplicatorWallNominalThickness\" vr=\"DS\" vm=\"1\">Source Applicator Wall Nominal Thickness</tag>
    <tag group=\"300A\" element=\"029E\" keyword=\"SourceApplicatorWallNominalTransmission\" vr=\"DS\" vm=\"1\">Source Applicator Wall Nominal Transmission</tag>
    <tag group=\"300A\" element=\"02A0\" keyword=\"SourceApplicatorStepSize\" vr=\"DS\" vm=\"1\">Source Applicator Step Size</tag>
    <tag group=\"300A\" element=\"02A2\" keyword=\"TransferTubeNumber\" vr=\"IS\" vm=\"1\">Transfer Tube Number</tag>
    <tag group=\"300A\" element=\"02A4\" keyword=\"TransferTubeLength\" vr=\"DS\" vm=\"1\">Transfer Tube Length</tag>
    <tag group=\"300A\" element=\"02B0\" keyword=\"ChannelShieldSequence\" vr=\"SQ\" vm=\"1\">Channel Shield Sequence</tag>
    <tag group=\"300A\" element=\"02B2\" keyword=\"ChannelShieldNumber\" vr=\"IS\" vm=\"1\">Channel Shield Number</tag>
    <tag group=\"300A\" element=\"02B3\" keyword=\"ChannelShieldID\" vr=\"SH\" vm=\"1\">Channel Shield ID</tag>
    <tag group=\"300A\" element=\"02B4\" keyword=\"ChannelShieldName\" vr=\"LO\" vm=\"1\">Channel Shield Name</tag>
    <tag group=\"300A\" element=\"02B8\" keyword=\"ChannelShieldNominalThickness\" vr=\"DS\" vm=\"1\">Channel Shield Nominal Thickness</tag>
    <tag group=\"300A\" element=\"02BA\" keyword=\"ChannelShieldNominalTransmission\" vr=\"DS\" vm=\"1\">Channel Shield Nominal Transmission</tag>
    <tag group=\"300A\" element=\"02C8\" keyword=\"FinalCumulativeTimeWeight\" vr=\"DS\" vm=\"1\">Final Cumulative Time Weight</tag>
    <tag group=\"300A\" element=\"02D0\" keyword=\"BrachyControlPointSequence\" vr=\"SQ\" vm=\"1\">Brachy Control Point Sequence</tag>
    <tag group=\"300A\" element=\"02D2\" keyword=\"ControlPointRelativePosition\" vr=\"DS\" vm=\"1\">Control Point Relative Position</tag>
    <tag group=\"300A\" element=\"02D4\" keyword=\"ControlPoint3DPosition\" vr=\"DS\" vm=\"3\">Control Point 3D Position</tag>
    <tag group=\"300A\" element=\"02D6\" keyword=\"CumulativeTimeWeight\" vr=\"DS\" vm=\"1\">Cumulative Time Weight</tag>
    <tag group=\"300A\" element=\"02E0\" keyword=\"CompensatorDivergence\" vr=\"CS\" vm=\"1\">Compensator Divergence</tag>
    <tag group=\"300A\" element=\"02E1\" keyword=\"CompensatorMountingPosition\" vr=\"CS\" vm=\"1\">Compensator Mounting Position</tag>
    <tag group=\"300A\" element=\"02E2\" keyword=\"SourceToCompensatorDistance\" vr=\"DS\" vm=\"1-n\">Source to Compensator Distance</tag>
    <tag group=\"300A\" element=\"02E3\" keyword=\"TotalCompensatorTrayWaterEquivalentThickness\" vr=\"FL\" vm=\"1\">Total Compensator Tray Water-Equivalent Thickness</tag>
    <tag group=\"300A\" element=\"02E4\" keyword=\"IsocenterToCompensatorTrayDistance\" vr=\"FL\" vm=\"1\">Isocenter to Compensator Tray Distance</tag>
    <tag group=\"300A\" element=\"02E5\" keyword=\"CompensatorColumnOffset\" vr=\"FL\" vm=\"1\">Compensator Column Offset</tag>
    <tag group=\"300A\" element=\"02E6\" keyword=\"IsocenterToCompensatorDistances\" vr=\"FL\" vm=\"1-n\">Isocenter to Compensator Distances</tag>
    <tag group=\"300A\" element=\"02E7\" keyword=\"CompensatorRelativeStoppingPowerRatio\" vr=\"FL\" vm=\"1\">Compensator Relative Stopping Power Ratio</tag>
    <tag group=\"300A\" element=\"02E8\" keyword=\"CompensatorMillingToolDiameter\" vr=\"FL\" vm=\"1\">Compensator Milling Tool Diameter</tag>
    <tag group=\"300A\" element=\"02EA\" keyword=\"IonRangeCompensatorSequence\" vr=\"SQ\" vm=\"1\">Ion Range Compensator Sequence</tag>
    <tag group=\"300A\" element=\"02EB\" keyword=\"CompensatorDescription\" vr=\"LT\" vm=\"1\">Compensator Description</tag>
    <tag group=\"300A\" element=\"0302\" keyword=\"RadiationMassNumber\" vr=\"IS\" vm=\"1\">Radiation Mass Number</tag>
    <tag group=\"300A\" element=\"0304\" keyword=\"RadiationAtomicNumber\" vr=\"IS\" vm=\"1\">Radiation Atomic Number</tag>
    <tag group=\"300A\" element=\"0306\" keyword=\"RadiationChargeState\" vr=\"SS\" vm=\"1\">Radiation Charge State</tag>
    <tag group=\"300A\" element=\"0308\" keyword=\"ScanMode\" vr=\"CS\" vm=\"1\">Scan Mode</tag>
    <tag group=\"300A\" element=\"0309\" keyword=\"ModulatedScanModeType\" vr=\"CS\" vm=\"1\">Modulated Scan Mode Type</tag>
    <tag group=\"300A\" element=\"030A\" keyword=\"VirtualSourceAxisDistances\" vr=\"FL\" vm=\"2\">Virtual Source-Axis Distances</tag>
    <tag group=\"300A\" element=\"030C\" keyword=\"SnoutSequence\" vr=\"SQ\" vm=\"1\">Snout Sequence</tag>
    <tag group=\"300A\" element=\"030D\" keyword=\"SnoutPosition\" vr=\"FL\" vm=\"1\">Snout Position</tag>
    <tag group=\"300A\" element=\"030F\" keyword=\"SnoutID\" vr=\"SH\" vm=\"1\">Snout ID</tag>
    <tag group=\"300A\" element=\"0312\" keyword=\"NumberOfRangeShifters\" vr=\"IS\" vm=\"1\">Number of Range Shifters</tag>
    <tag group=\"300A\" element=\"0314\" keyword=\"RangeShifterSequence\" vr=\"SQ\" vm=\"1\">Range Shifter Sequence</tag>
    <tag group=\"300A\" element=\"0316\" keyword=\"RangeShifterNumber\" vr=\"IS\" vm=\"1\">Range Shifter Number</tag>
    <tag group=\"300A\" element=\"0318\" keyword=\"RangeShifterID\" vr=\"SH\" vm=\"1\">Range Shifter ID</tag>
    <tag group=\"300A\" element=\"0320\" keyword=\"RangeShifterType\" vr=\"CS\" vm=\"1\">Range Shifter Type</tag>
    <tag group=\"300A\" element=\"0322\" keyword=\"RangeShifterDescription\" vr=\"LO\" vm=\"1\">Range Shifter Description</tag>
    <tag group=\"300A\" element=\"0330\" keyword=\"NumberOfLateralSpreadingDevices\" vr=\"IS\" vm=\"1\">Number of Lateral Spreading Devices</tag>
    <tag group=\"300A\" element=\"0332\" keyword=\"LateralSpreadingDeviceSequence\" vr=\"SQ\" vm=\"1\">Lateral Spreading Device Sequence</tag>
    <tag group=\"300A\" element=\"0334\" keyword=\"LateralSpreadingDeviceNumber\" vr=\"IS\" vm=\"1\">Lateral Spreading Device Number</tag>
    <tag group=\"300A\" element=\"0336\" keyword=\"LateralSpreadingDeviceID\" vr=\"SH\" vm=\"1\">Lateral Spreading Device ID</tag>
    <tag group=\"300A\" element=\"0338\" keyword=\"LateralSpreadingDeviceType\" vr=\"CS\" vm=\"1\">Lateral Spreading Device Type</tag>
    <tag group=\"300A\" element=\"033A\" keyword=\"LateralSpreadingDeviceDescription\" vr=\"LO\" vm=\"1\">Lateral Spreading Device Description</tag>
    <tag group=\"300A\" element=\"033C\" keyword=\"LateralSpreadingDeviceWaterEquivalentThickness\" vr=\"FL\" vm=\"1\">Lateral Spreading Device Water Equivalent Thickness</tag>
    <tag group=\"300A\" element=\"0340\" keyword=\"NumberOfRangeModulators\" vr=\"IS\" vm=\"1\">Number of Range Modulators</tag>
    <tag group=\"300A\" element=\"0342\" keyword=\"RangeModulatorSequence\" vr=\"SQ\" vm=\"1\">Range Modulator Sequence</tag>
    <tag group=\"300A\" element=\"0344\" keyword=\"RangeModulatorNumber\" vr=\"IS\" vm=\"1\">Range Modulator Number</tag>
    <tag group=\"300A\" element=\"0346\" keyword=\"RangeModulatorID\" vr=\"SH\" vm=\"1\">Range Modulator ID</tag>
    <tag group=\"300A\" element=\"0348\" keyword=\"RangeModulatorType\" vr=\"CS\" vm=\"1\">Range Modulator Type</tag>
    <tag group=\"300A\" element=\"034A\" keyword=\"RangeModulatorDescription\" vr=\"LO\" vm=\"1\">Range Modulator Description</tag>
    <tag group=\"300A\" element=\"034C\" keyword=\"BeamCurrentModulationID\" vr=\"SH\" vm=\"1\">Beam Current Modulation ID</tag>
    <tag group=\"300A\" element=\"0350\" keyword=\"PatientSupportType\" vr=\"CS\" vm=\"1\">Patient Support Type</tag>
    <tag group=\"300A\" element=\"0352\" keyword=\"PatientSupportID\" vr=\"SH\" vm=\"1\">Patient Support ID</tag>
    <tag group=\"300A\" element=\"0354\" keyword=\"PatientSupportAccessoryCode\" vr=\"LO\" vm=\"1\">Patient Support Accessory Code</tag>
    <tag group=\"300A\" element=\"0355\" keyword=\"TrayAccessoryCode\" vr=\"LO\" vm=\"1\">Tray Accessory Code</tag>
    <tag group=\"300A\" element=\"0356\" keyword=\"FixationLightAzimuthalAngle\" vr=\"FL\" vm=\"1\">Fixation Light Azimuthal Angle</tag>
    <tag group=\"300A\" element=\"0358\" keyword=\"FixationLightPolarAngle\" vr=\"FL\" vm=\"1\">Fixation Light Polar Angle</tag>
    <tag group=\"300A\" element=\"035A\" keyword=\"MetersetRate\" vr=\"FL\" vm=\"1\">Meterset Rate</tag>
    <tag group=\"300A\" element=\"0360\" keyword=\"RangeShifterSettingsSequence\" vr=\"SQ\" vm=\"1\">Range Shifter Settings Sequence</tag>
    <tag group=\"300A\" element=\"0362\" keyword=\"RangeShifterSetting\" vr=\"LO\" vm=\"1\">Range Shifter Setting</tag>
    <tag group=\"300A\" element=\"0364\" keyword=\"IsocenterToRangeShifterDistance\" vr=\"FL\" vm=\"1\">Isocenter to Range Shifter Distance</tag>
    <tag group=\"300A\" element=\"0366\" keyword=\"RangeShifterWaterEquivalentThickness\" vr=\"FL\" vm=\"1\">Range Shifter Water Equivalent Thickness</tag>
    <tag group=\"300A\" element=\"0370\" keyword=\"LateralSpreadingDeviceSettingsSequence\" vr=\"SQ\" vm=\"1\">Lateral Spreading Device Settings Sequence</tag>
    <tag group=\"300A\" element=\"0372\" keyword=\"LateralSpreadingDeviceSetting\" vr=\"LO\" vm=\"1\">Lateral Spreading Device Setting</tag>
    <tag group=\"300A\" element=\"0374\" keyword=\"IsocenterToLateralSpreadingDeviceDistance\" vr=\"FL\" vm=\"1\">Isocenter to Lateral Spreading Device Distance</tag>
    <tag group=\"300A\" element=\"0380\" keyword=\"RangeModulatorSettingsSequence\" vr=\"SQ\" vm=\"1\">Range Modulator Settings Sequence</tag>
    <tag group=\"300A\" element=\"0382\" keyword=\"RangeModulatorGatingStartValue\" vr=\"FL\" vm=\"1\">Range Modulator Gating Start Value</tag>
    <tag group=\"300A\" element=\"0384\" keyword=\"RangeModulatorGatingStopValue\" vr=\"FL\" vm=\"1\">Range Modulator Gating Stop Value</tag>
    <tag group=\"300A\" element=\"0386\" keyword=\"RangeModulatorGatingStartWaterEquivalentThickness\" vr=\"FL\" vm=\"1\">Range Modulator Gating Start Water Equivalent Thickness</tag>
    <tag group=\"300A\" element=\"0388\" keyword=\"RangeModulatorGatingStopWaterEquivalentThickness\" vr=\"FL\" vm=\"1\">Range Modulator Gating Stop Water Equivalent Thickness</tag>
    <tag group=\"300A\" element=\"038A\" keyword=\"IsocenterToRangeModulatorDistance\" vr=\"FL\" vm=\"1\">Isocenter to Range Modulator Distance</tag>
    <tag group=\"300A\" element=\"038F\" keyword=\"ScanSpotTimeOffset\" vr=\"FL\" vm=\"1-n\">Scan Spot Time Offset</tag>
    <tag group=\"300A\" element=\"0390\" keyword=\"ScanSpotTuneID\" vr=\"SH\" vm=\"1\">Scan Spot Tune ID</tag>
    <tag group=\"300A\" element=\"0391\" keyword=\"ScanSpotPrescribedIndices\" vr=\"IS\" vm=\"1-n\">Scan Spot Prescribed Indices</tag>
    <tag group=\"300A\" element=\"0392\" keyword=\"NumberOfScanSpotPositions\" vr=\"IS\" vm=\"1\">Number of Scan Spot Positions</tag>
    <tag group=\"300A\" element=\"0393\" keyword=\"ScanSpotReordered\" vr=\"CS\" vm=\"1\">Scan Spot Reordered</tag>
    <tag group=\"300A\" element=\"0394\" keyword=\"ScanSpotPositionMap\" vr=\"FL\" vm=\"1-n\">Scan Spot Position Map</tag>
    <tag group=\"300A\" element=\"0395\" keyword=\"ScanSpotReorderingAllowed\" vr=\"CS\" vm=\"1\">Scan Spot Reordering Allowed</tag>
    <tag group=\"300A\" element=\"0396\" keyword=\"ScanSpotMetersetWeights\" vr=\"FL\" vm=\"1-n\">Scan Spot Meterset Weights</tag>
    <tag group=\"300A\" element=\"0398\" keyword=\"ScanningSpotSize\" vr=\"FL\" vm=\"2\">Scanning Spot Size</tag>
    <tag group=\"300A\" element=\"039A\" keyword=\"NumberOfPaintings\" vr=\"IS\" vm=\"1\">Number of Paintings</tag>
    <tag group=\"300A\" element=\"03A0\" keyword=\"IonToleranceTableSequence\" vr=\"SQ\" vm=\"1\">Ion Tolerance Table Sequence</tag>
    <tag group=\"300A\" element=\"03A2\" keyword=\"IonBeamSequence\" vr=\"SQ\" vm=\"1\">Ion Beam Sequence</tag>
    <tag group=\"300A\" element=\"03A4\" keyword=\"IonBeamLimitingDeviceSequence\" vr=\"SQ\" vm=\"1\">Ion Beam Limiting Device Sequence</tag>
    <tag group=\"300A\" element=\"03A6\" keyword=\"IonBlockSequence\" vr=\"SQ\" vm=\"1\">Ion Block Sequence</tag>
    <tag group=\"300A\" element=\"03A8\" keyword=\"IonControlPointSequence\" vr=\"SQ\" vm=\"1\">Ion Control Point Sequence</tag>
    <tag group=\"300A\" element=\"03AA\" keyword=\"IonWedgeSequence\" vr=\"SQ\" vm=\"1\">Ion Wedge Sequence</tag>
    <tag group=\"300A\" element=\"03AC\" keyword=\"IonWedgePositionSequence\" vr=\"SQ\" vm=\"1\">Ion Wedge Position Sequence</tag>
    <tag group=\"300A\" element=\"0401\" keyword=\"ReferencedSetupImageSequence\" vr=\"SQ\" vm=\"1\">Referenced Setup Image Sequence</tag>
    <tag group=\"300A\" element=\"0402\" keyword=\"SetupImageComment\" vr=\"ST\" vm=\"1\">Setup Image Comment</tag>
    <tag group=\"300A\" element=\"0410\" keyword=\"MotionSynchronizationSequence\" vr=\"SQ\" vm=\"1\">Motion Synchronization Sequence</tag>
    <tag group=\"300A\" element=\"0412\" keyword=\"ControlPointOrientation\" vr=\"FL\" vm=\"3\">Control Point Orientation</tag>
    <tag group=\"300A\" element=\"0420\" keyword=\"GeneralAccessorySequence\" vr=\"SQ\" vm=\"1\">General Accessory Sequence</tag>
    <tag group=\"300A\" element=\"0421\" keyword=\"GeneralAccessoryID\" vr=\"SH\" vm=\"1\">General Accessory ID</tag>
    <tag group=\"300A\" element=\"0422\" keyword=\"GeneralAccessoryDescription\" vr=\"ST\" vm=\"1\">General Accessory Description</tag>
    <tag group=\"300A\" element=\"0423\" keyword=\"GeneralAccessoryType\" vr=\"CS\" vm=\"1\">General Accessory Type</tag>
    <tag group=\"300A\" element=\"0424\" keyword=\"GeneralAccessoryNumber\" vr=\"IS\" vm=\"1\">General Accessory Number</tag>
    <tag group=\"300A\" element=\"0425\" keyword=\"SourceToGeneralAccessoryDistance\" vr=\"FL\" vm=\"1\">Source to General Accessory Distance</tag>
    <tag group=\"300A\" element=\"0431\" keyword=\"ApplicatorGeometrySequence\" vr=\"SQ\" vm=\"1\">Applicator Geometry Sequence</tag>
    <tag group=\"300A\" element=\"0432\" keyword=\"ApplicatorApertureShape\" vr=\"CS\" vm=\"1\">Applicator Aperture Shape</tag>
    <tag group=\"300A\" element=\"0433\" keyword=\"ApplicatorOpening\" vr=\"FL\" vm=\"1\">Applicator Opening</tag>
    <tag group=\"300A\" element=\"0434\" keyword=\"ApplicatorOpeningX\" vr=\"FL\" vm=\"1\">Applicator Opening X</tag>
    <tag group=\"300A\" element=\"0435\" keyword=\"ApplicatorOpeningY\" vr=\"FL\" vm=\"1\">Applicator Opening Y</tag>
    <tag group=\"300A\" element=\"0436\" keyword=\"SourceToApplicatorMountingPositionDistance\" vr=\"FL\" vm=\"1\">Source to Applicator Mounting Position Distance</tag>
    <tag group=\"300A\" element=\"0440\" keyword=\"NumberOfBlockSlabItems\" vr=\"IS\" vm=\"1\">Number of Block Slab Items</tag>
    <tag group=\"300A\" element=\"0441\" keyword=\"BlockSlabSequence\" vr=\"SQ\" vm=\"1\">Block Slab Sequence</tag>
    <tag group=\"300A\" element=\"0442\" keyword=\"BlockSlabThickness\" vr=\"DS\" vm=\"1\">Block Slab Thickness</tag>
    <tag group=\"300A\" element=\"0443\" keyword=\"BlockSlabNumber\" vr=\"US\" vm=\"1\">Block Slab Number</tag>
    <tag group=\"300A\" element=\"0450\" keyword=\"DeviceMotionControlSequence\" vr=\"SQ\" vm=\"1\">Device Motion Control Sequence</tag>
    <tag group=\"300A\" element=\"0451\" keyword=\"DeviceMotionExecutionMode\" vr=\"CS\" vm=\"1\">Device Motion Execution Mode</tag>
    <tag group=\"300A\" element=\"0452\" keyword=\"DeviceMotionObservationMode\" vr=\"CS\" vm=\"1\">Device Motion Observation Mode</tag>
    <tag group=\"300A\" element=\"0453\" keyword=\"DeviceMotionParameterCodeSequence\" vr=\"SQ\" vm=\"1\">Device Motion Parameter Code Sequence</tag>
    <tag group=\"300A\" element=\"0501\" keyword=\"DistalDepthFraction\" vr=\"FL\" vm=\"1\">Distal Depth Fraction</tag>
    <tag group=\"300A\" element=\"0502\" keyword=\"DistalDepth\" vr=\"FL\" vm=\"1\">Distal Depth</tag>
    <tag group=\"300A\" element=\"0503\" keyword=\"NominalRangeModulationFractions\" vr=\"FL\" vm=\"2\">Nominal Range Modulation Fractions</tag>
    <tag group=\"300A\" element=\"0504\" keyword=\"NominalRangeModulatedRegionDepths\" vr=\"FL\" vm=\"2\">Nominal Range Modulated Region Depths</tag>
    <tag group=\"300A\" element=\"0505\" keyword=\"DepthDoseParametersSequence\" vr=\"SQ\" vm=\"1\">Depth Dose Parameters Sequence</tag>
    <tag group=\"300A\" element=\"0506\" keyword=\"DeliveredDepthDoseParametersSequence\" vr=\"SQ\" vm=\"1\">Delivered Depth Dose Parameters Sequence</tag>
    <tag group=\"300A\" element=\"0507\" keyword=\"DeliveredDistalDepthFraction\" vr=\"FL\" vm=\"1\">Delivered Distal Depth Fraction</tag>
    <tag group=\"300A\" element=\"0508\" keyword=\"DeliveredDistalDepth\" vr=\"FL\" vm=\"1\">Delivered Distal Depth</tag>
    <tag group=\"300A\" element=\"0509\" keyword=\"DeliveredNominalRangeModulationFractions\" vr=\"FL\" vm=\"2\">Delivered Nominal Range Modulation Fractions</tag>
    <tag group=\"300A\" element=\"0510\" keyword=\"DeliveredNominalRangeModulatedRegionDepths\" vr=\"FL\" vm=\"2\">Delivered Nominal Range Modulated Region Depths</tag>
    <tag group=\"300A\" element=\"0511\" keyword=\"DeliveredReferenceDoseDefinition\" vr=\"CS\" vm=\"1\">Delivered Reference Dose Definition</tag>
    <tag group=\"300A\" element=\"0512\" keyword=\"ReferenceDoseDefinition\" vr=\"CS\" vm=\"1\">Reference Dose Definition</tag>
    <tag group=\"300C\" element=\"0002\" keyword=\"ReferencedRTPlanSequence\" vr=\"SQ\" vm=\"1\">Referenced RT Plan Sequence</tag>
    <tag group=\"300C\" element=\"0004\" keyword=\"ReferencedBeamSequence\" vr=\"SQ\" vm=\"1\">Referenced Beam Sequence</tag>
    <tag group=\"300C\" element=\"0006\" keyword=\"ReferencedBeamNumber\" vr=\"IS\" vm=\"1\">Referenced Beam Number</tag>
    <tag group=\"300C\" element=\"0007\" keyword=\"ReferencedReferenceImageNumber\" vr=\"IS\" vm=\"1\">Referenced Reference Image Number</tag>
    <tag group=\"300C\" element=\"0008\" keyword=\"StartCumulativeMetersetWeight\" vr=\"DS\" vm=\"1\">Start Cumulative Meterset Weight</tag>
    <tag group=\"300C\" element=\"0009\" keyword=\"EndCumulativeMetersetWeight\" vr=\"DS\" vm=\"1\">End Cumulative Meterset Weight</tag>
    <tag group=\"300C\" element=\"000A\" keyword=\"ReferencedBrachyApplicationSetupSequence\" vr=\"SQ\" vm=\"1\">Referenced Brachy Application Setup Sequence</tag>
    <tag group=\"300C\" element=\"000C\" keyword=\"ReferencedBrachyApplicationSetupNumber\" vr=\"IS\" vm=\"1\">Referenced Brachy Application Setup Number</tag>
    <tag group=\"300C\" element=\"000E\" keyword=\"ReferencedSourceNumber\" vr=\"IS\" vm=\"1\">Referenced Source Number</tag>
    <tag group=\"300C\" element=\"0020\" keyword=\"ReferencedFractionGroupSequence\" vr=\"SQ\" vm=\"1\">Referenced Fraction Group Sequence</tag>
    <tag group=\"300C\" element=\"0022\" keyword=\"ReferencedFractionGroupNumber\" vr=\"IS\" vm=\"1\">Referenced Fraction Group Number</tag>
    <tag group=\"300C\" element=\"0040\" keyword=\"ReferencedVerificationImageSequence\" vr=\"SQ\" vm=\"1\">Referenced Verification Image Sequence</tag>
    <tag group=\"300C\" element=\"0042\" keyword=\"ReferencedReferenceImageSequence\" vr=\"SQ\" vm=\"1\">Referenced Reference Image Sequence</tag>
    <tag group=\"300C\" element=\"0050\" keyword=\"ReferencedDoseReferenceSequence\" vr=\"SQ\" vm=\"1\">Referenced Dose Reference Sequence</tag>
    <tag group=\"300C\" element=\"0051\" keyword=\"ReferencedDoseReferenceNumber\" vr=\"IS\" vm=\"1\">Referenced Dose Reference Number</tag>
    <tag group=\"300C\" element=\"0055\" keyword=\"BrachyReferencedDoseReferenceSequence\" vr=\"SQ\" vm=\"1\">Brachy Referenced Dose Reference Sequence</tag>
    <tag group=\"300C\" element=\"0060\" keyword=\"ReferencedStructureSetSequence\" vr=\"SQ\" vm=\"1\">Referenced Structure Set Sequence</tag>
    <tag group=\"300C\" element=\"006A\" keyword=\"ReferencedPatientSetupNumber\" vr=\"IS\" vm=\"1\">Referenced Patient Setup Number</tag>
    <tag group=\"300C\" element=\"0080\" keyword=\"ReferencedDoseSequence\" vr=\"SQ\" vm=\"1\">Referenced Dose Sequence</tag>
    <tag group=\"300C\" element=\"00A0\" keyword=\"ReferencedToleranceTableNumber\" vr=\"IS\" vm=\"1\">Referenced Tolerance Table Number</tag>
    <tag group=\"300C\" element=\"00B0\" keyword=\"ReferencedBolusSequence\" vr=\"SQ\" vm=\"1\">Referenced Bolus Sequence</tag>
    <tag group=\"300C\" element=\"00C0\" keyword=\"ReferencedWedgeNumber\" vr=\"IS\" vm=\"1\">Referenced Wedge Number</tag>
    <tag group=\"300C\" element=\"00D0\" keyword=\"ReferencedCompensatorNumber\" vr=\"IS\" vm=\"1\">Referenced Compensator Number</tag>
    <tag group=\"300C\" element=\"00E0\" keyword=\"ReferencedBlockNumber\" vr=\"IS\" vm=\"1\">Referenced Block Number</tag>
    <tag group=\"300C\" element=\"00F0\" keyword=\"ReferencedControlPointIndex\" vr=\"IS\" vm=\"1\">Referenced Control Point Index</tag>
    <tag group=\"300C\" element=\"00F2\" keyword=\"ReferencedControlPointSequence\" vr=\"SQ\" vm=\"1\">Referenced Control Point Sequence</tag>
    <tag group=\"300C\" element=\"00F4\" keyword=\"ReferencedStartControlPointIndex\" vr=\"IS\" vm=\"1\">Referenced Start Control Point Index</tag>
    <tag group=\"300C\" element=\"00F6\" keyword=\"ReferencedStopControlPointIndex\" vr=\"IS\" vm=\"1\">Referenced Stop Control Point Index</tag>
    <tag group=\"300C\" element=\"0100\" keyword=\"ReferencedRangeShifterNumber\" vr=\"IS\" vm=\"1\">Referenced Range Shifter Number</tag>
    <tag group=\"300C\" element=\"0102\" keyword=\"ReferencedLateralSpreadingDeviceNumber\" vr=\"IS\" vm=\"1\">Referenced Lateral Spreading Device Number</tag>
    <tag group=\"300C\" element=\"0104\" keyword=\"ReferencedRangeModulatorNumber\" vr=\"IS\" vm=\"1\">Referenced Range Modulator Number</tag>
    <tag group=\"300C\" element=\"0111\" keyword=\"OmittedBeamTaskSequence\" vr=\"SQ\" vm=\"1\">Omitted Beam Task Sequence</tag>
    <tag group=\"300C\" element=\"0112\" keyword=\"ReasonForOmission\" vr=\"CS\" vm=\"1\">Reason for Omission</tag>
    <tag group=\"300C\" element=\"0113\" keyword=\"ReasonForOmissionDescription\" vr=\"LO\" vm=\"1\">Reason for Omission Description</tag>
    <tag group=\"300E\" element=\"0002\" keyword=\"ApprovalStatus\" vr=\"CS\" vm=\"1\">Approval Status</tag>
    <tag group=\"300E\" element=\"0004\" keyword=\"ReviewDate\" vr=\"DA\" vm=\"1\">Review Date</tag>
    <tag group=\"300E\" element=\"0005\" keyword=\"ReviewTime\" vr=\"TM\" vm=\"1\">Review Time</tag>
    <tag group=\"300E\" element=\"0008\" keyword=\"ReviewerName\" vr=\"PN\" vm=\"1\">Reviewer Name</tag>
    <tag group=\"4000\" element=\"0010\" keyword=\"Arbitrary\" vr=\"LT\" vm=\"1\" retired=\"true\">Arbitrary</tag>
    <tag group=\"4000\" element=\"4000\" keyword=\"TextComments\" vr=\"LT\" vm=\"1\" retired=\"true\">Text Comments</tag>
    <tag group=\"4008\" element=\"0040\" keyword=\"ResultsID\" vr=\"SH\" vm=\"1\" retired=\"true\">Results ID</tag>
    <tag group=\"4008\" element=\"0042\" keyword=\"ResultsIDIssuer\" vr=\"LO\" vm=\"1\" retired=\"true\">Results ID Issuer</tag>
    <tag group=\"4008\" element=\"0050\" keyword=\"ReferencedInterpretationSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Referenced Interpretation Sequence</tag>
    <tag group=\"4008\" element=\"00FF\" keyword=\"ReportProductionStatusTrial\" vr=\"CS\" vm=\"1\" retired=\"true\">Report Production Status (Trial)</tag>
    <tag group=\"4008\" element=\"0100\" keyword=\"InterpretationRecordedDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Interpretation Recorded Date</tag>
    <tag group=\"4008\" element=\"0101\" keyword=\"InterpretationRecordedTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Interpretation Recorded Time</tag>
    <tag group=\"4008\" element=\"0102\" keyword=\"InterpretationRecorder\" vr=\"PN\" vm=\"1\" retired=\"true\">Interpretation Recorder</tag>
    <tag group=\"4008\" element=\"0103\" keyword=\"ReferenceToRecordedSound\" vr=\"LO\" vm=\"1\" retired=\"true\">Reference to Recorded Sound</tag>
    <tag group=\"4008\" element=\"0108\" keyword=\"InterpretationTranscriptionDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Interpretation Transcription Date</tag>
    <tag group=\"4008\" element=\"0109\" keyword=\"InterpretationTranscriptionTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Interpretation Transcription Time</tag>
    <tag group=\"4008\" element=\"010A\" keyword=\"InterpretationTranscriber\" vr=\"PN\" vm=\"1\" retired=\"true\">Interpretation Transcriber</tag>
    <tag group=\"4008\" element=\"010B\" keyword=\"InterpretationText\" vr=\"ST\" vm=\"1\" retired=\"true\">Interpretation Text</tag>
    <tag group=\"4008\" element=\"010C\" keyword=\"InterpretationAuthor\" vr=\"PN\" vm=\"1\" retired=\"true\">Interpretation Author</tag>
    <tag group=\"4008\" element=\"0111\" keyword=\"InterpretationApproverSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Interpretation Approver Sequence</tag>
    <tag group=\"4008\" element=\"0112\" keyword=\"InterpretationApprovalDate\" vr=\"DA\" vm=\"1\" retired=\"true\">Interpretation Approval Date</tag>
    <tag group=\"4008\" element=\"0113\" keyword=\"InterpretationApprovalTime\" vr=\"TM\" vm=\"1\" retired=\"true\">Interpretation Approval Time</tag>
    <tag group=\"4008\" element=\"0114\" keyword=\"PhysicianApprovingInterpretation\" vr=\"PN\" vm=\"1\" retired=\"true\">Physician Approving Interpretation</tag>
    <tag group=\"4008\" element=\"0115\" keyword=\"InterpretationDiagnosisDescription\" vr=\"LT\" vm=\"1\" retired=\"true\">Interpretation Diagnosis Description</tag>
    <tag group=\"4008\" element=\"0117\" keyword=\"InterpretationDiagnosisCodeSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Interpretation Diagnosis Code Sequence</tag>
    <tag group=\"4008\" element=\"0118\" keyword=\"ResultsDistributionListSequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Results Distribution List Sequence</tag>
    <tag group=\"4008\" element=\"0119\" keyword=\"DistributionName\" vr=\"PN\" vm=\"1\" retired=\"true\">Distribution Name</tag>
    <tag group=\"4008\" element=\"011A\" keyword=\"DistributionAddress\" vr=\"LO\" vm=\"1\" retired=\"true\">Distribution Address</tag>
    <tag group=\"4008\" element=\"0200\" keyword=\"InterpretationID\" vr=\"SH\" vm=\"1\" retired=\"true\">Interpretation ID</tag>
    <tag group=\"4008\" element=\"0202\" keyword=\"InterpretationIDIssuer\" vr=\"LO\" vm=\"1\" retired=\"true\">Interpretation ID Issuer</tag>
    <tag group=\"4008\" element=\"0210\" keyword=\"InterpretationTypeID\" vr=\"CS\" vm=\"1\" retired=\"true\">Interpretation Type ID</tag>
    <tag group=\"4008\" element=\"0212\" keyword=\"InterpretationStatusID\" vr=\"CS\" vm=\"1\" retired=\"true\">Interpretation Status ID</tag>
    <tag group=\"4008\" element=\"0300\" keyword=\"Impressions\" vr=\"ST\" vm=\"1\" retired=\"true\">Impressions</tag>
    <tag group=\"4008\" element=\"4000\" keyword=\"ResultsComments\" vr=\"ST\" vm=\"1\" retired=\"true\">Results Comments</tag>
    <tag group=\"4010\" element=\"0001\" keyword=\"LowEnergyDetectors\" vr=\"CS\" vm=\"1\">Low Energy Detectors</tag>
    <tag group=\"4010\" element=\"0002\" keyword=\"HighEnergyDetectors\" vr=\"CS\" vm=\"1\">High Energy Detectors</tag>
    <tag group=\"4010\" element=\"0004\" keyword=\"DetectorGeometrySequence\" vr=\"SQ\" vm=\"1\">Detector Geometry Sequence</tag>
    <tag group=\"4010\" element=\"1001\" keyword=\"ThreatROIVoxelSequence\" vr=\"SQ\" vm=\"1\">Threat ROI Voxel Sequence</tag>
    <tag group=\"4010\" element=\"1004\" keyword=\"ThreatROIBase\" vr=\"FL\" vm=\"3\">Threat ROI Base</tag>
    <tag group=\"4010\" element=\"1005\" keyword=\"ThreatROIExtents\" vr=\"FL\" vm=\"3\">Threat ROI Extents</tag>
    <tag group=\"4010\" element=\"1006\" keyword=\"ThreatROIBitmap\" vr=\"OB\" vm=\"1\">Threat ROI Bitmap</tag>
    <tag group=\"4010\" element=\"1007\" keyword=\"RouteSegmentID\" vr=\"SH\" vm=\"1\">Route Segment ID</tag>
    <tag group=\"4010\" element=\"1008\" keyword=\"GantryType\" vr=\"CS\" vm=\"1\">Gantry Type</tag>
    <tag group=\"4010\" element=\"1009\" keyword=\"OOIOwnerType\" vr=\"CS\" vm=\"1\">OOI Owner Type</tag>
    <tag group=\"4010\" element=\"100A\" keyword=\"RouteSegmentSequence\" vr=\"SQ\" vm=\"1\">Route Segment Sequence</tag>
    <tag group=\"4010\" element=\"1010\" keyword=\"PotentialThreatObjectID\" vr=\"US\" vm=\"1\">Potential Threat Object ID</tag>
    <tag group=\"4010\" element=\"1011\" keyword=\"ThreatSequence\" vr=\"SQ\" vm=\"1\">Threat Sequence</tag>
    <tag group=\"4010\" element=\"1012\" keyword=\"ThreatCategory\" vr=\"CS\" vm=\"1\">Threat Category</tag>
    <tag group=\"4010\" element=\"1013\" keyword=\"ThreatCategoryDescription\" vr=\"LT\" vm=\"1\">Threat Category Description</tag>
    <tag group=\"4010\" element=\"1014\" keyword=\"ATDAbilityAssessment\" vr=\"CS\" vm=\"1\">ATD Ability Assessment</tag>
    <tag group=\"4010\" element=\"1015\" keyword=\"ATDAssessmentFlag\" vr=\"CS\" vm=\"1\">ATD Assessment Flag</tag>
    <tag group=\"4010\" element=\"1016\" keyword=\"ATDAssessmentProbability\" vr=\"FL\" vm=\"1\">ATD Assessment Probability</tag>
    <tag group=\"4010\" element=\"1017\" keyword=\"Mass\" vr=\"FL\" vm=\"1\">Mass</tag>
    <tag group=\"4010\" element=\"1018\" keyword=\"Density\" vr=\"FL\" vm=\"1\">Density</tag>
    <tag group=\"4010\" element=\"1019\" keyword=\"ZEffective\" vr=\"FL\" vm=\"1\">Z Effective</tag>
    <tag group=\"4010\" element=\"101A\" keyword=\"BoardingPassID\" vr=\"SH\" vm=\"1\">Boarding Pass ID</tag>
    <tag group=\"4010\" element=\"101B\" keyword=\"CenterOfMass\" vr=\"FL\" vm=\"3\">Center of Mass</tag>
    <tag group=\"4010\" element=\"101C\" keyword=\"CenterOfPTO\" vr=\"FL\" vm=\"3\">Center of PTO</tag>
    <tag group=\"4010\" element=\"101D\" keyword=\"BoundingPolygon\" vr=\"FL\" vm=\"6-n\">Bounding Polygon</tag>
    <tag group=\"4010\" element=\"101E\" keyword=\"RouteSegmentStartLocationID\" vr=\"SH\" vm=\"1\">Route Segment Start Location ID</tag>
    <tag group=\"4010\" element=\"101F\" keyword=\"RouteSegmentEndLocationID\" vr=\"SH\" vm=\"1\">Route Segment End Location ID</tag>
    <tag group=\"4010\" element=\"1020\" keyword=\"RouteSegmentLocationIDType\" vr=\"CS\" vm=\"1\">Route Segment Location ID Type</tag>
    <tag group=\"4010\" element=\"1021\" keyword=\"AbortReason\" vr=\"CS\" vm=\"1-n\">Abort Reason</tag>
    <tag group=\"4010\" element=\"1023\" keyword=\"VolumeOfPTO\" vr=\"FL\" vm=\"1\">Volume of PTO</tag>
    <tag group=\"4010\" element=\"1024\" keyword=\"AbortFlag\" vr=\"CS\" vm=\"1\">Abort Flag</tag>
    <tag group=\"4010\" element=\"1025\" keyword=\"RouteSegmentStartTime\" vr=\"DT\" vm=\"1\">Route Segment Start Time</tag>
    <tag group=\"4010\" element=\"1026\" keyword=\"RouteSegmentEndTime\" vr=\"DT\" vm=\"1\">Route Segment End Time</tag>
    <tag group=\"4010\" element=\"1027\" keyword=\"TDRType\" vr=\"CS\" vm=\"1\">TDR Type</tag>
    <tag group=\"4010\" element=\"1028\" keyword=\"InternationalRouteSegment\" vr=\"CS\" vm=\"1\">International Route Segment</tag>
    <tag group=\"4010\" element=\"1029\" keyword=\"ThreatDetectionAlgorithmandVersion\" vr=\"LO\" vm=\"1-n\">Threat Detection Algorithm and Version</tag>
    <tag group=\"4010\" element=\"102A\" keyword=\"AssignedLocation\" vr=\"SH\" vm=\"1\">Assigned Location</tag>
    <tag group=\"4010\" element=\"102B\" keyword=\"AlarmDecisionTime\" vr=\"DT\" vm=\"1\">Alarm Decision Time</tag>
    <tag group=\"4010\" element=\"1031\" keyword=\"AlarmDecision\" vr=\"CS\" vm=\"1\">Alarm Decision</tag>
    <tag group=\"4010\" element=\"1033\" keyword=\"NumberOfTotalObjects\" vr=\"US\" vm=\"1\">Number of Total Objects</tag>
    <tag group=\"4010\" element=\"1034\" keyword=\"NumberOfAlarmObjects\" vr=\"US\" vm=\"1\">Number of Alarm Objects</tag>
    <tag group=\"4010\" element=\"1037\" keyword=\"PTORepresentationSequence\" vr=\"SQ\" vm=\"1\">PTO Representation Sequence</tag>
    <tag group=\"4010\" element=\"1038\" keyword=\"ATDAssessmentSequence\" vr=\"SQ\" vm=\"1\">ATD Assessment Sequence</tag>
    <tag group=\"4010\" element=\"1039\" keyword=\"TIPType\" vr=\"CS\" vm=\"1\">TIP Type</tag>
    <tag group=\"4010\" element=\"103A\" keyword=\"DICOSVersion\" vr=\"CS\" vm=\"1\">DICOS Version</tag>
    <tag group=\"4010\" element=\"1041\" keyword=\"OOIOwnerCreationTime\" vr=\"DT\" vm=\"1\">OOI Owner Creation Time</tag>
    <tag group=\"4010\" element=\"1042\" keyword=\"OOIType\" vr=\"CS\" vm=\"1\">OOI Type</tag>
    <tag group=\"4010\" element=\"1043\" keyword=\"OOISize\" vr=\"FL\" vm=\"3\">OOI Size</tag>
    <tag group=\"4010\" element=\"1044\" keyword=\"AcquisitionStatus\" vr=\"CS\" vm=\"1\">Acquisition Status</tag>
    <tag group=\"4010\" element=\"1045\" keyword=\"BasisMaterialsCodeSequence\" vr=\"SQ\" vm=\"1\">Basis Materials Code Sequence</tag>
    <tag group=\"4010\" element=\"1046\" keyword=\"PhantomType\" vr=\"CS\" vm=\"1\">Phantom Type</tag>
    <tag group=\"4010\" element=\"1047\" keyword=\"OOIOwnerSequence\" vr=\"SQ\" vm=\"1\">OOI Owner Sequence</tag>
    <tag group=\"4010\" element=\"1048\" keyword=\"ScanType\" vr=\"CS\" vm=\"1\">Scan Type</tag>
    <tag group=\"4010\" element=\"1051\" keyword=\"ItineraryID\" vr=\"LO\" vm=\"1\">Itinerary ID</tag>
    <tag group=\"4010\" element=\"1052\" keyword=\"ItineraryIDType\" vr=\"SH\" vm=\"1\">Itinerary ID Type</tag>
    <tag group=\"4010\" element=\"1053\" keyword=\"ItineraryIDAssigningAuthority\" vr=\"LO\" vm=\"1\">Itinerary ID Assigning Authority</tag>
    <tag group=\"4010\" element=\"1054\" keyword=\"RouteID\" vr=\"SH\" vm=\"1\">Route ID</tag>
    <tag group=\"4010\" element=\"1055\" keyword=\"RouteIDAssigningAuthority\" vr=\"SH\" vm=\"1\">Route ID Assigning Authority</tag>
    <tag group=\"4010\" element=\"1056\" keyword=\"InboundArrivalType\" vr=\"CS\" vm=\"1\">Inbound Arrival Type</tag>
    <tag group=\"4010\" element=\"1058\" keyword=\"CarrierID\" vr=\"SH\" vm=\"1\">Carrier ID</tag>
    <tag group=\"4010\" element=\"1059\" keyword=\"CarrierIDAssigningAuthority\" vr=\"CS\" vm=\"1\">Carrier ID Assigning Authority</tag>
    <tag group=\"4010\" element=\"1060\" keyword=\"SourceOrientation\" vr=\"FL\" vm=\"3\">Source Orientation</tag>
    <tag group=\"4010\" element=\"1061\" keyword=\"SourcePosition\" vr=\"FL\" vm=\"3\">Source Position</tag>
    <tag group=\"4010\" element=\"1062\" keyword=\"BeltHeight\" vr=\"FL\" vm=\"1\">Belt Height</tag>
    <tag group=\"4010\" element=\"1064\" keyword=\"AlgorithmRoutingCodeSequence\" vr=\"SQ\" vm=\"1\">Algorithm Routing Code Sequence</tag>
    <tag group=\"4010\" element=\"1067\" keyword=\"TransportClassification\" vr=\"CS\" vm=\"1\">Transport Classification</tag>
    <tag group=\"4010\" element=\"1068\" keyword=\"OOITypeDescriptor\" vr=\"LT\" vm=\"1\">OOI Type Descriptor</tag>
    <tag group=\"4010\" element=\"1069\" keyword=\"TotalProcessingTime\" vr=\"FL\" vm=\"1\">Total Processing Time</tag>
    <tag group=\"4010\" element=\"106C\" keyword=\"DetectorCalibrationData\" vr=\"OB\" vm=\"1\">Detector Calibration Data</tag>
    <tag group=\"4010\" element=\"106D\" keyword=\"AdditionalScreeningPerformed\" vr=\"CS\" vm=\"1\">Additional Screening Performed</tag>
    <tag group=\"4010\" element=\"106E\" keyword=\"AdditionalInspectionSelectionCriteria\" vr=\"CS\" vm=\"1\">Additional Inspection Selection Criteria</tag>
    <tag group=\"4010\" element=\"106F\" keyword=\"AdditionalInspectionMethodSequence\" vr=\"SQ\" vm=\"1\">Additional Inspection Method Sequence</tag>
    <tag group=\"4010\" element=\"1070\" keyword=\"AITDeviceType\" vr=\"CS\" vm=\"1\">AIT Device Type</tag>
    <tag group=\"4010\" element=\"1071\" keyword=\"QRMeasurementsSequence\" vr=\"SQ\" vm=\"1\">QR Measurements Sequence</tag>
    <tag group=\"4010\" element=\"1072\" keyword=\"TargetMaterialSequence\" vr=\"SQ\" vm=\"1\">Target Material Sequence</tag>
    <tag group=\"4010\" element=\"1073\" keyword=\"SNRThreshold\" vr=\"FD\" vm=\"1\">SNR Threshold</tag>
    <tag group=\"4010\" element=\"1075\" keyword=\"ImageScaleRepresentation\" vr=\"DS\" vm=\"1\">Image Scale Representation</tag>
    <tag group=\"4010\" element=\"1076\" keyword=\"ReferencedPTOSequence\" vr=\"SQ\" vm=\"1\">Referenced PTO Sequence</tag>
    <tag group=\"4010\" element=\"1077\" keyword=\"ReferencedTDRInstanceSequence\" vr=\"SQ\" vm=\"1\">Referenced TDR Instance Sequence</tag>
    <tag group=\"4010\" element=\"1078\" keyword=\"PTOLocationDescription\" vr=\"ST\" vm=\"1\">PTO Location Description</tag>
    <tag group=\"4010\" element=\"1079\" keyword=\"AnomalyLocatorIndicatorSequence\" vr=\"SQ\" vm=\"1\">Anomaly Locator Indicator Sequence</tag>
    <tag group=\"4010\" element=\"107A\" keyword=\"AnomalyLocatorIndicator\" vr=\"FL\" vm=\"3\">Anomaly Locator Indicator</tag>
    <tag group=\"4010\" element=\"107B\" keyword=\"PTORegionSequence\" vr=\"SQ\" vm=\"1\">PTO Region Sequence</tag>
    <tag group=\"4010\" element=\"107C\" keyword=\"InspectionSelectionCriteria\" vr=\"CS\" vm=\"1\">Inspection Selection Criteria</tag>
    <tag group=\"4010\" element=\"107D\" keyword=\"SecondaryInspectionMethodSequence\" vr=\"SQ\" vm=\"1\">Secondary Inspection Method Sequence</tag>
    <tag group=\"4010\" element=\"107E\" keyword=\"PRCSToRCSOrientation\" vr=\"DS\" vm=\"6\">PRCS to RCS Orientation</tag>
    <tag group=\"4FFE\" element=\"0001\" keyword=\"MACParametersSequence\" vr=\"SQ\" vm=\"1\">MAC Parameters Sequence</tag>
    <tag group=\"50xx\" element=\"0005\" keyword=\"CurveDimensions\" vr=\"US\" vm=\"1\" retired=\"true\">Curve Dimensions</tag>
    <tag group=\"50xx\" element=\"0010\" keyword=\"NumberOfPoints\" vr=\"US\" vm=\"1\" retired=\"true\">Number of Points</tag>
    <tag group=\"50xx\" element=\"0020\" keyword=\"TypeOfData\" vr=\"CS\" vm=\"1\" retired=\"true\">Type of Data</tag>
    <tag group=\"50xx\" element=\"0022\" keyword=\"CurveDescription\" vr=\"LO\" vm=\"1\" retired=\"true\">Curve Description</tag>
    <tag group=\"50xx\" element=\"0030\" keyword=\"AxisUnits\" vr=\"SH\" vm=\"1-n\" retired=\"true\">Axis Units</tag>
    <tag group=\"50xx\" element=\"0040\" keyword=\"AxisLabels\" vr=\"SH\" vm=\"1-n\" retired=\"true\">Axis Labels</tag>
    <tag group=\"50xx\" element=\"0103\" keyword=\"DataValueRepresentation\" vr=\"US\" vm=\"1\" retired=\"true\">Data Value Representation</tag>
    <tag group=\"50xx\" element=\"0104\" keyword=\"MinimumCoordinateValue\" vr=\"US\" vm=\"1-n\" retired=\"true\">Minimum Coordinate Value</tag>
    <tag group=\"50xx\" element=\"0105\" keyword=\"MaximumCoordinateValue\" vr=\"US\" vm=\"1-n\" retired=\"true\">Maximum Coordinate Value</tag>
    <tag group=\"50xx\" element=\"0106\" keyword=\"CurveRange\" vr=\"SH\" vm=\"1-n\" retired=\"true\">Curve Range</tag>
    <tag group=\"50xx\" element=\"0110\" keyword=\"CurveDataDescriptor\" vr=\"US\" vm=\"1-n\" retired=\"true\">Curve Data Descriptor</tag>
    <tag group=\"50xx\" element=\"0112\" keyword=\"CoordinateStartValue\" vr=\"US\" vm=\"1-n\" retired=\"true\">Coordinate Start Value</tag>
    <tag group=\"50xx\" element=\"0114\" keyword=\"CoordinateStepValue\" vr=\"US\" vm=\"1-n\" retired=\"true\">Coordinate Step Value</tag>
    <tag group=\"50xx\" element=\"1001\" keyword=\"CurveActivationLayer\" vr=\"CS\" vm=\"1\" retired=\"true\">Curve Activation Layer</tag>
    <tag group=\"50xx\" element=\"2000\" keyword=\"AudioType\" vr=\"US\" vm=\"1\" retired=\"true\">Audio Type</tag>
    <tag group=\"50xx\" element=\"2002\" keyword=\"AudioSampleFormat\" vr=\"US\" vm=\"1\" retired=\"true\">Audio Sample Format</tag>
    <tag group=\"50xx\" element=\"2004\" keyword=\"NumberOfChannels\" vr=\"US\" vm=\"1\" retired=\"true\">Number of Channels</tag>
    <tag group=\"50xx\" element=\"2006\" keyword=\"NumberOfSamples\" vr=\"UL\" vm=\"1\" retired=\"true\">Number of Samples</tag>
    <tag group=\"50xx\" element=\"2008\" keyword=\"SampleRate\" vr=\"UL\" vm=\"1\" retired=\"true\">Sample Rate</tag>
    <tag group=\"50xx\" element=\"200A\" keyword=\"TotalTime\" vr=\"UL\" vm=\"1\" retired=\"true\">Total Time</tag>
    <tag group=\"50xx\" element=\"200C\" keyword=\"AudioSampleData\" vr=\"OB/OW\" vm=\"1\" retired=\"true\">Audio Sample Data</tag>
    <tag group=\"50xx\" element=\"200E\" keyword=\"AudioComments\" vr=\"LT\" vm=\"1\" retired=\"true\">Audio Comments</tag>
    <tag group=\"50xx\" element=\"2500\" keyword=\"CurveLabel\" vr=\"LO\" vm=\"1\" retired=\"true\">Curve Label</tag>
    <tag group=\"50xx\" element=\"2600\" keyword=\"CurveReferencedOverlaySequence\" vr=\"SQ\" vm=\"1\" retired=\"true\">Curve Referenced Overlay Sequence</tag>
    <tag group=\"50xx\" element=\"2610\" keyword=\"CurveReferencedOverlayGroup\" vr=\"US\" vm=\"1\" retired=\"true\">Curve Referenced Overlay Group</tag>
    <tag group=\"50xx\" element=\"3000\" keyword=\"CurveData\" vr=\"OB/OW\" vm=\"1\" retired=\"true\">Curve Data</tag>
    <tag group=\"5200\" element=\"9229\" keyword=\"SharedFunctionalGroupsSequence\" vr=\"SQ\" vm=\"1\">Shared Functional Groups Sequence</tag>
    <tag group=\"5200\" element=\"9230\" keyword=\"PerFrameFunctionalGroupsSequence\" vr=\"SQ\" vm=\"1\">Per-frame Functional Groups Sequence</tag>
    <tag group=\"5400\" element=\"0100\" keyword=\"WaveformSequence\" vr=\"SQ\" vm=\"1\">Waveform Sequence</tag>
    <tag group=\"5400\" element=\"0110\" keyword=\"ChannelMinimumValue\" vr=\"OB/OW\" vm=\"1\">Channel Minimum Value</tag>
    <tag group=\"5400\" element=\"0112\" keyword=\"ChannelMaximumValue\" vr=\"OB/OW\" vm=\"1\">Channel Maximum Value</tag>
    <tag group=\"5400\" element=\"1004\" keyword=\"WaveformBitsAllocated\" vr=\"US\" vm=\"1\">Waveform Bits Allocated</tag>
    <tag group=\"5400\" element=\"1006\" keyword=\"WaveformSampleInterpretation\" vr=\"CS\" vm=\"1\">Waveform Sample Interpretation</tag>
    <tag group=\"5400\" element=\"100A\" keyword=\"WaveformPaddingValue\" vr=\"OB/OW\" vm=\"1\">Waveform Padding Value</tag>
    <tag group=\"5400\" element=\"1010\" keyword=\"WaveformData\" vr=\"OB/OW\" vm=\"1\">Waveform Data</tag>
    <tag group=\"5600\" element=\"0010\" keyword=\"FirstOrderPhaseCorrectionAngle\" vr=\"OF\" vm=\"1\">First Order Phase Correction Angle</tag>
    <tag group=\"5600\" element=\"0020\" keyword=\"SpectroscopyData\" vr=\"OF\" vm=\"1\">Spectroscopy Data</tag>
    <tag group=\"60xx\" element=\"0010\" keyword=\"OverlayRows\" vr=\"US\" vm=\"1\">Overlay Rows</tag>
    <tag group=\"60xx\" element=\"0011\" keyword=\"OverlayColumns\" vr=\"US\" vm=\"1\">Overlay Columns</tag>
    <tag group=\"60xx\" element=\"0012\" keyword=\"OverlayPlanes\" vr=\"US\" vm=\"1\" retired=\"true\">Overlay Planes</tag>
    <tag group=\"60xx\" element=\"0015\" keyword=\"NumberOfFramesInOverlay\" vr=\"IS\" vm=\"1\">Number of Frames in Overlay</tag>
    <tag group=\"60xx\" element=\"0022\" keyword=\"OverlayDescription\" vr=\"LO\" vm=\"1\">Overlay Description</tag>
    <tag group=\"60xx\" element=\"0040\" keyword=\"OverlayType\" vr=\"CS\" vm=\"1\">Overlay Type</tag>
    <tag group=\"60xx\" element=\"0045\" keyword=\"OverlaySubtype\" vr=\"LO\" vm=\"1\">Overlay Subtype</tag>
    <tag group=\"60xx\" element=\"0050\" keyword=\"OverlayOrigin\" vr=\"SS\" vm=\"2\">Overlay Origin</tag>
    <tag group=\"60xx\" element=\"0051\" keyword=\"ImageFrameOrigin\" vr=\"US\" vm=\"1\">Image Frame Origin</tag>
    <tag group=\"60xx\" element=\"0052\" keyword=\"OverlayPlaneOrigin\" vr=\"US\" vm=\"1\" retired=\"true\">Overlay Plane Origin</tag>
    <tag group=\"60xx\" element=\"0060\" keyword=\"OverlayCompressionCode\" vr=\"CS\" vm=\"1\" retired=\"true\">Overlay Compression Code</tag>
    <tag group=\"60xx\" element=\"0061\" keyword=\"OverlayCompressionOriginator\" vr=\"SH\" vm=\"1\" retired=\"true\">Overlay Compression Originator</tag>
    <tag group=\"60xx\" element=\"0062\" keyword=\"OverlayCompressionLabel\" vr=\"SH\" vm=\"1\" retired=\"true\">Overlay Compression Label</tag>
    <tag group=\"60xx\" element=\"0063\" keyword=\"OverlayCompressionDescription\" vr=\"CS\" vm=\"1\" retired=\"true\">Overlay Compression Description</tag>
    <tag group=\"60xx\" element=\"0066\" keyword=\"OverlayCompressionStepPointers\" vr=\"AT\" vm=\"1-n\" retired=\"true\">Overlay Compression Step Pointers</tag>
    <tag group=\"60xx\" element=\"0068\" keyword=\"OverlayRepeatInterval\" vr=\"US\" vm=\"1\" retired=\"true\">Overlay Repeat Interval</tag>
    <tag group=\"60xx\" element=\"0069\" keyword=\"OverlayBitsGrouped\" vr=\"US\" vm=\"1\" retired=\"true\">Overlay Bits Grouped</tag>
    <tag group=\"60xx\" element=\"0100\" keyword=\"OverlayBitsAllocated\" vr=\"US\" vm=\"1\">Overlay Bits Allocated</tag>
    <tag group=\"60xx\" element=\"0102\" keyword=\"OverlayBitPosition\" vr=\"US\" vm=\"1\">Overlay Bit Position</tag>
    <tag group=\"60xx\" element=\"0110\" keyword=\"OverlayFormat\" vr=\"CS\" vm=\"1\" retired=\"true\">Overlay Format</tag>
    <tag group=\"60xx\" element=\"0200\" keyword=\"OverlayLocation\" vr=\"US\" vm=\"1\" retired=\"true\">Overlay Location</tag>
    <tag group=\"60xx\" element=\"0800\" keyword=\"OverlayCodeLabel\" vr=\"CS\" vm=\"1-n\" retired=\"true\">Overlay Code Label</tag>
    <tag group=\"60xx\" element=\"0802\" keyword=\"OverlayNumberOfTables\" vr=\"US\" vm=\"1\" retired=\"true\">Overlay Number of Tables</tag>
    <tag group=\"60xx\" element=\"0803\" keyword=\"OverlayCodeTableLocation\" vr=\"AT\" vm=\"1-n\" retired=\"true\">Overlay Code Table Location</tag>
    <tag group=\"60xx\" element=\"0804\" keyword=\"OverlayBitsForCodeWord\" vr=\"US\" vm=\"1\" retired=\"true\">Overlay Bits For Code Word</tag>
    <tag group=\"60xx\" element=\"1001\" keyword=\"OverlayActivationLayer\" vr=\"CS\" vm=\"1\">Overlay Activation Layer</tag>
    <tag group=\"60xx\" element=\"1100\" keyword=\"OverlayDescriptorGray\" vr=\"US\" vm=\"1\" retired=\"true\">Overlay Descriptor - Gray</tag>
    <tag group=\"60xx\" element=\"1101\" keyword=\"OverlayDescriptorRed\" vr=\"US\" vm=\"1\" retired=\"true\">Overlay Descriptor - Red</tag>
    <tag group=\"60xx\" element=\"1102\" keyword=\"OverlayDescriptorGreen\" vr=\"US\" vm=\"1\" retired=\"true\">Overlay Descriptor - Green</tag>
    <tag group=\"60xx\" element=\"1103\" keyword=\"OverlayDescriptorBlue\" vr=\"US\" vm=\"1\" retired=\"true\">Overlay Descriptor - Blue</tag>
    <tag group=\"60xx\" element=\"1200\" keyword=\"OverlaysGray\" vr=\"US\" vm=\"1-n\" retired=\"true\">Overlays - Gray</tag>
    <tag group=\"60xx\" element=\"1201\" keyword=\"OverlaysRed\" vr=\"US\" vm=\"1-n\" retired=\"true\">Overlays - Red</tag>
    <tag group=\"60xx\" element=\"1202\" keyword=\"OverlaysGreen\" vr=\"US\" vm=\"1-n\" retired=\"true\">Overlays - Green</tag>
    <tag group=\"60xx\" element=\"1203\" keyword=\"OverlaysBlue\" vr=\"US\" vm=\"1-n\" retired=\"true\">Overlays - Blue</tag>
    <tag group=\"60xx\" element=\"1301\" keyword=\"ROIArea\" vr=\"IS\" vm=\"1\">ROI Area</tag>
    <tag group=\"60xx\" element=\"1302\" keyword=\"ROIMean\" vr=\"DS\" vm=\"1\">ROI Mean</tag>
    <tag group=\"60xx\" element=\"1303\" keyword=\"ROIStandardDeviation\" vr=\"DS\" vm=\"1\">ROI Standard Deviation</tag>
    <tag group=\"60xx\" element=\"1500\" keyword=\"OverlayLabel\" vr=\"LO\" vm=\"1\">Overlay Label</tag>
    <tag group=\"60xx\" element=\"3000\" keyword=\"OverlayData\" vr=\"OB/OW\" vm=\"1\">Overlay Data</tag>
    <tag group=\"60xx\" element=\"4000\" keyword=\"OverlayComments\" vr=\"LT\" vm=\"1\" retired=\"true\">Overlay Comments</tag>
    <tag group=\"7FE0\" element=\"0008\" keyword=\"FloatPixelData\" vr=\"OF\" vm=\"1\">Float Pixel Data</tag>
    <tag group=\"7FE0\" element=\"0009\" keyword=\"DoubleFloatPixelData\" vr=\"OD\" vm=\"1\">Double Float Pixel Data</tag>
    <tag group=\"7FE0\" element=\"0010\" keyword=\"PixelData\" vr=\"OB/OW\" vm=\"1\">Pixel Data</tag>
    <tag group=\"7FE0\" element=\"0020\" keyword=\"CoefficientsSDVN\" vr=\"OW\" vm=\"1\" retired=\"true\">Coefficients SDVN</tag>
    <tag group=\"7FE0\" element=\"0030\" keyword=\"CoefficientsSDHN\" vr=\"OW\" vm=\"1\" retired=\"true\">Coefficients SDHN</tag>
    <tag group=\"7FE0\" element=\"0040\" keyword=\"CoefficientsSDDN\" vr=\"OW\" vm=\"1\" retired=\"true\">Coefficients SDDN</tag>
    <tag group=\"7Fxx\" element=\"0010\" keyword=\"VariablePixelData\" vr=\"OB/OW\" vm=\"1\" retired=\"true\">Variable Pixel Data</tag>
    <tag group=\"7Fxx\" element=\"0011\" keyword=\"VariableNextDataGroup\" vr=\"US\" vm=\"1\" retired=\"true\">Variable Next Data Group</tag>
    <tag group=\"7Fxx\" element=\"0020\" keyword=\"VariableCoefficientsSDVN\" vr=\"OW\" vm=\"1\" retired=\"true\">Variable Coefficients SDVN</tag>
    <tag group=\"7Fxx\" element=\"0030\" keyword=\"VariableCoefficientsSDHN\" vr=\"OW\" vm=\"1\" retired=\"true\">Variable Coefficients SDHN</tag>
    <tag group=\"7Fxx\" element=\"0040\" keyword=\"VariableCoefficientsSDDN\" vr=\"OW\" vm=\"1\" retired=\"true\">Variable Coefficients SDDN</tag>
    <tag group=\"FFFA\" element=\"FFFA\" keyword=\"DigitalSignaturesSequence\" vr=\"SQ\" vm=\"1\">Digital Signatures Sequence</tag>
    <tag group=\"FFFC\" element=\"FFFC\" keyword=\"DataSetTrailingPadding\" vr=\"OB\" vm=\"1\">Data Set Trailing Padding</tag>
    <tag group=\"FFFE\" element=\"E000\" keyword=\"Item\" vm=\"1\">Item</tag>
    <tag group=\"FFFE\" element=\"E00D\" keyword=\"ItemDelimitationItem\" vm=\"1\">Item Delimitation Item</tag>
    <tag group=\"FFFE\" element=\"E0DD\" keyword=\"SequenceDelimitationItem\" vm=\"1\">Sequence Delimitation Item</tag>

    <uid uid=\"1.2.840.10008.1.1\" keyword=\"Verification\" type=\"SOP Class\">Verification SOP Class</uid>
    <uid uid=\"1.2.840.10008.1.2\" keyword=\"ImplicitVRLittleEndian\" type=\"Transfer Syntax\">Implicit VR Little Endian: Default Transfer Syntax for DICOM</uid>
    <uid uid=\"1.2.840.10008.1.2.1\" keyword=\"ExplicitVRLittleEndian\" type=\"Transfer Syntax\">Explicit VR Little Endian</uid>
    <uid uid=\"1.2.840.10008.1.2.1.99\" keyword=\"DeflatedExplicitVRLittleEndian\" type=\"Transfer Syntax\">Deflated Explicit VR Little Endian</uid>
    <uid uid=\"1.2.840.10008.1.2.2\" keyword=\"ExplicitVRBigEndian\" type=\"Transfer Syntax\" retired=\"true\">Explicit VR Big Endian (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.50\" keyword=\"JPEGBaseline1\" type=\"Transfer Syntax\">JPEG Baseline (Process 1): Default Transfer Syntax for Lossy JPEG 8 Bit Image Compression</uid>
    <uid uid=\"1.2.840.10008.1.2.4.51\" keyword=\"JPEGExtended24\" type=\"Transfer Syntax\">JPEG Extended (Process 2 &amp; 4): Default Transfer Syntax for Lossy JPEG 12 Bit Image Compression (Process 4 only)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.52\" keyword=\"JPEGExtended35\" type=\"Transfer Syntax\" retired=\"true\">JPEG Extended (Process 3 &amp; 5) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.53\" keyword=\"JPEGSpectralSelectionNonHierarchical68\" type=\"Transfer Syntax\" retired=\"true\">JPEG Spectral Selection, Non-Hierarchical (Process 6 &amp; 8) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.54\" keyword=\"JPEGSpectralSelectionNonHierarchical79\" type=\"Transfer Syntax\" retired=\"true\">JPEG Spectral Selection, Non-Hierarchical (Process 7 &amp; 9) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.55\" keyword=\"JPEGFullProgressionNonHierarchical1012\" type=\"Transfer Syntax\" retired=\"true\">JPEG Full Progression, Non-Hierarchical (Process 10 &amp; 12) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.56\" keyword=\"JPEGFullProgressionNonHierarchical1113\" type=\"Transfer Syntax\" retired=\"true\">JPEG Full Progression, Non-Hierarchical (Process 11 &amp; 13) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.57\" keyword=\"JPEGLosslessNonHierarchical14\" type=\"Transfer Syntax\">JPEG Lossless, Non-Hierarchical (Process 14)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.58\" keyword=\"JPEGLosslessNonHierarchical15\" type=\"Transfer Syntax\" retired=\"true\">JPEG Lossless, Non-Hierarchical (Process 15) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.59\" keyword=\"JPEGExtendedHierarchical1618\" type=\"Transfer Syntax\" retired=\"true\">JPEG Extended, Hierarchical (Process 16 &amp; 18) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.60\" keyword=\"JPEGExtendedHierarchical1719\" type=\"Transfer Syntax\" retired=\"true\">JPEG Extended, Hierarchical (Process 17 &amp; 19) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.61\" keyword=\"JPEGSpectralSelectionHierarchical2022\" type=\"Transfer Syntax\" retired=\"true\">JPEG Spectral Selection, Hierarchical (Process 20 &amp; 22) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.62\" keyword=\"JPEGSpectralSelectionHierarchical2123\" type=\"Transfer Syntax\" retired=\"true\">JPEG Spectral Selection, Hierarchical (Process 21 &amp; 23) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.63\" keyword=\"JPEGFullProgressionHierarchical2426\" type=\"Transfer Syntax\" retired=\"true\">JPEG Full Progression, Hierarchical (Process 24 &amp; 26) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.64\" keyword=\"JPEGFullProgressionHierarchical2527\" type=\"Transfer Syntax\" retired=\"true\">JPEG Full Progression, Hierarchical (Process 25 &amp; 27) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.65\" keyword=\"JPEGLosslessHierarchical28\" type=\"Transfer Syntax\" retired=\"true\">JPEG Lossless, Hierarchical (Process 28) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.66\" keyword=\"JPEGLosslessHierarchical29\" type=\"Transfer Syntax\" retired=\"true\">JPEG Lossless, Hierarchical (Process 29) (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.70\" keyword=\"JPEGLossless\" type=\"Transfer Syntax\">JPEG Lossless, Non-Hierarchical, First-Order Prediction (Process 14 [Selection Value 1]): Default Transfer Syntax for Lossless JPEG Image Compression</uid>
    <uid uid=\"1.2.840.10008.1.2.4.80\" keyword=\"JPEGLSLossless\" type=\"Transfer Syntax\">JPEG-LS Lossless Image Compression</uid>
    <uid uid=\"1.2.840.10008.1.2.4.81\" keyword=\"JPEGLSLossyNearLossless\" type=\"Transfer Syntax\">JPEG-LS Lossy (Near-Lossless) Image Compression</uid>
    <uid uid=\"1.2.840.10008.1.2.4.90\" keyword=\"JPEG2000LosslessOnly\" type=\"Transfer Syntax\">JPEG 2000 Image Compression (Lossless Only)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.91\" keyword=\"JPEG2000\" type=\"Transfer Syntax\">JPEG 2000 Image Compression</uid>
    <uid uid=\"1.2.840.10008.1.2.4.92\" keyword=\"JPEG2000Part2MultiComponentLosslessOnly\" type=\"Transfer Syntax\">JPEG 2000 Part 2 Multi-component Image Compression (Lossless Only)</uid>
    <uid uid=\"1.2.840.10008.1.2.4.93\" keyword=\"JPEG2000Part2MultiComponent\" type=\"Transfer Syntax\">JPEG 2000 Part 2 Multi-component Image Compression</uid>
    <uid uid=\"1.2.840.10008.1.2.4.94\" keyword=\"JPIPReferenced\" type=\"Transfer Syntax\">JPIP Referenced</uid>
    <uid uid=\"1.2.840.10008.1.2.4.95\" keyword=\"JPIPReferencedDeflate\" type=\"Transfer Syntax\">JPIP Referenced Deflate</uid>
    <uid uid=\"1.2.840.10008.1.2.4.100\" keyword=\"MPEG2\" type=\"Transfer Syntax\">MPEG2 Main Profile / Main Level</uid>
    <uid uid=\"1.2.840.10008.1.2.4.101\" keyword=\"MPEG2MainProfileHighLevel\" type=\"Transfer Syntax\">MPEG2 Main Profile / High Level</uid>
    <uid uid=\"1.2.840.10008.1.2.4.102\" keyword=\"MPEG4AVCH264HighProfileLevel41\" type=\"Transfer Syntax\">MPEG-4 AVC/H.264 High Profile / Level 4.1</uid>
    <uid uid=\"1.2.840.10008.1.2.4.103\" keyword=\"MPEG4AVCH264BDCompatibleHighProfileLevel41\" type=\"Transfer Syntax\">MPEG-4 AVC/H.264 BD-compatible High Profile / Level 4.1</uid>
    <uid uid=\"1.2.840.10008.1.2.4.104\" keyword=\"MPEG4AVCH264HighProfileLevel42For2DVideo\" type=\"Transfer Syntax\">MPEG-4 AVC/H.264 High Profile / Level 4.2 For 2D Video</uid>
    <uid uid=\"1.2.840.10008.1.2.4.105\" keyword=\"MPEG4AVCH264HighProfileLevel42For3DVideo\" type=\"Transfer Syntax\">MPEG-4 AVC/H.264 High Profile / Level 4.2 For 3D Video</uid>
    <uid uid=\"1.2.840.10008.1.2.4.106\" keyword=\"MPEG4AVCH264StereoHighProfileLevel42\" type=\"Transfer Syntax\">MPEG-4 AVC/H.264 Stereo High Profile / Level 4.2</uid>
    <uid uid=\"1.2.840.10008.1.2.4.107\" keyword=\"HEVCH265MainProfileLevel51\" type=\"Transfer Syntax\">HEVC/H.265 Main Profile / Level 5.1</uid>
    <uid uid=\"1.2.840.10008.1.2.4.108\" keyword=\"HEVCH265Main10ProfileLevel51\" type=\"Transfer Syntax\">HEVC/H.265 Main 10 Profile / Level 5.1</uid>
    <uid uid=\"1.2.840.10008.1.2.5\" keyword=\"RLELossless\" type=\"Transfer Syntax\">RLE Lossless</uid>
    <uid uid=\"1.2.840.10008.1.2.6.1\" keyword=\"RFC2557MIMEEncapsulation\" type=\"Transfer Syntax\">RFC 2557 MIME encapsulation</uid>
    <uid uid=\"1.2.840.10008.1.2.6.2\" keyword=\"XMLEncoding\" type=\"Transfer Syntax\">XML Encoding</uid>
    <uid uid=\"1.2.840.10008.1.3.10\" keyword=\"MediaStorageDirectoryStorage\" type=\"SOP Class\">Media Storage Directory Storage</uid>
    <uid uid=\"1.2.840.10008.1.4.1.1\" keyword=\"TalairachBrainAtlasFrameOfReference\" type=\"Well-known frame of reference\">Talairach Brain Atlas Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.2\" keyword=\"SPM2T1FrameOfReference\" type=\"Well-known frame of reference\">SPM2 T1 Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.3\" keyword=\"SPM2T2FrameOfReference\" type=\"Well-known frame of reference\">SPM2 T2 Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.4\" keyword=\"SPM2PDFrameOfReference\" type=\"Well-known frame of reference\">SPM2 PD Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.5\" keyword=\"SPM2EPIFrameOfReference\" type=\"Well-known frame of reference\">SPM2 EPI Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.6\" keyword=\"SPM2FILT1FrameOfReference\" type=\"Well-known frame of reference\">SPM2 FIL T1 Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.7\" keyword=\"SPM2PETFrameOfReference\" type=\"Well-known frame of reference\">SPM2 PET Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.8\" keyword=\"SPM2TRANSMFrameOfReference\" type=\"Well-known frame of reference\">SPM2 TRANSM Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.9\" keyword=\"SPM2SPECTFrameOfReference\" type=\"Well-known frame of reference\">SPM2 SPECT Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.10\" keyword=\"SPM2GRAYFrameOfReference\" type=\"Well-known frame of reference\">SPM2 GRAY Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.11\" keyword=\"SPM2WHITEFrameOfReference\" type=\"Well-known frame of reference\">SPM2 WHITE Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.12\" keyword=\"SPM2CSFFrameOfReference\" type=\"Well-known frame of reference\">SPM2 CSF Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.13\" keyword=\"SPM2BRAINMASKFrameOfReference\" type=\"Well-known frame of reference\">SPM2 BRAINMASK Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.14\" keyword=\"SPM2AVG305T1FrameOfReference\" type=\"Well-known frame of reference\">SPM2 AVG305T1 Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.15\" keyword=\"SPM2AVG152T1FrameOfReference\" type=\"Well-known frame of reference\">SPM2 AVG152T1 Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.16\" keyword=\"SPM2AVG152T2FrameOfReference\" type=\"Well-known frame of reference\">SPM2 AVG152T2 Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.17\" keyword=\"SPM2AVG152PDFrameOfReference\" type=\"Well-known frame of reference\">SPM2 AVG152PD Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.1.18\" keyword=\"SPM2SINGLESUBJT1FrameOfReference\" type=\"Well-known frame of reference\">SPM2 SINGLESUBJT1 Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.2.1\" keyword=\"ICBM452T1FrameOfReference\" type=\"Well-known frame of reference\">ICBM 452 T1 Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.4.2.2\" keyword=\"ICBMSingleSubjectMRIFrameOfReference\" type=\"Well-known frame of reference\">ICBM Single Subject MRI Frame of Reference</uid>
    <uid uid=\"1.2.840.10008.1.5.1\" keyword=\"HotIronColorPaletteSOPInstance\" type=\"Well-known SOP Instance\">Hot Iron Color Palette SOP Instance</uid>
    <uid uid=\"1.2.840.10008.1.5.2\" keyword=\"PETColorPaletteSOPInstance\" type=\"Well-known SOP Instance\">PET Color Palette SOP Instance</uid>
    <uid uid=\"1.2.840.10008.1.5.3\" keyword=\"HotMetalBlueColorPaletteSOPInstance\" type=\"Well-known SOP Instance\">Hot Metal Blue Color Palette SOP Instance</uid>
    <uid uid=\"1.2.840.10008.1.5.4\" keyword=\"PET20StepColorPaletteSOPInstance\" type=\"Well-known SOP Instance\">PET 20 Step Color Palette SOP Instance</uid>
    <uid uid=\"1.2.840.10008.1.5.5\" keyword=\"SpringColorPaletteSOPInstance\" type=\"Well-known SOP Instance\">Spring Color Palette SOP Instance</uid>
    <uid uid=\"1.2.840.10008.1.5.6\" keyword=\"SummerColorPaletteSOPInstance\" type=\"Well-known SOP Instance\">Summer Color Palette SOP Instance</uid>
    <uid uid=\"1.2.840.10008.1.5.7\" keyword=\"FallColorPaletteSOPInstance\" type=\"Well-known SOP Instance\">Fall Color Palette SOP Instance</uid>
    <uid uid=\"1.2.840.10008.1.5.8\" keyword=\"WinterColorPaletteSOPInstance\" type=\"Well-known SOP Instance\">Winter Color Palette SOP Instance</uid>
    <uid uid=\"1.2.840.10008.1.9\" keyword=\"BasicStudyContentNotificationSOPClass\" type=\"SOP Class\" retired=\"true\">Basic Study Content Notification SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.20\" keyword=\"Papyrus3ImplicitVRLittleEndian\" type=\"Transfer Syntax\" retired=\"true\">Papyrus 3 Implicit VR Little Endian (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.20.1\" keyword=\"StorageCommitmentPushModelSOPClass\" type=\"SOP Class\">Storage Commitment Push Model SOP Class</uid>
    <uid uid=\"1.2.840.10008.1.20.1.1\" keyword=\"StorageCommitmentPushModelSOPInstance\" type=\"Well-known SOP Instance\">Storage Commitment Push Model SOP Instance</uid>
    <uid uid=\"1.2.840.10008.1.20.2\" keyword=\"StorageCommitmentPullModelSOPClass\" type=\"SOP Class\" retired=\"true\">Storage Commitment Pull Model SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.20.2.1\" keyword=\"StorageCommitmentPullModelSOPInstance\" type=\"Well-known SOP Instance\" retired=\"true\">Storage Commitment Pull Model SOP Instance (Retired)</uid>
    <uid uid=\"1.2.840.10008.1.40\" keyword=\"ProceduralEventLoggingSOPClass\" type=\"SOP Class\">Procedural Event Logging SOP Class</uid>
    <uid uid=\"1.2.840.10008.1.40.1\" keyword=\"ProceduralEventLoggingSOPInstance\" type=\"Well-known SOP Instance\">Procedural Event Logging SOP Instance</uid>
    <uid uid=\"1.2.840.10008.1.42\" keyword=\"SubstanceAdministrationLoggingSOPClass\" type=\"SOP Class\">Substance Administration Logging SOP Class</uid>
    <uid uid=\"1.2.840.10008.1.42.1\" keyword=\"SubstanceAdministrationLoggingSOPInstance\" type=\"Well-known SOP Instance\">Substance Administration Logging SOP Instance</uid>
    <uid uid=\"1.2.840.10008.2.6.1\" keyword=\"DICOMUIDRegistry\" type=\"DICOM UIDs as a Coding Scheme\">DICOM UID Registry</uid>
    <uid uid=\"1.2.840.10008.2.16.4\" keyword=\"DICOMControlledTerminology\" type=\"Coding Scheme\">DICOM Controlled Terminology</uid>
    <uid uid=\"1.2.840.10008.2.16.5\" keyword=\"AdultMouseAnatomyOntology\" type=\"Coding Scheme\">Adult Mouse Anatomy Ontology</uid>
    <uid uid=\"1.2.840.10008.2.16.6\" keyword=\"UberonOntology\" type=\"Coding Scheme\">Uberon Ontology</uid>
    <uid uid=\"1.2.840.10008.2.16.7\" keyword=\"IntegratedTaxonomicInformationSystemITISTaxonomicSerialNumberTSN\" type=\"Coding Scheme\">Integrated Taxonomic Information System (ITIS) Taxonomic Serial Number (TSN)</uid>
    <uid uid=\"1.2.840.10008.2.16.8\" keyword=\"MouseGenomeInitiativeMGI\" type=\"Coding Scheme\">Mouse Genome Initiative (MGI)</uid>
    <uid uid=\"1.2.840.10008.2.16.9\" keyword=\"PubChemCompoundCID\" type=\"Coding Scheme\">PubChem Compound CID</uid>
    <uid uid=\"1.2.840.10008.3.1.1.1\" keyword=\"DICOMApplicationContextName\" type=\"Application Context Name\">DICOM Application Context Name</uid>
    <uid uid=\"1.2.840.10008.3.1.2.1.1\" keyword=\"DetachedPatientManagementSOPClass\" type=\"SOP Class\" retired=\"true\">Detached Patient Management SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.3.1.2.1.4\" keyword=\"DetachedPatientManagementMetaSOPClass\" type=\"Meta SOP Class\" retired=\"true\">Detached Patient Management Meta SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.3.1.2.2.1\" keyword=\"DetachedVisitManagementSOPClass\" type=\"SOP Class\" retired=\"true\">Detached Visit Management SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.3.1.2.3.1\" keyword=\"DetachedStudyManagementSOPClass\" type=\"SOP Class\" retired=\"true\">Detached Study Management SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.3.1.2.3.2\" keyword=\"StudyComponentManagementSOPClass\" type=\"SOP Class\" retired=\"true\">Study Component Management SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.3.1.2.3.3\" keyword=\"ModalityPerformedProcedureStepSOPClass\" type=\"SOP Class\">Modality Performed Procedure Step SOP Class</uid>
    <uid uid=\"1.2.840.10008.3.1.2.3.4\" keyword=\"ModalityPerformedProcedureStepRetrieveSOPClass\" type=\"SOP Class\">Modality Performed Procedure Step Retrieve SOP Class</uid>
    <uid uid=\"1.2.840.10008.3.1.2.3.5\" keyword=\"ModalityPerformedProcedureStepNotificationSOPClass\" type=\"SOP Class\">Modality Performed Procedure Step Notification SOP Class</uid>
    <uid uid=\"1.2.840.10008.3.1.2.5.1\" keyword=\"DetachedResultsManagementSOPClass\" type=\"SOP Class\" retired=\"true\">Detached Results Management SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.3.1.2.5.4\" keyword=\"DetachedResultsManagementMetaSOPClass\" type=\"Meta SOP Class\" retired=\"true\">Detached Results Management Meta SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.3.1.2.5.5\" keyword=\"DetachedStudyManagementMetaSOPClass\" type=\"Meta SOP Class\" retired=\"true\">Detached Study Management Meta SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.3.1.2.6.1\" keyword=\"DetachedInterpretationManagementSOPClass\" type=\"SOP Class\" retired=\"true\">Detached Interpretation Management SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.4.2\" keyword=\"StorageServiceClass\" type=\"Service Class\">Storage Service Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.1\" keyword=\"BasicFilmSessionSOPClass\" type=\"SOP Class\">Basic Film Session SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.2\" keyword=\"BasicFilmBoxSOPClass\" type=\"SOP Class\">Basic Film Box SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.4\" keyword=\"BasicGrayscaleImageBoxSOPClass\" type=\"SOP Class\">Basic Grayscale Image Box SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.4.1\" keyword=\"BasicColorImageBoxSOPClass\" type=\"SOP Class\">Basic Color Image Box SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.4.2\" keyword=\"ReferencedImageBoxSOPClass\" type=\"SOP Class\" retired=\"true\">Referenced Image Box SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.1.9\" keyword=\"BasicGrayscalePrintManagementMetaSOPClass\" type=\"Meta SOP Class\">Basic Grayscale Print Management Meta SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.9.1\" keyword=\"ReferencedGrayscalePrintManagementMetaSOPClass\" type=\"Meta SOP Class\" retired=\"true\">Referenced Grayscale Print Management Meta SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.1.14\" keyword=\"PrintJobSOPClass\" type=\"SOP Class\">Print Job SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.15\" keyword=\"BasicAnnotationBoxSOPClass\" type=\"SOP Class\">Basic Annotation Box SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.16\" keyword=\"PrinterSOPClass\" type=\"SOP Class\">Printer SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.16.376\" keyword=\"PrinterConfigurationRetrievalSOPClass\" type=\"SOP Class\">Printer Configuration Retrieval SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.17\" keyword=\"PrinterSOPInstance\" type=\"Well-known Printer SOP Instance\">Printer SOP Instance</uid>
    <uid uid=\"1.2.840.10008.5.1.1.17.376\" keyword=\"PrinterConfigurationRetrievalSOPInstance\" type=\"Well-known Printer SOP Instance\">Printer Configuration Retrieval SOP Instance</uid>
    <uid uid=\"1.2.840.10008.5.1.1.18\" keyword=\"BasicColorPrintManagementMetaSOPClass\" type=\"Meta SOP Class\">Basic Color Print Management Meta SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.18.1\" keyword=\"ReferencedColorPrintManagementMetaSOPClass\" type=\"Meta SOP Class\" retired=\"true\">Referenced Color Print Management Meta SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.1.22\" keyword=\"VOILUTBoxSOPClass\" type=\"SOP Class\">VOI LUT Box SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.23\" keyword=\"PresentationLUTSOPClass\" type=\"SOP Class\">Presentation LUT SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.24\" keyword=\"ImageOverlayBoxSOPClass\" type=\"SOP Class\" retired=\"true\">Image Overlay Box SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.1.24.1\" keyword=\"BasicPrintImageOverlayBoxSOPClass\" type=\"SOP Class\" retired=\"true\">Basic Print Image Overlay Box SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.1.25\" keyword=\"PrintQueueSOPInstance\" type=\"Well-known Print Queue SOP Instance\" retired=\"true\">Print Queue SOP Instance (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.1.26\" keyword=\"PrintQueueManagementSOPClass\" type=\"SOP Class\" retired=\"true\">Print Queue Management SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.1.27\" keyword=\"StoredPrintStorageSOPClass\" type=\"SOP Class\" retired=\"true\">Stored Print Storage SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.1.29\" keyword=\"HardcopyGrayscaleImageStorageSOPClass\" type=\"SOP Class\" retired=\"true\">Hardcopy Grayscale Image Storage SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.1.30\" keyword=\"HardcopyColorImageStorageSOPClass\" type=\"SOP Class\" retired=\"true\">Hardcopy Color Image Storage SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.1.31\" keyword=\"PullPrintRequestSOPClass\" type=\"SOP Class\" retired=\"true\">Pull Print Request SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.1.32\" keyword=\"PullStoredPrintManagementMetaSOPClass\" type=\"Meta SOP Class\" retired=\"true\">Pull Stored Print Management Meta SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.1.33\" keyword=\"MediaCreationManagementSOPClassUID\" type=\"SOP Class\">Media Creation Management SOP Class UID</uid>
    <uid uid=\"1.2.840.10008.5.1.1.40\" keyword=\"DisplaySystemSOPClass\" type=\"SOP Class\">Display System SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.1.40.1\" keyword=\"DisplaySystemSOPInstance\" type=\"Well-known SOP Instance\">Display System SOP Instance</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.1\" keyword=\"ComputedRadiographyImageStorage\" type=\"SOP Class\">Computed Radiography Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.1.1\" keyword=\"DigitalXRayImageStorageForPresentation\" type=\"SOP Class\">Digital X-Ray Image Storage - For Presentation</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.1.1.1\" keyword=\"DigitalXRayImageStorageForProcessing\" type=\"SOP Class\">Digital X-Ray Image Storage - For Processing</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.1.2\" keyword=\"DigitalMammographyXRayImageStorageForPresentation\" type=\"SOP Class\">Digital Mammography X-Ray Image Storage - For Presentation</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.1.2.1\" keyword=\"DigitalMammographyXRayImageStorageForProcessing\" type=\"SOP Class\">Digital Mammography X-Ray Image Storage - For Processing</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.1.3\" keyword=\"DigitalIntraOralXRayImageStorageForPresentation\" type=\"SOP Class\">Digital Intra-Oral X-Ray Image Storage - For Presentation</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.1.3.1\" keyword=\"DigitalIntraOralXRayImageStorageForProcessing\" type=\"SOP Class\">Digital Intra-Oral X-Ray Image Storage - For Processing</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.2\" keyword=\"CTImageStorage\" type=\"SOP Class\">CT Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.2.1\" keyword=\"EnhancedCTImageStorage\" type=\"SOP Class\">Enhanced CT Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.2.2\" keyword=\"LegacyConvertedEnhancedCTImageStorage\" type=\"SOP Class\">Legacy Converted Enhanced CT Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.3\" keyword=\"UltrasoundMultiFrameImageStorage\" type=\"SOP Class\" retired=\"true\">Ultrasound Multi-frame Image Storage (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.3.1\" keyword=\"UltrasoundMultiFrameImageStorage\" type=\"SOP Class\">Ultrasound Multi-frame Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.4\" keyword=\"MRImageStorage\" type=\"SOP Class\">MR Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.4.1\" keyword=\"EnhancedMRImageStorage\" type=\"SOP Class\">Enhanced MR Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.4.2\" keyword=\"MRSpectroscopyStorage\" type=\"SOP Class\">MR Spectroscopy Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.4.3\" keyword=\"EnhancedMRColorImageStorage\" type=\"SOP Class\">Enhanced MR Color Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.4.4\" keyword=\"LegacyConvertedEnhancedMRImageStorage\" type=\"SOP Class\">Legacy Converted Enhanced MR Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.5\" keyword=\"NuclearMedicineImageStorage\" type=\"SOP Class\" retired=\"true\">Nuclear Medicine Image Storage (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.6\" keyword=\"UltrasoundImageStorage\" type=\"SOP Class\" retired=\"true\">Ultrasound Image Storage (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.6.1\" keyword=\"UltrasoundImageStorage\" type=\"SOP Class\">Ultrasound Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.6.2\" keyword=\"EnhancedUSVolumeStorage\" type=\"SOP Class\">Enhanced US Volume Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.7\" keyword=\"SecondaryCaptureImageStorage\" type=\"SOP Class\">Secondary Capture Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.7.1\" keyword=\"MultiFrameSingleBitSecondaryCaptureImageStorage\" type=\"SOP Class\">Multi-frame Single Bit Secondary Capture Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.7.2\" keyword=\"MultiFrameGrayscaleByteSecondaryCaptureImageStorage\" type=\"SOP Class\">Multi-frame Grayscale Byte Secondary Capture Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.7.3\" keyword=\"MultiFrameGrayscaleWordSecondaryCaptureImageStorage\" type=\"SOP Class\">Multi-frame Grayscale Word Secondary Capture Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.7.4\" keyword=\"MultiFrameTrueColorSecondaryCaptureImageStorage\" type=\"SOP Class\">Multi-frame True Color Secondary Capture Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.8\" keyword=\"StandaloneOverlayStorage\" type=\"SOP Class\" retired=\"true\">Standalone Overlay Storage (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.9\" keyword=\"StandaloneCurveStorage\" type=\"SOP Class\" retired=\"true\">Standalone Curve Storage (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.9.1\" keyword=\"WaveformStorageTrial\" type=\"SOP Class\" retired=\"true\">Waveform Storage - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.9.1.1\" keyword=\"TwelveLeadECGWaveformStorage\" type=\"SOP Class\">12-lead ECG Waveform Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.9.1.2\" keyword=\"GeneralECGWaveformStorage\" type=\"SOP Class\">General ECG Waveform Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.9.1.3\" keyword=\"AmbulatoryECGWaveformStorage\" type=\"SOP Class\">Ambulatory ECG Waveform Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.9.2.1\" keyword=\"HemodynamicWaveformStorage\" type=\"SOP Class\">Hemodynamic Waveform Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.9.3.1\" keyword=\"CardiacElectrophysiologyWaveformStorage\" type=\"SOP Class\">Cardiac Electrophysiology Waveform Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.9.4.1\" keyword=\"BasicVoiceAudioWaveformStorage\" type=\"SOP Class\">Basic Voice Audio Waveform Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.9.4.2\" keyword=\"GeneralAudioWaveformStorage\" type=\"SOP Class\">General Audio Waveform Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.9.5.1\" keyword=\"ArterialPulseWaveformStorage\" type=\"SOP Class\">Arterial Pulse Waveform Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.9.6.1\" keyword=\"RespiratoryWaveformStorage\" type=\"SOP Class\">Respiratory Waveform Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.10\" keyword=\"StandaloneModalityLUTStorage\" type=\"SOP Class\" retired=\"true\">Standalone Modality LUT Storage (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.11\" keyword=\"StandaloneVOILUTStorage\" type=\"SOP Class\" retired=\"true\">Standalone VOI LUT Storage (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.11.1\" keyword=\"GrayscaleSoftcopyPresentationStateStorage\" type=\"SOP Class\">Grayscale Softcopy Presentation State Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.11.2\" keyword=\"ColorSoftcopyPresentationStateStorage\" type=\"SOP Class\">Color Softcopy Presentation State Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.11.3\" keyword=\"PseudoColorSoftcopyPresentationStateStorage\" type=\"SOP Class\">Pseudo-Color Softcopy Presentation State Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.11.4\" keyword=\"BlendingSoftcopyPresentationStateStorage\" type=\"SOP Class\">Blending Softcopy Presentation State Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.11.5\" keyword=\"XAXRFGrayscaleSoftcopyPresentationStateStorage\" type=\"SOP Class\">XA/XRF Grayscale Softcopy Presentation State Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.11.6\" keyword=\"GrayscalePlanarMPRVolumetricPresentationStateStorage\" type=\"SOP Class\">Grayscale Planar MPR Volumetric Presentation State Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.11.7\" keyword=\"CompositingPlanarMPRVolumetricPresentationStateStorage\" type=\"SOP Class\">Compositing Planar MPR Volumetric Presentation State Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.11.8\" keyword=\"AdvancedBlendingPresentationStateStorage\" type=\"SOP Class\">Advanced Blending Presentation State Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.11.9\" keyword=\"VolumeRenderingVolumetricPresentationStateStorage\" type=\"SOP Class\">Volume Rendering Volumetric Presentation State Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.11.10\" keyword=\"SegmentedVolumeRenderingVolumetricPresentationStateStorage\" type=\"SOP Class\">Segmented Volume Rendering Volumetric Presentation State Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.11.11\" keyword=\"MultipleVolumeRenderingVolumetricPresentationStateStorage\" type=\"SOP Class\">Multiple Volume Rendering Volumetric Presentation State Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.12.1\" keyword=\"XRayAngiographicImageStorage\" type=\"SOP Class\">X-Ray Angiographic Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.12.1.1\" keyword=\"EnhancedXAImageStorage\" type=\"SOP Class\">Enhanced XA Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.12.2\" keyword=\"XRayRadiofluoroscopicImageStorage\" type=\"SOP Class\">X-Ray Radiofluoroscopic Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.12.2.1\" keyword=\"EnhancedXRFImageStorage\" type=\"SOP Class\">Enhanced XRF Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.12.3\" keyword=\"XRayAngiographicBiPlaneImageStorage\" type=\"SOP Class\" retired=\"true\">X-Ray Angiographic Bi-Plane Image Storage (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.12.77\" keyword=\"UID_1_2_840_10008_5_1_4_1_1_12_77\" type=\"SOP Class\" retired=\"true\">(Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.13.1.1\" keyword=\"XRay3DAngiographicImageStorage\" type=\"SOP Class\">X-Ray 3D Angiographic Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.13.1.2\" keyword=\"XRay3DCraniofacialImageStorage\" type=\"SOP Class\">X-Ray 3D Craniofacial Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.13.1.3\" keyword=\"BreastTomosynthesisImageStorage\" type=\"SOP Class\">Breast Tomosynthesis Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.13.1.4\" keyword=\"BreastProjectionXRayImageStorageForPresentation\" type=\"SOP Class\">Breast Projection X-Ray Image Storage - For Presentation</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.13.1.5\" keyword=\"BreastProjectionXRayImageStorageForProcessing\" type=\"SOP Class\">Breast Projection X-Ray Image Storage - For Processing</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.14.1\" keyword=\"IntravascularOpticalCoherenceTomographyImageStorageForPresentation\" type=\"SOP Class\">Intravascular Optical Coherence Tomography Image Storage - For Presentation</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.14.2\" keyword=\"IntravascularOpticalCoherenceTomographyImageStorageForProcessing\" type=\"SOP Class\">Intravascular Optical Coherence Tomography Image Storage - For Processing</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.20\" keyword=\"NuclearMedicineImageStorage\" type=\"SOP Class\">Nuclear Medicine Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.30\" keyword=\"ParametricMapStorage\" type=\"SOP Class\">Parametric Map Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.40\" keyword=\"UID_1_2_840_10008_5_1_4_1_1_40\" type=\"SOP Class\" retired=\"true\">(Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.66\" keyword=\"RawDataStorage\" type=\"SOP Class\">Raw Data Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.66.1\" keyword=\"SpatialRegistrationStorage\" type=\"SOP Class\">Spatial Registration Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.66.2\" keyword=\"SpatialFiducialsStorage\" type=\"SOP Class\">Spatial Fiducials Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.66.3\" keyword=\"DeformableSpatialRegistrationStorage\" type=\"SOP Class\">Deformable Spatial Registration Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.66.4\" keyword=\"SegmentationStorage\" type=\"SOP Class\">Segmentation Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.66.5\" keyword=\"SurfaceSegmentationStorage\" type=\"SOP Class\">Surface Segmentation Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.66.6\" keyword=\"TractographyResultsStorage\" type=\"SOP Class\">Tractography Results Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.67\" keyword=\"RealWorldValueMappingStorage\" type=\"SOP Class\">Real World Value Mapping Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.68.1\" keyword=\"SurfaceScanMeshStorage\" type=\"SOP Class\">Surface Scan Mesh Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.68.2\" keyword=\"SurfaceScanPointCloudStorage\" type=\"SOP Class\">Surface Scan Point Cloud Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1\" keyword=\"VLImageStorageTrial\" type=\"SOP Class\" retired=\"true\">VL Image Storage - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.2\" keyword=\"VLMultiFrameImageStorageTrial\" type=\"SOP Class\" retired=\"true\">VL Multi-frame Image Storage - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.1\" keyword=\"VLEndoscopicImageStorage\" type=\"SOP Class\">VL Endoscopic Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.1.1\" keyword=\"VideoEndoscopicImageStorage\" type=\"SOP Class\">Video Endoscopic Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.2\" keyword=\"VLMicroscopicImageStorage\" type=\"SOP Class\">VL Microscopic Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.2.1\" keyword=\"VideoMicroscopicImageStorage\" type=\"SOP Class\">Video Microscopic Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.3\" keyword=\"VLSlideCoordinatesMicroscopicImageStorage\" type=\"SOP Class\">VL Slide-Coordinates Microscopic Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.4\" keyword=\"VLPhotographicImageStorage\" type=\"SOP Class\">VL Photographic Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.4.1\" keyword=\"VideoPhotographicImageStorage\" type=\"SOP Class\">Video Photographic Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.5.1\" keyword=\"OphthalmicPhotography8BitImageStorage\" type=\"SOP Class\">Ophthalmic Photography 8 Bit Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.5.2\" keyword=\"OphthalmicPhotography16BitImageStorage\" type=\"SOP Class\">Ophthalmic Photography 16 Bit Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.5.3\" keyword=\"StereometricRelationshipStorage\" type=\"SOP Class\">Stereometric Relationship Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.5.4\" keyword=\"OphthalmicTomographyImageStorage\" type=\"SOP Class\">Ophthalmic Tomography Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.5.5\" keyword=\"WideFieldOphthalmicPhotographyStereographicProjectionImageStorage\" type=\"SOP Class\">Wide Field Ophthalmic Photography Stereographic Projection Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.5.6\" keyword=\"WideFieldOphthalmicPhotography3DCoordinatesImageStorage\" type=\"SOP Class\">Wide Field Ophthalmic Photography 3D Coordinates Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.5.7\" keyword=\"OphthalmicOpticalCoherenceTomographyEnFaceImageStorage\" type=\"SOP Class\">Ophthalmic Optical Coherence Tomography En Face Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.5.8\" keyword=\"OphthalmicOpticalCoherenceTomographyBScanVolumeAnalysisStorage\" type=\"SOP Class\">Ophthalmic Optical Coherence Tomography B-scan Volume Analysis Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.77.1.6\" keyword=\"VLWholeSlideMicroscopyImageStorage\" type=\"SOP Class\">VL Whole Slide Microscopy Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.78.1\" keyword=\"LensometryMeasurementsStorage\" type=\"SOP Class\">Lensometry Measurements Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.78.2\" keyword=\"AutorefractionMeasurementsStorage\" type=\"SOP Class\">Autorefraction Measurements Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.78.3\" keyword=\"KeratometryMeasurementsStorage\" type=\"SOP Class\">Keratometry Measurements Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.78.4\" keyword=\"SubjectiveRefractionMeasurementsStorage\" type=\"SOP Class\">Subjective Refraction Measurements Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.78.5\" keyword=\"VisualAcuityMeasurementsStorage\" type=\"SOP Class\">Visual Acuity Measurements Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.78.6\" keyword=\"SpectaclePrescriptionReportStorage\" type=\"SOP Class\">Spectacle Prescription Report Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.78.7\" keyword=\"OphthalmicAxialMeasurementsStorage\" type=\"SOP Class\">Ophthalmic Axial Measurements Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.78.8\" keyword=\"IntraocularLensCalculationsStorage\" type=\"SOP Class\">Intraocular Lens Calculations Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.79.1\" keyword=\"MacularGridThicknessAndVolumeReportStorage\" type=\"SOP Class\">Macular Grid Thickness and Volume Report Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.80.1\" keyword=\"OphthalmicVisualFieldStaticPerimetryMeasurementsStorage\" type=\"SOP Class\">Ophthalmic Visual Field Static Perimetry Measurements Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.81.1\" keyword=\"OphthalmicThicknessMapStorage\" type=\"SOP Class\">Ophthalmic Thickness Map Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.82.1\" keyword=\"CornealTopographyMapStorage\" type=\"SOP Class\">Corneal Topography Map Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.1\" keyword=\"TextSRStorageTrial\" type=\"SOP Class\" retired=\"true\">Text SR Storage - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.2\" keyword=\"AudioSRStorageTrial\" type=\"SOP Class\" retired=\"true\">Audio SR Storage - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.3\" keyword=\"DetailSRStorageTrial\" type=\"SOP Class\" retired=\"true\">Detail SR Storage - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.4\" keyword=\"ComprehensiveSRStorageTrial\" type=\"SOP Class\" retired=\"true\">Comprehensive SR Storage - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.11\" keyword=\"BasicTextSRStorage\" type=\"SOP Class\">Basic Text SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.22\" keyword=\"EnhancedSRStorage\" type=\"SOP Class\">Enhanced SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.33\" keyword=\"ComprehensiveSRStorage\" type=\"SOP Class\">Comprehensive SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.34\" keyword=\"Comprehensive3DSRStorage\" type=\"SOP Class\">Comprehensive 3D SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.35\" keyword=\"ExtensibleSRStorage\" type=\"SOP Class\">Extensible SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.40\" keyword=\"ProcedureLogStorage\" type=\"SOP Class\">Procedure Log Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.50\" keyword=\"MammographyCADSRStorage\" type=\"SOP Class\">Mammography CAD SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.59\" keyword=\"KeyObjectSelectionDocumentStorage\" type=\"SOP Class\">Key Object Selection Document Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.65\" keyword=\"ChestCADSRStorage\" type=\"SOP Class\">Chest CAD SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.67\" keyword=\"XRayRadiationDoseSRStorage\" type=\"SOP Class\">X-Ray Radiation Dose SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.68\" keyword=\"RadiopharmaceuticalRadiationDoseSRStorage\" type=\"SOP Class\">Radiopharmaceutical Radiation Dose SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.69\" keyword=\"ColonCADSRStorage\" type=\"SOP Class\">Colon CAD SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.70\" keyword=\"ImplantationPlanSRStorage\" type=\"SOP Class\">Implantation Plan SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.71\" keyword=\"AcquisitionContextSRStorage\" type=\"SOP Class\">Acquisition Context SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.72\" keyword=\"SimplifiedAdultEchoSRStorage\" type=\"SOP Class\">Simplified Adult Echo SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.88.73\" keyword=\"PatientRadiationDoseSRStorage\" type=\"SOP Class\">Patient Radiation Dose SR Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.90.1\" keyword=\"ContentAssessmentResultsStorage\" type=\"SOP Class\">Content Assessment Results Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.104.1\" keyword=\"EncapsulatedPDFStorage\" type=\"SOP Class\">Encapsulated PDF Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.104.2\" keyword=\"EncapsulatedCDAStorage\" type=\"SOP Class\">Encapsulated CDA Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.128\" keyword=\"PositronEmissionTomographyImageStorage\" type=\"SOP Class\">Positron Emission Tomography Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.128.1\" keyword=\"LegacyConvertedEnhancedPETImageStorage\" type=\"SOP Class\">Legacy Converted Enhanced PET Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.129\" keyword=\"StandalonePETCurveStorage\" type=\"SOP Class\" retired=\"true\">Standalone PET Curve Storage (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.130\" keyword=\"EnhancedPETImageStorage\" type=\"SOP Class\">Enhanced PET Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.131\" keyword=\"BasicStructuredDisplayStorage\" type=\"SOP Class\">Basic Structured Display Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.200.1\" keyword=\"CTDefinedProcedureProtocolStorage\" type=\"SOP Class\">CT Defined Procedure Protocol Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.200.2\" keyword=\"CTPerformedProcedureProtocolStorage\" type=\"SOP Class\">CT Performed Procedure Protocol Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.200.3\" keyword=\"ProtocolApprovalStorage\" type=\"SOP Class\">Protocol Approval Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.200.4\" keyword=\"ProtocolApprovalInformationModelFIND\" type=\"SOP Class\">Protocol Approval Information Model - FIND</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.200.5\" keyword=\"ProtocolApprovalInformationModelMOVE\" type=\"SOP Class\">Protocol Approval Information Model - MOVE</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.200.6\" keyword=\"ProtocolApprovalInformationModelGET\" type=\"SOP Class\">Protocol Approval Information Model - GET</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.481.1\" keyword=\"RTImageStorage\" type=\"SOP Class\">RT Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.481.2\" keyword=\"RTDoseStorage\" type=\"SOP Class\">RT Dose Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.481.3\" keyword=\"RTStructureSetStorage\" type=\"SOP Class\">RT Structure Set Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.481.4\" keyword=\"RTBeamsTreatmentRecordStorage\" type=\"SOP Class\">RT Beams Treatment Record Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.481.5\" keyword=\"RTPlanStorage\" type=\"SOP Class\">RT Plan Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.481.6\" keyword=\"RTBrachyTreatmentRecordStorage\" type=\"SOP Class\">RT Brachy Treatment Record Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.481.7\" keyword=\"RTTreatmentSummaryRecordStorage\" type=\"SOP Class\">RT Treatment Summary Record Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.481.8\" keyword=\"RTIonPlanStorage\" type=\"SOP Class\">RT Ion Plan Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.481.9\" keyword=\"RTIonBeamsTreatmentRecordStorage\" type=\"SOP Class\">RT Ion Beams Treatment Record Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.501.1\" keyword=\"DICOSCTImageStorage\" type=\"SOP Class\">DICOS CT Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.501.2.1\" keyword=\"DICOSDigitalXRayImageStorageForPresentation\" type=\"SOP Class\">DICOS Digital X-Ray Image Storage - For Presentation</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.501.2.2\" keyword=\"DICOSDigitalXRayImageStorageForProcessing\" type=\"SOP Class\">DICOS Digital X-Ray Image Storage - For Processing</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.501.3\" keyword=\"DICOSThreatDetectionReportStorage\" type=\"SOP Class\">DICOS Threat Detection Report Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.501.4\" keyword=\"DICOS2DAITStorage\" type=\"SOP Class\">DICOS 2D AIT Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.501.5\" keyword=\"DICOS3DAITStorage\" type=\"SOP Class\">DICOS 3D AIT Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.501.6\" keyword=\"DICOSQuadrupoleResonanceQRStorage\" type=\"SOP Class\">DICOS Quadrupole Resonance (QR) Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.601.1\" keyword=\"EddyCurrentImageStorage\" type=\"SOP Class\">Eddy Current Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.1.601.2\" keyword=\"EddyCurrentMultiFrameImageStorage\" type=\"SOP Class\">Eddy Current Multi-frame Image Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.2.1.1\" keyword=\"PatientRootQueryRetrieveInformationModelFIND\" type=\"SOP Class\">Patient Root Query/Retrieve Information Model - FIND</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.2.1.2\" keyword=\"PatientRootQueryRetrieveInformationModelMOVE\" type=\"SOP Class\">Patient Root Query/Retrieve Information Model - MOVE</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.2.1.3\" keyword=\"PatientRootQueryRetrieveInformationModelGET\" type=\"SOP Class\">Patient Root Query/Retrieve Information Model - GET</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.2.2.1\" keyword=\"StudyRootQueryRetrieveInformationModelFIND\" type=\"SOP Class\">Study Root Query/Retrieve Information Model - FIND</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.2.2.2\" keyword=\"StudyRootQueryRetrieveInformationModelMOVE\" type=\"SOP Class\">Study Root Query/Retrieve Information Model - MOVE</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.2.2.3\" keyword=\"StudyRootQueryRetrieveInformationModelGET\" type=\"SOP Class\">Study Root Query/Retrieve Information Model - GET</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.2.3.1\" keyword=\"PatientStudyOnlyQueryRetrieveInformationModelFIND\" type=\"SOP Class\" retired=\"true\">Patient/Study Only Query/Retrieve Information Model - FIND (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.2.3.2\" keyword=\"PatientStudyOnlyQueryRetrieveInformationModelMOVE\" type=\"SOP Class\" retired=\"true\">Patient/Study Only Query/Retrieve Information Model - MOVE (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.2.3.3\" keyword=\"PatientStudyOnlyQueryRetrieveInformationModelGET\" type=\"SOP Class\" retired=\"true\">Patient/Study Only Query/Retrieve Information Model - GET (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.2.4.2\" keyword=\"CompositeInstanceRootRetrieveMOVE\" type=\"SOP Class\">Composite Instance Root Retrieve - MOVE</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.2.4.3\" keyword=\"CompositeInstanceRootRetrieveGET\" type=\"SOP Class\">Composite Instance Root Retrieve - GET</uid>
    <uid uid=\"1.2.840.10008.5.1.4.1.2.5.3\" keyword=\"CompositeInstanceRetrieveWithoutBulkDataGET\" type=\"SOP Class\">Composite Instance Retrieve Without Bulk Data - GET</uid>
    <uid uid=\"1.2.840.10008.5.1.4.20.1\" keyword=\"DefinedProcedureProtocolInformationModelFIND\" type=\"SOP Class\">Defined Procedure Protocol Information Model - FIND</uid>
    <uid uid=\"1.2.840.10008.5.1.4.20.2\" keyword=\"DefinedProcedureProtocolInformationModelMOVE\" type=\"SOP Class\">Defined Procedure Protocol Information Model - MOVE</uid>
    <uid uid=\"1.2.840.10008.5.1.4.20.3\" keyword=\"DefinedProcedureProtocolInformationModelGET\" type=\"SOP Class\">Defined Procedure Protocol Information Model - GET</uid>
    <uid uid=\"1.2.840.10008.5.1.4.31\" keyword=\"ModalityWorklistInformationModelFIND\" type=\"SOP Class\">Modality Worklist Information Model - FIND</uid>
    <uid uid=\"1.2.840.10008.5.1.4.32\" keyword=\"GeneralPurposeWorklistManagementMetaSOPClass\" type=\"Meta SOP Class\" retired=\"true\">General Purpose Worklist Management Meta SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.32.1\" keyword=\"GeneralPurposeWorklistInformationModelFIND\" type=\"SOP Class\" retired=\"true\">General Purpose Worklist Information Model - FIND (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.32.2\" keyword=\"GeneralPurposeScheduledProcedureStepSOPClass\" type=\"SOP Class\" retired=\"true\">General Purpose Scheduled Procedure Step SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.32.3\" keyword=\"GeneralPurposePerformedProcedureStepSOPClass\" type=\"SOP Class\" retired=\"true\">General Purpose Performed Procedure Step SOP Class (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.33\" keyword=\"InstanceAvailabilityNotificationSOPClass\" type=\"SOP Class\">Instance Availability Notification SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.1\" keyword=\"RTBeamsDeliveryInstructionStorageTrial\" type=\"SOP Class\" retired=\"true\">RT Beams Delivery Instruction Storage - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.2\" keyword=\"RTConventionalMachineVerificationTrial\" type=\"SOP Class\" retired=\"true\">RT Conventional Machine Verification - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.3\" keyword=\"RTIonMachineVerificationTrial\" type=\"SOP Class\" retired=\"true\">RT Ion Machine Verification - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.4\" keyword=\"UnifiedWorklistAndProcedureStepServiceClassTrial\" type=\"Service Class\" retired=\"true\">Unified Worklist and Procedure Step Service Class - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.4.1\" keyword=\"UnifiedProcedureStepPushSOPClassTrial\" type=\"SOP Class\" retired=\"true\">Unified Procedure Step - Push SOP Class - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.4.2\" keyword=\"UnifiedProcedureStepWatchSOPClassTrial\" type=\"SOP Class\" retired=\"true\">Unified Procedure Step - Watch SOP Class - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.4.3\" keyword=\"UnifiedProcedureStepPullSOPClassTrial\" type=\"SOP Class\" retired=\"true\">Unified Procedure Step - Pull SOP Class - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.4.4\" keyword=\"UnifiedProcedureStepEventSOPClassTrial\" type=\"SOP Class\" retired=\"true\">Unified Procedure Step - Event SOP Class - Trial (Retired)</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.5\" keyword=\"UPSGlobalSubscriptionSOPInstance\" type=\"Well-known SOP Instance\">UPS Global Subscription SOP Instance</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.5.1\" keyword=\"UPSFilteredGlobalSubscriptionSOPInstance\" type=\"Well-known SOP Instance\">UPS Filtered Global Subscription SOP Instance</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.6\" keyword=\"UnifiedWorklistAndProcedureStepServiceClass\" type=\"Service Class\">Unified Worklist and Procedure Step Service Class</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.6.1\" keyword=\"UnifiedProcedureStepPushSOPClass\" type=\"SOP Class\">Unified Procedure Step - Push SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.6.2\" keyword=\"UnifiedProcedureStepWatchSOPClass\" type=\"SOP Class\">Unified Procedure Step - Watch SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.6.3\" keyword=\"UnifiedProcedureStepPullSOPClass\" type=\"SOP Class\">Unified Procedure Step - Pull SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.6.4\" keyword=\"UnifiedProcedureStepEventSOPClass\" type=\"SOP Class\">Unified Procedure Step - Event SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.7\" keyword=\"RTBeamsDeliveryInstructionStorage\" type=\"SOP Class\">RT Beams Delivery Instruction Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.8\" keyword=\"RTConventionalMachineVerification\" type=\"SOP Class\">RT Conventional Machine Verification</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.9\" keyword=\"RTIonMachineVerification\" type=\"SOP Class\">RT Ion Machine Verification</uid>
    <uid uid=\"1.2.840.10008.5.1.4.34.10\" keyword=\"RTBrachyApplicationSetupDeliveryInstructionStorage\" type=\"SOP Class\">RT Brachy Application Setup Delivery Instruction Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.37.1\" keyword=\"GeneralRelevantPatientInformationQuery\" type=\"SOP Class\">General Relevant Patient Information Query</uid>
    <uid uid=\"1.2.840.10008.5.1.4.37.2\" keyword=\"BreastImagingRelevantPatientInformationQuery\" type=\"SOP Class\">Breast Imaging Relevant Patient Information Query</uid>
    <uid uid=\"1.2.840.10008.5.1.4.37.3\" keyword=\"CardiacRelevantPatientInformationQuery\" type=\"SOP Class\">Cardiac Relevant Patient Information Query</uid>
    <uid uid=\"1.2.840.10008.5.1.4.38.1\" keyword=\"HangingProtocolStorage\" type=\"SOP Class\">Hanging Protocol Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.38.2\" keyword=\"HangingProtocolInformationModelFIND\" type=\"SOP Class\">Hanging Protocol Information Model - FIND</uid>
    <uid uid=\"1.2.840.10008.5.1.4.38.3\" keyword=\"HangingProtocolInformationModelMOVE\" type=\"SOP Class\">Hanging Protocol Information Model - MOVE</uid>
    <uid uid=\"1.2.840.10008.5.1.4.38.4\" keyword=\"HangingProtocolInformationModelGET\" type=\"SOP Class\">Hanging Protocol Information Model - GET</uid>
    <uid uid=\"1.2.840.10008.5.1.4.39.1\" keyword=\"ColorPaletteStorage\" type=\"SOP Class\">Color Palette Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.39.2\" keyword=\"ColorPaletteQueryRetrieveInformationModelFIND\" type=\"SOP Class\">Color Palette Query/Retrieve Information Model - FIND</uid>
    <uid uid=\"1.2.840.10008.5.1.4.39.3\" keyword=\"ColorPaletteQueryRetrieveInformationModelMOVE\" type=\"SOP Class\">Color Palette Query/Retrieve Information Model - MOVE</uid>
    <uid uid=\"1.2.840.10008.5.1.4.39.4\" keyword=\"ColorPaletteQueryRetrieveInformationModelGET\" type=\"SOP Class\">Color Palette Query/Retrieve Information Model - GET</uid>
    <uid uid=\"1.2.840.10008.5.1.4.41\" keyword=\"ProductCharacteristicsQuerySOPClass\" type=\"SOP Class\">Product Characteristics Query SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.4.42\" keyword=\"SubstanceApprovalQuerySOPClass\" type=\"SOP Class\">Substance Approval Query SOP Class</uid>
    <uid uid=\"1.2.840.10008.5.1.4.43.1\" keyword=\"GenericImplantTemplateStorage\" type=\"SOP Class\">Generic Implant Template Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.43.2\" keyword=\"GenericImplantTemplateInformationModelFIND\" type=\"SOP Class\">Generic Implant Template Information Model - FIND</uid>
    <uid uid=\"1.2.840.10008.5.1.4.43.3\" keyword=\"GenericImplantTemplateInformationModelMOVE\" type=\"SOP Class\">Generic Implant Template Information Model - MOVE</uid>
    <uid uid=\"1.2.840.10008.5.1.4.43.4\" keyword=\"GenericImplantTemplateInformationModelGET\" type=\"SOP Class\">Generic Implant Template Information Model - GET</uid>
    <uid uid=\"1.2.840.10008.5.1.4.44.1\" keyword=\"ImplantAssemblyTemplateStorage\" type=\"SOP Class\">Implant Assembly Template Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.44.2\" keyword=\"ImplantAssemblyTemplateInformationModelFIND\" type=\"SOP Class\">Implant Assembly Template Information Model - FIND</uid>
    <uid uid=\"1.2.840.10008.5.1.4.44.3\" keyword=\"ImplantAssemblyTemplateInformationModelMOVE\" type=\"SOP Class\">Implant Assembly Template Information Model - MOVE</uid>
    <uid uid=\"1.2.840.10008.5.1.4.44.4\" keyword=\"ImplantAssemblyTemplateInformationModelGET\" type=\"SOP Class\">Implant Assembly Template Information Model - GET</uid>
    <uid uid=\"1.2.840.10008.5.1.4.45.1\" keyword=\"ImplantTemplateGroupStorage\" type=\"SOP Class\">Implant Template Group Storage</uid>
    <uid uid=\"1.2.840.10008.5.1.4.45.2\" keyword=\"ImplantTemplateGroupInformationModelFIND\" type=\"SOP Class\">Implant Template Group Information Model - FIND</uid>
    <uid uid=\"1.2.840.10008.5.1.4.45.3\" keyword=\"ImplantTemplateGroupInformationModelMOVE\" type=\"SOP Class\">Implant Template Group Information Model - MOVE</uid>
    <uid uid=\"1.2.840.10008.5.1.4.45.4\" keyword=\"ImplantTemplateGroupInformationModelGET\" type=\"SOP Class\">Implant Template Group Information Model - GET</uid>
    <uid uid=\"1.2.840.10008.7.1.1\" keyword=\"NativeDICOMModel\" type=\"Application Hosting Model\">Native DICOM Model</uid>
    <uid uid=\"1.2.840.10008.7.1.2\" keyword=\"AbstractMultiDimensionalImageModel\" type=\"Application Hosting Model\">Abstract Multi-Dimensional Image Model</uid>
    <uid uid=\"1.2.840.10008.8.1.1\" keyword=\"DICOMContentMappingResource\" type=\"Mapping Resource\">DICOM Content Mapping Resource</uid>
    <uid uid=\"1.2.840.10008.15.0.3.1\" keyword=\"dicomDeviceName\" type=\"LDAP OID\">dicomDeviceName</uid>
    <uid uid=\"1.2.840.10008.15.0.3.2\" keyword=\"dicomDescription\" type=\"LDAP OID\">dicomDescription</uid>
    <uid uid=\"1.2.840.10008.15.0.3.3\" keyword=\"dicomManufacturer\" type=\"LDAP OID\">dicomManufacturer</uid>
    <uid uid=\"1.2.840.10008.15.0.3.4\" keyword=\"dicomManufacturerModelName\" type=\"LDAP OID\">dicomManufacturerModelName</uid>
    <uid uid=\"1.2.840.10008.15.0.3.5\" keyword=\"dicomSoftwareVersion\" type=\"LDAP OID\">dicomSoftwareVersion</uid>
    <uid uid=\"1.2.840.10008.15.0.3.6\" keyword=\"dicomVendorData\" type=\"LDAP OID\">dicomVendorData</uid>
    <uid uid=\"1.2.840.10008.15.0.3.7\" keyword=\"dicomAETitle\" type=\"LDAP OID\">dicomAETitle</uid>
    <uid uid=\"1.2.840.10008.15.0.3.8\" keyword=\"dicomNetworkConnectionReference\" type=\"LDAP OID\">dicomNetworkConnectionReference</uid>
    <uid uid=\"1.2.840.10008.15.0.3.9\" keyword=\"dicomApplicationCluster\" type=\"LDAP OID\">dicomApplicationCluster</uid>
    <uid uid=\"1.2.840.10008.15.0.3.10\" keyword=\"dicomAssociationInitiator\" type=\"LDAP OID\">dicomAssociationInitiator</uid>
    <uid uid=\"1.2.840.10008.15.0.3.11\" keyword=\"dicomAssociationAcceptor\" type=\"LDAP OID\">dicomAssociationAcceptor</uid>
    <uid uid=\"1.2.840.10008.15.0.3.12\" keyword=\"dicomHostname\" type=\"LDAP OID\">dicomHostname</uid>
    <uid uid=\"1.2.840.10008.15.0.3.13\" keyword=\"dicomPort\" type=\"LDAP OID\">dicomPort</uid>
    <uid uid=\"1.2.840.10008.15.0.3.14\" keyword=\"dicomSOPClass\" type=\"LDAP OID\">dicomSOPClass</uid>
    <uid uid=\"1.2.840.10008.15.0.3.15\" keyword=\"dicomTransferRole\" type=\"LDAP OID\">dicomTransferRole</uid>
    <uid uid=\"1.2.840.10008.15.0.3.16\" keyword=\"dicomTransferSyntax\" type=\"LDAP OID\">dicomTransferSyntax</uid>
    <uid uid=\"1.2.840.10008.15.0.3.17\" keyword=\"dicomPrimaryDeviceType\" type=\"LDAP OID\">dicomPrimaryDeviceType</uid>
    <uid uid=\"1.2.840.10008.15.0.3.18\" keyword=\"dicomRelatedDeviceReference\" type=\"LDAP OID\">dicomRelatedDeviceReference</uid>
    <uid uid=\"1.2.840.10008.15.0.3.19\" keyword=\"dicomPreferredCalledAETitle\" type=\"LDAP OID\">dicomPreferredCalledAETitle</uid>
    <uid uid=\"1.2.840.10008.15.0.3.20\" keyword=\"dicomTLSCyphersuite\" type=\"LDAP OID\">dicomTLSCyphersuite</uid>
    <uid uid=\"1.2.840.10008.15.0.3.21\" keyword=\"dicomAuthorizedNodeCertificateReference\" type=\"LDAP OID\">dicomAuthorizedNodeCertificateReference</uid>
    <uid uid=\"1.2.840.10008.15.0.3.22\" keyword=\"dicomThisNodeCertificateReference\" type=\"LDAP OID\">dicomThisNodeCertificateReference</uid>
    <uid uid=\"1.2.840.10008.15.0.3.23\" keyword=\"dicomInstalled\" type=\"LDAP OID\">dicomInstalled</uid>
    <uid uid=\"1.2.840.10008.15.0.3.24\" keyword=\"dicomStationName\" type=\"LDAP OID\">dicomStationName</uid>
    <uid uid=\"1.2.840.10008.15.0.3.25\" keyword=\"dicomDeviceSerialNumber\" type=\"LDAP OID\">dicomDeviceSerialNumber</uid>
    <uid uid=\"1.2.840.10008.15.0.3.26\" keyword=\"dicomInstitutionName\" type=\"LDAP OID\">dicomInstitutionName</uid>
    <uid uid=\"1.2.840.10008.15.0.3.27\" keyword=\"dicomInstitutionAddress\" type=\"LDAP OID\">dicomInstitutionAddress</uid>
    <uid uid=\"1.2.840.10008.15.0.3.28\" keyword=\"dicomInstitutionDepartmentName\" type=\"LDAP OID\">dicomInstitutionDepartmentName</uid>
    <uid uid=\"1.2.840.10008.15.0.3.29\" keyword=\"dicomIssuerOfPatientID\" type=\"LDAP OID\">dicomIssuerOfPatientID</uid>
    <uid uid=\"1.2.840.10008.15.0.3.30\" keyword=\"dicomPreferredCallingAETitle\" type=\"LDAP OID\">dicomPreferredCallingAETitle</uid>
    <uid uid=\"1.2.840.10008.15.0.3.31\" keyword=\"dicomSupportedCharacterSet\" type=\"LDAP OID\">dicomSupportedCharacterSet</uid>
    <uid uid=\"1.2.840.10008.15.0.4.1\" keyword=\"dicomConfigurationRoot\" type=\"LDAP OID\">dicomConfigurationRoot</uid>
    <uid uid=\"1.2.840.10008.15.0.4.2\" keyword=\"dicomDevicesRoot\" type=\"LDAP OID\">dicomDevicesRoot</uid>
    <uid uid=\"1.2.840.10008.15.0.4.3\" keyword=\"dicomUniqueAETitlesRegistryRoot\" type=\"LDAP OID\">dicomUniqueAETitlesRegistryRoot</uid>
    <uid uid=\"1.2.840.10008.15.0.4.4\" keyword=\"dicomDevice\" type=\"LDAP OID\">dicomDevice</uid>
    <uid uid=\"1.2.840.10008.15.0.4.5\" keyword=\"dicomNetworkAE\" type=\"LDAP OID\">dicomNetworkAE</uid>
    <uid uid=\"1.2.840.10008.15.0.4.6\" keyword=\"dicomNetworkConnection\" type=\"LDAP OID\">dicomNetworkConnection</uid>
    <uid uid=\"1.2.840.10008.15.0.4.7\" keyword=\"dicomUniqueAETitle\" type=\"LDAP OID\">dicomUniqueAETitle</uid>
    <uid uid=\"1.2.840.10008.15.0.4.8\" keyword=\"dicomTransferCapability\" type=\"LDAP OID\">dicomTransferCapability</uid>
    <uid uid=\"1.2.840.10008.15.1.1\" keyword=\"UniversalCoordinatedTime\" type=\"Synchronization Frame of Reference\">Universal Coordinated Time</uid>
    <uid uid=\"1.2.840.10008.6.1.1\" keyword=\"AnatomicModifier2\" type=\"Context Group Name\">Anatomic Modifier (2)</uid>
    <uid uid=\"1.2.840.10008.6.1.2\" keyword=\"AnatomicRegion4\" type=\"Context Group Name\">Anatomic Region (4)</uid>
    <uid uid=\"1.2.840.10008.6.1.3\" keyword=\"TransducerApproach5\" type=\"Context Group Name\">Transducer Approach (5)</uid>
    <uid uid=\"1.2.840.10008.6.1.4\" keyword=\"TransducerOrientation6\" type=\"Context Group Name\">Transducer Orientation (6)</uid>
    <uid uid=\"1.2.840.10008.6.1.5\" keyword=\"UltrasoundBeamPath7\" type=\"Context Group Name\">Ultrasound Beam Path (7)</uid>
    <uid uid=\"1.2.840.10008.6.1.6\" keyword=\"AngiographicInterventionalDevices8\" type=\"Context Group Name\">Angiographic Interventional Devices (8)</uid>
    <uid uid=\"1.2.840.10008.6.1.7\" keyword=\"ImageGuidedTherapeuticProcedures9\" type=\"Context Group Name\">Image Guided Therapeutic Procedures (9)</uid>
    <uid uid=\"1.2.840.10008.6.1.8\" keyword=\"InterventionalDrug10\" type=\"Context Group Name\">Interventional Drug (10)</uid>
    <uid uid=\"1.2.840.10008.6.1.9\" keyword=\"RouteOfAdministration11\" type=\"Context Group Name\">Route of Administration (11)</uid>
    <uid uid=\"1.2.840.10008.6.1.10\" keyword=\"RadiographicContrastAgent12\" type=\"Context Group Name\">Radiographic Contrast Agent (12)</uid>
    <uid uid=\"1.2.840.10008.6.1.11\" keyword=\"RadiographicContrastAgentIngredient13\" type=\"Context Group Name\">Radiographic Contrast Agent Ingredient (13)</uid>
    <uid uid=\"1.2.840.10008.6.1.12\" keyword=\"IsotopesInRadiopharmaceuticals18\" type=\"Context Group Name\">Isotopes in Radiopharmaceuticals (18)</uid>
    <uid uid=\"1.2.840.10008.6.1.13\" keyword=\"PatientOrientation19\" type=\"Context Group Name\">Patient Orientation (19)</uid>
    <uid uid=\"1.2.840.10008.6.1.14\" keyword=\"PatientOrientationModifier20\" type=\"Context Group Name\">Patient Orientation Modifier (20)</uid>
    <uid uid=\"1.2.840.10008.6.1.15\" keyword=\"PatientEquipmentRelationship21\" type=\"Context Group Name\">Patient Equipment Relationship (21)</uid>
    <uid uid=\"1.2.840.10008.6.1.16\" keyword=\"CranioCaudadAngulation23\" type=\"Context Group Name\">Cranio-Caudad Angulation (23)</uid>
    <uid uid=\"1.2.840.10008.6.1.17\" keyword=\"Radiopharmaceuticals25\" type=\"Context Group Name\">Radiopharmaceuticals (25)</uid>
    <uid uid=\"1.2.840.10008.6.1.18\" keyword=\"NuclearMedicineProjections26\" type=\"Context Group Name\">Nuclear Medicine Projections (26)</uid>
    <uid uid=\"1.2.840.10008.6.1.19\" keyword=\"AcquisitionModality29\" type=\"Context Group Name\">Acquisition Modality (29)</uid>
    <uid uid=\"1.2.840.10008.6.1.20\" keyword=\"DICOMDevices30\" type=\"Context Group Name\">DICOM Devices (30)</uid>
    <uid uid=\"1.2.840.10008.6.1.21\" keyword=\"AbstractPriors31\" type=\"Context Group Name\">Abstract Priors (31)</uid>
    <uid uid=\"1.2.840.10008.6.1.22\" keyword=\"NumericValueQualifier42\" type=\"Context Group Name\">Numeric Value Qualifier (42)</uid>
    <uid uid=\"1.2.840.10008.6.1.23\" keyword=\"UnitsOfMeasurement82\" type=\"Context Group Name\">Units of Measurement (82)</uid>
    <uid uid=\"1.2.840.10008.6.1.24\" keyword=\"UnitsForRealWorldValueMapping83\" type=\"Context Group Name\">Units for Real World Value Mapping (83)</uid>
    <uid uid=\"1.2.840.10008.6.1.25\" keyword=\"LevelOfSignificance220\" type=\"Context Group Name\">Level of Significance (220)</uid>
    <uid uid=\"1.2.840.10008.6.1.26\" keyword=\"MeasurementRangeConcepts221\" type=\"Context Group Name\">Measurement Range Concepts (221)</uid>
    <uid uid=\"1.2.840.10008.6.1.27\" keyword=\"NormalityCodes222\" type=\"Context Group Name\">Normality Codes (222)</uid>
    <uid uid=\"1.2.840.10008.6.1.28\" keyword=\"NormalRangeValues223\" type=\"Context Group Name\">Normal Range Values (223)</uid>
    <uid uid=\"1.2.840.10008.6.1.29\" keyword=\"SelectionMethod224\" type=\"Context Group Name\">Selection Method (224)</uid>
    <uid uid=\"1.2.840.10008.6.1.30\" keyword=\"MeasurementUncertaintyConcepts225\" type=\"Context Group Name\">Measurement Uncertainty Concepts (225)</uid>
    <uid uid=\"1.2.840.10008.6.1.31\" keyword=\"PopulationStatisticalDescriptors226\" type=\"Context Group Name\">Population Statistical Descriptors (226)</uid>
    <uid uid=\"1.2.840.10008.6.1.32\" keyword=\"SampleStatisticalDescriptors227\" type=\"Context Group Name\">Sample Statistical Descriptors (227)</uid>
    <uid uid=\"1.2.840.10008.6.1.33\" keyword=\"EquationOrTable228\" type=\"Context Group Name\">Equation or Table (228)</uid>
    <uid uid=\"1.2.840.10008.6.1.34\" keyword=\"YesNo230\" type=\"Context Group Name\">Yes-No (230)</uid>
    <uid uid=\"1.2.840.10008.6.1.35\" keyword=\"PresentAbsent240\" type=\"Context Group Name\">Present-Absent (240)</uid>
    <uid uid=\"1.2.840.10008.6.1.36\" keyword=\"NormalAbnormal242\" type=\"Context Group Name\">Normal-Abnormal (242)</uid>
    <uid uid=\"1.2.840.10008.6.1.37\" keyword=\"Laterality244\" type=\"Context Group Name\">Laterality (244)</uid>
    <uid uid=\"1.2.840.10008.6.1.38\" keyword=\"PositiveNegative250\" type=\"Context Group Name\">Positive-Negative (250)</uid>
    <uid uid=\"1.2.840.10008.6.1.39\" keyword=\"SeverityOfComplication251\" type=\"Context Group Name\">Severity of Complication (251)</uid>
    <uid uid=\"1.2.840.10008.6.1.40\" keyword=\"ObserverType270\" type=\"Context Group Name\">Observer Type (270)</uid>
    <uid uid=\"1.2.840.10008.6.1.41\" keyword=\"ObservationSubjectClass271\" type=\"Context Group Name\">Observation Subject Class (271)</uid>
    <uid uid=\"1.2.840.10008.6.1.42\" keyword=\"AudioChannelSource3000\" type=\"Context Group Name\">Audio Channel Source (3000)</uid>
    <uid uid=\"1.2.840.10008.6.1.43\" keyword=\"ECGLeads3001\" type=\"Context Group Name\">ECG Leads (3001)</uid>
    <uid uid=\"1.2.840.10008.6.1.44\" keyword=\"HemodynamicWaveformSources3003\" type=\"Context Group Name\">Hemodynamic Waveform Sources (3003)</uid>
    <uid uid=\"1.2.840.10008.6.1.45\" keyword=\"CardiovascularAnatomicLocations3010\" type=\"Context Group Name\">Cardiovascular Anatomic Locations (3010)</uid>
    <uid uid=\"1.2.840.10008.6.1.46\" keyword=\"ElectrophysiologyAnatomicLocations3011\" type=\"Context Group Name\">Electrophysiology Anatomic Locations (3011)</uid>
    <uid uid=\"1.2.840.10008.6.1.47\" keyword=\"CoronaryArterySegments3014\" type=\"Context Group Name\">Coronary Artery Segments (3014)</uid>
    <uid uid=\"1.2.840.10008.6.1.48\" keyword=\"CoronaryArteries3015\" type=\"Context Group Name\">Coronary Arteries (3015)</uid>
    <uid uid=\"1.2.840.10008.6.1.49\" keyword=\"CardiovascularAnatomicLocationModifiers3019\" type=\"Context Group Name\">Cardiovascular Anatomic Location Modifiers (3019)</uid>
    <uid uid=\"1.2.840.10008.6.1.50\" keyword=\"CardiologyUnitsOfMeasurement3082\" type=\"Context Group Name\" retired=\"true\">Cardiology Units of Measurement (Retired) (3082)</uid>
    <uid uid=\"1.2.840.10008.6.1.51\" keyword=\"TimeSynchronizationChannelTypes3090\" type=\"Context Group Name\">Time Synchronization Channel Types (3090)</uid>
    <uid uid=\"1.2.840.10008.6.1.52\" keyword=\"CardiacProceduralStateValues3101\" type=\"Context Group Name\">Cardiac Procedural State Values (3101)</uid>
    <uid uid=\"1.2.840.10008.6.1.53\" keyword=\"ElectrophysiologyMeasurementFunctionsAndTechniques3240\" type=\"Context Group Name\">Electrophysiology Measurement Functions and Techniques (3240)</uid>
    <uid uid=\"1.2.840.10008.6.1.54\" keyword=\"HemodynamicMeasurementTechniques3241\" type=\"Context Group Name\">Hemodynamic Measurement Techniques (3241)</uid>
    <uid uid=\"1.2.840.10008.6.1.55\" keyword=\"CatheterizationProcedurePhase3250\" type=\"Context Group Name\">Catheterization Procedure Phase (3250)</uid>
    <uid uid=\"1.2.840.10008.6.1.56\" keyword=\"ElectrophysiologyProcedurePhase3254\" type=\"Context Group Name\">Electrophysiology Procedure Phase (3254)</uid>
    <uid uid=\"1.2.840.10008.6.1.57\" keyword=\"StressProtocols3261\" type=\"Context Group Name\">Stress Protocols (3261)</uid>
    <uid uid=\"1.2.840.10008.6.1.58\" keyword=\"ECGPatientStateValues3262\" type=\"Context Group Name\">ECG Patient State Values (3262)</uid>
    <uid uid=\"1.2.840.10008.6.1.59\" keyword=\"ElectrodePlacementValues3263\" type=\"Context Group Name\">Electrode Placement Values (3263)</uid>
    <uid uid=\"1.2.840.10008.6.1.60\" keyword=\"XYZElectrodePlacementValues3264\" type=\"Context Group Name\" retired=\"true\">XYZ Electrode Placement Values (Retired) (3264)</uid>
    <uid uid=\"1.2.840.10008.6.1.61\" keyword=\"HemodynamicPhysiologicalChallenges3271\" type=\"Context Group Name\">Hemodynamic Physiological Challenges (3271)</uid>
    <uid uid=\"1.2.840.10008.6.1.62\" keyword=\"ECGAnnotations3335\" type=\"Context Group Name\">ECG Annotations (3335)</uid>
    <uid uid=\"1.2.840.10008.6.1.63\" keyword=\"HemodynamicAnnotations3337\" type=\"Context Group Name\">Hemodynamic Annotations (3337)</uid>
    <uid uid=\"1.2.840.10008.6.1.64\" keyword=\"ElectrophysiologyAnnotations3339\" type=\"Context Group Name\">Electrophysiology Annotations (3339)</uid>
    <uid uid=\"1.2.840.10008.6.1.65\" keyword=\"ProcedureLogTitles3400\" type=\"Context Group Name\">Procedure Log Titles (3400)</uid>
    <uid uid=\"1.2.840.10008.6.1.66\" keyword=\"TypesOfLogNotes3401\" type=\"Context Group Name\">Types of Log Notes (3401)</uid>
    <uid uid=\"1.2.840.10008.6.1.67\" keyword=\"PatientStatusAndEvents3402\" type=\"Context Group Name\">Patient Status and Events (3402)</uid>
    <uid uid=\"1.2.840.10008.6.1.68\" keyword=\"PercutaneousEntry3403\" type=\"Context Group Name\">Percutaneous Entry (3403)</uid>
    <uid uid=\"1.2.840.10008.6.1.69\" keyword=\"StaffActions3404\" type=\"Context Group Name\">Staff Actions (3404)</uid>
    <uid uid=\"1.2.840.10008.6.1.70\" keyword=\"ProcedureActionValues3405\" type=\"Context Group Name\">Procedure Action Values (3405)</uid>
    <uid uid=\"1.2.840.10008.6.1.71\" keyword=\"NonCoronaryTranscatheterInterventions3406\" type=\"Context Group Name\">Non-coronary Transcatheter Interventions (3406)</uid>
    <uid uid=\"1.2.840.10008.6.1.72\" keyword=\"PurposeOfReferenceToObject3407\" type=\"Context Group Name\">Purpose of Reference to Object (3407)</uid>
    <uid uid=\"1.2.840.10008.6.1.73\" keyword=\"ActionsWithConsumables3408\" type=\"Context Group Name\">Actions With Consumables (3408)</uid>
    <uid uid=\"1.2.840.10008.6.1.74\" keyword=\"AdministrationOfDrugsContrast3409\" type=\"Context Group Name\">Administration of Drugs/Contrast (3409)</uid>
    <uid uid=\"1.2.840.10008.6.1.75\" keyword=\"NumericParametersOfDrugsContrast3410\" type=\"Context Group Name\">Numeric Parameters of Drugs/Contrast (3410)</uid>
    <uid uid=\"1.2.840.10008.6.1.76\" keyword=\"IntracoronaryDevices3411\" type=\"Context Group Name\">Intracoronary Devices (3411)</uid>
    <uid uid=\"1.2.840.10008.6.1.77\" keyword=\"InterventionActionsAndStatus3412\" type=\"Context Group Name\">Intervention Actions and Status (3412)</uid>
    <uid uid=\"1.2.840.10008.6.1.78\" keyword=\"AdverseOutcomes3413\" type=\"Context Group Name\">Adverse Outcomes (3413)</uid>
    <uid uid=\"1.2.840.10008.6.1.79\" keyword=\"ProcedureUrgency3414\" type=\"Context Group Name\">Procedure Urgency (3414)</uid>
    <uid uid=\"1.2.840.10008.6.1.80\" keyword=\"CardiacRhythms3415\" type=\"Context Group Name\">Cardiac Rhythms (3415)</uid>
    <uid uid=\"1.2.840.10008.6.1.81\" keyword=\"RespirationRhythms3416\" type=\"Context Group Name\">Respiration Rhythms (3416)</uid>
    <uid uid=\"1.2.840.10008.6.1.82\" keyword=\"LesionRisk3418\" type=\"Context Group Name\">Lesion Risk (3418)</uid>
    <uid uid=\"1.2.840.10008.6.1.83\" keyword=\"FindingsTitles3419\" type=\"Context Group Name\">Findings Titles (3419)</uid>
    <uid uid=\"1.2.840.10008.6.1.84\" keyword=\"ProcedureAction3421\" type=\"Context Group Name\">Procedure Action (3421)</uid>
    <uid uid=\"1.2.840.10008.6.1.85\" keyword=\"DeviceUseActions3422\" type=\"Context Group Name\">Device Use Actions (3422)</uid>
    <uid uid=\"1.2.840.10008.6.1.86\" keyword=\"NumericDeviceCharacteristics3423\" type=\"Context Group Name\">Numeric Device Characteristics (3423)</uid>
    <uid uid=\"1.2.840.10008.6.1.87\" keyword=\"InterventionParameters3425\" type=\"Context Group Name\">Intervention Parameters (3425)</uid>
    <uid uid=\"1.2.840.10008.6.1.88\" keyword=\"ConsumablesParameters3426\" type=\"Context Group Name\">Consumables Parameters (3426)</uid>
    <uid uid=\"1.2.840.10008.6.1.89\" keyword=\"EquipmentEvents3427\" type=\"Context Group Name\">Equipment Events (3427)</uid>
    <uid uid=\"1.2.840.10008.6.1.90\" keyword=\"ImagingProcedures3428\" type=\"Context Group Name\">Imaging Procedures (3428)</uid>
    <uid uid=\"1.2.840.10008.6.1.91\" keyword=\"CatheterizationDevices3429\" type=\"Context Group Name\">Catheterization Devices (3429)</uid>
    <uid uid=\"1.2.840.10008.6.1.92\" keyword=\"DateTimeQualifiers3430\" type=\"Context Group Name\">DateTime Qualifiers (3430)</uid>
    <uid uid=\"1.2.840.10008.6.1.93\" keyword=\"PeripheralPulseLocations3440\" type=\"Context Group Name\">Peripheral Pulse Locations (3440)</uid>
    <uid uid=\"1.2.840.10008.6.1.94\" keyword=\"PatientAssessments3441\" type=\"Context Group Name\">Patient Assessments (3441)</uid>
    <uid uid=\"1.2.840.10008.6.1.95\" keyword=\"PeripheralPulseMethods3442\" type=\"Context Group Name\">Peripheral Pulse Methods (3442)</uid>
    <uid uid=\"1.2.840.10008.6.1.96\" keyword=\"SkinCondition3446\" type=\"Context Group Name\">Skin Condition (3446)</uid>
    <uid uid=\"1.2.840.10008.6.1.97\" keyword=\"AirwayAssessment3448\" type=\"Context Group Name\">Airway Assessment (3448)</uid>
    <uid uid=\"1.2.840.10008.6.1.98\" keyword=\"CalibrationObjects3451\" type=\"Context Group Name\">Calibration Objects (3451)</uid>
    <uid uid=\"1.2.840.10008.6.1.99\" keyword=\"CalibrationMethods3452\" type=\"Context Group Name\">Calibration Methods (3452)</uid>
    <uid uid=\"1.2.840.10008.6.1.100\" keyword=\"CardiacVolumeMethods3453\" type=\"Context Group Name\">Cardiac Volume Methods (3453)</uid>
    <uid uid=\"1.2.840.10008.6.1.101\" keyword=\"IndexMethods3455\" type=\"Context Group Name\">Index Methods (3455)</uid>
    <uid uid=\"1.2.840.10008.6.1.102\" keyword=\"SubSegmentMethods3456\" type=\"Context Group Name\">Sub-segment Methods (3456)</uid>
    <uid uid=\"1.2.840.10008.6.1.103\" keyword=\"ContourRealignment3458\" type=\"Context Group Name\">Contour Realignment (3458)</uid>
    <uid uid=\"1.2.840.10008.6.1.104\" keyword=\"CircumferentialExtent3460\" type=\"Context Group Name\">Circumferential Extent (3460)</uid>
    <uid uid=\"1.2.840.10008.6.1.105\" keyword=\"RegionalExtent3461\" type=\"Context Group Name\">Regional Extent (3461)</uid>
    <uid uid=\"1.2.840.10008.6.1.106\" keyword=\"ChamberIdentification3462\" type=\"Context Group Name\">Chamber Identification (3462)</uid>
    <uid uid=\"1.2.840.10008.6.1.107\" keyword=\"QAReferenceMethods3465\" type=\"Context Group Name\">QA Reference Methods (3465)</uid>
    <uid uid=\"1.2.840.10008.6.1.108\" keyword=\"PlaneIdentification3466\" type=\"Context Group Name\">Plane Identification (3466)</uid>
    <uid uid=\"1.2.840.10008.6.1.109\" keyword=\"EjectionFraction3467\" type=\"Context Group Name\">Ejection Fraction (3467)</uid>
    <uid uid=\"1.2.840.10008.6.1.110\" keyword=\"EDVolume3468\" type=\"Context Group Name\">ED Volume (3468)</uid>
    <uid uid=\"1.2.840.10008.6.1.111\" keyword=\"ESVolume3469\" type=\"Context Group Name\">ES Volume (3469)</uid>
    <uid uid=\"1.2.840.10008.6.1.112\" keyword=\"VesselLumenCrossSectionalAreaCalculationMethods3470\" type=\"Context Group Name\">Vessel Lumen Cross-sectional Area Calculation Methods (3470)</uid>
    <uid uid=\"1.2.840.10008.6.1.113\" keyword=\"EstimatedVolumes3471\" type=\"Context Group Name\">Estimated Volumes (3471)</uid>
    <uid uid=\"1.2.840.10008.6.1.114\" keyword=\"CardiacContractionPhase3472\" type=\"Context Group Name\">Cardiac Contraction Phase (3472)</uid>
    <uid uid=\"1.2.840.10008.6.1.115\" keyword=\"IVUSProcedurePhases3480\" type=\"Context Group Name\">IVUS Procedure Phases (3480)</uid>
    <uid uid=\"1.2.840.10008.6.1.116\" keyword=\"IVUSDistanceMeasurements3481\" type=\"Context Group Name\">IVUS Distance Measurements (3481)</uid>
    <uid uid=\"1.2.840.10008.6.1.117\" keyword=\"IVUSAreaMeasurements3482\" type=\"Context Group Name\">IVUS Area Measurements (3482)</uid>
    <uid uid=\"1.2.840.10008.6.1.118\" keyword=\"IVUSLongitudinalMeasurements3483\" type=\"Context Group Name\">IVUS Longitudinal Measurements (3483)</uid>
    <uid uid=\"1.2.840.10008.6.1.119\" keyword=\"IVUSIndicesAndRatios3484\" type=\"Context Group Name\">IVUS Indices and Ratios (3484)</uid>
    <uid uid=\"1.2.840.10008.6.1.120\" keyword=\"IVUSVolumeMeasurements3485\" type=\"Context Group Name\">IVUS Volume Measurements (3485)</uid>
    <uid uid=\"1.2.840.10008.6.1.121\" keyword=\"VascularMeasurementSites3486\" type=\"Context Group Name\">Vascular Measurement Sites (3486)</uid>
    <uid uid=\"1.2.840.10008.6.1.122\" keyword=\"IntravascularVolumetricRegions3487\" type=\"Context Group Name\">Intravascular Volumetric Regions (3487)</uid>
    <uid uid=\"1.2.840.10008.6.1.123\" keyword=\"MinMaxMean3488\" type=\"Context Group Name\">Min/Max/Mean (3488)</uid>
    <uid uid=\"1.2.840.10008.6.1.124\" keyword=\"CalciumDistribution3489\" type=\"Context Group Name\">Calcium Distribution (3489)</uid>
    <uid uid=\"1.2.840.10008.6.1.125\" keyword=\"IVUSLesionMorphologies3491\" type=\"Context Group Name\">IVUS Lesion Morphologies (3491)</uid>
    <uid uid=\"1.2.840.10008.6.1.126\" keyword=\"VascularDissectionClassifications3492\" type=\"Context Group Name\">Vascular Dissection Classifications (3492)</uid>
    <uid uid=\"1.2.840.10008.6.1.127\" keyword=\"IVUSRelativeStenosisSeverities3493\" type=\"Context Group Name\">IVUS Relative Stenosis Severities (3493)</uid>
    <uid uid=\"1.2.840.10008.6.1.128\" keyword=\"IVUSNonMorphologicalFindings3494\" type=\"Context Group Name\">IVUS Non Morphological Findings (3494)</uid>
    <uid uid=\"1.2.840.10008.6.1.129\" keyword=\"IVUSPlaqueComposition3495\" type=\"Context Group Name\">IVUS Plaque Composition (3495)</uid>
    <uid uid=\"1.2.840.10008.6.1.130\" keyword=\"IVUSFiducialPoints3496\" type=\"Context Group Name\">IVUS Fiducial Points (3496)</uid>
    <uid uid=\"1.2.840.10008.6.1.131\" keyword=\"IVUSArterialMorphology3497\" type=\"Context Group Name\">IVUS Arterial Morphology (3497)</uid>
    <uid uid=\"1.2.840.10008.6.1.132\" keyword=\"PressureUnits3500\" type=\"Context Group Name\">Pressure Units (3500)</uid>
    <uid uid=\"1.2.840.10008.6.1.133\" keyword=\"HemodynamicResistanceUnits3502\" type=\"Context Group Name\">Hemodynamic Resistance Units (3502)</uid>
    <uid uid=\"1.2.840.10008.6.1.134\" keyword=\"IndexedHemodynamicResistanceUnits3503\" type=\"Context Group Name\">Indexed Hemodynamic Resistance Units (3503)</uid>
    <uid uid=\"1.2.840.10008.6.1.135\" keyword=\"CatheterSizeUnits3510\" type=\"Context Group Name\">Catheter Size Units (3510)</uid>
    <uid uid=\"1.2.840.10008.6.1.136\" keyword=\"SpecimenCollection3515\" type=\"Context Group Name\">Specimen Collection (3515)</uid>
    <uid uid=\"1.2.840.10008.6.1.137\" keyword=\"BloodSourceType3520\" type=\"Context Group Name\">Blood Source Type (3520)</uid>
    <uid uid=\"1.2.840.10008.6.1.138\" keyword=\"BloodGasPressures3524\" type=\"Context Group Name\">Blood Gas Pressures (3524)</uid>
    <uid uid=\"1.2.840.10008.6.1.139\" keyword=\"BloodGasContent3525\" type=\"Context Group Name\">Blood Gas Content (3525)</uid>
    <uid uid=\"1.2.840.10008.6.1.140\" keyword=\"BloodGasSaturation3526\" type=\"Context Group Name\">Blood Gas Saturation (3526)</uid>
    <uid uid=\"1.2.840.10008.6.1.141\" keyword=\"BloodBaseExcess3527\" type=\"Context Group Name\">Blood Base Excess (3527)</uid>
    <uid uid=\"1.2.840.10008.6.1.142\" keyword=\"BloodPH3528\" type=\"Context Group Name\">Blood pH (3528)</uid>
    <uid uid=\"1.2.840.10008.6.1.143\" keyword=\"ArterialVenousContent3529\" type=\"Context Group Name\">Arterial / Venous Content (3529)</uid>
    <uid uid=\"1.2.840.10008.6.1.144\" keyword=\"OxygenAdministrationActions3530\" type=\"Context Group Name\">Oxygen Administration Actions (3530)</uid>
    <uid uid=\"1.2.840.10008.6.1.145\" keyword=\"OxygenAdministration3531\" type=\"Context Group Name\">Oxygen Administration (3531)</uid>
    <uid uid=\"1.2.840.10008.6.1.146\" keyword=\"CirculatorySupportActions3550\" type=\"Context Group Name\">Circulatory Support Actions (3550)</uid>
    <uid uid=\"1.2.840.10008.6.1.147\" keyword=\"VentilationActions3551\" type=\"Context Group Name\">Ventilation Actions (3551)</uid>
    <uid uid=\"1.2.840.10008.6.1.148\" keyword=\"PacingActions3552\" type=\"Context Group Name\">Pacing Actions (3552)</uid>
    <uid uid=\"1.2.840.10008.6.1.149\" keyword=\"CirculatorySupport3553\" type=\"Context Group Name\">Circulatory Support (3553)</uid>
    <uid uid=\"1.2.840.10008.6.1.150\" keyword=\"Ventilation3554\" type=\"Context Group Name\">Ventilation (3554)</uid>
    <uid uid=\"1.2.840.10008.6.1.151\" keyword=\"Pacing3555\" type=\"Context Group Name\">Pacing (3555)</uid>
    <uid uid=\"1.2.840.10008.6.1.152\" keyword=\"BloodPressureMethods3560\" type=\"Context Group Name\">Blood Pressure Methods (3560)</uid>
    <uid uid=\"1.2.840.10008.6.1.153\" keyword=\"RelativeTimes3600\" type=\"Context Group Name\">Relative Times (3600)</uid>
    <uid uid=\"1.2.840.10008.6.1.154\" keyword=\"HemodynamicPatientState3602\" type=\"Context Group Name\">Hemodynamic Patient State (3602)</uid>
    <uid uid=\"1.2.840.10008.6.1.155\" keyword=\"ArterialLesionLocations3604\" type=\"Context Group Name\">Arterial Lesion Locations (3604)</uid>
    <uid uid=\"1.2.840.10008.6.1.156\" keyword=\"ArterialSourceLocations3606\" type=\"Context Group Name\">Arterial Source Locations (3606)</uid>
    <uid uid=\"1.2.840.10008.6.1.157\" keyword=\"VenousSourceLocations3607\" type=\"Context Group Name\">Venous Source Locations (3607)</uid>
    <uid uid=\"1.2.840.10008.6.1.158\" keyword=\"AtrialSourceLocations3608\" type=\"Context Group Name\">Atrial Source Locations (3608)</uid>
    <uid uid=\"1.2.840.10008.6.1.159\" keyword=\"VentricularSourceLocations3609\" type=\"Context Group Name\">Ventricular Source Locations (3609)</uid>
    <uid uid=\"1.2.840.10008.6.1.160\" keyword=\"GradientSourceLocations3610\" type=\"Context Group Name\">Gradient Source Locations (3610)</uid>
    <uid uid=\"1.2.840.10008.6.1.161\" keyword=\"PressureMeasurements3611\" type=\"Context Group Name\">Pressure Measurements (3611)</uid>
    <uid uid=\"1.2.840.10008.6.1.162\" keyword=\"BloodVelocityMeasurements3612\" type=\"Context Group Name\">Blood Velocity Measurements (3612)</uid>
    <uid uid=\"1.2.840.10008.6.1.163\" keyword=\"HemodynamicTimeMeasurements3613\" type=\"Context Group Name\">Hemodynamic Time Measurements (3613)</uid>
    <uid uid=\"1.2.840.10008.6.1.164\" keyword=\"ValveAreasNonMitral3614\" type=\"Context Group Name\">Valve Areas, Non-mitral (3614)</uid>
    <uid uid=\"1.2.840.10008.6.1.165\" keyword=\"ValveAreas3615\" type=\"Context Group Name\">Valve Areas (3615)</uid>
    <uid uid=\"1.2.840.10008.6.1.166\" keyword=\"HemodynamicPeriodMeasurements3616\" type=\"Context Group Name\">Hemodynamic Period Measurements (3616)</uid>
    <uid uid=\"1.2.840.10008.6.1.167\" keyword=\"ValveFlows3617\" type=\"Context Group Name\">Valve Flows (3617)</uid>
    <uid uid=\"1.2.840.10008.6.1.168\" keyword=\"HemodynamicFlows3618\" type=\"Context Group Name\">Hemodynamic Flows (3618)</uid>
    <uid uid=\"1.2.840.10008.6.1.169\" keyword=\"HemodynamicResistanceMeasurements3619\" type=\"Context Group Name\">Hemodynamic Resistance Measurements (3619)</uid>
    <uid uid=\"1.2.840.10008.6.1.170\" keyword=\"HemodynamicRatios3620\" type=\"Context Group Name\">Hemodynamic Ratios (3620)</uid>
    <uid uid=\"1.2.840.10008.6.1.171\" keyword=\"FractionalFlowReserve3621\" type=\"Context Group Name\">Fractional Flow Reserve (3621)</uid>
    <uid uid=\"1.2.840.10008.6.1.172\" keyword=\"MeasurementType3627\" type=\"Context Group Name\">Measurement Type (3627)</uid>
    <uid uid=\"1.2.840.10008.6.1.173\" keyword=\"CardiacOutputMethods3628\" type=\"Context Group Name\">Cardiac Output Methods (3628)</uid>
    <uid uid=\"1.2.840.10008.6.1.174\" keyword=\"ProcedureIntent3629\" type=\"Context Group Name\">Procedure Intent (3629)</uid>
    <uid uid=\"1.2.840.10008.6.1.175\" keyword=\"CardiovascularAnatomicLocations3630\" type=\"Context Group Name\">Cardiovascular Anatomic Locations (3630)</uid>
    <uid uid=\"1.2.840.10008.6.1.176\" keyword=\"Hypertension3640\" type=\"Context Group Name\">Hypertension (3640)</uid>
    <uid uid=\"1.2.840.10008.6.1.177\" keyword=\"HemodynamicAssessments3641\" type=\"Context Group Name\">Hemodynamic Assessments (3641)</uid>
    <uid uid=\"1.2.840.10008.6.1.178\" keyword=\"DegreeFindings3642\" type=\"Context Group Name\">Degree Findings (3642)</uid>
    <uid uid=\"1.2.840.10008.6.1.179\" keyword=\"HemodynamicMeasurementPhase3651\" type=\"Context Group Name\">Hemodynamic Measurement Phase (3651)</uid>
    <uid uid=\"1.2.840.10008.6.1.180\" keyword=\"BodySurfaceAreaEquations3663\" type=\"Context Group Name\">Body Surface Area Equations (3663)</uid>
    <uid uid=\"1.2.840.10008.6.1.181\" keyword=\"OxygenConsumptionEquationsAndTables3664\" type=\"Context Group Name\">Oxygen Consumption Equations and Tables (3664)</uid>
    <uid uid=\"1.2.840.10008.6.1.182\" keyword=\"P50Equations3666\" type=\"Context Group Name\">P50 Equations (3666)</uid>
    <uid uid=\"1.2.840.10008.6.1.183\" keyword=\"FraminghamScores3667\" type=\"Context Group Name\">Framingham Scores (3667)</uid>
    <uid uid=\"1.2.840.10008.6.1.184\" keyword=\"FraminghamTables3668\" type=\"Context Group Name\">Framingham Tables (3668)</uid>
    <uid uid=\"1.2.840.10008.6.1.185\" keyword=\"ECGProcedureTypes3670\" type=\"Context Group Name\">ECG Procedure Types (3670)</uid>
    <uid uid=\"1.2.840.10008.6.1.186\" keyword=\"ReasonForECGExam3671\" type=\"Context Group Name\">Reason for ECG Exam (3671)</uid>
    <uid uid=\"1.2.840.10008.6.1.187\" keyword=\"Pacemakers3672\" type=\"Context Group Name\">Pacemakers (3672)</uid>
    <uid uid=\"1.2.840.10008.6.1.188\" keyword=\"Diagnosis3673\" type=\"Context Group Name\" retired=\"true\">Diagnosis (Retired) (3673)</uid>
    <uid uid=\"1.2.840.10008.6.1.189\" keyword=\"OtherFilters3675\" type=\"Context Group Name\" retired=\"true\">Other Filters (Retired) (3675)</uid>
    <uid uid=\"1.2.840.10008.6.1.190\" keyword=\"LeadMeasurementTechnique3676\" type=\"Context Group Name\">Lead Measurement Technique (3676)</uid>
    <uid uid=\"1.2.840.10008.6.1.191\" keyword=\"SummaryCodesECG3677\" type=\"Context Group Name\">Summary Codes ECG (3677)</uid>
    <uid uid=\"1.2.840.10008.6.1.192\" keyword=\"QTCorrectionAlgorithms3678\" type=\"Context Group Name\">QT Correction Algorithms (3678)</uid>
    <uid uid=\"1.2.840.10008.6.1.193\" keyword=\"ECGMorphologyDescriptions3679\" type=\"Context Group Name\" retired=\"true\">ECG Morphology Descriptions (Retired) (3679)</uid>
    <uid uid=\"1.2.840.10008.6.1.194\" keyword=\"ECGLeadNoiseDescriptions3680\" type=\"Context Group Name\">ECG Lead Noise Descriptions (3680)</uid>
    <uid uid=\"1.2.840.10008.6.1.195\" keyword=\"ECGLeadNoiseModifiers3681\" type=\"Context Group Name\" retired=\"true\">ECG Lead Noise Modifiers (Retired) (3681)</uid>
    <uid uid=\"1.2.840.10008.6.1.196\" keyword=\"Probability3682\" type=\"Context Group Name\" retired=\"true\">Probability (Retired) (3682)</uid>
    <uid uid=\"1.2.840.10008.6.1.197\" keyword=\"Modifiers3683\" type=\"Context Group Name\" retired=\"true\">Modifiers (Retired) (3683)</uid>
    <uid uid=\"1.2.840.10008.6.1.198\" keyword=\"Trend3684\" type=\"Context Group Name\" retired=\"true\">Trend (Retired) (3684)</uid>
    <uid uid=\"1.2.840.10008.6.1.199\" keyword=\"ConjunctiveTerms3685\" type=\"Context Group Name\" retired=\"true\">Conjunctive Terms (Retired) (3685)</uid>
    <uid uid=\"1.2.840.10008.6.1.200\" keyword=\"ECGInterpretiveStatements3686\" type=\"Context Group Name\" retired=\"true\">ECG Interpretive Statements (Retired) (3686)</uid>
    <uid uid=\"1.2.840.10008.6.1.201\" keyword=\"ElectrophysiologyWaveformDurations3687\" type=\"Context Group Name\">Electrophysiology Waveform Durations (3687)</uid>
    <uid uid=\"1.2.840.10008.6.1.202\" keyword=\"ElectrophysiologyWaveformVoltages3688\" type=\"Context Group Name\">Electrophysiology Waveform Voltages (3688)</uid>
    <uid uid=\"1.2.840.10008.6.1.203\" keyword=\"CathDiagnosis3700\" type=\"Context Group Name\">Cath Diagnosis (3700)</uid>
    <uid uid=\"1.2.840.10008.6.1.204\" keyword=\"CardiacValvesAndTracts3701\" type=\"Context Group Name\">Cardiac Valves and Tracts (3701)</uid>
    <uid uid=\"1.2.840.10008.6.1.205\" keyword=\"WallMotion3703\" type=\"Context Group Name\">Wall Motion (3703)</uid>
    <uid uid=\"1.2.840.10008.6.1.206\" keyword=\"MyocardiumWallMorphologyFindings3704\" type=\"Context Group Name\">Myocardium Wall Morphology Findings (3704)</uid>
    <uid uid=\"1.2.840.10008.6.1.207\" keyword=\"ChamberSize3705\" type=\"Context Group Name\">Chamber Size (3705)</uid>
    <uid uid=\"1.2.840.10008.6.1.208\" keyword=\"OverallContractility3706\" type=\"Context Group Name\">Overall Contractility (3706)</uid>
    <uid uid=\"1.2.840.10008.6.1.209\" keyword=\"VSDDescription3707\" type=\"Context Group Name\">VSD Description (3707)</uid>
    <uid uid=\"1.2.840.10008.6.1.210\" keyword=\"AorticRootDescription3709\" type=\"Context Group Name\">Aortic Root Description (3709)</uid>
    <uid uid=\"1.2.840.10008.6.1.211\" keyword=\"CoronaryDominance3710\" type=\"Context Group Name\">Coronary Dominance (3710)</uid>
    <uid uid=\"1.2.840.10008.6.1.212\" keyword=\"ValvularAbnormalities3711\" type=\"Context Group Name\">Valvular Abnormalities (3711)</uid>
    <uid uid=\"1.2.840.10008.6.1.213\" keyword=\"VesselDescriptors3712\" type=\"Context Group Name\">Vessel Descriptors (3712)</uid>
    <uid uid=\"1.2.840.10008.6.1.214\" keyword=\"TIMIFlowCharacteristics3713\" type=\"Context Group Name\">TIMI Flow Characteristics (3713)</uid>
    <uid uid=\"1.2.840.10008.6.1.215\" keyword=\"Thrombus3714\" type=\"Context Group Name\">Thrombus (3714)</uid>
    <uid uid=\"1.2.840.10008.6.1.216\" keyword=\"LesionMargin3715\" type=\"Context Group Name\">Lesion Margin (3715)</uid>
    <uid uid=\"1.2.840.10008.6.1.217\" keyword=\"Severity3716\" type=\"Context Group Name\">Severity (3716)</uid>
    <uid uid=\"1.2.840.10008.6.1.218\" keyword=\"MyocardialWallSegments3717\" type=\"Context Group Name\">Myocardial Wall Segments (3717)</uid>
    <uid uid=\"1.2.840.10008.6.1.219\" keyword=\"MyocardialWallSegmentsInProjection3718\" type=\"Context Group Name\">Myocardial Wall Segments in Projection (3718)</uid>
    <uid uid=\"1.2.840.10008.6.1.220\" keyword=\"CanadianClinicalClassification3719\" type=\"Context Group Name\">Canadian Clinical Classification (3719)</uid>
    <uid uid=\"1.2.840.10008.6.1.221\" keyword=\"CardiacHistoryDates3720\" type=\"Context Group Name\" retired=\"true\">Cardiac History Dates (Retired) (3720)</uid>
    <uid uid=\"1.2.840.10008.6.1.222\" keyword=\"CardiovascularSurgeries3721\" type=\"Context Group Name\">Cardiovascular Surgeries (3721)</uid>
    <uid uid=\"1.2.840.10008.6.1.223\" keyword=\"DiabeticTherapy3722\" type=\"Context Group Name\">Diabetic Therapy (3722)</uid>
    <uid uid=\"1.2.840.10008.6.1.224\" keyword=\"MITypes3723\" type=\"Context Group Name\">MI Types (3723)</uid>
    <uid uid=\"1.2.840.10008.6.1.225\" keyword=\"SmokingHistory3724\" type=\"Context Group Name\">Smoking History (3724)</uid>
    <uid uid=\"1.2.840.10008.6.1.226\" keyword=\"IndicationsForCoronaryIntervention3726\" type=\"Context Group Name\">Indications for Coronary Intervention (3726)</uid>
    <uid uid=\"1.2.840.10008.6.1.227\" keyword=\"IndicationsForCatheterization3727\" type=\"Context Group Name\">Indications for Catheterization (3727)</uid>
    <uid uid=\"1.2.840.10008.6.1.228\" keyword=\"CathFindings3728\" type=\"Context Group Name\">Cath Findings (3728)</uid>
    <uid uid=\"1.2.840.10008.6.1.229\" keyword=\"AdmissionStatus3729\" type=\"Context Group Name\">Admission Status (3729)</uid>
    <uid uid=\"1.2.840.10008.6.1.230\" keyword=\"InsurancePayor3730\" type=\"Context Group Name\">Insurance Payor (3730)</uid>
    <uid uid=\"1.2.840.10008.6.1.231\" keyword=\"PrimaryCauseOfDeath3733\" type=\"Context Group Name\">Primary Cause of Death (3733)</uid>
    <uid uid=\"1.2.840.10008.6.1.232\" keyword=\"AcuteCoronarySyndromeTimePeriod3735\" type=\"Context Group Name\">Acute Coronary Syndrome Time Period (3735)</uid>
    <uid uid=\"1.2.840.10008.6.1.233\" keyword=\"NYHAClassification3736\" type=\"Context Group Name\">NYHA Classification (3736)</uid>
    <uid uid=\"1.2.840.10008.6.1.234\" keyword=\"NonInvasiveTestIschemia3737\" type=\"Context Group Name\">Non-invasive Test - Ischemia (3737)</uid>
    <uid uid=\"1.2.840.10008.6.1.235\" keyword=\"PreCathAnginaType3738\" type=\"Context Group Name\">Pre-Cath Angina Type (3738)</uid>
    <uid uid=\"1.2.840.10008.6.1.236\" keyword=\"CathProcedureType3739\" type=\"Context Group Name\">Cath Procedure Type (3739)</uid>
    <uid uid=\"1.2.840.10008.6.1.237\" keyword=\"ThrombolyticAdministration3740\" type=\"Context Group Name\">Thrombolytic Administration (3740)</uid>
    <uid uid=\"1.2.840.10008.6.1.238\" keyword=\"MedicationAdministrationLabVisit3741\" type=\"Context Group Name\">Medication Administration, Lab Visit (3741)</uid>
    <uid uid=\"1.2.840.10008.6.1.239\" keyword=\"MedicationAdministrationPCI3742\" type=\"Context Group Name\">Medication Administration, PCI (3742)</uid>
    <uid uid=\"1.2.840.10008.6.1.240\" keyword=\"ClopidogrelTiclopidineAdministration3743\" type=\"Context Group Name\">Clopidogrel/Ticlopidine Administration (3743)</uid>
    <uid uid=\"1.2.840.10008.6.1.241\" keyword=\"EFTestingMethod3744\" type=\"Context Group Name\">EF Testing Method (3744)</uid>
    <uid uid=\"1.2.840.10008.6.1.242\" keyword=\"CalculationMethod3745\" type=\"Context Group Name\">Calculation Method (3745)</uid>
    <uid uid=\"1.2.840.10008.6.1.243\" keyword=\"PercutaneousEntrySite3746\" type=\"Context Group Name\">Percutaneous Entry Site (3746)</uid>
    <uid uid=\"1.2.840.10008.6.1.244\" keyword=\"PercutaneousClosure3747\" type=\"Context Group Name\">Percutaneous Closure (3747)</uid>
    <uid uid=\"1.2.840.10008.6.1.245\" keyword=\"AngiographicEFTestingMethod3748\" type=\"Context Group Name\">Angiographic EF Testing Method (3748)</uid>
    <uid uid=\"1.2.840.10008.6.1.246\" keyword=\"PCIProcedureResult3749\" type=\"Context Group Name\">PCI Procedure Result (3749)</uid>
    <uid uid=\"1.2.840.10008.6.1.247\" keyword=\"PreviouslyDilatedLesion3750\" type=\"Context Group Name\">Previously Dilated Lesion (3750)</uid>
    <uid uid=\"1.2.840.10008.6.1.248\" keyword=\"GuidewireCrossing3752\" type=\"Context Group Name\">Guidewire Crossing (3752)</uid>
    <uid uid=\"1.2.840.10008.6.1.249\" keyword=\"VascularComplications3754\" type=\"Context Group Name\">Vascular Complications (3754)</uid>
    <uid uid=\"1.2.840.10008.6.1.250\" keyword=\"CathComplications3755\" type=\"Context Group Name\">Cath Complications (3755)</uid>
    <uid uid=\"1.2.840.10008.6.1.251\" keyword=\"CardiacPatientRiskFactors3756\" type=\"Context Group Name\">Cardiac Patient Risk Factors (3756)</uid>
    <uid uid=\"1.2.840.10008.6.1.252\" keyword=\"CardiacDiagnosticProcedures3757\" type=\"Context Group Name\">Cardiac Diagnostic Procedures (3757)</uid>
    <uid uid=\"1.2.840.10008.6.1.253\" keyword=\"CardiovascularFamilyHistory3758\" type=\"Context Group Name\">Cardiovascular Family History (3758)</uid>
    <uid uid=\"1.2.840.10008.6.1.254\" keyword=\"HypertensionTherapy3760\" type=\"Context Group Name\">Hypertension Therapy (3760)</uid>
    <uid uid=\"1.2.840.10008.6.1.255\" keyword=\"AntilipemicAgents3761\" type=\"Context Group Name\">Antilipemic Agents (3761)</uid>
    <uid uid=\"1.2.840.10008.6.1.256\" keyword=\"AntiarrhythmicAgents3762\" type=\"Context Group Name\">Antiarrhythmic Agents (3762)</uid>
    <uid uid=\"1.2.840.10008.6.1.257\" keyword=\"MyocardialInfarctionTherapies3764\" type=\"Context Group Name\">Myocardial Infarction Therapies (3764)</uid>
    <uid uid=\"1.2.840.10008.6.1.258\" keyword=\"ConcernTypes3769\" type=\"Context Group Name\">Concern Types (3769)</uid>
    <uid uid=\"1.2.840.10008.6.1.259\" keyword=\"ProblemStatus3770\" type=\"Context Group Name\">Problem Status (3770)</uid>
    <uid uid=\"1.2.840.10008.6.1.260\" keyword=\"HealthStatus3772\" type=\"Context Group Name\">Health Status (3772)</uid>
    <uid uid=\"1.2.840.10008.6.1.261\" keyword=\"UseStatus3773\" type=\"Context Group Name\">Use Status (3773)</uid>
    <uid uid=\"1.2.840.10008.6.1.262\" keyword=\"SocialHistory3774\" type=\"Context Group Name\">Social History (3774)</uid>
    <uid uid=\"1.2.840.10008.6.1.263\" keyword=\"ImplantedDevices3777\" type=\"Context Group Name\">Implanted Devices (3777)</uid>
    <uid uid=\"1.2.840.10008.6.1.264\" keyword=\"PlaqueStructures3802\" type=\"Context Group Name\">Plaque Structures (3802)</uid>
    <uid uid=\"1.2.840.10008.6.1.265\" keyword=\"StenosisMeasurementMethods3804\" type=\"Context Group Name\">Stenosis Measurement Methods (3804)</uid>
    <uid uid=\"1.2.840.10008.6.1.266\" keyword=\"StenosisTypes3805\" type=\"Context Group Name\">Stenosis Types (3805)</uid>
    <uid uid=\"1.2.840.10008.6.1.267\" keyword=\"StenosisShape3806\" type=\"Context Group Name\">Stenosis Shape (3806)</uid>
    <uid uid=\"1.2.840.10008.6.1.268\" keyword=\"VolumeMeasurementMethods3807\" type=\"Context Group Name\">Volume Measurement Methods (3807)</uid>
    <uid uid=\"1.2.840.10008.6.1.269\" keyword=\"AneurysmTypes3808\" type=\"Context Group Name\">Aneurysm Types (3808)</uid>
    <uid uid=\"1.2.840.10008.6.1.270\" keyword=\"AssociatedConditions3809\" type=\"Context Group Name\">Associated Conditions (3809)</uid>
    <uid uid=\"1.2.840.10008.6.1.271\" keyword=\"VascularMorphology3810\" type=\"Context Group Name\">Vascular Morphology (3810)</uid>
    <uid uid=\"1.2.840.10008.6.1.272\" keyword=\"StentFindings3813\" type=\"Context Group Name\">Stent Findings (3813)</uid>
    <uid uid=\"1.2.840.10008.6.1.273\" keyword=\"StentComposition3814\" type=\"Context Group Name\">Stent Composition (3814)</uid>
    <uid uid=\"1.2.840.10008.6.1.274\" keyword=\"SourceOfVascularFinding3815\" type=\"Context Group Name\">Source of Vascular Finding (3815)</uid>
    <uid uid=\"1.2.840.10008.6.1.275\" keyword=\"VascularSclerosisTypes3817\" type=\"Context Group Name\">Vascular Sclerosis Types (3817)</uid>
    <uid uid=\"1.2.840.10008.6.1.276\" keyword=\"NonInvasiveVascularProcedures3820\" type=\"Context Group Name\">Non-invasive Vascular Procedures (3820)</uid>
    <uid uid=\"1.2.840.10008.6.1.277\" keyword=\"PapillaryMuscleIncludedExcluded3821\" type=\"Context Group Name\">Papillary Muscle Included/Excluded (3821)</uid>
    <uid uid=\"1.2.840.10008.6.1.278\" keyword=\"RespiratoryStatus3823\" type=\"Context Group Name\">Respiratory Status (3823)</uid>
    <uid uid=\"1.2.840.10008.6.1.279\" keyword=\"HeartRhythm3826\" type=\"Context Group Name\">Heart Rhythm (3826)</uid>
    <uid uid=\"1.2.840.10008.6.1.280\" keyword=\"VesselSegments3827\" type=\"Context Group Name\">Vessel Segments (3827)</uid>
    <uid uid=\"1.2.840.10008.6.1.281\" keyword=\"PulmonaryArteries3829\" type=\"Context Group Name\">Pulmonary Arteries (3829)</uid>
    <uid uid=\"1.2.840.10008.6.1.282\" keyword=\"StenosisLength3831\" type=\"Context Group Name\">Stenosis Length (3831)</uid>
    <uid uid=\"1.2.840.10008.6.1.283\" keyword=\"StenosisGrade3832\" type=\"Context Group Name\">Stenosis Grade (3832)</uid>
    <uid uid=\"1.2.840.10008.6.1.284\" keyword=\"CardiacEjectionFraction3833\" type=\"Context Group Name\">Cardiac Ejection Fraction (3833)</uid>
    <uid uid=\"1.2.840.10008.6.1.285\" keyword=\"CardiacVolumeMeasurements3835\" type=\"Context Group Name\">Cardiac Volume Measurements (3835)</uid>
    <uid uid=\"1.2.840.10008.6.1.286\" keyword=\"TimeBasedPerfusionMeasurements3836\" type=\"Context Group Name\">Time-based Perfusion Measurements (3836)</uid>
    <uid uid=\"1.2.840.10008.6.1.287\" keyword=\"FiducialFeature3837\" type=\"Context Group Name\">Fiducial Feature (3837)</uid>
    <uid uid=\"1.2.840.10008.6.1.288\" keyword=\"DiameterDerivation3838\" type=\"Context Group Name\">Diameter Derivation (3838)</uid>
    <uid uid=\"1.2.840.10008.6.1.289\" keyword=\"CoronaryVeins3839\" type=\"Context Group Name\">Coronary Veins (3839)</uid>
    <uid uid=\"1.2.840.10008.6.1.290\" keyword=\"PulmonaryVeins3840\" type=\"Context Group Name\">Pulmonary Veins (3840)</uid>
    <uid uid=\"1.2.840.10008.6.1.291\" keyword=\"MyocardialSubsegment3843\" type=\"Context Group Name\">Myocardial Subsegment (3843)</uid>
    <uid uid=\"1.2.840.10008.6.1.292\" keyword=\"PartialViewSectionForMammography4005\" type=\"Context Group Name\">Partial View Section for Mammography (4005)</uid>
    <uid uid=\"1.2.840.10008.6.1.293\" keyword=\"DXAnatomyImaged4009\" type=\"Context Group Name\">DX Anatomy Imaged (4009)</uid>
    <uid uid=\"1.2.840.10008.6.1.294\" keyword=\"DXView4010\" type=\"Context Group Name\">DX View (4010)</uid>
    <uid uid=\"1.2.840.10008.6.1.295\" keyword=\"DXViewModifier4011\" type=\"Context Group Name\">DX View Modifier (4011)</uid>
    <uid uid=\"1.2.840.10008.6.1.296\" keyword=\"ProjectionEponymousName4012\" type=\"Context Group Name\">Projection Eponymous Name (4012)</uid>
    <uid uid=\"1.2.840.10008.6.1.297\" keyword=\"AnatomicRegionForMammography4013\" type=\"Context Group Name\">Anatomic Region for Mammography (4013)</uid>
    <uid uid=\"1.2.840.10008.6.1.298\" keyword=\"ViewForMammography4014\" type=\"Context Group Name\">View for Mammography (4014)</uid>
    <uid uid=\"1.2.840.10008.6.1.299\" keyword=\"ViewModifierForMammography4015\" type=\"Context Group Name\">View Modifier for Mammography (4015)</uid>
    <uid uid=\"1.2.840.10008.6.1.300\" keyword=\"AnatomicRegionForIntraOralRadiography4016\" type=\"Context Group Name\">Anatomic Region for Intra-oral Radiography (4016)</uid>
    <uid uid=\"1.2.840.10008.6.1.301\" keyword=\"AnatomicRegionModifierForIntraOralRadiography4017\" type=\"Context Group Name\">Anatomic Region Modifier for Intra-oral Radiography (4017)</uid>
    <uid uid=\"1.2.840.10008.6.1.302\" keyword=\"PrimaryAnatomicStructureForIntraOralRadiographyPermanentDentitionDesignationOfTeeth4018\" type=\"Context Group Name\">Primary Anatomic Structure for Intra-oral Radiography (Permanent Dentition - Designation of Teeth) (4018)</uid>
    <uid uid=\"1.2.840.10008.6.1.303\" keyword=\"PrimaryAnatomicStructureForIntraOralRadiographyDeciduousDentitionDesignationOfTeeth4019\" type=\"Context Group Name\">Primary Anatomic Structure for Intra-oral Radiography (Deciduous Dentition - Designation of Teeth) (4019)</uid>
    <uid uid=\"1.2.840.10008.6.1.304\" keyword=\"PETRadionuclide4020\" type=\"Context Group Name\">PET Radionuclide (4020)</uid>
    <uid uid=\"1.2.840.10008.6.1.305\" keyword=\"PETRadiopharmaceutical4021\" type=\"Context Group Name\">PET Radiopharmaceutical (4021)</uid>
    <uid uid=\"1.2.840.10008.6.1.306\" keyword=\"CraniofacialAnatomicRegions4028\" type=\"Context Group Name\">Craniofacial Anatomic Regions (4028)</uid>
    <uid uid=\"1.2.840.10008.6.1.307\" keyword=\"CTMRAndPETAnatomyImaged4030\" type=\"Context Group Name\">CT, MR and PET Anatomy Imaged (4030)</uid>
    <uid uid=\"1.2.840.10008.6.1.308\" keyword=\"CommonAnatomicRegions4031\" type=\"Context Group Name\">Common Anatomic Regions (4031)</uid>
    <uid uid=\"1.2.840.10008.6.1.309\" keyword=\"MRSpectroscopyMetabolites4032\" type=\"Context Group Name\">MR Spectroscopy Metabolites (4032)</uid>
    <uid uid=\"1.2.840.10008.6.1.310\" keyword=\"MRProtonSpectroscopyMetabolites4033\" type=\"Context Group Name\">MR Proton Spectroscopy Metabolites (4033)</uid>
    <uid uid=\"1.2.840.10008.6.1.311\" keyword=\"EndoscopyAnatomicRegions4040\" type=\"Context Group Name\">Endoscopy Anatomic Regions (4040)</uid>
    <uid uid=\"1.2.840.10008.6.1.312\" keyword=\"XAXRFAnatomyImaged4042\" type=\"Context Group Name\">XA/XRF Anatomy Imaged (4042)</uid>
    <uid uid=\"1.2.840.10008.6.1.313\" keyword=\"DrugOrContrastAgentCharacteristics4050\" type=\"Context Group Name\">Drug or Contrast Agent Characteristics (4050)</uid>
    <uid uid=\"1.2.840.10008.6.1.314\" keyword=\"GeneralDevices4051\" type=\"Context Group Name\">General Devices (4051)</uid>
    <uid uid=\"1.2.840.10008.6.1.315\" keyword=\"PhantomDevices4052\" type=\"Context Group Name\">Phantom Devices (4052)</uid>
    <uid uid=\"1.2.840.10008.6.1.316\" keyword=\"OphthalmicImagingAgent4200\" type=\"Context Group Name\">Ophthalmic Imaging Agent (4200)</uid>
    <uid uid=\"1.2.840.10008.6.1.317\" keyword=\"PatientEyeMovementCommand4201\" type=\"Context Group Name\">Patient Eye Movement Command (4201)</uid>
    <uid uid=\"1.2.840.10008.6.1.318\" keyword=\"OphthalmicPhotographyAcquisitionDevice4202\" type=\"Context Group Name\">Ophthalmic Photography Acquisition Device (4202)</uid>
    <uid uid=\"1.2.840.10008.6.1.319\" keyword=\"OphthalmicPhotographyIllumination4203\" type=\"Context Group Name\">Ophthalmic Photography Illumination (4203)</uid>
    <uid uid=\"1.2.840.10008.6.1.320\" keyword=\"OphthalmicFilter4204\" type=\"Context Group Name\">Ophthalmic Filter (4204)</uid>
    <uid uid=\"1.2.840.10008.6.1.321\" keyword=\"OphthalmicLens4205\" type=\"Context Group Name\">Ophthalmic Lens (4205)</uid>
    <uid uid=\"1.2.840.10008.6.1.322\" keyword=\"OphthalmicChannelDescription4206\" type=\"Context Group Name\">Ophthalmic Channel Description (4206)</uid>
    <uid uid=\"1.2.840.10008.6.1.323\" keyword=\"OphthalmicImagePosition4207\" type=\"Context Group Name\">Ophthalmic Image Position (4207)</uid>
    <uid uid=\"1.2.840.10008.6.1.324\" keyword=\"MydriaticAgent4208\" type=\"Context Group Name\">Mydriatic Agent (4208)</uid>
    <uid uid=\"1.2.840.10008.6.1.325\" keyword=\"OphthalmicAnatomicStructureImaged4209\" type=\"Context Group Name\">Ophthalmic Anatomic Structure Imaged (4209)</uid>
    <uid uid=\"1.2.840.10008.6.1.326\" keyword=\"OphthalmicTomographyAcquisitionDevice4210\" type=\"Context Group Name\">Ophthalmic Tomography Acquisition Device (4210)</uid>
    <uid uid=\"1.2.840.10008.6.1.327\" keyword=\"OphthalmicOCTAnatomicStructureImaged4211\" type=\"Context Group Name\">Ophthalmic OCT Anatomic Structure Imaged (4211)</uid>
    <uid uid=\"1.2.840.10008.6.1.328\" keyword=\"Languages5000\" type=\"Context Group Name\">Languages (5000)</uid>
    <uid uid=\"1.2.840.10008.6.1.329\" keyword=\"Countries5001\" type=\"Context Group Name\">Countries (5001)</uid>
    <uid uid=\"1.2.840.10008.6.1.330\" keyword=\"OverallBreastComposition6000\" type=\"Context Group Name\">Overall Breast Composition (6000)</uid>
    <uid uid=\"1.2.840.10008.6.1.331\" keyword=\"OverallBreastCompositionFromBIRADS6001\" type=\"Context Group Name\">Overall Breast Composition from BI-RADS® (6001)</uid>
    <uid uid=\"1.2.840.10008.6.1.332\" keyword=\"ChangeSinceLastMammogramOrPriorSurgery6002\" type=\"Context Group Name\">Change Since Last Mammogram or Prior Surgery (6002)</uid>
    <uid uid=\"1.2.840.10008.6.1.333\" keyword=\"ChangeSinceLastMammogramOrPriorSurgeryFromBIRADS6003\" type=\"Context Group Name\">Change Since Last Mammogram or Prior Surgery from BI-RADS® (6003)</uid>
    <uid uid=\"1.2.840.10008.6.1.334\" keyword=\"MammographyCharacteristicsOfShape6004\" type=\"Context Group Name\">Mammography Characteristics of Shape (6004)</uid>
    <uid uid=\"1.2.840.10008.6.1.335\" keyword=\"CharacteristicsOfShapeFromBIRADS6005\" type=\"Context Group Name\">Characteristics of Shape from BI-RADS® (6005)</uid>
    <uid uid=\"1.2.840.10008.6.1.336\" keyword=\"MammographyCharacteristicsOfMargin6006\" type=\"Context Group Name\">Mammography Characteristics of Margin (6006)</uid>
    <uid uid=\"1.2.840.10008.6.1.337\" keyword=\"CharacteristicsOfMarginFromBIRADS6007\" type=\"Context Group Name\">Characteristics of Margin from BI-RADS® (6007)</uid>
    <uid uid=\"1.2.840.10008.6.1.338\" keyword=\"DensityModifier6008\" type=\"Context Group Name\">Density Modifier (6008)</uid>
    <uid uid=\"1.2.840.10008.6.1.339\" keyword=\"DensityModifierFromBIRADS6009\" type=\"Context Group Name\">Density Modifier from BI-RADS® (6009)</uid>
    <uid uid=\"1.2.840.10008.6.1.340\" keyword=\"MammographyCalcificationTypes6010\" type=\"Context Group Name\">Mammography Calcification Types (6010)</uid>
    <uid uid=\"1.2.840.10008.6.1.341\" keyword=\"CalcificationTypesFromBIRADS6011\" type=\"Context Group Name\">Calcification Types from BI-RADS® (6011)</uid>
    <uid uid=\"1.2.840.10008.6.1.342\" keyword=\"CalcificationDistributionModifier6012\" type=\"Context Group Name\">Calcification Distribution Modifier (6012)</uid>
    <uid uid=\"1.2.840.10008.6.1.343\" keyword=\"CalcificationDistributionModifierFromBIRADS6013\" type=\"Context Group Name\">Calcification Distribution Modifier from BI-RADS® (6013)</uid>
    <uid uid=\"1.2.840.10008.6.1.344\" keyword=\"MammographySingleImageFinding6014\" type=\"Context Group Name\">Mammography Single Image Finding (6014)</uid>
    <uid uid=\"1.2.840.10008.6.1.345\" keyword=\"SingleImageFindingFromBIRADS6015\" type=\"Context Group Name\">Single Image Finding from BI-RADS® (6015)</uid>
    <uid uid=\"1.2.840.10008.6.1.346\" keyword=\"MammographyCompositeFeature6016\" type=\"Context Group Name\">Mammography Composite Feature (6016)</uid>
    <uid uid=\"1.2.840.10008.6.1.347\" keyword=\"CompositeFeatureFromBIRADS6017\" type=\"Context Group Name\">Composite Feature from BI-RADS® (6017)</uid>
    <uid uid=\"1.2.840.10008.6.1.348\" keyword=\"ClockfaceLocationOrRegion6018\" type=\"Context Group Name\">Clockface Location or Region (6018)</uid>
    <uid uid=\"1.2.840.10008.6.1.349\" keyword=\"ClockfaceLocationOrRegionFromBIRADS6019\" type=\"Context Group Name\">Clockface Location or Region from BI-RADS® (6019)</uid>
    <uid uid=\"1.2.840.10008.6.1.350\" keyword=\"QuadrantLocation6020\" type=\"Context Group Name\">Quadrant Location (6020)</uid>
    <uid uid=\"1.2.840.10008.6.1.351\" keyword=\"QuadrantLocationFromBIRADS6021\" type=\"Context Group Name\">Quadrant Location from BI-RADS® (6021)</uid>
    <uid uid=\"1.2.840.10008.6.1.352\" keyword=\"Side6022\" type=\"Context Group Name\">Side (6022)</uid>
    <uid uid=\"1.2.840.10008.6.1.353\" keyword=\"SideFromBIRADS6023\" type=\"Context Group Name\">Side from BI-RADS® (6023)</uid>
    <uid uid=\"1.2.840.10008.6.1.354\" keyword=\"Depth6024\" type=\"Context Group Name\">Depth (6024)</uid>
    <uid uid=\"1.2.840.10008.6.1.355\" keyword=\"DepthFromBIRADS6025\" type=\"Context Group Name\">Depth from BI-RADS® (6025)</uid>
    <uid uid=\"1.2.840.10008.6.1.356\" keyword=\"MammographyAssessment6026\" type=\"Context Group Name\">Mammography Assessment (6026)</uid>
    <uid uid=\"1.2.840.10008.6.1.357\" keyword=\"AssessmentFromBIRADS6027\" type=\"Context Group Name\">Assessment from BI-RADS® (6027)</uid>
    <uid uid=\"1.2.840.10008.6.1.358\" keyword=\"MammographyRecommendedFollowUp6028\" type=\"Context Group Name\">Mammography Recommended Follow-up (6028)</uid>
    <uid uid=\"1.2.840.10008.6.1.359\" keyword=\"RecommendedFollowUpFromBIRADS6029\" type=\"Context Group Name\">Recommended Follow-up from BI-RADS® (6029)</uid>
    <uid uid=\"1.2.840.10008.6.1.360\" keyword=\"MammographyPathologyCodes6030\" type=\"Context Group Name\">Mammography Pathology Codes (6030)</uid>
    <uid uid=\"1.2.840.10008.6.1.361\" keyword=\"BenignPathologyCodesFromBIRADS6031\" type=\"Context Group Name\">Benign Pathology Codes from BI-RADS® (6031)</uid>
    <uid uid=\"1.2.840.10008.6.1.362\" keyword=\"HighRiskLesionsPathologyCodesFromBIRADS6032\" type=\"Context Group Name\">High Risk Lesions Pathology Codes from BI-RADS® (6032)</uid>
    <uid uid=\"1.2.840.10008.6.1.363\" keyword=\"MalignantPathologyCodesFromBIRADS6033\" type=\"Context Group Name\">Malignant Pathology Codes from BI-RADS® (6033)</uid>
    <uid uid=\"1.2.840.10008.6.1.364\" keyword=\"IntendedUseOfCADOutput6034\" type=\"Context Group Name\">Intended Use of CAD Output (6034)</uid>
    <uid uid=\"1.2.840.10008.6.1.365\" keyword=\"CompositeFeatureRelations6035\" type=\"Context Group Name\">Composite Feature Relations (6035)</uid>
    <uid uid=\"1.2.840.10008.6.1.366\" keyword=\"ScopeOfFeature6036\" type=\"Context Group Name\">Scope of Feature (6036)</uid>
    <uid uid=\"1.2.840.10008.6.1.367\" keyword=\"MammographyQuantitativeTemporalDifferenceType6037\" type=\"Context Group Name\">Mammography Quantitative Temporal Difference Type (6037)</uid>
    <uid uid=\"1.2.840.10008.6.1.368\" keyword=\"MammographyQualitativeTemporalDifferenceType6038\" type=\"Context Group Name\">Mammography Qualitative Temporal Difference Type (6038)</uid>
    <uid uid=\"1.2.840.10008.6.1.369\" keyword=\"NippleCharacteristic6039\" type=\"Context Group Name\">Nipple Characteristic (6039)</uid>
    <uid uid=\"1.2.840.10008.6.1.370\" keyword=\"NonLesionObjectType6040\" type=\"Context Group Name\">Non-lesion Object Type (6040)</uid>
    <uid uid=\"1.2.840.10008.6.1.371\" keyword=\"MammographyImageQualityFinding6041\" type=\"Context Group Name\">Mammography Image Quality Finding (6041)</uid>
    <uid uid=\"1.2.840.10008.6.1.372\" keyword=\"StatusOfResults6042\" type=\"Context Group Name\">Status of Results (6042)</uid>
    <uid uid=\"1.2.840.10008.6.1.373\" keyword=\"TypesOfMammographyCADAnalysis6043\" type=\"Context Group Name\">Types of Mammography CAD Analysis (6043)</uid>
    <uid uid=\"1.2.840.10008.6.1.374\" keyword=\"TypesOfImageQualityAssessment6044\" type=\"Context Group Name\">Types of Image Quality Assessment (6044)</uid>
    <uid uid=\"1.2.840.10008.6.1.375\" keyword=\"MammographyTypesOfQualityControlStandard6045\" type=\"Context Group Name\">Mammography Types of Quality Control Standard (6045)</uid>
    <uid uid=\"1.2.840.10008.6.1.376\" keyword=\"UnitsOfFollowUpInterval6046\" type=\"Context Group Name\">Units of Follow-up Interval (6046)</uid>
    <uid uid=\"1.2.840.10008.6.1.377\" keyword=\"CADProcessingAndFindingsSummary6047\" type=\"Context Group Name\">CAD Processing and Findings Summary (6047)</uid>
    <uid uid=\"1.2.840.10008.6.1.378\" keyword=\"CADOperatingPointAxisLabel6048\" type=\"Context Group Name\">CAD Operating Point Axis Label (6048)</uid>
    <uid uid=\"1.2.840.10008.6.1.379\" keyword=\"BreastProcedureReported6050\" type=\"Context Group Name\">Breast Procedure Reported (6050)</uid>
    <uid uid=\"1.2.840.10008.6.1.380\" keyword=\"BreastProcedureReason6051\" type=\"Context Group Name\">Breast Procedure Reason (6051)</uid>
    <uid uid=\"1.2.840.10008.6.1.381\" keyword=\"BreastImagingReportSectionTitle6052\" type=\"Context Group Name\">Breast Imaging Report Section Title (6052)</uid>
    <uid uid=\"1.2.840.10008.6.1.382\" keyword=\"BreastImagingReportElements6053\" type=\"Context Group Name\">Breast Imaging Report Elements (6053)</uid>
    <uid uid=\"1.2.840.10008.6.1.383\" keyword=\"BreastImagingFindings6054\" type=\"Context Group Name\">Breast Imaging Findings (6054)</uid>
    <uid uid=\"1.2.840.10008.6.1.384\" keyword=\"BreastClinicalFindingOrIndicatedProblem6055\" type=\"Context Group Name\">Breast Clinical Finding or Indicated Problem (6055)</uid>
    <uid uid=\"1.2.840.10008.6.1.385\" keyword=\"AssociatedFindingsForBreast6056\" type=\"Context Group Name\">Associated Findings for Breast (6056)</uid>
    <uid uid=\"1.2.840.10008.6.1.386\" keyword=\"DuctographyFindingsForBreast6057\" type=\"Context Group Name\">Ductography Findings for Breast (6057)</uid>
    <uid uid=\"1.2.840.10008.6.1.387\" keyword=\"ProcedureModifiersForBreast6058\" type=\"Context Group Name\">Procedure Modifiers for Breast (6058)</uid>
    <uid uid=\"1.2.840.10008.6.1.388\" keyword=\"BreastImplantTypes6059\" type=\"Context Group Name\">Breast Implant Types (6059)</uid>
    <uid uid=\"1.2.840.10008.6.1.389\" keyword=\"BreastBiopsyTechniques6060\" type=\"Context Group Name\">Breast Biopsy Techniques (6060)</uid>
    <uid uid=\"1.2.840.10008.6.1.390\" keyword=\"BreastImagingProcedureModifiers6061\" type=\"Context Group Name\">Breast Imaging Procedure Modifiers (6061)</uid>
    <uid uid=\"1.2.840.10008.6.1.391\" keyword=\"InterventionalProcedureComplications6062\" type=\"Context Group Name\">Interventional Procedure Complications (6062)</uid>
    <uid uid=\"1.2.840.10008.6.1.392\" keyword=\"InterventionalProcedureResults6063\" type=\"Context Group Name\">Interventional Procedure Results (6063)</uid>
    <uid uid=\"1.2.840.10008.6.1.393\" keyword=\"UltrasoundFindingsForBreast6064\" type=\"Context Group Name\">Ultrasound Findings for Breast (6064)</uid>
    <uid uid=\"1.2.840.10008.6.1.394\" keyword=\"InstrumentApproach6065\" type=\"Context Group Name\">Instrument Approach (6065)</uid>
    <uid uid=\"1.2.840.10008.6.1.395\" keyword=\"TargetConfirmation6066\" type=\"Context Group Name\">Target Confirmation (6066)</uid>
    <uid uid=\"1.2.840.10008.6.1.396\" keyword=\"FluidColor6067\" type=\"Context Group Name\">Fluid Color (6067)</uid>
    <uid uid=\"1.2.840.10008.6.1.397\" keyword=\"TumorStagesFromAJCC6068\" type=\"Context Group Name\">Tumor Stages From AJCC (6068)</uid>
    <uid uid=\"1.2.840.10008.6.1.398\" keyword=\"NottinghamCombinedHistologicGrade6069\" type=\"Context Group Name\">Nottingham Combined Histologic Grade (6069)</uid>
    <uid uid=\"1.2.840.10008.6.1.399\" keyword=\"BloomRichardsonHistologicGrade6070\" type=\"Context Group Name\">Bloom-Richardson Histologic Grade (6070)</uid>
    <uid uid=\"1.2.840.10008.6.1.400\" keyword=\"HistologicGradingMethod6071\" type=\"Context Group Name\">Histologic Grading Method (6071)</uid>
    <uid uid=\"1.2.840.10008.6.1.401\" keyword=\"BreastImplantFindings6072\" type=\"Context Group Name\">Breast Implant Findings (6072)</uid>
    <uid uid=\"1.2.840.10008.6.1.402\" keyword=\"GynecologicalHormones6080\" type=\"Context Group Name\">Gynecological Hormones (6080)</uid>
    <uid uid=\"1.2.840.10008.6.1.403\" keyword=\"BreastCancerRiskFactors6081\" type=\"Context Group Name\">Breast Cancer Risk Factors (6081)</uid>
    <uid uid=\"1.2.840.10008.6.1.404\" keyword=\"GynecologicalProcedures6082\" type=\"Context Group Name\">Gynecological Procedures (6082)</uid>
    <uid uid=\"1.2.840.10008.6.1.405\" keyword=\"ProceduresForBreast6083\" type=\"Context Group Name\">Procedures for Breast (6083)</uid>
    <uid uid=\"1.2.840.10008.6.1.406\" keyword=\"MammoplastyProcedures6084\" type=\"Context Group Name\">Mammoplasty Procedures (6084)</uid>
    <uid uid=\"1.2.840.10008.6.1.407\" keyword=\"TherapiesForBreast6085\" type=\"Context Group Name\">Therapies for Breast (6085)</uid>
    <uid uid=\"1.2.840.10008.6.1.408\" keyword=\"MenopausalPhase6086\" type=\"Context Group Name\">Menopausal Phase (6086)</uid>
    <uid uid=\"1.2.840.10008.6.1.409\" keyword=\"GeneralRiskFactors6087\" type=\"Context Group Name\">General Risk Factors (6087)</uid>
    <uid uid=\"1.2.840.10008.6.1.410\" keyword=\"OBGYNMaternalRiskFactors6088\" type=\"Context Group Name\">OB-GYN Maternal Risk Factors (6088)</uid>
    <uid uid=\"1.2.840.10008.6.1.411\" keyword=\"Substances6089\" type=\"Context Group Name\">Substances (6089)</uid>
    <uid uid=\"1.2.840.10008.6.1.412\" keyword=\"RelativeUsageExposureAmount6090\" type=\"Context Group Name\">Relative Usage, Exposure Amount (6090)</uid>
    <uid uid=\"1.2.840.10008.6.1.413\" keyword=\"RelativeFrequencyOfEventValues6091\" type=\"Context Group Name\">Relative Frequency of Event Values (6091)</uid>
    <uid uid=\"1.2.840.10008.6.1.414\" keyword=\"QuantitativeConceptsForUsageExposure6092\" type=\"Context Group Name\">Quantitative Concepts for Usage, Exposure (6092)</uid>
    <uid uid=\"1.2.840.10008.6.1.415\" keyword=\"QualitativeConceptsForUsageExposureAmount6093\" type=\"Context Group Name\">Qualitative Concepts for Usage, Exposure Amount (6093)</uid>
    <uid uid=\"1.2.840.10008.6.1.416\" keyword=\"QualitativeConceptsForUsageExposureFrequency6094\" type=\"Context Group Name\">Qualitative Concepts for Usage, Exposure Frequency (6094)</uid>
    <uid uid=\"1.2.840.10008.6.1.417\" keyword=\"NumericPropertiesOfProcedures6095\" type=\"Context Group Name\">Numeric Properties of Procedures (6095)</uid>
    <uid uid=\"1.2.840.10008.6.1.418\" keyword=\"PregnancyStatus6096\" type=\"Context Group Name\">Pregnancy Status (6096)</uid>
    <uid uid=\"1.2.840.10008.6.1.419\" keyword=\"SideOfFamily6097\" type=\"Context Group Name\">Side of Family (6097)</uid>
    <uid uid=\"1.2.840.10008.6.1.420\" keyword=\"ChestComponentCategories6100\" type=\"Context Group Name\">Chest Component Categories (6100)</uid>
    <uid uid=\"1.2.840.10008.6.1.421\" keyword=\"ChestFindingOrFeature6101\" type=\"Context Group Name\">Chest Finding or Feature (6101)</uid>
    <uid uid=\"1.2.840.10008.6.1.422\" keyword=\"ChestFindingOrFeatureModifier6102\" type=\"Context Group Name\">Chest Finding or Feature Modifier (6102)</uid>
    <uid uid=\"1.2.840.10008.6.1.423\" keyword=\"AbnormalLinesFindingOrFeature6103\" type=\"Context Group Name\">Abnormal Lines Finding or Feature (6103)</uid>
    <uid uid=\"1.2.840.10008.6.1.424\" keyword=\"AbnormalOpacityFindingOrFeature6104\" type=\"Context Group Name\">Abnormal Opacity Finding or Feature (6104)</uid>
    <uid uid=\"1.2.840.10008.6.1.425\" keyword=\"AbnormalLucencyFindingOrFeature6105\" type=\"Context Group Name\">Abnormal Lucency Finding or Feature (6105)</uid>
    <uid uid=\"1.2.840.10008.6.1.426\" keyword=\"AbnormalTextureFindingOrFeature6106\" type=\"Context Group Name\">Abnormal Texture Finding or Feature (6106)</uid>
    <uid uid=\"1.2.840.10008.6.1.427\" keyword=\"WidthDescriptor6107\" type=\"Context Group Name\">Width Descriptor (6107)</uid>
    <uid uid=\"1.2.840.10008.6.1.428\" keyword=\"ChestAnatomicStructureAbnormalDistribution6108\" type=\"Context Group Name\">Chest Anatomic Structure Abnormal Distribution (6108)</uid>
    <uid uid=\"1.2.840.10008.6.1.429\" keyword=\"RadiographicAnatomyFindingOrFeature6109\" type=\"Context Group Name\">Radiographic Anatomy Finding or Feature (6109)</uid>
    <uid uid=\"1.2.840.10008.6.1.430\" keyword=\"LungAnatomyFindingOrFeature6110\" type=\"Context Group Name\">Lung Anatomy Finding or Feature (6110)</uid>
    <uid uid=\"1.2.840.10008.6.1.431\" keyword=\"BronchovascularAnatomyFindingOrFeature6111\" type=\"Context Group Name\">Bronchovascular Anatomy Finding or Feature (6111)</uid>
    <uid uid=\"1.2.840.10008.6.1.432\" keyword=\"PleuraAnatomyFindingOrFeature6112\" type=\"Context Group Name\">Pleura Anatomy Finding or Feature (6112)</uid>
    <uid uid=\"1.2.840.10008.6.1.433\" keyword=\"MediastinumAnatomyFindingOrFeature6113\" type=\"Context Group Name\">Mediastinum Anatomy Finding or Feature (6113)</uid>
    <uid uid=\"1.2.840.10008.6.1.434\" keyword=\"OsseousAnatomyFindingOrFeature6114\" type=\"Context Group Name\">Osseous Anatomy Finding or Feature (6114)</uid>
    <uid uid=\"1.2.840.10008.6.1.435\" keyword=\"OsseousAnatomyModifiers6115\" type=\"Context Group Name\">Osseous Anatomy Modifiers (6115)</uid>
    <uid uid=\"1.2.840.10008.6.1.436\" keyword=\"MuscularAnatomy6116\" type=\"Context Group Name\">Muscular Anatomy (6116)</uid>
    <uid uid=\"1.2.840.10008.6.1.437\" keyword=\"VascularAnatomy6117\" type=\"Context Group Name\">Vascular Anatomy (6117)</uid>
    <uid uid=\"1.2.840.10008.6.1.438\" keyword=\"SizeDescriptor6118\" type=\"Context Group Name\">Size Descriptor (6118)</uid>
    <uid uid=\"1.2.840.10008.6.1.439\" keyword=\"ChestBorderShape6119\" type=\"Context Group Name\">Chest Border Shape (6119)</uid>
    <uid uid=\"1.2.840.10008.6.1.440\" keyword=\"ChestBorderDefinition6120\" type=\"Context Group Name\">Chest Border Definition (6120)</uid>
    <uid uid=\"1.2.840.10008.6.1.441\" keyword=\"ChestOrientationDescriptor6121\" type=\"Context Group Name\">Chest Orientation Descriptor (6121)</uid>
    <uid uid=\"1.2.840.10008.6.1.442\" keyword=\"ChestContentDescriptor6122\" type=\"Context Group Name\">Chest Content Descriptor (6122)</uid>
    <uid uid=\"1.2.840.10008.6.1.443\" keyword=\"ChestOpacityDescriptor6123\" type=\"Context Group Name\">Chest Opacity Descriptor (6123)</uid>
    <uid uid=\"1.2.840.10008.6.1.444\" keyword=\"LocationInChest6124\" type=\"Context Group Name\">Location in Chest (6124)</uid>
    <uid uid=\"1.2.840.10008.6.1.445\" keyword=\"GeneralChestLocation6125\" type=\"Context Group Name\">General Chest Location (6125)</uid>
    <uid uid=\"1.2.840.10008.6.1.446\" keyword=\"LocationInLung6126\" type=\"Context Group Name\">Location in Lung (6126)</uid>
    <uid uid=\"1.2.840.10008.6.1.447\" keyword=\"SegmentLocationInLung6127\" type=\"Context Group Name\">Segment Location in Lung (6127)</uid>
    <uid uid=\"1.2.840.10008.6.1.448\" keyword=\"ChestDistributionDescriptor6128\" type=\"Context Group Name\">Chest Distribution Descriptor (6128)</uid>
    <uid uid=\"1.2.840.10008.6.1.449\" keyword=\"ChestSiteInvolvement6129\" type=\"Context Group Name\">Chest Site Involvement (6129)</uid>
    <uid uid=\"1.2.840.10008.6.1.450\" keyword=\"SeverityDescriptor6130\" type=\"Context Group Name\">Severity Descriptor (6130)</uid>
    <uid uid=\"1.2.840.10008.6.1.451\" keyword=\"ChestTextureDescriptor6131\" type=\"Context Group Name\">Chest Texture Descriptor (6131)</uid>
    <uid uid=\"1.2.840.10008.6.1.452\" keyword=\"ChestCalcificationDescriptor6132\" type=\"Context Group Name\">Chest Calcification Descriptor (6132)</uid>
    <uid uid=\"1.2.840.10008.6.1.453\" keyword=\"ChestQuantitativeTemporalDifferenceType6133\" type=\"Context Group Name\">Chest Quantitative Temporal Difference Type (6133)</uid>
    <uid uid=\"1.2.840.10008.6.1.454\" keyword=\"ChestQualitativeTemporalDifferenceType6134\" type=\"Context Group Name\">Chest Qualitative Temporal Difference Type (6134)</uid>
    <uid uid=\"1.2.840.10008.6.1.455\" keyword=\"ImageQualityFinding6135\" type=\"Context Group Name\">Image Quality Finding (6135)</uid>
    <uid uid=\"1.2.840.10008.6.1.456\" keyword=\"ChestTypesOfQualityControlStandard6136\" type=\"Context Group Name\">Chest Types of Quality Control Standard (6136)</uid>
    <uid uid=\"1.2.840.10008.6.1.457\" keyword=\"TypesOfCADAnalysis6137\" type=\"Context Group Name\">Types of CAD Analysis (6137)</uid>
    <uid uid=\"1.2.840.10008.6.1.458\" keyword=\"ChestNonLesionObjectType6138\" type=\"Context Group Name\">Chest Non-lesion Object Type (6138)</uid>
    <uid uid=\"1.2.840.10008.6.1.459\" keyword=\"NonLesionModifiers6139\" type=\"Context Group Name\">Non-lesion Modifiers (6139)</uid>
    <uid uid=\"1.2.840.10008.6.1.460\" keyword=\"CalculationMethods6140\" type=\"Context Group Name\">Calculation Methods (6140)</uid>
    <uid uid=\"1.2.840.10008.6.1.461\" keyword=\"AttenuationCoefficientMeasurements6141\" type=\"Context Group Name\">Attenuation Coefficient Measurements (6141)</uid>
    <uid uid=\"1.2.840.10008.6.1.462\" keyword=\"CalculatedValue6142\" type=\"Context Group Name\">Calculated Value (6142)</uid>
    <uid uid=\"1.2.840.10008.6.1.463\" keyword=\"LesionResponse6143\" type=\"Context Group Name\">Lesion Response (6143)</uid>
    <uid uid=\"1.2.840.10008.6.1.464\" keyword=\"RECISTDefinedLesionResponse6144\" type=\"Context Group Name\">RECIST Defined Lesion Response (6144)</uid>
    <uid uid=\"1.2.840.10008.6.1.465\" keyword=\"BaselineCategory6145\" type=\"Context Group Name\">Baseline Category (6145)</uid>
    <uid uid=\"1.2.840.10008.6.1.466\" keyword=\"BackgroundEchotexture6151\" type=\"Context Group Name\">Background Echotexture (6151)</uid>
    <uid uid=\"1.2.840.10008.6.1.467\" keyword=\"Orientation6152\" type=\"Context Group Name\">Orientation (6152)</uid>
    <uid uid=\"1.2.840.10008.6.1.468\" keyword=\"LesionBoundary6153\" type=\"Context Group Name\">Lesion Boundary (6153)</uid>
    <uid uid=\"1.2.840.10008.6.1.469\" keyword=\"EchoPattern6154\" type=\"Context Group Name\">Echo Pattern (6154)</uid>
    <uid uid=\"1.2.840.10008.6.1.470\" keyword=\"PosteriorAcousticFeatures6155\" type=\"Context Group Name\">Posterior Acoustic Features (6155)</uid>
    <uid uid=\"1.2.840.10008.6.1.471\" keyword=\"Vascularity6157\" type=\"Context Group Name\">Vascularity (6157)</uid>
    <uid uid=\"1.2.840.10008.6.1.472\" keyword=\"CorrelationToOtherFindings6158\" type=\"Context Group Name\">Correlation to Other Findings (6158)</uid>
    <uid uid=\"1.2.840.10008.6.1.473\" keyword=\"MalignancyType6159\" type=\"Context Group Name\">Malignancy Type (6159)</uid>
    <uid uid=\"1.2.840.10008.6.1.474\" keyword=\"BreastPrimaryTumorAssessmentFromAJCC6160\" type=\"Context Group Name\">Breast Primary Tumor Assessment From AJCC (6160)</uid>
    <uid uid=\"1.2.840.10008.6.1.475\" keyword=\"ClinicalRegionalLymphNodeAssessmentForBreast6161\" type=\"Context Group Name\">Clinical Regional Lymph Node Assessment for Breast (6161)</uid>
    <uid uid=\"1.2.840.10008.6.1.476\" keyword=\"AssessmentOfMetastasisForBreast6162\" type=\"Context Group Name\">Assessment of Metastasis for Breast (6162)</uid>
    <uid uid=\"1.2.840.10008.6.1.477\" keyword=\"MenstrualCyclePhase6163\" type=\"Context Group Name\">Menstrual Cycle Phase (6163)</uid>
    <uid uid=\"1.2.840.10008.6.1.478\" keyword=\"TimeIntervals6164\" type=\"Context Group Name\">Time Intervals (6164)</uid>
    <uid uid=\"1.2.840.10008.6.1.479\" keyword=\"BreastLinearMeasurements6165\" type=\"Context Group Name\">Breast Linear Measurements (6165)</uid>
    <uid uid=\"1.2.840.10008.6.1.480\" keyword=\"CADGeometrySecondaryGraphicalRepresentation6166\" type=\"Context Group Name\">CAD Geometry Secondary Graphical Representation (6166)</uid>
    <uid uid=\"1.2.840.10008.6.1.481\" keyword=\"DiagnosticImagingReportDocumentTitles7000\" type=\"Context Group Name\">Diagnostic Imaging Report Document Titles (7000)</uid>
    <uid uid=\"1.2.840.10008.6.1.482\" keyword=\"DiagnosticImagingReportHeadings7001\" type=\"Context Group Name\">Diagnostic Imaging Report Headings (7001)</uid>
    <uid uid=\"1.2.840.10008.6.1.483\" keyword=\"DiagnosticImagingReportElements7002\" type=\"Context Group Name\">Diagnostic Imaging Report Elements (7002)</uid>
    <uid uid=\"1.2.840.10008.6.1.484\" keyword=\"DiagnosticImagingReportPurposesOfReference7003\" type=\"Context Group Name\">Diagnostic Imaging Report Purposes of Reference (7003)</uid>
    <uid uid=\"1.2.840.10008.6.1.485\" keyword=\"WaveformPurposesOfReference7004\" type=\"Context Group Name\">Waveform Purposes of Reference (7004)</uid>
    <uid uid=\"1.2.840.10008.6.1.486\" keyword=\"ContributingEquipmentPurposesOfReference7005\" type=\"Context Group Name\">Contributing Equipment Purposes of Reference (7005)</uid>
    <uid uid=\"1.2.840.10008.6.1.487\" keyword=\"SRDocumentPurposesOfReference7006\" type=\"Context Group Name\">SR Document Purposes of Reference (7006)</uid>
    <uid uid=\"1.2.840.10008.6.1.488\" keyword=\"SignaturePurpose7007\" type=\"Context Group Name\">Signature Purpose (7007)</uid>
    <uid uid=\"1.2.840.10008.6.1.489\" keyword=\"MediaImport7008\" type=\"Context Group Name\">Media Import (7008)</uid>
    <uid uid=\"1.2.840.10008.6.1.490\" keyword=\"KeyObjectSelectionDocumentTitle7010\" type=\"Context Group Name\">Key Object Selection Document Title (7010)</uid>
    <uid uid=\"1.2.840.10008.6.1.491\" keyword=\"RejectedForQualityReasons7011\" type=\"Context Group Name\">Rejected for Quality Reasons (7011)</uid>
    <uid uid=\"1.2.840.10008.6.1.492\" keyword=\"BestInSet7012\" type=\"Context Group Name\">Best in Set (7012)</uid>
    <uid uid=\"1.2.840.10008.6.1.493\" keyword=\"DocumentTitles7020\" type=\"Context Group Name\">Document Titles (7020)</uid>
    <uid uid=\"1.2.840.10008.6.1.494\" keyword=\"RCSRegistrationMethodType7100\" type=\"Context Group Name\">RCS Registration Method Type (7100)</uid>
    <uid uid=\"1.2.840.10008.6.1.495\" keyword=\"BrainAtlasFiducials7101\" type=\"Context Group Name\">Brain Atlas Fiducials (7101)</uid>
    <uid uid=\"1.2.840.10008.6.1.496\" keyword=\"SegmentationPropertyCategories7150\" type=\"Context Group Name\">Segmentation Property Categories (7150)</uid>
    <uid uid=\"1.2.840.10008.6.1.497\" keyword=\"SegmentationPropertyTypes7151\" type=\"Context Group Name\">Segmentation Property Types (7151)</uid>
    <uid uid=\"1.2.840.10008.6.1.498\" keyword=\"CardiacStructureSegmentationTypes7152\" type=\"Context Group Name\">Cardiac Structure Segmentation Types (7152)</uid>
    <uid uid=\"1.2.840.10008.6.1.499\" keyword=\"CNSTissueSegmentationTypes7153\" type=\"Context Group Name\">CNS Tissue Segmentation Types (7153)</uid>
    <uid uid=\"1.2.840.10008.6.1.500\" keyword=\"AbdominalOrganSegmentationTypes7154\" type=\"Context Group Name\">Abdominal Organ Segmentation Types (7154)</uid>
    <uid uid=\"1.2.840.10008.6.1.501\" keyword=\"ThoracicTissueSegmentationTypes7155\" type=\"Context Group Name\">Thoracic Tissue Segmentation Types (7155)</uid>
    <uid uid=\"1.2.840.10008.6.1.502\" keyword=\"VascularTissueSegmentationTypes7156\" type=\"Context Group Name\">Vascular Tissue Segmentation Types (7156)</uid>
    <uid uid=\"1.2.840.10008.6.1.503\" keyword=\"DeviceSegmentationTypes7157\" type=\"Context Group Name\">Device Segmentation Types (7157)</uid>
    <uid uid=\"1.2.840.10008.6.1.504\" keyword=\"ArtifactSegmentationTypes7158\" type=\"Context Group Name\">Artifact Segmentation Types (7158)</uid>
    <uid uid=\"1.2.840.10008.6.1.505\" keyword=\"LesionSegmentationTypes7159\" type=\"Context Group Name\">Lesion Segmentation Types (7159)</uid>
    <uid uid=\"1.2.840.10008.6.1.506\" keyword=\"PelvicOrganSegmentationTypes7160\" type=\"Context Group Name\">Pelvic Organ Segmentation Types (7160)</uid>
    <uid uid=\"1.2.840.10008.6.1.507\" keyword=\"PhysiologySegmentationTypes7161\" type=\"Context Group Name\">Physiology Segmentation Types (7161)</uid>
    <uid uid=\"1.2.840.10008.6.1.508\" keyword=\"ReferencedImagePurposesOfReference7201\" type=\"Context Group Name\">Referenced Image Purposes of Reference (7201)</uid>
    <uid uid=\"1.2.840.10008.6.1.509\" keyword=\"SourceImagePurposesOfReference7202\" type=\"Context Group Name\">Source Image Purposes of Reference (7202)</uid>
    <uid uid=\"1.2.840.10008.6.1.510\" keyword=\"ImageDerivation7203\" type=\"Context Group Name\">Image Derivation (7203)</uid>
    <uid uid=\"1.2.840.10008.6.1.511\" keyword=\"PurposeOfReferenceToAlternateRepresentation7205\" type=\"Context Group Name\">Purpose of Reference to Alternate Representation (7205)</uid>
    <uid uid=\"1.2.840.10008.6.1.512\" keyword=\"RelatedSeriesPurposesOfReference7210\" type=\"Context Group Name\">Related Series Purposes of Reference (7210)</uid>
    <uid uid=\"1.2.840.10008.6.1.513\" keyword=\"MultiFrameSubsetType7250\" type=\"Context Group Name\">Multi-Frame Subset Type (7250)</uid>
    <uid uid=\"1.2.840.10008.6.1.514\" keyword=\"PersonRoles7450\" type=\"Context Group Name\">Person Roles (7450)</uid>
    <uid uid=\"1.2.840.10008.6.1.515\" keyword=\"FamilyMember7451\" type=\"Context Group Name\">Family Member (7451)</uid>
    <uid uid=\"1.2.840.10008.6.1.516\" keyword=\"OrganizationalRoles7452\" type=\"Context Group Name\">Organizational Roles (7452)</uid>
    <uid uid=\"1.2.840.10008.6.1.517\" keyword=\"PerformingRoles7453\" type=\"Context Group Name\">Performing Roles (7453)</uid>
    <uid uid=\"1.2.840.10008.6.1.518\" keyword=\"AnimalTaxonomicRankValues7454\" type=\"Context Group Name\">Animal Taxonomic Rank Values (7454)</uid>
    <uid uid=\"1.2.840.10008.6.1.519\" keyword=\"Sex7455\" type=\"Context Group Name\">Sex (7455)</uid>
    <uid uid=\"1.2.840.10008.6.1.520\" keyword=\"UnitsOfMeasureForAge7456\" type=\"Context Group Name\">Units of Measure for Age (7456)</uid>
    <uid uid=\"1.2.840.10008.6.1.521\" keyword=\"UnitsOfLinearMeasurement7460\" type=\"Context Group Name\">Units of Linear Measurement (7460)</uid>
    <uid uid=\"1.2.840.10008.6.1.522\" keyword=\"UnitsOfAreaMeasurement7461\" type=\"Context Group Name\">Units of Area Measurement (7461)</uid>
    <uid uid=\"1.2.840.10008.6.1.523\" keyword=\"UnitsOfVolumeMeasurement7462\" type=\"Context Group Name\">Units of Volume Measurement (7462)</uid>
    <uid uid=\"1.2.840.10008.6.1.524\" keyword=\"LinearMeasurements7470\" type=\"Context Group Name\">Linear Measurements (7470)</uid>
    <uid uid=\"1.2.840.10008.6.1.525\" keyword=\"AreaMeasurements7471\" type=\"Context Group Name\">Area Measurements (7471)</uid>
    <uid uid=\"1.2.840.10008.6.1.526\" keyword=\"VolumeMeasurements7472\" type=\"Context Group Name\">Volume Measurements (7472)</uid>
    <uid uid=\"1.2.840.10008.6.1.527\" keyword=\"GeneralAreaCalculationMethods7473\" type=\"Context Group Name\">General Area Calculation Methods (7473)</uid>
    <uid uid=\"1.2.840.10008.6.1.528\" keyword=\"GeneralVolumeCalculationMethods7474\" type=\"Context Group Name\">General Volume Calculation Methods (7474)</uid>
    <uid uid=\"1.2.840.10008.6.1.529\" keyword=\"Breed7480\" type=\"Context Group Name\">Breed (7480)</uid>
    <uid uid=\"1.2.840.10008.6.1.530\" keyword=\"BreedRegistry7481\" type=\"Context Group Name\">Breed Registry (7481)</uid>
    <uid uid=\"1.2.840.10008.6.1.531\" keyword=\"WorkitemDefinition9231\" type=\"Context Group Name\">Workitem Definition (9231)</uid>
    <uid uid=\"1.2.840.10008.6.1.532\" keyword=\"NonDICOMOutputTypes9232\" type=\"Context Group Name\" retired=\"true\">Non-DICOM Output Types (Retired) (9232)</uid>
    <uid uid=\"1.2.840.10008.6.1.533\" keyword=\"ProcedureDiscontinuationReasons9300\" type=\"Context Group Name\">Procedure Discontinuation Reasons (9300)</uid>
    <uid uid=\"1.2.840.10008.6.1.534\" keyword=\"ScopeOfAccumulation10000\" type=\"Context Group Name\">Scope of Accumulation (10000)</uid>
    <uid uid=\"1.2.840.10008.6.1.535\" keyword=\"UIDTypes10001\" type=\"Context Group Name\">UID Types (10001)</uid>
    <uid uid=\"1.2.840.10008.6.1.536\" keyword=\"IrradiationEventTypes10002\" type=\"Context Group Name\">Irradiation Event Types (10002)</uid>
    <uid uid=\"1.2.840.10008.6.1.537\" keyword=\"EquipmentPlaneIdentification10003\" type=\"Context Group Name\">Equipment Plane Identification (10003)</uid>
    <uid uid=\"1.2.840.10008.6.1.538\" keyword=\"FluoroModes10004\" type=\"Context Group Name\">Fluoro Modes (10004)</uid>
    <uid uid=\"1.2.840.10008.6.1.539\" keyword=\"XRayFilterMaterials10006\" type=\"Context Group Name\">X-Ray Filter Materials (10006)</uid>
    <uid uid=\"1.2.840.10008.6.1.540\" keyword=\"XRayFilterTypes10007\" type=\"Context Group Name\">X-Ray Filter Types (10007)</uid>
    <uid uid=\"1.2.840.10008.6.1.541\" keyword=\"DoseRelatedDistanceMeasurements10008\" type=\"Context Group Name\">Dose Related Distance Measurements (10008)</uid>
    <uid uid=\"1.2.840.10008.6.1.542\" keyword=\"MeasuredCalculated10009\" type=\"Context Group Name\">Measured/Calculated (10009)</uid>
    <uid uid=\"1.2.840.10008.6.1.543\" keyword=\"DoseMeasurementDevices10010\" type=\"Context Group Name\">Dose Measurement Devices (10010)</uid>
    <uid uid=\"1.2.840.10008.6.1.544\" keyword=\"EffectiveDoseEvaluationMethod10011\" type=\"Context Group Name\">Effective Dose Evaluation Method (10011)</uid>
    <uid uid=\"1.2.840.10008.6.1.545\" keyword=\"CTAcquisitionType10013\" type=\"Context Group Name\">CT Acquisition Type (10013)</uid>
    <uid uid=\"1.2.840.10008.6.1.546\" keyword=\"ContrastImagingTechnique10014\" type=\"Context Group Name\">Contrast Imaging Technique (10014)</uid>
    <uid uid=\"1.2.840.10008.6.1.547\" keyword=\"CTDoseReferenceAuthorities10015\" type=\"Context Group Name\">CT Dose Reference Authorities (10015)</uid>
    <uid uid=\"1.2.840.10008.6.1.548\" keyword=\"AnodeTargetMaterial10016\" type=\"Context Group Name\">Anode Target Material (10016)</uid>
    <uid uid=\"1.2.840.10008.6.1.549\" keyword=\"XRayGrid10017\" type=\"Context Group Name\">X-Ray Grid (10017)</uid>
    <uid uid=\"1.2.840.10008.6.1.550\" keyword=\"UltrasoundProtocolTypes12001\" type=\"Context Group Name\">Ultrasound Protocol Types (12001)</uid>
    <uid uid=\"1.2.840.10008.6.1.551\" keyword=\"UltrasoundProtocolStageTypes12002\" type=\"Context Group Name\">Ultrasound Protocol Stage Types (12002)</uid>
    <uid uid=\"1.2.840.10008.6.1.552\" keyword=\"OBGYNDates12003\" type=\"Context Group Name\">OB-GYN Dates (12003)</uid>
    <uid uid=\"1.2.840.10008.6.1.553\" keyword=\"FetalBiometryRatios12004\" type=\"Context Group Name\">Fetal Biometry Ratios (12004)</uid>
    <uid uid=\"1.2.840.10008.6.1.554\" keyword=\"FetalBiometryMeasurements12005\" type=\"Context Group Name\">Fetal Biometry Measurements (12005)</uid>
    <uid uid=\"1.2.840.10008.6.1.555\" keyword=\"FetalLongBonesBiometryMeasurements12006\" type=\"Context Group Name\">Fetal Long Bones Biometry Measurements (12006)</uid>
    <uid uid=\"1.2.840.10008.6.1.556\" keyword=\"FetalCranium12007\" type=\"Context Group Name\">Fetal Cranium (12007)</uid>
    <uid uid=\"1.2.840.10008.6.1.557\" keyword=\"OBGYNAmnioticSac12008\" type=\"Context Group Name\">OB-GYN Amniotic Sac (12008)</uid>
    <uid uid=\"1.2.840.10008.6.1.558\" keyword=\"EarlyGestationBiometryMeasurements12009\" type=\"Context Group Name\">Early Gestation Biometry Measurements (12009)</uid>
    <uid uid=\"1.2.840.10008.6.1.559\" keyword=\"UltrasoundPelvisAndUterus12011\" type=\"Context Group Name\">Ultrasound Pelvis and Uterus (12011)</uid>
    <uid uid=\"1.2.840.10008.6.1.560\" keyword=\"OBEquationsAndTables12012\" type=\"Context Group Name\">OB Equations and Tables (12012)</uid>
    <uid uid=\"1.2.840.10008.6.1.561\" keyword=\"GestationalAgeEquationsAndTables12013\" type=\"Context Group Name\">Gestational Age Equations and Tables (12013)</uid>
    <uid uid=\"1.2.840.10008.6.1.562\" keyword=\"OBFetalBodyWeightEquationsAndTables12014\" type=\"Context Group Name\">OB Fetal Body Weight Equations and Tables (12014)</uid>
    <uid uid=\"1.2.840.10008.6.1.563\" keyword=\"FetalGrowthEquationsAndTables12015\" type=\"Context Group Name\">Fetal Growth Equations and Tables (12015)</uid>
    <uid uid=\"1.2.840.10008.6.1.564\" keyword=\"EstimatedFetalWeightPercentileEquationsAndTables12016\" type=\"Context Group Name\">Estimated Fetal Weight Percentile Equations and Tables (12016)</uid>
    <uid uid=\"1.2.840.10008.6.1.565\" keyword=\"GrowthDistributionRank12017\" type=\"Context Group Name\">Growth Distribution Rank (12017)</uid>
    <uid uid=\"1.2.840.10008.6.1.566\" keyword=\"OBGYNSummary12018\" type=\"Context Group Name\">OB-GYN Summary (12018)</uid>
    <uid uid=\"1.2.840.10008.6.1.567\" keyword=\"OBGYNFetusSummary12019\" type=\"Context Group Name\">OB-GYN Fetus Summary (12019)</uid>
    <uid uid=\"1.2.840.10008.6.1.568\" keyword=\"VascularSummary12101\" type=\"Context Group Name\">Vascular Summary (12101)</uid>
    <uid uid=\"1.2.840.10008.6.1.569\" keyword=\"TemporalPeriodsRelatingToProcedureOrTherapy12102\" type=\"Context Group Name\">Temporal Periods Relating to Procedure or Therapy (12102)</uid>
    <uid uid=\"1.2.840.10008.6.1.570\" keyword=\"VascularUltrasoundAnatomicLocation12103\" type=\"Context Group Name\">Vascular Ultrasound Anatomic Location (12103)</uid>
    <uid uid=\"1.2.840.10008.6.1.571\" keyword=\"ExtracranialArteries12104\" type=\"Context Group Name\">Extracranial Arteries (12104)</uid>
    <uid uid=\"1.2.840.10008.6.1.572\" keyword=\"IntracranialCerebralVessels12105\" type=\"Context Group Name\">Intracranial Cerebral Vessels (12105)</uid>
    <uid uid=\"1.2.840.10008.6.1.573\" keyword=\"IntracranialCerebralVesselsUnilateral12106\" type=\"Context Group Name\">Intracranial Cerebral Vessels (Unilateral) (12106)</uid>
    <uid uid=\"1.2.840.10008.6.1.574\" keyword=\"UpperExtremityArteries12107\" type=\"Context Group Name\">Upper Extremity Arteries (12107)</uid>
    <uid uid=\"1.2.840.10008.6.1.575\" keyword=\"UpperExtremityVeins12108\" type=\"Context Group Name\">Upper Extremity Veins (12108)</uid>
    <uid uid=\"1.2.840.10008.6.1.576\" keyword=\"LowerExtremityArteries12109\" type=\"Context Group Name\">Lower Extremity Arteries (12109)</uid>
    <uid uid=\"1.2.840.10008.6.1.577\" keyword=\"LowerExtremityVeins12110\" type=\"Context Group Name\">Lower Extremity Veins (12110)</uid>
    <uid uid=\"1.2.840.10008.6.1.578\" keyword=\"AbdominalArteriesLateral12111\" type=\"Context Group Name\">Abdominal Arteries (Lateral) (12111)</uid>
    <uid uid=\"1.2.840.10008.6.1.579\" keyword=\"AbdominalArteriesUnilateral12112\" type=\"Context Group Name\">Abdominal Arteries (Unilateral) (12112)</uid>
    <uid uid=\"1.2.840.10008.6.1.580\" keyword=\"AbdominalVeinsLateral12113\" type=\"Context Group Name\">Abdominal Veins (Lateral) (12113)</uid>
    <uid uid=\"1.2.840.10008.6.1.581\" keyword=\"AbdominalVeinsUnilateral12114\" type=\"Context Group Name\">Abdominal Veins (Unilateral) (12114)</uid>
    <uid uid=\"1.2.840.10008.6.1.582\" keyword=\"RenalVessels12115\" type=\"Context Group Name\">Renal Vessels (12115)</uid>
    <uid uid=\"1.2.840.10008.6.1.583\" keyword=\"VesselSegmentModifiers12116\" type=\"Context Group Name\">Vessel Segment Modifiers (12116)</uid>
    <uid uid=\"1.2.840.10008.6.1.584\" keyword=\"VesselBranchModifiers12117\" type=\"Context Group Name\">Vessel Branch Modifiers (12117)</uid>
    <uid uid=\"1.2.840.10008.6.1.585\" keyword=\"VascularUltrasoundProperty12119\" type=\"Context Group Name\">Vascular Ultrasound Property (12119)</uid>
    <uid uid=\"1.2.840.10008.6.1.586\" keyword=\"BloodVelocityMeasurementsByUltrasound12120\" type=\"Context Group Name\">Blood Velocity Measurements by Ultrasound (12120)</uid>
    <uid uid=\"1.2.840.10008.6.1.587\" keyword=\"VascularIndicesAndRatios12121\" type=\"Context Group Name\">Vascular Indices and Ratios (12121)</uid>
    <uid uid=\"1.2.840.10008.6.1.588\" keyword=\"OtherVascularProperties12122\" type=\"Context Group Name\">Other Vascular Properties (12122)</uid>
    <uid uid=\"1.2.840.10008.6.1.589\" keyword=\"CarotidRatios12123\" type=\"Context Group Name\">Carotid Ratios (12123)</uid>
    <uid uid=\"1.2.840.10008.6.1.590\" keyword=\"RenalRatios12124\" type=\"Context Group Name\">Renal Ratios (12124)</uid>
    <uid uid=\"1.2.840.10008.6.1.591\" keyword=\"PelvicVasculatureAnatomicalLocation12140\" type=\"Context Group Name\">Pelvic Vasculature Anatomical Location (12140)</uid>
    <uid uid=\"1.2.840.10008.6.1.592\" keyword=\"FetalVasculatureAnatomicalLocation12141\" type=\"Context Group Name\">Fetal Vasculature Anatomical Location (12141)</uid>
    <uid uid=\"1.2.840.10008.6.1.593\" keyword=\"EchocardiographyLeftVentricle12200\" type=\"Context Group Name\">Echocardiography Left Ventricle (12200)</uid>
    <uid uid=\"1.2.840.10008.6.1.594\" keyword=\"LeftVentricleLinear12201\" type=\"Context Group Name\">Left Ventricle Linear (12201)</uid>
    <uid uid=\"1.2.840.10008.6.1.595\" keyword=\"LeftVentricleVolume12202\" type=\"Context Group Name\">Left Ventricle Volume (12202)</uid>
    <uid uid=\"1.2.840.10008.6.1.596\" keyword=\"LeftVentricleOther12203\" type=\"Context Group Name\">Left Ventricle Other (12203)</uid>
    <uid uid=\"1.2.840.10008.6.1.597\" keyword=\"EchocardiographyRightVentricle12204\" type=\"Context Group Name\">Echocardiography Right Ventricle (12204)</uid>
    <uid uid=\"1.2.840.10008.6.1.598\" keyword=\"EchocardiographyLeftAtrium12205\" type=\"Context Group Name\">Echocardiography Left Atrium (12205)</uid>
    <uid uid=\"1.2.840.10008.6.1.599\" keyword=\"EchocardiographyRightAtrium12206\" type=\"Context Group Name\">Echocardiography Right Atrium (12206)</uid>
    <uid uid=\"1.2.840.10008.6.1.600\" keyword=\"EchocardiographyMitralValve12207\" type=\"Context Group Name\">Echocardiography Mitral Valve (12207)</uid>
    <uid uid=\"1.2.840.10008.6.1.601\" keyword=\"EchocardiographyTricuspidValve12208\" type=\"Context Group Name\">Echocardiography Tricuspid Valve (12208)</uid>
    <uid uid=\"1.2.840.10008.6.1.602\" keyword=\"EchocardiographyPulmonicValve12209\" type=\"Context Group Name\">Echocardiography Pulmonic Valve (12209)</uid>
    <uid uid=\"1.2.840.10008.6.1.603\" keyword=\"EchocardiographyPulmonaryArtery12210\" type=\"Context Group Name\">Echocardiography Pulmonary Artery (12210)</uid>
    <uid uid=\"1.2.840.10008.6.1.604\" keyword=\"EchocardiographyAorticValve12211\" type=\"Context Group Name\">Echocardiography Aortic Valve (12211)</uid>
    <uid uid=\"1.2.840.10008.6.1.605\" keyword=\"EchocardiographyAorta12212\" type=\"Context Group Name\">Echocardiography Aorta (12212)</uid>
    <uid uid=\"1.2.840.10008.6.1.606\" keyword=\"EchocardiographyPulmonaryVeins12214\" type=\"Context Group Name\">Echocardiography Pulmonary Veins (12214)</uid>
    <uid uid=\"1.2.840.10008.6.1.607\" keyword=\"EchocardiographyVenaCavae12215\" type=\"Context Group Name\">Echocardiography Vena Cavae (12215)</uid>
    <uid uid=\"1.2.840.10008.6.1.608\" keyword=\"EchocardiographyHepaticVeins12216\" type=\"Context Group Name\">Echocardiography Hepatic Veins (12216)</uid>
    <uid uid=\"1.2.840.10008.6.1.609\" keyword=\"EchocardiographyCardiacShunt12217\" type=\"Context Group Name\">Echocardiography Cardiac Shunt (12217)</uid>
    <uid uid=\"1.2.840.10008.6.1.610\" keyword=\"EchocardiographyCongenital12218\" type=\"Context Group Name\">Echocardiography Congenital (12218)</uid>
    <uid uid=\"1.2.840.10008.6.1.611\" keyword=\"PulmonaryVeinModifiers12219\" type=\"Context Group Name\">Pulmonary Vein Modifiers (12219)</uid>
    <uid uid=\"1.2.840.10008.6.1.612\" keyword=\"EchocardiographyCommonMeasurements12220\" type=\"Context Group Name\">Echocardiography Common Measurements (12220)</uid>
    <uid uid=\"1.2.840.10008.6.1.613\" keyword=\"FlowDirection12221\" type=\"Context Group Name\">Flow Direction (12221)</uid>
    <uid uid=\"1.2.840.10008.6.1.614\" keyword=\"OrificeFlowProperties12222\" type=\"Context Group Name\">Orifice Flow Properties (12222)</uid>
    <uid uid=\"1.2.840.10008.6.1.615\" keyword=\"EchocardiographyStrokeVolumeOrigin12223\" type=\"Context Group Name\">Echocardiography Stroke Volume Origin (12223)</uid>
    <uid uid=\"1.2.840.10008.6.1.616\" keyword=\"UltrasoundImageModes12224\" type=\"Context Group Name\">Ultrasound Image Modes (12224)</uid>
    <uid uid=\"1.2.840.10008.6.1.617\" keyword=\"EchocardiographyImageView12226\" type=\"Context Group Name\">Echocardiography Image View (12226)</uid>
    <uid uid=\"1.2.840.10008.6.1.618\" keyword=\"EchocardiographyMeasurementMethod12227\" type=\"Context Group Name\">Echocardiography Measurement Method (12227)</uid>
    <uid uid=\"1.2.840.10008.6.1.619\" keyword=\"EchocardiographyVolumeMethods12228\" type=\"Context Group Name\">Echocardiography Volume Methods (12228)</uid>
    <uid uid=\"1.2.840.10008.6.1.620\" keyword=\"EchocardiographyAreaMethods12229\" type=\"Context Group Name\">Echocardiography Area Methods (12229)</uid>
    <uid uid=\"1.2.840.10008.6.1.621\" keyword=\"GradientMethods12230\" type=\"Context Group Name\">Gradient Methods (12230)</uid>
    <uid uid=\"1.2.840.10008.6.1.622\" keyword=\"VolumeFlowMethods12231\" type=\"Context Group Name\">Volume Flow Methods (12231)</uid>
    <uid uid=\"1.2.840.10008.6.1.623\" keyword=\"MyocardiumMassMethods12232\" type=\"Context Group Name\">Myocardium Mass Methods (12232)</uid>
    <uid uid=\"1.2.840.10008.6.1.624\" keyword=\"CardiacPhase12233\" type=\"Context Group Name\">Cardiac Phase (12233)</uid>
    <uid uid=\"1.2.840.10008.6.1.625\" keyword=\"RespirationState12234\" type=\"Context Group Name\">Respiration State (12234)</uid>
    <uid uid=\"1.2.840.10008.6.1.626\" keyword=\"MitralValveAnatomicSites12235\" type=\"Context Group Name\">Mitral Valve Anatomic Sites (12235)</uid>
    <uid uid=\"1.2.840.10008.6.1.627\" keyword=\"EchoAnatomicSites12236\" type=\"Context Group Name\">Echo Anatomic Sites (12236)</uid>
    <uid uid=\"1.2.840.10008.6.1.628\" keyword=\"EchocardiographyAnatomicSiteModifiers12237\" type=\"Context Group Name\">Echocardiography Anatomic Site Modifiers (12237)</uid>
    <uid uid=\"1.2.840.10008.6.1.629\" keyword=\"WallMotionScoringSchemes12238\" type=\"Context Group Name\">Wall Motion Scoring Schemes (12238)</uid>
    <uid uid=\"1.2.840.10008.6.1.630\" keyword=\"CardiacOutputProperties12239\" type=\"Context Group Name\">Cardiac Output Properties (12239)</uid>
    <uid uid=\"1.2.840.10008.6.1.631\" keyword=\"LeftVentricleArea12240\" type=\"Context Group Name\">Left Ventricle Area (12240)</uid>
    <uid uid=\"1.2.840.10008.6.1.632\" keyword=\"TricuspidValveFindingSites12241\" type=\"Context Group Name\">Tricuspid Valve Finding Sites (12241)</uid>
    <uid uid=\"1.2.840.10008.6.1.633\" keyword=\"AorticValveFindingSites12242\" type=\"Context Group Name\">Aortic Valve Finding Sites (12242)</uid>
    <uid uid=\"1.2.840.10008.6.1.634\" keyword=\"LeftVentricleFindingSites12243\" type=\"Context Group Name\">Left Ventricle Finding Sites (12243)</uid>
    <uid uid=\"1.2.840.10008.6.1.635\" keyword=\"CongenitalFindingSites12244\" type=\"Context Group Name\">Congenital Finding Sites (12244)</uid>
    <uid uid=\"1.2.840.10008.6.1.636\" keyword=\"SurfaceProcessingAlgorithmFamilies7162\" type=\"Context Group Name\">Surface Processing Algorithm Families (7162)</uid>
    <uid uid=\"1.2.840.10008.6.1.637\" keyword=\"StressTestProcedurePhases3207\" type=\"Context Group Name\">Stress Test Procedure Phases (3207)</uid>
    <uid uid=\"1.2.840.10008.6.1.638\" keyword=\"Stages3778\" type=\"Context Group Name\">Stages (3778)</uid>
    <uid uid=\"1.2.840.10008.6.1.735\" keyword=\"SMLSizeDescriptor252\" type=\"Context Group Name\">S-M-L Size Descriptor (252)</uid>
    <uid uid=\"1.2.840.10008.6.1.736\" keyword=\"MajorCoronaryArteries3016\" type=\"Context Group Name\">Major Coronary Arteries (3016)</uid>
    <uid uid=\"1.2.840.10008.6.1.737\" keyword=\"UnitsOfRadioactivity3083\" type=\"Context Group Name\">Units of Radioactivity (3083)</uid>
    <uid uid=\"1.2.840.10008.6.1.738\" keyword=\"RestStress3102\" type=\"Context Group Name\">Rest-Stress (3102)</uid>
    <uid uid=\"1.2.840.10008.6.1.739\" keyword=\"PETCardiologyProtocols3106\" type=\"Context Group Name\">PET Cardiology Protocols (3106)</uid>
    <uid uid=\"1.2.840.10008.6.1.740\" keyword=\"PETCardiologyRadiopharmaceuticals3107\" type=\"Context Group Name\">PET Cardiology Radiopharmaceuticals (3107)</uid>
    <uid uid=\"1.2.840.10008.6.1.741\" keyword=\"NMPETProcedures3108\" type=\"Context Group Name\">NM/PET Procedures (3108)</uid>
    <uid uid=\"1.2.840.10008.6.1.742\" keyword=\"NuclearCardiologyProtocols3110\" type=\"Context Group Name\">Nuclear Cardiology Protocols (3110)</uid>
    <uid uid=\"1.2.840.10008.6.1.743\" keyword=\"NuclearCardiologyRadiopharmaceuticals3111\" type=\"Context Group Name\">Nuclear Cardiology Radiopharmaceuticals (3111)</uid>
    <uid uid=\"1.2.840.10008.6.1.744\" keyword=\"AttenuationCorrection3112\" type=\"Context Group Name\">Attenuation Correction (3112)</uid>
    <uid uid=\"1.2.840.10008.6.1.745\" keyword=\"TypesOfPerfusionDefects3113\" type=\"Context Group Name\">Types of Perfusion Defects (3113)</uid>
    <uid uid=\"1.2.840.10008.6.1.746\" keyword=\"StudyQuality3114\" type=\"Context Group Name\">Study Quality (3114)</uid>
    <uid uid=\"1.2.840.10008.6.1.747\" keyword=\"StressImagingQualityIssues3115\" type=\"Context Group Name\">Stress Imaging Quality Issues (3115)</uid>
    <uid uid=\"1.2.840.10008.6.1.748\" keyword=\"NMExtracardiacFindings3116\" type=\"Context Group Name\">NM Extracardiac Findings (3116)</uid>
    <uid uid=\"1.2.840.10008.6.1.749\" keyword=\"AttenuationCorrectionMethods3117\" type=\"Context Group Name\">Attenuation Correction Methods (3117)</uid>
    <uid uid=\"1.2.840.10008.6.1.750\" keyword=\"LevelOfRisk3118\" type=\"Context Group Name\">Level of Risk (3118)</uid>
    <uid uid=\"1.2.840.10008.6.1.751\" keyword=\"LVFunction3119\" type=\"Context Group Name\">LV Function (3119)</uid>
    <uid uid=\"1.2.840.10008.6.1.752\" keyword=\"PerfusionFindings3120\" type=\"Context Group Name\">Perfusion Findings (3120)</uid>
    <uid uid=\"1.2.840.10008.6.1.753\" keyword=\"PerfusionMorphology3121\" type=\"Context Group Name\">Perfusion Morphology (3121)</uid>
    <uid uid=\"1.2.840.10008.6.1.754\" keyword=\"VentricularEnlargement3122\" type=\"Context Group Name\">Ventricular Enlargement (3122)</uid>
    <uid uid=\"1.2.840.10008.6.1.755\" keyword=\"StressTestProcedure3200\" type=\"Context Group Name\">Stress Test Procedure (3200)</uid>
    <uid uid=\"1.2.840.10008.6.1.756\" keyword=\"IndicationsForStressTest3201\" type=\"Context Group Name\">Indications for Stress Test (3201)</uid>
    <uid uid=\"1.2.840.10008.6.1.757\" keyword=\"ChestPain3202\" type=\"Context Group Name\">Chest Pain (3202)</uid>
    <uid uid=\"1.2.840.10008.6.1.758\" keyword=\"ExerciserDevice3203\" type=\"Context Group Name\">Exerciser Device (3203)</uid>
    <uid uid=\"1.2.840.10008.6.1.759\" keyword=\"StressAgents3204\" type=\"Context Group Name\">Stress Agents (3204)</uid>
    <uid uid=\"1.2.840.10008.6.1.760\" keyword=\"IndicationsForPharmacologicalStressTest3205\" type=\"Context Group Name\">Indications for Pharmacological Stress Test (3205)</uid>
    <uid uid=\"1.2.840.10008.6.1.761\" keyword=\"NonInvasiveCardiacImagingProcedures3206\" type=\"Context Group Name\">Non-invasive Cardiac Imaging Procedures (3206)</uid>
    <uid uid=\"1.2.840.10008.6.1.763\" keyword=\"SummaryCodesExerciseECG3208\" type=\"Context Group Name\">Summary Codes Exercise ECG (3208)</uid>
    <uid uid=\"1.2.840.10008.6.1.764\" keyword=\"SummaryCodesStressImaging3209\" type=\"Context Group Name\">Summary Codes Stress Imaging (3209)</uid>
    <uid uid=\"1.2.840.10008.6.1.765\" keyword=\"SpeedOfResponse3210\" type=\"Context Group Name\">Speed of Response (3210)</uid>
    <uid uid=\"1.2.840.10008.6.1.766\" keyword=\"BPResponse3211\" type=\"Context Group Name\">BP Response (3211)</uid>
    <uid uid=\"1.2.840.10008.6.1.767\" keyword=\"TreadmillSpeed3212\" type=\"Context Group Name\">Treadmill Speed (3212)</uid>
    <uid uid=\"1.2.840.10008.6.1.768\" keyword=\"StressHemodynamicFindings3213\" type=\"Context Group Name\">Stress Hemodynamic Findings (3213)</uid>
    <uid uid=\"1.2.840.10008.6.1.769\" keyword=\"PerfusionFindingMethod3215\" type=\"Context Group Name\">Perfusion Finding Method (3215)</uid>
    <uid uid=\"1.2.840.10008.6.1.770\" keyword=\"ComparisonFinding3217\" type=\"Context Group Name\">Comparison Finding (3217)</uid>
    <uid uid=\"1.2.840.10008.6.1.771\" keyword=\"StressSymptoms3220\" type=\"Context Group Name\">Stress Symptoms (3220)</uid>
    <uid uid=\"1.2.840.10008.6.1.772\" keyword=\"StressTestTerminationReasons3221\" type=\"Context Group Name\">Stress Test Termination Reasons (3221)</uid>
    <uid uid=\"1.2.840.10008.6.1.773\" keyword=\"QTcMeasurements3227\" type=\"Context Group Name\">QTc Measurements (3227)</uid>
    <uid uid=\"1.2.840.10008.6.1.774\" keyword=\"ECGTimingMeasurements3228\" type=\"Context Group Name\">ECG Timing Measurements (3228)</uid>
    <uid uid=\"1.2.840.10008.6.1.775\" keyword=\"ECGAxisMeasurements3229\" type=\"Context Group Name\">ECG Axis Measurements (3229)</uid>
    <uid uid=\"1.2.840.10008.6.1.776\" keyword=\"ECGFindings3230\" type=\"Context Group Name\">ECG Findings (3230)</uid>
    <uid uid=\"1.2.840.10008.6.1.777\" keyword=\"STSegmentFindings3231\" type=\"Context Group Name\">ST Segment Findings (3231)</uid>
    <uid uid=\"1.2.840.10008.6.1.778\" keyword=\"STSegmentLocation3232\" type=\"Context Group Name\">ST Segment Location (3232)</uid>
    <uid uid=\"1.2.840.10008.6.1.779\" keyword=\"STSegmentMorphology3233\" type=\"Context Group Name\">ST Segment Morphology (3233)</uid>
    <uid uid=\"1.2.840.10008.6.1.780\" keyword=\"EctopicBeatMorphology3234\" type=\"Context Group Name\">Ectopic Beat Morphology (3234)</uid>
    <uid uid=\"1.2.840.10008.6.1.781\" keyword=\"PerfusionComparisonFindings3235\" type=\"Context Group Name\">Perfusion Comparison Findings (3235)</uid>
    <uid uid=\"1.2.840.10008.6.1.782\" keyword=\"ToleranceComparisonFindings3236\" type=\"Context Group Name\">Tolerance Comparison Findings (3236)</uid>
    <uid uid=\"1.2.840.10008.6.1.783\" keyword=\"WallMotionComparisonFindings3237\" type=\"Context Group Name\">Wall Motion Comparison Findings (3237)</uid>
    <uid uid=\"1.2.840.10008.6.1.784\" keyword=\"StressScoringScales3238\" type=\"Context Group Name\">Stress Scoring Scales (3238)</uid>
    <uid uid=\"1.2.840.10008.6.1.785\" keyword=\"PerceivedExertionScales3239\" type=\"Context Group Name\">Perceived Exertion Scales (3239)</uid>
    <uid uid=\"1.2.840.10008.6.1.786\" keyword=\"VentricleIdentification3463\" type=\"Context Group Name\">Ventricle Identification (3463)</uid>
    <uid uid=\"1.2.840.10008.6.1.787\" keyword=\"ColonOverallAssessment6200\" type=\"Context Group Name\">Colon Overall Assessment (6200)</uid>
    <uid uid=\"1.2.840.10008.6.1.788\" keyword=\"ColonFindingOrFeature6201\" type=\"Context Group Name\">Colon Finding or Feature (6201)</uid>
    <uid uid=\"1.2.840.10008.6.1.789\" keyword=\"ColonFindingOrFeatureModifier6202\" type=\"Context Group Name\">Colon Finding or Feature Modifier (6202)</uid>
    <uid uid=\"1.2.840.10008.6.1.790\" keyword=\"ColonNonLesionObjectType6203\" type=\"Context Group Name\">Colon Non-lesion Object Type (6203)</uid>
    <uid uid=\"1.2.840.10008.6.1.791\" keyword=\"AnatomicNonColonFindings6204\" type=\"Context Group Name\">Anatomic Non-colon Findings (6204)</uid>
    <uid uid=\"1.2.840.10008.6.1.792\" keyword=\"ClockfaceLocationForColon6205\" type=\"Context Group Name\">Clockface Location for Colon (6205)</uid>
    <uid uid=\"1.2.840.10008.6.1.793\" keyword=\"RecumbentPatientOrientationForColon6206\" type=\"Context Group Name\">Recumbent Patient Orientation for Colon (6206)</uid>
    <uid uid=\"1.2.840.10008.6.1.794\" keyword=\"ColonQuantitativeTemporalDifferenceType6207\" type=\"Context Group Name\">Colon Quantitative Temporal Difference Type (6207)</uid>
    <uid uid=\"1.2.840.10008.6.1.795\" keyword=\"ColonTypesOfQualityControlStandard6208\" type=\"Context Group Name\">Colon Types of Quality Control Standard (6208)</uid>
    <uid uid=\"1.2.840.10008.6.1.796\" keyword=\"ColonMorphologyDescriptor6209\" type=\"Context Group Name\">Colon Morphology Descriptor (6209)</uid>
    <uid uid=\"1.2.840.10008.6.1.797\" keyword=\"LocationInIntestinalTract6210\" type=\"Context Group Name\">Location in Intestinal Tract (6210)</uid>
    <uid uid=\"1.2.840.10008.6.1.798\" keyword=\"ColonCADMaterialDescription6211\" type=\"Context Group Name\">Colon CAD Material Description (6211)</uid>
    <uid uid=\"1.2.840.10008.6.1.799\" keyword=\"CalculatedValueForColonFindings6212\" type=\"Context Group Name\">Calculated Value for Colon Findings (6212)</uid>
    <uid uid=\"1.2.840.10008.6.1.800\" keyword=\"OphthalmicHorizontalDirections4214\" type=\"Context Group Name\">Ophthalmic Horizontal Directions (4214)</uid>
    <uid uid=\"1.2.840.10008.6.1.801\" keyword=\"OphthalmicVerticalDirections4215\" type=\"Context Group Name\">Ophthalmic Vertical Directions (4215)</uid>
    <uid uid=\"1.2.840.10008.6.1.802\" keyword=\"OphthalmicVisualAcuityType4216\" type=\"Context Group Name\">Ophthalmic Visual Acuity Type (4216)</uid>
    <uid uid=\"1.2.840.10008.6.1.803\" keyword=\"ArterialPulseWaveform3004\" type=\"Context Group Name\">Arterial Pulse Waveform (3004)</uid>
    <uid uid=\"1.2.840.10008.6.1.804\" keyword=\"RespirationWaveform3005\" type=\"Context Group Name\">Respiration Waveform (3005)</uid>
    <uid uid=\"1.2.840.10008.6.1.805\" keyword=\"UltrasoundContrastBolusAgents12030\" type=\"Context Group Name\">Ultrasound Contrast/Bolus Agents (12030)</uid>
    <uid uid=\"1.2.840.10008.6.1.806\" keyword=\"ProtocolIntervalEvents12031\" type=\"Context Group Name\">Protocol Interval Events (12031)</uid>
    <uid uid=\"1.2.840.10008.6.1.807\" keyword=\"TransducerScanPattern12032\" type=\"Context Group Name\">Transducer Scan Pattern (12032)</uid>
    <uid uid=\"1.2.840.10008.6.1.808\" keyword=\"UltrasoundTransducerGeometry12033\" type=\"Context Group Name\">Ultrasound Transducer Geometry (12033)</uid>
    <uid uid=\"1.2.840.10008.6.1.809\" keyword=\"UltrasoundTransducerBeamSteering12034\" type=\"Context Group Name\">Ultrasound Transducer Beam Steering (12034)</uid>
    <uid uid=\"1.2.840.10008.6.1.810\" keyword=\"UltrasoundTransducerApplication12035\" type=\"Context Group Name\">Ultrasound Transducer Application (12035)</uid>
    <uid uid=\"1.2.840.10008.6.1.811\" keyword=\"InstanceAvailabilityStatus50\" type=\"Context Group Name\">Instance Availability Status (50)</uid>
    <uid uid=\"1.2.840.10008.6.1.812\" keyword=\"ModalityPPSDiscontinuationReasons9301\" type=\"Context Group Name\">Modality PPS Discontinuation Reasons (9301)</uid>
    <uid uid=\"1.2.840.10008.6.1.813\" keyword=\"MediaImportPPSDiscontinuationReasons9302\" type=\"Context Group Name\">Media Import PPS Discontinuation Reasons (9302)</uid>
    <uid uid=\"1.2.840.10008.6.1.814\" keyword=\"DXAnatomyImagedForAnimals7482\" type=\"Context Group Name\">DX Anatomy Imaged for Animals (7482)</uid>
    <uid uid=\"1.2.840.10008.6.1.815\" keyword=\"CommonAnatomicRegionsForAnimals7483\" type=\"Context Group Name\">Common Anatomic Regions for Animals (7483)</uid>
    <uid uid=\"1.2.840.10008.6.1.816\" keyword=\"DXViewForAnimals7484\" type=\"Context Group Name\">DX View for Animals (7484)</uid>
    <uid uid=\"1.2.840.10008.6.1.817\" keyword=\"InstitutionalDepartmentsUnitsAndServices7030\" type=\"Context Group Name\">Institutional Departments, Units and Services (7030)</uid>
    <uid uid=\"1.2.840.10008.6.1.818\" keyword=\"PurposeOfReferenceToPredecessorReport7009\" type=\"Context Group Name\">Purpose of Reference to Predecessor Report (7009)</uid>
    <uid uid=\"1.2.840.10008.6.1.819\" keyword=\"VisualFixationQualityDuringAcquisition4220\" type=\"Context Group Name\">Visual Fixation Quality During Acquisition (4220)</uid>
    <uid uid=\"1.2.840.10008.6.1.820\" keyword=\"VisualFixationQualityProblem4221\" type=\"Context Group Name\">Visual Fixation Quality Problem (4221)</uid>
    <uid uid=\"1.2.840.10008.6.1.821\" keyword=\"OphthalmicMacularGridProblem4222\" type=\"Context Group Name\">Ophthalmic Macular Grid Problem (4222)</uid>
    <uid uid=\"1.2.840.10008.6.1.822\" keyword=\"Organizations5002\" type=\"Context Group Name\">Organizations (5002)</uid>
    <uid uid=\"1.2.840.10008.6.1.823\" keyword=\"MixedBreeds7486\" type=\"Context Group Name\">Mixed Breeds (7486)</uid>
    <uid uid=\"1.2.840.10008.6.1.824\" keyword=\"BroselowLutenPediatricSizeCategories7040\" type=\"Context Group Name\">Broselow-Luten Pediatric Size Categories (7040)</uid>
    <uid uid=\"1.2.840.10008.6.1.825\" keyword=\"CMDCTECCCalciumScoringPatientSizeCategories7042\" type=\"Context Group Name\">CMDCTECC Calcium Scoring Patient Size Categories (7042)</uid>
    <uid uid=\"1.2.840.10008.6.1.826\" keyword=\"CardiacUltrasoundReportTitles12245\" type=\"Context Group Name\">Cardiac Ultrasound Report Titles (12245)</uid>
    <uid uid=\"1.2.840.10008.6.1.827\" keyword=\"CardiacUltrasoundIndicationForStudy12246\" type=\"Context Group Name\">Cardiac Ultrasound Indication for Study (12246)</uid>
    <uid uid=\"1.2.840.10008.6.1.828\" keyword=\"PediatricFetalAndCongenitalCardiacSurgicalInterventions12247\" type=\"Context Group Name\">Pediatric, Fetal and Congenital Cardiac Surgical Interventions (12247)</uid>
    <uid uid=\"1.2.840.10008.6.1.829\" keyword=\"CardiacUltrasoundSummaryCodes12248\" type=\"Context Group Name\">Cardiac Ultrasound Summary Codes (12248)</uid>
    <uid uid=\"1.2.840.10008.6.1.830\" keyword=\"CardiacUltrasoundFetalSummaryCodes12249\" type=\"Context Group Name\">Cardiac Ultrasound Fetal Summary Codes (12249)</uid>
    <uid uid=\"1.2.840.10008.6.1.831\" keyword=\"CardiacUltrasoundCommonLinearMeasurements12250\" type=\"Context Group Name\">Cardiac Ultrasound Common Linear Measurements (12250)</uid>
    <uid uid=\"1.2.840.10008.6.1.832\" keyword=\"CardiacUltrasoundLinearValveMeasurements12251\" type=\"Context Group Name\">Cardiac Ultrasound Linear Valve Measurements (12251)</uid>
    <uid uid=\"1.2.840.10008.6.1.833\" keyword=\"CardiacUltrasoundCardiacFunction12252\" type=\"Context Group Name\">Cardiac Ultrasound Cardiac Function (12252)</uid>
    <uid uid=\"1.2.840.10008.6.1.834\" keyword=\"CardiacUltrasoundAreaMeasurements12253\" type=\"Context Group Name\">Cardiac Ultrasound Area Measurements (12253)</uid>
    <uid uid=\"1.2.840.10008.6.1.835\" keyword=\"CardiacUltrasoundHemodynamicMeasurements12254\" type=\"Context Group Name\">Cardiac Ultrasound Hemodynamic Measurements (12254)</uid>
    <uid uid=\"1.2.840.10008.6.1.836\" keyword=\"CardiacUltrasoundMyocardiumMeasurements12255\" type=\"Context Group Name\">Cardiac Ultrasound Myocardium Measurements (12255)</uid>
    <uid uid=\"1.2.840.10008.6.1.838\" keyword=\"CardiacUltrasoundLeftVentricle12257\" type=\"Context Group Name\">Cardiac Ultrasound Left Ventricle (12257)</uid>
    <uid uid=\"1.2.840.10008.6.1.839\" keyword=\"CardiacUltrasoundRightVentricle12258\" type=\"Context Group Name\">Cardiac Ultrasound Right Ventricle (12258)</uid>
    <uid uid=\"1.2.840.10008.6.1.840\" keyword=\"CardiacUltrasoundVentriclesMeasurements12259\" type=\"Context Group Name\">Cardiac Ultrasound Ventricles Measurements (12259)</uid>
    <uid uid=\"1.2.840.10008.6.1.841\" keyword=\"CardiacUltrasoundPulmonaryArtery12260\" type=\"Context Group Name\">Cardiac Ultrasound Pulmonary Artery (12260)</uid>
    <uid uid=\"1.2.840.10008.6.1.842\" keyword=\"CardiacUltrasoundPulmonaryVein12261\" type=\"Context Group Name\">Cardiac Ultrasound Pulmonary Vein (12261)</uid>
    <uid uid=\"1.2.840.10008.6.1.843\" keyword=\"CardiacUltrasoundPulmonaryValve12262\" type=\"Context Group Name\">Cardiac Ultrasound Pulmonary Valve (12262)</uid>
    <uid uid=\"1.2.840.10008.6.1.844\" keyword=\"CardiacUltrasoundVenousReturnPulmonaryMeasurements12263\" type=\"Context Group Name\">Cardiac Ultrasound Venous Return Pulmonary Measurements (12263)</uid>
    <uid uid=\"1.2.840.10008.6.1.845\" keyword=\"CardiacUltrasoundVenousReturnSystemicMeasurements12264\" type=\"Context Group Name\">Cardiac Ultrasound Venous Return Systemic Measurements (12264)</uid>
    <uid uid=\"1.2.840.10008.6.1.846\" keyword=\"CardiacUltrasoundAtriaAndAtrialSeptumMeasurements12265\" type=\"Context Group Name\">Cardiac Ultrasound Atria and Atrial Septum Measurements (12265)</uid>
    <uid uid=\"1.2.840.10008.6.1.847\" keyword=\"CardiacUltrasoundMitralValve12266\" type=\"Context Group Name\">Cardiac Ultrasound Mitral Valve (12266)</uid>
    <uid uid=\"1.2.840.10008.6.1.848\" keyword=\"CardiacUltrasoundTricuspidValve12267\" type=\"Context Group Name\">Cardiac Ultrasound Tricuspid Valve (12267)</uid>
    <uid uid=\"1.2.840.10008.6.1.849\" keyword=\"CardiacUltrasoundAtrioventricularValvesMeasurements12268\" type=\"Context Group Name\">Cardiac Ultrasound Atrioventricular Valves Measurements (12268)</uid>
    <uid uid=\"1.2.840.10008.6.1.850\" keyword=\"CardiacUltrasoundInterventricularSeptumMeasurements12269\" type=\"Context Group Name\">Cardiac Ultrasound Interventricular Septum Measurements (12269)</uid>
    <uid uid=\"1.2.840.10008.6.1.851\" keyword=\"CardiacUltrasoundAorticValve12270\" type=\"Context Group Name\">Cardiac Ultrasound Aortic Valve (12270)</uid>
    <uid uid=\"1.2.840.10008.6.1.852\" keyword=\"CardiacUltrasoundOutflowTractsMeasurements12271\" type=\"Context Group Name\">Cardiac Ultrasound Outflow Tracts Measurements (12271)</uid>
    <uid uid=\"1.2.840.10008.6.1.853\" keyword=\"CardiacUltrasoundSemilunarValvesAnnulateAndSinusesMeasurements12272\" type=\"Context Group Name\">Cardiac Ultrasound Semilunar Valves, Annulate and Sinuses Measurements (12272)</uid>
    <uid uid=\"1.2.840.10008.6.1.854\" keyword=\"CardiacUltrasoundAorticSinotubularJunction12273\" type=\"Context Group Name\">Cardiac Ultrasound Aortic Sinotubular Junction (12273)</uid>
    <uid uid=\"1.2.840.10008.6.1.855\" keyword=\"CardiacUltrasoundAortaMeasurements12274\" type=\"Context Group Name\">Cardiac Ultrasound Aorta Measurements (12274)</uid>
    <uid uid=\"1.2.840.10008.6.1.856\" keyword=\"CardiacUltrasoundCoronaryArteriesMeasurements12275\" type=\"Context Group Name\">Cardiac Ultrasound Coronary Arteries Measurements (12275)</uid>
    <uid uid=\"1.2.840.10008.6.1.857\" keyword=\"CardiacUltrasoundAortoPulmonaryConnectionsMeasurements12276\" type=\"Context Group Name\">Cardiac Ultrasound Aorto Pulmonary Connections Measurements (12276)</uid>
    <uid uid=\"1.2.840.10008.6.1.858\" keyword=\"CardiacUltrasoundPericardiumAndPleuraMeasurements12277\" type=\"Context Group Name\">Cardiac Ultrasound Pericardium and Pleura Measurements (12277)</uid>
    <uid uid=\"1.2.840.10008.6.1.859\" keyword=\"CardiacUltrasoundFetalGeneralMeasurements12279\" type=\"Context Group Name\">Cardiac Ultrasound Fetal General Measurements (12279)</uid>
    <uid uid=\"1.2.840.10008.6.1.860\" keyword=\"CardiacUltrasoundTargetSites12280\" type=\"Context Group Name\">Cardiac Ultrasound Target Sites (12280)</uid>
    <uid uid=\"1.2.840.10008.6.1.861\" keyword=\"CardiacUltrasoundTargetSiteModifiers12281\" type=\"Context Group Name\">Cardiac Ultrasound Target Site Modifiers (12281)</uid>
    <uid uid=\"1.2.840.10008.6.1.862\" keyword=\"CardiacUltrasoundVenousReturnSystemicFindingSites12282\" type=\"Context Group Name\">Cardiac Ultrasound Venous Return Systemic Finding Sites (12282)</uid>
    <uid uid=\"1.2.840.10008.6.1.863\" keyword=\"CardiacUltrasoundVenousReturnPulmonaryFindingSites12283\" type=\"Context Group Name\">Cardiac Ultrasound Venous Return Pulmonary Finding Sites (12283)</uid>
    <uid uid=\"1.2.840.10008.6.1.864\" keyword=\"CardiacUltrasoundAtriaAndAtrialSeptumFindingSites12284\" type=\"Context Group Name\">Cardiac Ultrasound Atria and Atrial Septum Finding Sites (12284)</uid>
    <uid uid=\"1.2.840.10008.6.1.865\" keyword=\"CardiacUltrasoundAtrioventricularValvesFindingSites12285\" type=\"Context Group Name\">Cardiac Ultrasound Atrioventricular Valves Finding Sites (12285)</uid>
    <uid uid=\"1.2.840.10008.6.1.866\" keyword=\"CardiacUltrasoundInterventricularSeptumFindingSites12286\" type=\"Context Group Name\">Cardiac Ultrasound Interventricular Septum Finding Sites (12286)</uid>
    <uid uid=\"1.2.840.10008.6.1.867\" keyword=\"CardiacUltrasoundVentriclesFindingSites12287\" type=\"Context Group Name\">Cardiac Ultrasound Ventricles Finding Sites (12287)</uid>
    <uid uid=\"1.2.840.10008.6.1.868\" keyword=\"CardiacUltrasoundOutflowTractsFindingSites12288\" type=\"Context Group Name\">Cardiac Ultrasound Outflow Tracts Finding Sites (12288)</uid>
    <uid uid=\"1.2.840.10008.6.1.869\" keyword=\"CardiacUltrasoundSemilunarValvesAnnulusAndSinusesFindingSites12289\" type=\"Context Group Name\">Cardiac Ultrasound Semilunar Valves, Annulus and Sinuses Finding Sites (12289)</uid>
    <uid uid=\"1.2.840.10008.6.1.870\" keyword=\"CardiacUltrasoundPulmonaryArteriesFindingSites12290\" type=\"Context Group Name\">Cardiac Ultrasound Pulmonary Arteries Finding Sites (12290)</uid>
    <uid uid=\"1.2.840.10008.6.1.871\" keyword=\"CardiacUltrasoundAortaFindingSites12291\" type=\"Context Group Name\">Cardiac Ultrasound Aorta Finding Sites (12291)</uid>
    <uid uid=\"1.2.840.10008.6.1.872\" keyword=\"CardiacUltrasoundCoronaryArteriesFindingSites12292\" type=\"Context Group Name\">Cardiac Ultrasound Coronary Arteries Finding Sites (12292)</uid>
    <uid uid=\"1.2.840.10008.6.1.873\" keyword=\"CardiacUltrasoundAortopulmonaryConnectionsFindingSites12293\" type=\"Context Group Name\">Cardiac Ultrasound Aortopulmonary Connections Finding Sites (12293)</uid>
    <uid uid=\"1.2.840.10008.6.1.874\" keyword=\"CardiacUltrasoundPericardiumAndPleuraFindingSites12294\" type=\"Context Group Name\">Cardiac Ultrasound Pericardium and Pleura Finding Sites (12294)</uid>
    <uid uid=\"1.2.840.10008.6.1.876\" keyword=\"OphthalmicUltrasoundAxialMeasurementsType4230\" type=\"Context Group Name\">Ophthalmic Ultrasound Axial Measurements Type (4230)</uid>
    <uid uid=\"1.2.840.10008.6.1.877\" keyword=\"LensStatus4231\" type=\"Context Group Name\">Lens Status (4231)</uid>
    <uid uid=\"1.2.840.10008.6.1.878\" keyword=\"VitreousStatus4232\" type=\"Context Group Name\">Vitreous Status (4232)</uid>
    <uid uid=\"1.2.840.10008.6.1.879\" keyword=\"OphthalmicAxialLengthMeasurementsSegmentNames4233\" type=\"Context Group Name\">Ophthalmic Axial Length Measurements Segment Names (4233)</uid>
    <uid uid=\"1.2.840.10008.6.1.880\" keyword=\"RefractiveSurgeryTypes4234\" type=\"Context Group Name\">Refractive Surgery Types (4234)</uid>
    <uid uid=\"1.2.840.10008.6.1.881\" keyword=\"KeratometryDescriptors4235\" type=\"Context Group Name\">Keratometry Descriptors (4235)</uid>
    <uid uid=\"1.2.840.10008.6.1.882\" keyword=\"IOLCalculationFormula4236\" type=\"Context Group Name\">IOL Calculation Formula (4236)</uid>
    <uid uid=\"1.2.840.10008.6.1.883\" keyword=\"LensConstantType4237\" type=\"Context Group Name\">Lens Constant Type (4237)</uid>
    <uid uid=\"1.2.840.10008.6.1.884\" keyword=\"RefractiveErrorTypes4238\" type=\"Context Group Name\">Refractive Error Types (4238)</uid>
    <uid uid=\"1.2.840.10008.6.1.885\" keyword=\"AnteriorChamberDepthDefinition4239\" type=\"Context Group Name\">Anterior Chamber Depth Definition (4239)</uid>
    <uid uid=\"1.2.840.10008.6.1.886\" keyword=\"OphthalmicMeasurementOrCalculationDataSource4240\" type=\"Context Group Name\">Ophthalmic Measurement or Calculation Data Source (4240)</uid>
    <uid uid=\"1.2.840.10008.6.1.887\" keyword=\"OphthalmicAxialLengthSelectionMethod4241\" type=\"Context Group Name\">Ophthalmic Axial Length Selection Method (4241)</uid>
    <uid uid=\"1.2.840.10008.6.1.889\" keyword=\"OphthalmicQualityMetricType4243\" type=\"Context Group Name\">Ophthalmic Quality Metric Type (4243)</uid>
    <uid uid=\"1.2.840.10008.6.1.890\" keyword=\"OphthalmicAgentConcentrationUnits4244\" type=\"Context Group Name\">Ophthalmic Agent Concentration Units (4244)</uid>
    <uid uid=\"1.2.840.10008.6.1.891\" keyword=\"FunctionalConditionPresentDuringAcquisition91\" type=\"Context Group Name\">Functional Condition Present During Acquisition (91)</uid>
    <uid uid=\"1.2.840.10008.6.1.892\" keyword=\"JointPositionDuringAcquisition92\" type=\"Context Group Name\">Joint Position During Acquisition (92)</uid>
    <uid uid=\"1.2.840.10008.6.1.893\" keyword=\"JointPositioningMethod93\" type=\"Context Group Name\">Joint Positioning Method (93)</uid>
    <uid uid=\"1.2.840.10008.6.1.894\" keyword=\"PhysicalForceAppliedDuringAcquisition94\" type=\"Context Group Name\">Physical Force Applied During Acquisition (94)</uid>
    <uid uid=\"1.2.840.10008.6.1.895\" keyword=\"ECGControlVariablesNumeric3690\" type=\"Context Group Name\">ECG Control Variables Numeric (3690)</uid>
    <uid uid=\"1.2.840.10008.6.1.896\" keyword=\"ECGControlVariablesText3691\" type=\"Context Group Name\">ECG Control Variables Text (3691)</uid>
    <uid uid=\"1.2.840.10008.6.1.897\" keyword=\"WSIReferencedImagePurposesOfReference8120\" type=\"Context Group Name\">WSI Referenced Image Purposes of Reference (8120)</uid>
    <uid uid=\"1.2.840.10008.6.1.898\" keyword=\"MicroscopyLensType8121\" type=\"Context Group Name\">Microscopy Lens Type (8121)</uid>
    <uid uid=\"1.2.840.10008.6.1.899\" keyword=\"MicroscopyIlluminatorAndSensorColor8122\" type=\"Context Group Name\">Microscopy Illuminator and Sensor Color (8122)</uid>
    <uid uid=\"1.2.840.10008.6.1.900\" keyword=\"MicroscopyIlluminationMethod8123\" type=\"Context Group Name\">Microscopy Illumination Method (8123)</uid>
    <uid uid=\"1.2.840.10008.6.1.901\" keyword=\"MicroscopyFilter8124\" type=\"Context Group Name\">Microscopy Filter (8124)</uid>
    <uid uid=\"1.2.840.10008.6.1.902\" keyword=\"MicroscopyIlluminatorType8125\" type=\"Context Group Name\">Microscopy Illuminator Type (8125)</uid>
    <uid uid=\"1.2.840.10008.6.1.903\" keyword=\"AuditEventID400\" type=\"Context Group Name\">Audit Event ID (400)</uid>
    <uid uid=\"1.2.840.10008.6.1.904\" keyword=\"AuditEventTypeCode401\" type=\"Context Group Name\">Audit Event Type Code (401)</uid>
    <uid uid=\"1.2.840.10008.6.1.905\" keyword=\"AuditActiveParticipantRoleIDCode402\" type=\"Context Group Name\">Audit Active Participant Role ID Code (402)</uid>
    <uid uid=\"1.2.840.10008.6.1.906\" keyword=\"SecurityAlertTypeCode403\" type=\"Context Group Name\">Security Alert Type Code (403)</uid>
    <uid uid=\"1.2.840.10008.6.1.907\" keyword=\"AuditParticipantObjectIDTypeCode404\" type=\"Context Group Name\">Audit Participant Object ID Type Code (404)</uid>
    <uid uid=\"1.2.840.10008.6.1.908\" keyword=\"MediaTypeCode405\" type=\"Context Group Name\">Media Type Code (405)</uid>
    <uid uid=\"1.2.840.10008.6.1.909\" keyword=\"VisualFieldStaticPerimetryTestPatterns4250\" type=\"Context Group Name\">Visual Field Static Perimetry Test Patterns (4250)</uid>
    <uid uid=\"1.2.840.10008.6.1.910\" keyword=\"VisualFieldStaticPerimetryTestStrategies4251\" type=\"Context Group Name\">Visual Field Static Perimetry Test Strategies (4251)</uid>
    <uid uid=\"1.2.840.10008.6.1.911\" keyword=\"VisualFieldStaticPerimetryScreeningTestModes4252\" type=\"Context Group Name\">Visual Field Static Perimetry Screening Test Modes (4252)</uid>
    <uid uid=\"1.2.840.10008.6.1.912\" keyword=\"VisualFieldStaticPerimetryFixationStrategy4253\" type=\"Context Group Name\">Visual Field Static Perimetry Fixation Strategy (4253)</uid>
    <uid uid=\"1.2.840.10008.6.1.913\" keyword=\"VisualFieldStaticPerimetryTestAnalysisResults4254\" type=\"Context Group Name\">Visual Field Static Perimetry Test Analysis Results (4254)</uid>
    <uid uid=\"1.2.840.10008.6.1.914\" keyword=\"VisualFieldIlluminationColor4255\" type=\"Context Group Name\">Visual Field Illumination Color (4255)</uid>
    <uid uid=\"1.2.840.10008.6.1.915\" keyword=\"VisualFieldProcedureModifier4256\" type=\"Context Group Name\">Visual Field Procedure Modifier (4256)</uid>
    <uid uid=\"1.2.840.10008.6.1.916\" keyword=\"VisualFieldGlobalIndexName4257\" type=\"Context Group Name\">Visual Field Global Index Name (4257)</uid>
    <uid uid=\"1.2.840.10008.6.1.917\" keyword=\"AbstractMultiDimensionalImageModelComponentSemantics7180\" type=\"Context Group Name\">Abstract Multi-dimensional Image Model Component Semantics (7180)</uid>
    <uid uid=\"1.2.840.10008.6.1.918\" keyword=\"AbstractMultiDimensionalImageModelComponentUnits7181\" type=\"Context Group Name\">Abstract Multi-dimensional Image Model Component Units (7181)</uid>
    <uid uid=\"1.2.840.10008.6.1.919\" keyword=\"AbstractMultiDimensionalImageModelDimensionSemantics7182\" type=\"Context Group Name\">Abstract Multi-dimensional Image Model Dimension Semantics (7182)</uid>
    <uid uid=\"1.2.840.10008.6.1.920\" keyword=\"AbstractMultiDimensionalImageModelDimensionUnits7183\" type=\"Context Group Name\">Abstract Multi-dimensional Image Model Dimension Units (7183)</uid>
    <uid uid=\"1.2.840.10008.6.1.921\" keyword=\"AbstractMultiDimensionalImageModelAxisDirection7184\" type=\"Context Group Name\">Abstract Multi-dimensional Image Model Axis Direction (7184)</uid>
    <uid uid=\"1.2.840.10008.6.1.922\" keyword=\"AbstractMultiDimensionalImageModelAxisOrientation7185\" type=\"Context Group Name\">Abstract Multi-dimensional Image Model Axis Orientation (7185)</uid>
    <uid uid=\"1.2.840.10008.6.1.923\" keyword=\"AbstractMultiDimensionalImageModelQualitativeDimensionSampleSemantics7186\" type=\"Context Group Name\">Abstract Multi-dimensional Image Model Qualitative Dimension Sample Semantics (7186)</uid>
    <uid uid=\"1.2.840.10008.6.1.924\" keyword=\"PlanningMethods7320\" type=\"Context Group Name\">Planning Methods (7320)</uid>
    <uid uid=\"1.2.840.10008.6.1.925\" keyword=\"DeIdentificationMethod7050\" type=\"Context Group Name\">De-identification Method (7050)</uid>
    <uid uid=\"1.2.840.10008.6.1.926\" keyword=\"MeasurementOrientation12118\" type=\"Context Group Name\">Measurement Orientation (12118)</uid>
    <uid uid=\"1.2.840.10008.6.1.927\" keyword=\"ECGGlobalWaveformDurations3689\" type=\"Context Group Name\">ECG Global Waveform Durations (3689)</uid>
    <uid uid=\"1.2.840.10008.6.1.930\" keyword=\"ICDs3692\" type=\"Context Group Name\">ICDs (3692)</uid>
    <uid uid=\"1.2.840.10008.6.1.931\" keyword=\"RadiotherapyGeneralWorkitemDefinition9241\" type=\"Context Group Name\">Radiotherapy General Workitem Definition (9241)</uid>
    <uid uid=\"1.2.840.10008.6.1.932\" keyword=\"RadiotherapyAcquisitionWorkitemDefinition9242\" type=\"Context Group Name\">Radiotherapy Acquisition Workitem Definition (9242)</uid>
    <uid uid=\"1.2.840.10008.6.1.933\" keyword=\"RadiotherapyRegistrationWorkitemDefinition9243\" type=\"Context Group Name\">Radiotherapy Registration Workitem Definition (9243)</uid>
    <uid uid=\"1.2.840.10008.6.1.934\" keyword=\"IntravascularOCTFlushAgent3850\" type=\"Context Group Name\">Intravascular OCT Flush Agent (3850)</uid>
    <uid uid=\"1.2.840.10008.6.1.935\" keyword=\"LabelTypes10022\" type=\"Context Group Name\">Label Types (10022)</uid>
    <uid uid=\"1.2.840.10008.6.1.936\" keyword=\"OphthalmicMappingUnitsForRealWorldValueMapping4260\" type=\"Context Group Name\">Ophthalmic Mapping Units for Real World Value Mapping (4260)</uid>
    <uid uid=\"1.2.840.10008.6.1.937\" keyword=\"OphthalmicMappingAcquisitionMethod4261\" type=\"Context Group Name\">Ophthalmic Mapping Acquisition Method (4261)</uid>
    <uid uid=\"1.2.840.10008.6.1.938\" keyword=\"RetinalThicknessDefinition4262\" type=\"Context Group Name\">Retinal Thickness Definition (4262)</uid>
    <uid uid=\"1.2.840.10008.6.1.939\" keyword=\"OphthalmicThicknessMapValueType4263\" type=\"Context Group Name\">Ophthalmic Thickness Map Value Type (4263)</uid>
    <uid uid=\"1.2.840.10008.6.1.940\" keyword=\"OphthalmicMapPurposesOfReference4264\" type=\"Context Group Name\">Ophthalmic Map Purposes of Reference (4264)</uid>
    <uid uid=\"1.2.840.10008.6.1.941\" keyword=\"OphthalmicThicknessDeviationCategories4265\" type=\"Context Group Name\">Ophthalmic Thickness Deviation Categories (4265)</uid>
    <uid uid=\"1.2.840.10008.6.1.942\" keyword=\"OphthalmicAnatomicStructureReferencePoint4266\" type=\"Context Group Name\">Ophthalmic Anatomic Structure Reference Point (4266)</uid>
    <uid uid=\"1.2.840.10008.6.1.943\" keyword=\"CardiacSynchronizationTechnique3104\" type=\"Context Group Name\">Cardiac Synchronization Technique (3104)</uid>
    <uid uid=\"1.2.840.10008.6.1.944\" keyword=\"StainingProtocols8130\" type=\"Context Group Name\">Staining Protocols (8130)</uid>
    <uid uid=\"1.2.840.10008.6.1.947\" keyword=\"SizeSpecificDoseEstimationMethodForCT10023\" type=\"Context Group Name\">Size Specific Dose Estimation Method for CT (10023)</uid>
    <uid uid=\"1.2.840.10008.6.1.948\" keyword=\"PathologyImagingProtocols8131\" type=\"Context Group Name\">Pathology Imaging Protocols (8131)</uid>
    <uid uid=\"1.2.840.10008.6.1.949\" keyword=\"MagnificationSelection8132\" type=\"Context Group Name\">Magnification Selection (8132)</uid>
    <uid uid=\"1.2.840.10008.6.1.950\" keyword=\"TissueSelection8133\" type=\"Context Group Name\">Tissue Selection (8133)</uid>
    <uid uid=\"1.2.840.10008.6.1.951\" keyword=\"GeneralRegionOfInterestMeasurementModifiers7464\" type=\"Context Group Name\">General Region of Interest Measurement Modifiers (7464)</uid>
    <uid uid=\"1.2.840.10008.6.1.952\" keyword=\"MeasurementsDerivedFromMultipleROIMeasurements7465\" type=\"Context Group Name\">Measurements Derived From Multiple ROI Measurements (7465)</uid>
    <uid uid=\"1.2.840.10008.6.1.953\" keyword=\"SurfaceScanAcquisitionTypes8201\" type=\"Context Group Name\">Surface Scan Acquisition Types (8201)</uid>
    <uid uid=\"1.2.840.10008.6.1.954\" keyword=\"SurfaceScanModeTypes8202\" type=\"Context Group Name\">Surface Scan Mode Types (8202)</uid>
    <uid uid=\"1.2.840.10008.6.1.956\" keyword=\"SurfaceScanRegistrationMethodTypes8203\" type=\"Context Group Name\">Surface Scan Registration Method Types (8203)</uid>
    <uid uid=\"1.2.840.10008.6.1.957\" keyword=\"BasicCardiacViews27\" type=\"Context Group Name\">Basic Cardiac Views (27)</uid>
    <uid uid=\"1.2.840.10008.6.1.958\" keyword=\"CTReconstructionAlgorithm10033\" type=\"Context Group Name\">CT Reconstruction Algorithm (10033)</uid>
    <uid uid=\"1.2.840.10008.6.1.959\" keyword=\"DetectorTypes10030\" type=\"Context Group Name\">Detector Types (10030)</uid>
    <uid uid=\"1.2.840.10008.6.1.960\" keyword=\"CRDRMechanicalConfiguration10031\" type=\"Context Group Name\">CR/DR Mechanical Configuration (10031)</uid>
    <uid uid=\"1.2.840.10008.6.1.961\" keyword=\"ProjectionXRayAcquisitionDeviceTypes10032\" type=\"Context Group Name\">Projection X-Ray Acquisition Device Types (10032)</uid>
    <uid uid=\"1.2.840.10008.6.1.962\" keyword=\"AbstractSegmentationTypes7165\" type=\"Context Group Name\">Abstract Segmentation Types (7165)</uid>
    <uid uid=\"1.2.840.10008.6.1.963\" keyword=\"CommonTissueSegmentationTypes7166\" type=\"Context Group Name\">Common Tissue Segmentation Types (7166)</uid>
    <uid uid=\"1.2.840.10008.6.1.964\" keyword=\"PeripheralNervousSystemSegmentationTypes7167\" type=\"Context Group Name\">Peripheral Nervous System Segmentation Types (7167)</uid>
    <uid uid=\"1.2.840.10008.6.1.965\" keyword=\"CornealTopographyMappingUnitsForRealWorldValueMapping4267\" type=\"Context Group Name\">Corneal Topography Mapping Units for Real World Value Mapping (4267)</uid>
    <uid uid=\"1.2.840.10008.6.1.966\" keyword=\"CornealTopographyMapValueType4268\" type=\"Context Group Name\">Corneal Topography Map Value Type (4268)</uid>
    <uid uid=\"1.2.840.10008.6.1.967\" keyword=\"BrainStructuresForVolumetricMeasurements7140\" type=\"Context Group Name\">Brain Structures for Volumetric Measurements (7140)</uid>
    <uid uid=\"1.2.840.10008.6.1.968\" keyword=\"RTDoseDerivation7220\" type=\"Context Group Name\">RT Dose Derivation (7220)</uid>
    <uid uid=\"1.2.840.10008.6.1.969\" keyword=\"RTDosePurposeOfReference7221\" type=\"Context Group Name\">RT Dose Purpose of Reference (7221)</uid>
    <uid uid=\"1.2.840.10008.6.1.970\" keyword=\"SpectroscopyPurposeOfReference7215\" type=\"Context Group Name\">Spectroscopy Purpose of Reference (7215)</uid>
    <uid uid=\"1.2.840.10008.6.1.971\" keyword=\"ScheduledProcessingParameterConceptCodesForRTTreatment9250\" type=\"Context Group Name\">Scheduled Processing Parameter Concept Codes for RT Treatment (9250)</uid>
    <uid uid=\"1.2.840.10008.6.1.972\" keyword=\"RadiopharmaceuticalOrganDoseReferenceAuthority10040\" type=\"Context Group Name\">Radiopharmaceutical Organ Dose Reference Authority (10040)</uid>
    <uid uid=\"1.2.840.10008.6.1.973\" keyword=\"SourceOfRadioisotopeActivityInformation10041\" type=\"Context Group Name\">Source of Radioisotope Activity Information (10041)</uid>
    <uid uid=\"1.2.840.10008.6.1.975\" keyword=\"IntravenousExtravasationSymptoms10043\" type=\"Context Group Name\">Intravenous Extravasation Symptoms (10043)</uid>
    <uid uid=\"1.2.840.10008.6.1.976\" keyword=\"RadiosensitiveOrgans10044\" type=\"Context Group Name\">Radiosensitive Organs (10044)</uid>
    <uid uid=\"1.2.840.10008.6.1.977\" keyword=\"RadiopharmaceuticalPatientState10045\" type=\"Context Group Name\">Radiopharmaceutical Patient State (10045)</uid>
    <uid uid=\"1.2.840.10008.6.1.978\" keyword=\"GFRMeasurements10046\" type=\"Context Group Name\">GFR Measurements (10046)</uid>
    <uid uid=\"1.2.840.10008.6.1.979\" keyword=\"GFRMeasurementMethods10047\" type=\"Context Group Name\">GFR Measurement Methods (10047)</uid>
    <uid uid=\"1.2.840.10008.6.1.980\" keyword=\"VisualEvaluationMethods8300\" type=\"Context Group Name\">Visual Evaluation Methods (8300)</uid>
    <uid uid=\"1.2.840.10008.6.1.981\" keyword=\"TestPatternCodes8301\" type=\"Context Group Name\">Test Pattern Codes (8301)</uid>
    <uid uid=\"1.2.840.10008.6.1.982\" keyword=\"MeasurementPatternCodes8302\" type=\"Context Group Name\">Measurement Pattern Codes (8302)</uid>
    <uid uid=\"1.2.840.10008.6.1.983\" keyword=\"DisplayDeviceType8303\" type=\"Context Group Name\">Display Device Type (8303)</uid>
    <uid uid=\"1.2.840.10008.6.1.984\" keyword=\"SUVUnits85\" type=\"Context Group Name\">SUV Units (85)</uid>
    <uid uid=\"1.2.840.10008.6.1.985\" keyword=\"T1MeasurementMethods4100\" type=\"Context Group Name\">T1 Measurement Methods (4100)</uid>
    <uid uid=\"1.2.840.10008.6.1.986\" keyword=\"TracerKineticModels4101\" type=\"Context Group Name\">Tracer Kinetic Models (4101)</uid>
    <uid uid=\"1.2.840.10008.6.1.987\" keyword=\"PerfusionMeasurementMethods4102\" type=\"Context Group Name\">Perfusion Measurement Methods (4102)</uid>
    <uid uid=\"1.2.840.10008.6.1.988\" keyword=\"ArterialInputFunctionMeasurementMethods4103\" type=\"Context Group Name\">Arterial Input Function Measurement Methods (4103)</uid>
    <uid uid=\"1.2.840.10008.6.1.989\" keyword=\"BolusArrivalTimeDerivationMethods4104\" type=\"Context Group Name\">Bolus Arrival Time Derivation Methods (4104)</uid>
    <uid uid=\"1.2.840.10008.6.1.990\" keyword=\"PerfusionAnalysisMethods4105\" type=\"Context Group Name\">Perfusion Analysis Methods (4105)</uid>
    <uid uid=\"1.2.840.10008.6.1.991\" keyword=\"QuantitativeMethodsUsedForPerfusionAndTracerKineticModels4106\" type=\"Context Group Name\">Quantitative Methods used for Perfusion And Tracer Kinetic Models (4106)</uid>
    <uid uid=\"1.2.840.10008.6.1.992\" keyword=\"TracerKineticModelParameters4107\" type=\"Context Group Name\">Tracer Kinetic Model Parameters (4107)</uid>
    <uid uid=\"1.2.840.10008.6.1.993\" keyword=\"PerfusionModelParameters4108\" type=\"Context Group Name\">Perfusion Model Parameters (4108)</uid>
    <uid uid=\"1.2.840.10008.6.1.994\" keyword=\"ModelIndependentDynamicContrastAnalysisParameters4109\" type=\"Context Group Name\">Model-Independent Dynamic Contrast Analysis Parameters (4109)</uid>
    <uid uid=\"1.2.840.10008.6.1.995\" keyword=\"TracerKineticModelingCovariates4110\" type=\"Context Group Name\">Tracer Kinetic Modeling Covariates (4110)</uid>
    <uid uid=\"1.2.840.10008.6.1.996\" keyword=\"ContrastCharacteristics4111\" type=\"Context Group Name\">Contrast Characteristics (4111)</uid>
    <uid uid=\"1.2.840.10008.6.1.997\" keyword=\"MeasurementReportDocumentTitles7021\" type=\"Context Group Name\">Measurement Report Document Titles (7021)</uid>
    <uid uid=\"1.2.840.10008.6.1.998\" keyword=\"QuantitativeDiagnosticImagingProcedures100\" type=\"Context Group Name\">Quantitative Diagnostic Imaging Procedures (100)</uid>
    <uid uid=\"1.2.840.10008.6.1.999\" keyword=\"PETRegionOfInterestMeasurements7466\" type=\"Context Group Name\">PET Region of Interest Measurements (7466)</uid>
    <uid uid=\"1.2.840.10008.6.1.1000\" keyword=\"GreyLevelCoOccurrenceMatrixMeasurements7467\" type=\"Context Group Name\">Grey Level Co-occurrence Matrix Measurements (7467)</uid>
    <uid uid=\"1.2.840.10008.6.1.1001\" keyword=\"TextureMeasurements7468\" type=\"Context Group Name\">Texture Measurements (7468)</uid>
    <uid uid=\"1.2.840.10008.6.1.1002\" keyword=\"TimePointTypes6146\" type=\"Context Group Name\">Time Point Types (6146)</uid>
    <uid uid=\"1.2.840.10008.6.1.1003\" keyword=\"GenericIntensityAndSizeMeasurements7469\" type=\"Context Group Name\">Generic Intensity and Size Measurements (7469)</uid>
    <uid uid=\"1.2.840.10008.6.1.1004\" keyword=\"ResponseCriteria6147\" type=\"Context Group Name\">Response Criteria (6147)</uid>
    <uid uid=\"1.2.840.10008.6.1.1005\" keyword=\"FetalBiometryAnatomicSites12020\" type=\"Context Group Name\">Fetal Biometry Anatomic Sites (12020)</uid>
    <uid uid=\"1.2.840.10008.6.1.1006\" keyword=\"FetalLongBoneAnatomicSites12021\" type=\"Context Group Name\">Fetal Long Bone Anatomic Sites (12021)</uid>
    <uid uid=\"1.2.840.10008.6.1.1007\" keyword=\"FetalCraniumAnatomicSites12022\" type=\"Context Group Name\">Fetal Cranium Anatomic Sites (12022)</uid>
    <uid uid=\"1.2.840.10008.6.1.1008\" keyword=\"PelvisAndUterusAnatomicSites12023\" type=\"Context Group Name\">Pelvis and Uterus Anatomic Sites (12023)</uid>
    <uid uid=\"1.2.840.10008.6.1.1009\" keyword=\"ParametricMapDerivationImagePurposeOfReference7222\" type=\"Context Group Name\">Parametric Map Derivation Image Purpose of Reference (7222)</uid>
    <uid uid=\"1.2.840.10008.6.1.1010\" keyword=\"PhysicalQuantityDescriptors9000\" type=\"Context Group Name\">Physical Quantity Descriptors (9000)</uid>
    <uid uid=\"1.2.840.10008.6.1.1011\" keyword=\"LymphNodeAnatomicSites7600\" type=\"Context Group Name\">Lymph Node Anatomic Sites (7600)</uid>
    <uid uid=\"1.2.840.10008.6.1.1012\" keyword=\"HeadAndNeckCancerAnatomicSites7601\" type=\"Context Group Name\">Head and Neck Cancer Anatomic Sites (7601)</uid>
    <uid uid=\"1.2.840.10008.6.1.1013\" keyword=\"FiberTractsInBrainstem7701\" type=\"Context Group Name\">Fiber Tracts In Brainstem (7701)</uid>
    <uid uid=\"1.2.840.10008.6.1.1014\" keyword=\"ProjectionAndThalamicFibers7702\" type=\"Context Group Name\">Projection and Thalamic Fibers (7702)</uid>
    <uid uid=\"1.2.840.10008.6.1.1015\" keyword=\"AssociationFibers7703\" type=\"Context Group Name\">Association Fibers (7703)</uid>
    <uid uid=\"1.2.840.10008.6.1.1016\" keyword=\"LimbicSystemTracts7704\" type=\"Context Group Name\">Limbic System Tracts (7704)</uid>
    <uid uid=\"1.2.840.10008.6.1.1017\" keyword=\"CommissuralFibers7705\" type=\"Context Group Name\">Commissural Fibers (7705)</uid>
    <uid uid=\"1.2.840.10008.6.1.1018\" keyword=\"CranialNerves7706\" type=\"Context Group Name\">Cranial Nerves (7706)</uid>
    <uid uid=\"1.2.840.10008.6.1.1019\" keyword=\"SpinalCordFibers7707\" type=\"Context Group Name\">Spinal Cord Fibers (7707)</uid>
    <uid uid=\"1.2.840.10008.6.1.1020\" keyword=\"TractographyAnatomicSites7710\" type=\"Context Group Name\">Tractography Anatomic Sites (7710)</uid>
    <uid uid=\"1.2.840.10008.6.1.1021\" keyword=\"PrimaryAnatomicStructureForIntraOralRadiographySupernumeraryDentitionDesignationOfTeeth4025\" type=\"Context Group Name\">Primary Anatomic Structure for Intra-oral Radiography (Supernumerary Dentition - Designation of Teeth) (4025)</uid>
    <uid uid=\"1.2.840.10008.6.1.1022\" keyword=\"PrimaryAnatomicStructureForIntraOralAndCraniofacialRadiographyTeeth4026\" type=\"Context Group Name\">Primary Anatomic Structure for Intra-oral and Craniofacial Radiography - Teeth (4026)</uid>
    <uid uid=\"1.2.840.10008.6.1.1023\" keyword=\"IEC61217DevicePositionParameters9401\" type=\"Context Group Name\">IEC61217 Device Position Parameters (9401)</uid>
    <uid uid=\"1.2.840.10008.6.1.1024\" keyword=\"IEC61217GantryPositionParameters9402\" type=\"Context Group Name\">IEC61217 Gantry Position Parameters (9402)</uid>
    <uid uid=\"1.2.840.10008.6.1.1025\" keyword=\"IEC61217PatientSupportPositionParameters9403\" type=\"Context Group Name\">IEC61217 Patient Support Position Parameters (9403)</uid>
    <uid uid=\"1.2.840.10008.6.1.1026\" keyword=\"ActionableFindingClassification7035\" type=\"Context Group Name\">Actionable Finding Classification (7035)</uid>
    <uid uid=\"1.2.840.10008.6.1.1027\" keyword=\"ImageQualityAssessment7036\" type=\"Context Group Name\">Image Quality Assessment (7036)</uid>
    <uid uid=\"1.2.840.10008.6.1.1028\" keyword=\"SummaryRadiationExposureQuantities10050\" type=\"Context Group Name\">Summary Radiation Exposure Quantities (10050)</uid>
    <uid uid=\"1.2.840.10008.6.1.1029\" keyword=\"WideFieldOphthalmicPhotographyTransformationMethod4245\" type=\"Context Group Name\">Wide Field Ophthalmic Photography Transformation Method (4245)</uid>
    <uid uid=\"1.2.840.10008.6.1.1030\" keyword=\"PETUnits84\" type=\"Context Group Name\">PET Units (84)</uid>
    <uid uid=\"1.2.840.10008.6.1.1031\" keyword=\"ImplantMaterials7300\" type=\"Context Group Name\">Implant Materials (7300)</uid>
    <uid uid=\"1.2.840.10008.6.1.1032\" keyword=\"InterventionTypes7301\" type=\"Context Group Name\">Intervention Types (7301)</uid>
    <uid uid=\"1.2.840.10008.6.1.1033\" keyword=\"ImplantTemplatesViewOrientations7302\" type=\"Context Group Name\">Implant Templates View Orientations (7302)</uid>
    <uid uid=\"1.2.840.10008.6.1.1034\" keyword=\"ImplantTemplatesModifiedViewOrientations7303\" type=\"Context Group Name\">Implant Templates Modified View Orientations (7303)</uid>
    <uid uid=\"1.2.840.10008.6.1.1035\" keyword=\"ImplantTargetAnatomy7304\" type=\"Context Group Name\">Implant Target Anatomy (7304)</uid>
    <uid uid=\"1.2.840.10008.6.1.1036\" keyword=\"ImplantPlanningLandmarks7305\" type=\"Context Group Name\">Implant Planning Landmarks (7305)</uid>
    <uid uid=\"1.2.840.10008.6.1.1037\" keyword=\"HumanHipImplantPlanningLandmarks7306\" type=\"Context Group Name\">Human Hip Implant Planning Landmarks (7306)</uid>
    <uid uid=\"1.2.840.10008.6.1.1038\" keyword=\"ImplantComponentTypes7307\" type=\"Context Group Name\">Implant Component Types (7307)</uid>
    <uid uid=\"1.2.840.10008.6.1.1039\" keyword=\"HumanHipImplantComponentTypes7308\" type=\"Context Group Name\">Human Hip Implant Component Types (7308)</uid>
    <uid uid=\"1.2.840.10008.6.1.1040\" keyword=\"HumanTraumaImplantComponentTypes7309\" type=\"Context Group Name\">Human Trauma Implant Component Types (7309)</uid>
    <uid uid=\"1.2.840.10008.6.1.1041\" keyword=\"ImplantFixationMethod7310\" type=\"Context Group Name\">Implant Fixation Method (7310)</uid>
    <uid uid=\"1.2.840.10008.6.1.1042\" keyword=\"DeviceParticipatingRoles7445\" type=\"Context Group Name\">Device Participating Roles (7445)</uid>
    <uid uid=\"1.2.840.10008.6.1.1043\" keyword=\"ContainerTypes8101\" type=\"Context Group Name\">Container Types (8101)</uid>
    <uid uid=\"1.2.840.10008.6.1.1044\" keyword=\"ContainerComponentTypes8102\" type=\"Context Group Name\">Container Component Types (8102)</uid>
    <uid uid=\"1.2.840.10008.6.1.1045\" keyword=\"AnatomicPathologySpecimenTypes8103\" type=\"Context Group Name\">Anatomic Pathology Specimen Types (8103)</uid>
    <uid uid=\"1.2.840.10008.6.1.1046\" keyword=\"BreastTissueSpecimenTypes8104\" type=\"Context Group Name\">Breast Tissue Specimen Types (8104)</uid>
    <uid uid=\"1.2.840.10008.6.1.1047\" keyword=\"SpecimenCollectionProcedure8109\" type=\"Context Group Name\">Specimen Collection Procedure (8109)</uid>
    <uid uid=\"1.2.840.10008.6.1.1048\" keyword=\"SpecimenSamplingProcedure8110\" type=\"Context Group Name\">Specimen Sampling Procedure (8110)</uid>
    <uid uid=\"1.2.840.10008.6.1.1049\" keyword=\"SpecimenPreparationProcedure8111\" type=\"Context Group Name\">Specimen Preparation Procedure (8111)</uid>
    <uid uid=\"1.2.840.10008.6.1.1050\" keyword=\"SpecimenStains8112\" type=\"Context Group Name\">Specimen Stains (8112)</uid>
    <uid uid=\"1.2.840.10008.6.1.1051\" keyword=\"SpecimenPreparationSteps8113\" type=\"Context Group Name\">Specimen Preparation Steps (8113)</uid>
    <uid uid=\"1.2.840.10008.6.1.1052\" keyword=\"SpecimenFixatives8114\" type=\"Context Group Name\">Specimen Fixatives (8114)</uid>
    <uid uid=\"1.2.840.10008.6.1.1053\" keyword=\"SpecimenEmbeddingMedia8115\" type=\"Context Group Name\">Specimen Embedding Media (8115)</uid>
    <uid uid=\"1.2.840.10008.6.1.1054\" keyword=\"SourceOfProjectionXRayDoseInformation10020\" type=\"Context Group Name\">Source of Projection X-Ray Dose Information (10020)</uid>
    <uid uid=\"1.2.840.10008.6.1.1055\" keyword=\"SourceOfCTDoseInformation10021\" type=\"Context Group Name\">Source of CT Dose Information (10021)</uid>
    <uid uid=\"1.2.840.10008.6.1.1056\" keyword=\"RadiationDoseReferencePoints10025\" type=\"Context Group Name\">Radiation Dose Reference Points (10025)</uid>
    <uid uid=\"1.2.840.10008.6.1.1057\" keyword=\"VolumetricViewDescription501\" type=\"Context Group Name\">Volumetric View Description (501)</uid>
    <uid uid=\"1.2.840.10008.6.1.1058\" keyword=\"VolumetricViewModifier502\" type=\"Context Group Name\">Volumetric View Modifier (502)</uid>
    <uid uid=\"1.2.840.10008.6.1.1059\" keyword=\"DiffusionAcquisitionValueTypes7260\" type=\"Context Group Name\">Diffusion Acquisition Value Types (7260)</uid>
    <uid uid=\"1.2.840.10008.6.1.1060\" keyword=\"DiffusionModelValueTypes7261\" type=\"Context Group Name\">Diffusion Model Value Types (7261)</uid>
    <uid uid=\"1.2.840.10008.6.1.1061\" keyword=\"DiffusionTractographyAlgorithmFamilies7262\" type=\"Context Group Name\">Diffusion Tractography Algorithm Families (7262)</uid>
    <uid uid=\"1.2.840.10008.6.1.1062\" keyword=\"DiffusionTractographyMeasurementTypes7263\" type=\"Context Group Name\">Diffusion Tractography Measurement Types (7263)</uid>
    <uid uid=\"1.2.840.10008.6.1.1063\" keyword=\"ResearchAnimalSourceRegistries7490\" type=\"Context Group Name\">Research Animal Source Registries (7490)</uid>
    <uid uid=\"1.2.840.10008.6.1.1064\" keyword=\"YesNoOnly231\" type=\"Context Group Name\">Yes-No Only (231)</uid>
    <uid uid=\"1.2.840.10008.6.1.1065\" keyword=\"BiosafetyLevels601\" type=\"Context Group Name\">Biosafety Levels (601)</uid>
    <uid uid=\"1.2.840.10008.6.1.1066\" keyword=\"BiosafetyControlReasons602\" type=\"Context Group Name\">Biosafety Control Reasons (602)</uid>
    <uid uid=\"1.2.840.10008.6.1.1067\" keyword=\"SexMaleFemaleOrBoth7457\" type=\"Context Group Name\">Sex - Male Female or Both (7457)</uid>
    <uid uid=\"1.2.840.10008.6.1.1068\" keyword=\"AnimalRoomTypes603\" type=\"Context Group Name\">Animal Room Types (603)</uid>
    <uid uid=\"1.2.840.10008.6.1.1069\" keyword=\"DeviceReuse604\" type=\"Context Group Name\">Device Reuse (604)</uid>
    <uid uid=\"1.2.840.10008.6.1.1070\" keyword=\"AnimalBeddingMaterial605\" type=\"Context Group Name\">Animal Bedding Material (605)</uid>
    <uid uid=\"1.2.840.10008.6.1.1071\" keyword=\"AnimalShelterTypes606\" type=\"Context Group Name\">Animal Shelter Types (606)</uid>
    <uid uid=\"1.2.840.10008.6.1.1072\" keyword=\"AnimalFeedTypes607\" type=\"Context Group Name\">Animal Feed Types (607)</uid>
    <uid uid=\"1.2.840.10008.6.1.1073\" keyword=\"AnimalFeedSources608\" type=\"Context Group Name\">Animal Feed Sources (608)</uid>
    <uid uid=\"1.2.840.10008.6.1.1074\" keyword=\"AnimalFeedingMethods609\" type=\"Context Group Name\">Animal Feeding Methods (609)</uid>
    <uid uid=\"1.2.840.10008.6.1.1075\" keyword=\"WaterTypes610\" type=\"Context Group Name\">Water Types (610)</uid>
    <uid uid=\"1.2.840.10008.6.1.1076\" keyword=\"AnesthesiaCategoryCodeTypeForSmallAnimalAnesthesia611\" type=\"Context Group Name\">Anesthesia Category Code Type for Small Animal Anesthesia (611)</uid>
    <uid uid=\"1.2.840.10008.6.1.1077\" keyword=\"AnesthesiaCategoryCodeTypeFromAnesthesiaQualityInitiativeAQI612\" type=\"Context Group Name\">Anesthesia Category Code Type from Anesthesia Quality Initiative (AQI) (612)</uid>
    <uid uid=\"1.2.840.10008.6.1.1078\" keyword=\"AnesthesiaInductionCodeTypeForSmallAnimalAnesthesia613\" type=\"Context Group Name\">Anesthesia Induction Code Type for Small Animal Anesthesia (613)</uid>
    <uid uid=\"1.2.840.10008.6.1.1079\" keyword=\"AnesthesiaInductionCodeTypeFromAnesthesiaQualityInitiativeAQI614\" type=\"Context Group Name\">Anesthesia Induction Code Type from Anesthesia Quality Initiative (AQI) (614)</uid>
    <uid uid=\"1.2.840.10008.6.1.1080\" keyword=\"AnesthesiaMaintenanceCodeTypeForSmallAnimalAnesthesia615\" type=\"Context Group Name\">Anesthesia Maintenance Code Type for Small Animal Anesthesia (615)</uid>
    <uid uid=\"1.2.840.10008.6.1.1081\" keyword=\"AnesthesiaMaintenanceCodeTypeFromAnesthesiaQualityInitiativeAQI616\" type=\"Context Group Name\">Anesthesia Maintenance Code Type from Anesthesia Quality Initiative (AQI) (616)</uid>
    <uid uid=\"1.2.840.10008.6.1.1082\" keyword=\"AirwayManagementMethodCodeTypeForSmallAnimalAnesthesia617\" type=\"Context Group Name\">Airway Management Method Code Type for Small Animal Anesthesia (617)</uid>
    <uid uid=\"1.2.840.10008.6.1.1083\" keyword=\"AirwayManagementMethodCodeTypeFromAnesthesiaQualityInitiativeAQI618\" type=\"Context Group Name\">Airway Management Method Code Type from Anesthesia Quality Initiative (AQI) (618)</uid>
    <uid uid=\"1.2.840.10008.6.1.1084\" keyword=\"AirwayManagementSubMethodCodeTypeForSmallAnimalAnesthesia619\" type=\"Context Group Name\">Airway Management Sub-Method Code Type for Small Animal Anesthesia (619)</uid>
    <uid uid=\"1.2.840.10008.6.1.1085\" keyword=\"AirwayManagementSubMethodCodeTypeFromAnesthesiaQualityInitiativeAQI620\" type=\"Context Group Name\">Airway Management Sub-Method Code Type from Anesthesia Quality Initiative (AQI) (620)</uid>
    <uid uid=\"1.2.840.10008.6.1.1086\" keyword=\"MedicationTypeCodeTypeForSmallAnimalAnesthesia621\" type=\"Context Group Name\">Medication Type Code Type for Small Animal Anesthesia (621)</uid>
    <uid uid=\"1.2.840.10008.6.1.1087\" keyword=\"MedicationTypeCodeTypeFromAnesthesiaQualityInitiativeAQI622\" type=\"Context Group Name\">Medication Type Code Type from Anesthesia Quality Initiative (AQI) (622)</uid>
    <uid uid=\"1.2.840.10008.6.1.1088\" keyword=\"MedicationForSmallAnimalAnesthesia623\" type=\"Context Group Name\">Medication for Small Animal Anesthesia (623)</uid>
    <uid uid=\"1.2.840.10008.6.1.1089\" keyword=\"InhalationalAnesthesiaAgentsForSmallAnimalAnesthesia624\" type=\"Context Group Name\">Inhalational Anesthesia Agents for Small Animal Anesthesia (624)</uid>
    <uid uid=\"1.2.840.10008.6.1.1090\" keyword=\"InjectableAnesthesiaAgentsForSmallAnimalAnesthesia625\" type=\"Context Group Name\">Injectable Anesthesia Agents for Small Animal Anesthesia (625)</uid>
    <uid uid=\"1.2.840.10008.6.1.1091\" keyword=\"PremedicationAgentsForSmallAnimalAnesthesia626\" type=\"Context Group Name\">Premedication Agents for Small Animal Anesthesia (626)</uid>
    <uid uid=\"1.2.840.10008.6.1.1092\" keyword=\"NeuromuscularBlockingAgentsForSmallAnimalAnesthesia627\" type=\"Context Group Name\">Neuromuscular Blocking Agents for Small Animal Anesthesia (627)</uid>
    <uid uid=\"1.2.840.10008.6.1.1093\" keyword=\"AncillaryMedicationsForSmallAnimalAnesthesia628\" type=\"Context Group Name\">Ancillary Medications for Small Animal Anesthesia (628)</uid>
    <uid uid=\"1.2.840.10008.6.1.1094\" keyword=\"CarrierGasesForSmallAnimalAnesthesia629\" type=\"Context Group Name\">Carrier Gases for Small Animal Anesthesia (629)</uid>
    <uid uid=\"1.2.840.10008.6.1.1095\" keyword=\"LocalAnestheticsForSmallAnimalAnesthesia630\" type=\"Context Group Name\">Local Anesthetics for Small Animal Anesthesia (630)</uid>
    <uid uid=\"1.2.840.10008.6.1.1096\" keyword=\"PhaseOfProcedureRequiringAnesthesia631\" type=\"Context Group Name\">Phase of Procedure Requiring Anesthesia (631)</uid>
    <uid uid=\"1.2.840.10008.6.1.1097\" keyword=\"PhaseOfSurgicalProcedureRequiringAnesthesia632\" type=\"Context Group Name\">Phase of Surgical Procedure Requiring Anesthesia (632)</uid>
    <uid uid=\"1.2.840.10008.6.1.1098\" keyword=\"PhaseOfImagingProcedureRequiringAnesthesia633\" type=\"Context Group Name\">Phase of Imaging Procedure Requiring Anesthesia (633)</uid>
    <uid uid=\"1.2.840.10008.6.1.1099\" keyword=\"PhaseOfAnimalHandling634\" type=\"Context Group Name\">Phase of Animal Handling (634)</uid>
    <uid uid=\"1.2.840.10008.6.1.1100\" keyword=\"HeatingMethod635\" type=\"Context Group Name\">Heating Method (635)</uid>
    <uid uid=\"1.2.840.10008.6.1.1101\" keyword=\"TemperatureSensorDeviceComponentTypeForSmallAnimalProcedures636\" type=\"Context Group Name\">Temperature Sensor Device Component Type for Small Animal Procedures (636)</uid>
    <uid uid=\"1.2.840.10008.6.1.1102\" keyword=\"ExogenousSubstanceTypes637\" type=\"Context Group Name\">Exogenous Substance Types (637)</uid>
    <uid uid=\"1.2.840.10008.6.1.1103\" keyword=\"ExogenousSubstance638\" type=\"Context Group Name\">Exogenous Substance (638)</uid>
    <uid uid=\"1.2.840.10008.6.1.1104\" keyword=\"TumorGraftHistologicType639\" type=\"Context Group Name\">Tumor Graft Histologic Type (639)</uid>
    <uid uid=\"1.2.840.10008.6.1.1105\" keyword=\"Fibrils640\" type=\"Context Group Name\">Fibrils (640)</uid>
    <uid uid=\"1.2.840.10008.6.1.1106\" keyword=\"Viruses641\" type=\"Context Group Name\">Viruses (641)</uid>
    <uid uid=\"1.2.840.10008.6.1.1107\" keyword=\"Cytokines642\" type=\"Context Group Name\">Cytokines (642)</uid>
    <uid uid=\"1.2.840.10008.6.1.1108\" keyword=\"Toxins643\" type=\"Context Group Name\">Toxins (643)</uid>
    <uid uid=\"1.2.840.10008.6.1.1109\" keyword=\"ExogenousSubstanceAdministrationSites644\" type=\"Context Group Name\">Exogenous Substance Administration Sites (644)</uid>
    <uid uid=\"1.2.840.10008.6.1.1110\" keyword=\"ExogenousSubstanceTissueOfOrigin645\" type=\"Context Group Name\">Exogenous Substance Tissue of Origin (645)</uid>
    <uid uid=\"1.2.840.10008.6.1.1111\" keyword=\"PreclinicalSmallAnimalImagingProcedures646\" type=\"Context Group Name\">Preclinical Small Animal Imaging Procedures (646)</uid>
    <uid uid=\"1.2.840.10008.6.1.1112\" keyword=\"PositionReferenceIndicatorForFrameOfReference647\" type=\"Context Group Name\">Position Reference Indicator for Frame of Reference (647)</uid>
    <uid uid=\"1.2.840.10008.6.1.1113\" keyword=\"PresentAbsentOnly241\" type=\"Context Group Name\">Present-Absent Only (241)</uid>
    <uid uid=\"1.2.840.10008.6.1.1114\" keyword=\"WaterEquivalentDiameterMethod10024\" type=\"Context Group Name\">Water Equivalent Diameter Method (10024)</uid>
    <uid uid=\"1.2.840.10008.6.1.1115\" keyword=\"RadiotherapyPurposesOfReference7022\" type=\"Context Group Name\">Radiotherapy Purposes of Reference (7022)</uid>
    <uid uid=\"1.2.840.10008.6.1.1116\" keyword=\"ContentAssessmentTypes701\" type=\"Context Group Name\">Content Assessment Types (701)</uid>
    <uid uid=\"1.2.840.10008.6.1.1117\" keyword=\"RTContentAssessmentTypes702\" type=\"Context Group Name\">RT Content Assessment Types (702)</uid>
    <uid uid=\"1.2.840.10008.6.1.1118\" keyword=\"BasisOfAssessment703\" type=\"Context Group Name\">Basis of Assessment (703)</uid>
    <uid uid=\"1.2.840.10008.6.1.1119\" keyword=\"ReaderSpecialty7449\" type=\"Context Group Name\">Reader Specialty (7449)</uid>
    <uid uid=\"1.2.840.10008.6.1.1120\" keyword=\"RequestedReportTypes9233\" type=\"Context Group Name\">Requested Report Types (9233)</uid>
    <uid uid=\"1.2.840.10008.6.1.1121\" keyword=\"CTTransversePlaneReferenceBasis1000\" type=\"Context Group Name\">CT Transverse Plane Reference Basis (1000)</uid>
    <uid uid=\"1.2.840.10008.6.1.1122\" keyword=\"AnatomicalReferenceBasis1001\" type=\"Context Group Name\">Anatomical Reference Basis (1001)</uid>
    <uid uid=\"1.2.840.10008.6.1.1123\" keyword=\"AnatomicalReferenceBasisHead1002\" type=\"Context Group Name\">Anatomical Reference Basis - Head (1002)</uid>
    <uid uid=\"1.2.840.10008.6.1.1124\" keyword=\"AnatomicalReferenceBasisSpine1003\" type=\"Context Group Name\">Anatomical Reference Basis - Spine (1003)</uid>
    <uid uid=\"1.2.840.10008.6.1.1125\" keyword=\"AnatomicalReferenceBasisChest1004\" type=\"Context Group Name\">Anatomical Reference Basis - Chest (1004)</uid>
    <uid uid=\"1.2.840.10008.6.1.1126\" keyword=\"AnatomicalReferenceBasisAbdomenPelvis1005\" type=\"Context Group Name\">Anatomical Reference Basis - Abdomen/Pelvis (1005)</uid>
    <uid uid=\"1.2.840.10008.6.1.1127\" keyword=\"AnatomicalReferenceBasisExtremities1006\" type=\"Context Group Name\">Anatomical Reference Basis - Extremities (1006)</uid>
    <uid uid=\"1.2.840.10008.6.1.1128\" keyword=\"ReferenceGeometryPlanes1010\" type=\"Context Group Name\">Reference Geometry - Planes (1010)</uid>
    <uid uid=\"1.2.840.10008.6.1.1129\" keyword=\"ReferenceGeometryPoints1011\" type=\"Context Group Name\">Reference Geometry - Points (1011)</uid>
    <uid uid=\"1.2.840.10008.6.1.1130\" keyword=\"PatientAlignmentMethods1015\" type=\"Context Group Name\">Patient Alignment Methods (1015)</uid>
    <uid uid=\"1.2.840.10008.6.1.1131\" keyword=\"ContraindicationsForCTImaging1200\" type=\"Context Group Name\">Contraindications For CT Imaging (1200)</uid>
    <uid uid=\"1.2.840.10008.6.1.1132\" keyword=\"FiducialsCategories7110\" type=\"Context Group Name\">Fiducials Categories (7110)</uid>
    <uid uid=\"1.2.840.10008.6.1.1133\" keyword=\"Fiducials7111\" type=\"Context Group Name\">Fiducials (7111)</uid>
    <uid uid=\"1.2.840.10008.6.1.1134\" keyword=\"SourceInstancePurposesOfReference7013\" type=\"Context Group Name\">Source Instance Purposes of Reference (7013)</uid>
    <uid uid=\"1.2.840.10008.6.1.1135\" keyword=\"RTProcessOutput7023\" type=\"Context Group Name\">RT Process Output (7023)</uid>
    <uid uid=\"1.2.840.10008.6.1.1136\" keyword=\"RTProcessInput7024\" type=\"Context Group Name\">RT Process Input (7024)</uid>
    <uid uid=\"1.2.840.10008.6.1.1137\" keyword=\"RTProcessInputUsed7025\" type=\"Context Group Name\">RT Process Input Used (7025)</uid>
    <uid uid=\"1.2.840.10008.6.1.1138\" keyword=\"ProstateSectorAnatomy6300\" type=\"Context Group Name\">Prostate Sector Anatomy (6300)</uid>
    <uid uid=\"1.2.840.10008.6.1.1139\" keyword=\"ProstateSectorAnatomyFromPIRADSV26301\" type=\"Context Group Name\">Prostate Sector Anatomy from PI-RADS v2 (6301)</uid>
    <uid uid=\"1.2.840.10008.6.1.1140\" keyword=\"ProstateSectorAnatomyFromEuropeanConcensus16SectorMinimalModel6302\" type=\"Context Group Name\">Prostate Sector Anatomy from European Concensus 16 Sector (Minimal) Model (6302)</uid>
    <uid uid=\"1.2.840.10008.6.1.1141\" keyword=\"ProstateSectorAnatomyFromEuropeanConcensus27SectorOptimalModel6303\" type=\"Context Group Name\">Prostate Sector Anatomy from European Concensus 27 Sector (Optimal) Model (6303)</uid>
    <uid uid=\"1.2.840.10008.6.1.1142\" keyword=\"MeasurementSelectionReasons12301\" type=\"Context Group Name\">Measurement Selection Reasons (12301)</uid>
    <uid uid=\"1.2.840.10008.6.1.1143\" keyword=\"EchoFindingObservationTypes12302\" type=\"Context Group Name\">Echo Finding Observation Types (12302)</uid>
    <uid uid=\"1.2.840.10008.6.1.1144\" keyword=\"EchoMeasurementTypes12303\" type=\"Context Group Name\">Echo Measurement Types (12303)</uid>
    <uid uid=\"1.2.840.10008.6.1.1145\" keyword=\"EchoMeasuredProperties12304\" type=\"Context Group Name\">Echo Measured Properties (12304)</uid>
    <uid uid=\"1.2.840.10008.6.1.1146\" keyword=\"BasicEchoAnatomicSites12305\" type=\"Context Group Name\">Basic Echo Anatomic Sites (12305)</uid>
    <uid uid=\"1.2.840.10008.6.1.1147\" keyword=\"EchoFlowDirections12306\" type=\"Context Group Name\">Echo Flow Directions (12306)</uid>
    <uid uid=\"1.2.840.10008.6.1.1148\" keyword=\"CardiacPhasesAndTimePoints12307\" type=\"Context Group Name\">Cardiac Phases and Time Points (12307)</uid>
    <uid uid=\"1.2.840.10008.6.1.1149\" keyword=\"CoreEchoMeasurements12300\" type=\"Context Group Name\">Core Echo Measurements (12300)</uid>
    <uid uid=\"1.2.840.10008.6.1.1150\" keyword=\"OCTAProcessingAlgorithmFamilies4270\" type=\"Context Group Name\">OCT-A Processing Algorithm Families (4270)</uid>
    <uid uid=\"1.2.840.10008.6.1.1151\" keyword=\"EnFaceImageTypes4271\" type=\"Context Group Name\">En Face Image Types (4271)</uid>
    <uid uid=\"1.2.840.10008.6.1.1152\" keyword=\"OptScanPatternTypes4272\" type=\"Context Group Name\">Opt Scan Pattern Types (4272)</uid>
    <uid uid=\"1.2.840.10008.6.1.1153\" keyword=\"RetinalSegmentationSurfaces4273\" type=\"Context Group Name\">Retinal Segmentation Surfaces (4273)</uid>
    <uid uid=\"1.2.840.10008.6.1.1154\" keyword=\"OrgansForRadiationDoseEstimates10060\" type=\"Context Group Name\">Organs for Radiation Dose Estimates (10060)</uid>
    <uid uid=\"1.2.840.10008.6.1.1155\" keyword=\"AbsorbedRadiationDoseTypes10061\" type=\"Context Group Name\">Absorbed Radiation Dose Types (10061)</uid>
    <uid uid=\"1.2.840.10008.6.1.1156\" keyword=\"EquivalentRadiationDoseTypes10062\" type=\"Context Group Name\">Equivalent Radiation Dose Types (10062)</uid>
    <uid uid=\"1.2.840.10008.6.1.1157\" keyword=\"RadiationDoseEstimateDistributionRepresentation10063\" type=\"Context Group Name\">Radiation Dose Estimate Distribution Representation (10063)</uid>
    <uid uid=\"1.2.840.10008.6.1.1158\" keyword=\"PatientModelType10064\" type=\"Context Group Name\">Patient Model Type (10064)</uid>
    <uid uid=\"1.2.840.10008.6.1.1159\" keyword=\"RadiationTransportModelType10065\" type=\"Context Group Name\">Radiation Transport Model Type (10065)</uid>
    <uid uid=\"1.2.840.10008.6.1.1160\" keyword=\"AttenuatorCategory10066\" type=\"Context Group Name\">Attenuator Category (10066)</uid>
    <uid uid=\"1.2.840.10008.6.1.1161\" keyword=\"RadiationAttenuatorMaterials10067\" type=\"Context Group Name\">Radiation Attenuator Materials (10067)</uid>
    <uid uid=\"1.2.840.10008.6.1.1162\" keyword=\"EstimateMethodTypes10068\" type=\"Context Group Name\">Estimate Method Types (10068)</uid>
    <uid uid=\"1.2.840.10008.6.1.1163\" keyword=\"RadiationDoseEstimationParameter10069\" type=\"Context Group Name\">Radiation Dose Estimation Parameter  (10069)</uid>
    <uid uid=\"1.2.840.10008.6.1.1164\" keyword=\"RadiationDoseTypes10070\" type=\"Context Group Name\">Radiation Dose Types (10070)</uid>
    <uid uid=\"1.2.840.10008.6.1.1165\" keyword=\"MRDiffusionComponentSemantics7270\" type=\"Context Group Name\">MR Diffusion Component Semantics (7270)</uid>
    <uid uid=\"1.2.840.10008.6.1.1166\" keyword=\"MRDiffusionAnisotropyIndices7271\" type=\"Context Group Name\">MR Diffusion Anisotropy Indices (7271)</uid>
    <uid uid=\"1.2.840.10008.6.1.1167\" keyword=\"MRDiffusionModelParameters7272\" type=\"Context Group Name\">MR Diffusion Model Parameters (7272)</uid>
    <uid uid=\"1.2.840.10008.6.1.1168\" keyword=\"MRDiffusionModels7273\" type=\"Context Group Name\">MR Diffusion Models (7273)</uid>
    <uid uid=\"1.2.840.10008.6.1.1169\" keyword=\"MRDiffusionModelFittingMethods7274\" type=\"Context Group Name\">MR Diffusion Model Fitting Methods (7274)</uid>
    <uid uid=\"1.2.840.10008.6.1.1170\" keyword=\"MRDiffusionModelSpecificMethods7275\" type=\"Context Group Name\">MR Diffusion Model Specific Methods (7275)</uid>
    <uid uid=\"1.2.840.10008.6.1.1171\" keyword=\"MRDiffusionModelInputs7276\" type=\"Context Group Name\">MR Diffusion Model Inputs (7276)</uid>
    <uid uid=\"1.2.840.10008.6.1.1172\" keyword=\"UnitsOfDiffusionRateAreaOverTime7277\" type=\"Context Group Name\">Units of Diffusion Rate Area Over Time (7277)</uid>
    <uid uid=\"1.2.840.10008.6.1.1173\" keyword=\"PediatricSizeCategories7039\" type=\"Context Group Name\">Pediatric Size Categories (7039)</uid>
    <uid uid=\"1.2.840.10008.6.1.1174\" keyword=\"CalciumScoringPatientSizeCategories7041\" type=\"Context Group Name\">Calcium Scoring Patient Size Categories (7041)</uid>
    <uid uid=\"1.2.840.10008.6.1.1175\" keyword=\"ReasonForRepeatingAcquisition10034\" type=\"Context Group Name\">Reason for Repeating Acquisition (10034)</uid>
    <uid uid=\"1.2.840.10008.6.1.1176\" keyword=\"ProtocolAssertionCodes800\" type=\"Context Group Name\">Protocol Assertion Codes (800)</uid>
</dictionary>
"""
