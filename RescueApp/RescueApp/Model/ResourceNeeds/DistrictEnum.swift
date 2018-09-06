//
//  DistrictEnum.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation

enum District: Int {
    case AL = 0
    case EK
    case ID
    case KN
    case KS
    case KL
    case KT
    case KZ
    case MA
    case PL
    case PT
    case TV
    case TS
    case WA
    case UNKNOWN
    
    static func getFromString(_ string: String?) -> District {
        switch string {
        case "ekm": return District.EK
        case "idk": return District.ID
        case "ksr": return District.KS
        case "ktm": return District.KT
        case "tcr": return District.TS
        case "alp": return District.AL
        case "pkd": return District.PL
        case "tvm": return District.TV
        case "wnd": return District.WA
        case "knr": return District.KN
        case "ptm": return District.PT
        case "kol": return District.KL
        case "koz": return District.KZ
        case "mpm": return District.MA
        default: return District.UNKNOWN
        }
    }
    
    static func getDisplayLabels(_ value: District) -> String {
        switch value {
        case .AL: return "Alapuzha"
        case .EK: return "Ernakulam"
        case .ID: return "Idukki"
        case .KN: return "Kannur"
        case .KS: return "Kasargod"
        case .KL: return "Kollam"
        case .KT: return "Kottayam"
        case .KZ: return "kozhikodu"
        case .MA: return "Malapuram"
        case .PL: return "Palakkad"
        case .PT: return "Pathanamtitta"
        case .TV: return "Trivandrum"
        case .TS: return "Thrissur"
        case .WA: return "Wayanad"
        case .UNKNOWN: return "Unknown"
        }
    }
    
    static let allValues = [AL, EK, ID, KN, KS, KL, KT, KZ, MA, PL, PT, TV, TS, WA]
}
