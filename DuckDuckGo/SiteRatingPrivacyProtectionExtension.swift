//
//  SiteRatingPrivacyProtectionExtension.swift
//  DuckDuckGo
//
//  Copyright © 2017 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import Foundation
import Core

extension SiteRating {

    func encryptedConnectionText() -> String {
        if !https {
            return UserText.privacyProtectionEncryptionBadConnection
        } else if !hasOnlySecureContent {
            return UserText.privacyProtectionEncryptionMixedConnection
        } else {
            return UserText.privacyProtectionEncryptionGoodConnection
        }
    }

    func encryptedConnectionSuccess() -> Bool {
        return https && hasOnlySecureContent
    }

    func privacyPracticesText() -> String {
        guard termsOfService != nil else { return UserText.privacyProtectionTOSUnknown }

        let score = termsOfServiceScore

        switch (score) {
        case _ where(score < 0):
            return UserText.privacyProtectionTOSGood

        case 0 ... 1:
            return UserText.privacyProtectionTOSMixed

        default:
            return UserText.privacyProtectionTOSPoor
        }
    }

    func privacyPracticesSuccess() -> Bool {
        guard termsOfService != nil else { return false}
        return termsOfServiceScore < 0
    }

    func majorTrackersText(contentBlocker: ContentBlockerConfigurationStore) -> String {
        return protecting(contentBlocker) ? majorTrackersBlockedText() : majorTrackersDetectedText()
    }

    func majorTrackersSuccess(contentBlocker: ContentBlockerConfigurationStore) -> Bool {
        return (protecting(contentBlocker) ? uniqueMajorTrackerNetworksBlocked : uniqueMajorTrackerNetworksDetected) <= 0
    }

    func majorTrackersBlockedText() -> String {
        return String(format: UserText.privacyProtectionMajorTrackersBlocked, uniqueMajorTrackerNetworksBlocked)
    }

    func majorTrackersDetectedText() -> String {
        return String(format: UserText.privacyProtectionMajorTrackersFound, uniqueMajorTrackerNetworksDetected)
    }

    func trackersText(contentBlocker: ContentBlockerConfigurationStore) -> String {
        return protecting(contentBlocker) ? trackersBlockedText() : trackersDetectedText()
    }

    func trackersSuccess(contentBlocker: ContentBlockerConfigurationStore) -> Bool {
        return (protecting(contentBlocker) ? uniqueTrackersBlocked : uniqueTrackersDetected) <= 0
    }

    func trackersBlockedText() -> String {
        return String(format: UserText.privacyProtectionTrackersBlocked, uniqueTrackersBlocked)
    }

    func trackersDetectedText() -> String {
        return String(format: UserText.privacyProtectionTrackersFound, uniqueTrackersDetected)
    }

    func protecting(_ contentBlocker: ContentBlockerConfigurationStore) -> Bool {
        return contentBlocker.enabled && !contentBlocker.domainWhitelist.contains(domain)
    }

    static let gradeImages: [SiteGrade: UIImage] = [
        .a: #imageLiteral(resourceName: "PP Inline A"),
        .b: #imageLiteral(resourceName: "PP Inline B"),
        .c: #imageLiteral(resourceName: "PP Inline C"),
        .d: #imageLiteral(resourceName: "PP Inline D")
    ]

    func siteGradeImages() -> (from: UIImage, to: UIImage) {
        let grades = siteGrade()

        let fromGrade = grades.before
        let toGrade = grades.after

        return (SiteRating.gradeImages[fromGrade]!, SiteRating.gradeImages[toGrade]!)
    }

}