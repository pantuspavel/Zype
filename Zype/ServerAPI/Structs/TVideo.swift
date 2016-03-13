//
//  Video.swift
//  Zype
//
//  Created by Pavel Pantus on 3/11/16.
//  Copyright © 2016 Pavel Pantus. All rights reserved.
//

import Foundation
import SwiftyJSON

struct TVideo {
    let identifier: String
    let title: String
    let thumbnailURI: NSURL?

    init?(json: JSON) {
        guard json["_id"].string != nil else { return nil }

        identifier = json["_id"].stringValue
        title = json["title"].stringValue
        let thumbnails = json["thumbnails"].arrayValue
        let thumbnail = thumbnails.count > 0 ? thumbnails[0].dictionaryValue : [:]
        thumbnailURI = thumbnail["url"]?.URL
    }
}