//
//  ImagesData.swift
//  ExportKeyPointToCSV
//
//  Created by Elvin Sestomi on 17/09/23.
//

import Foundation
import SwiftUI
import Vision

class ImagesData : NSObject {
    var image : NSImage
    var bodyPoseObservation : VNHumanBodyPoseObservation?
    
    init(image: NSImage, bodyPoseObservation: VNHumanBodyPoseObservation? = nil) {
        self.image = image
        self.bodyPoseObservation = bodyPoseObservation
    }
}
