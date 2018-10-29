//
//  Constants.swift
//  PixelCity
//
//  Created by Sultan Karybaev on 9/26/18.
//  Copyright © 2018 Sultan Karybaev. All rights reserved.
//

import Foundation

// Flickr API Key
let FLICKR_KEY = "e6326d0bd6a19a35cb74e32547d6ba14"
let FLICKR_SECRET = "1a29ad18c8029852"

func flickrURL(forApiKey key: String, withAnnotation annotation: DroppablePin, andNumberOfPhotos number: Int) -> String {
    return "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&lat=\(annotation.coordinate.latitude)&lon=\(annotation.coordinate.longitude)&radius=1&radius_units=km&per_page=\(number)&format=json&nojsoncallback=1"
}

let GETPERMS = "https://api.flickr.com/services/rest/?method=flickr.photos.getPerms&api_key=\(FLICKR_KEY)&photo_id=31703483968&format=json&nojsoncallback=1"
