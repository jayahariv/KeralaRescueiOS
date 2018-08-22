//
//  DistrictEnum.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation

enum District: String {
    case AL = "Alapuzha"
    case EK = "Ernakulam"
    case ID = "Idukki"
    case KN = "Kannur"
    case KS = "Kasargod"
    case KL = "Kollam"
    case KT = "Kottayam"
    case KZ = "kozhikodu"
    case MA = "Malapuram"
    case PL = "Palakkad"
    case PT = "Pathanamtitta"
    case TV = "Trivandrum"
    case TS = "Thrissur"
    case WA = "Wayanad"
    case UNKNOWN = "Unknown"
    
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
    
    static let allValues = [AL, EK, ID, KN, KS, KL, KT, KZ, MA, PL, PT, TV, TS, WA]
}
