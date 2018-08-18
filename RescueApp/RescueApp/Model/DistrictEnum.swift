//
//  DistrictEnum.swift
//  RescueApp
//
//  Created by Jayahari Vavachan on 8/17/18.
//  Copyright © 2018 Jayahari Vavachan. All rights reserved.
//

import Foundation

enum District {
    case AL // alapuzha
    case EK // ernakulam
    case ID // idukki
    case KN // kannur
    case KS // kasagod
    case KL // kollam
    case KT // kottayam
    case KZ // kaozhikodu
    case MA // malapuram
    case PL // palakaad
    case PT // Pathanamtitta
    case TV // trivandrum
    case TS // thrissur
    case WA // wayanad
    case UNKNOWN // unknown
    
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
}
