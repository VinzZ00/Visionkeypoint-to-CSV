//
//  HumanBodyJoint.swift
//  ExportKeyPointToCSV
//
//  Created by Elvin Sestomi on 18/09/23.
//

import Foundation
import Vision

class HumanBodyJoint {
    var jointName : VNHumanBodyPoseObservation.JointName
    var xPosition : CGFloat
    var yPosition : CGFloat
    
    init(jointName: VNHumanBodyPoseObservation.JointName, xPosition: CGFloat, yPosition: CGFloat) {
        self.jointName = jointName
        self.xPosition = xPosition
        self.yPosition = yPosition
    }
    
    public static var jointNames : [VNHumanBodyPoseObservation.JointName] =
    [
        .leftAnkle,
        .leftEar,
        .leftElbow,
        .leftEye,
        .leftHip,
        .leftKnee,
        .leftShoulder,
        .leftWrist,
        .neck,
        .nose,
        .rightAnkle,
        .rightEar,
        .rightElbow,
        .rightEye,
        .rightHip,
        .rightKnee,
        .rightShoulder,
        .rightWrist
    ]
    
}
