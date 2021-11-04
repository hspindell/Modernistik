//
//  Modernistik
//  Copyright © Modernistik LLC. All rights reserved.
//

import Foundation
import UIKit

/// A basic empty completion block that provides an error in case of failure.
/// - parameter error: An error if not successful.
public typealias CompletionResultBlock = (_ error: Error?) -> Void
public typealias ResultBlock = CompletionResultBlock

/// A completion block that returns a boolean result.
/// - parameter success: A boolean result whether it was completed successfully.
public typealias CompletionSuccessBlock = (_ success: Bool) -> Void
public typealias SuccessBlock = CompletionSuccessBlock

/// A completion block that returns a boolean result and a possible error.
/// - parameter success: A boolean result whether it was completed successfully.
/// - parameter error: An error if not successful.
public typealias CompletionBooleanBlock = (_ success: Bool, _ error: Error?) -> Void

/// A basic completion block with no parameters or result.
public typealias CompletionBlock = () -> Void

// MARK: NSBundle

extension Bundle {
    /// A settings bundle key where to store the displayed app version.
    public static let AppVersionSettingsKey = "AppVersionSettingsKey"

    /// This updates the settings key where the full app version is stored. This is useful when using the Settings bundle to
    /// display the current app version. You can set a `Title` field your `Root.plist` of your `Settings.bundle` with the title `Version`, and set the identifier
    /// to the value of `Bundle.AppVersionSettingsKey` (usually `AppVersionSettingsKey`). Calling this method, will then automatically update `UserDefaults`
    /// with the new value, updating the visible version number to users in the Settings app.
    public static func updateSettingsBundleAppVersion() {
        UserDefaults.standard.set(appVersion, forKey: AppVersionSettingsKey)
    }

    /// Returns the string `{releaseVersion}-{currentBuildVersion}`.
    public static var appVersion: String {
        "\(releaseVersion)-\(currentBuildVersion)"
    }

    /// Returns the current build version based on the `CFBundleVersion` of the Info.plist. Defaults 0.
    public static var releaseVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }

    /// Returns the current build version based on the `CFBundleVersion` of the Info.plist. Defaults 0.
    public static var currentBuildVersion: Int {
        if let buildVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String,
            let buildNumber = Int(buildVersion) {
            return buildNumber
        }
        return 0
    }
}

extension String {
    /// Uses the string as a NSLayoutConstraint visual format specification for constraints. For more information,
    /// see Auto Layout Cookbook in Auto Layout Guide.
    /// - parameter opts: Options describing the attribute and the direction of layout for all objects in the visual format string.
    /// - parameter metrics: A dictionary of constants that appear in the visual format string. The dictionary’s keys must be the string
    ///   values used in the visual format string. Their values must be NSNumber objects.
    /// - parameter views: A dictionary of views that appear in the visual format string. The keys must be the string values used in the visual format string, and the values must be the view objects.
    /// - returns: An array of NSLayoutConstraints that were parsed from the string.
    public func constraints(options opts: NSLayoutConstraint.FormatOptions = [], metrics: [String: Any]? = nil, views: [String: Any]) -> [NSLayoutConstraint] {
        // NOTE: If you exception breakpoint hits here, go back one call stack to see the constraint that is causing the error.
        NSLayoutConstraint.constraints(withVisualFormat: self, options: opts, metrics: metrics, views: views)
    }

    /// Uses the string as a NSLayoutConstraint visual format with no options or metrics.
    /// - parameter opts: Options describing the attribute and the direction of layout for all objects in the visual format string.
    /// - parameter views: A dictionary of views that appear in the visual format string. The keys must be the string values used in the visual format string, and the values must be the view objects.
    /// - returns: An array of NSLayoutConstraints that were parsed from the string.
    public func constraints(options opts: NSLayoutConstraint.FormatOptions, views: [String: Any]) -> [NSLayoutConstraint] {
        // NOTE: If you exception breakpoint hits here, go back one call stack to see the constraint that is causing the error.
        NSLayoutConstraint.constraints(withVisualFormat: self, options: opts, metrics: nil, views: views)
    }
}

extension URL {
    /// Returns true if the url is a file path and if it exists in the local file system.
    public var fileExists: Bool {
        isFileURL && FileManager.default.fileExists(atPath: path)
    }
}

extension FileManager {
    /// Returns the documents directory for the default file manager
    public static var documentsDirectory: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    /// Returns the caches directory for the default file manager
    public static var cachesDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    public static func directory(for directory: FileManager.SearchPathDirectory) -> URL {
        FileManager.default.urls(for: directory, in: .userDomainMask).first!
    }
}

// MARK: NSUserDefaults

extension UserDefaults {
    /**
     Sets true to the given key in NSUserDefaults. If the value has not been
      previously flagged this method returns true. If it has been previously flagged it returns false.

     Assume you want to run some code that should only happen once, you can do
      the following:
     ````
      let key = "ShouldShowOneTimePopUp"

      if UserDefaults.flagOnce(forKey: key) {
        // show one-time popup
      }

      // this will now return false
      UserDefaults.flagOnce(forKey: key) // => false

     ````
     - parameter key: The NSUserDefaults string key name to use for storing the flag.
     - returns: true if the flag was successfully created or changed from false to true.
     */
    public class func flagOnce(forKey key: String) -> Bool {
        let d = standard
        var flagged = false // only flag if we've never flagged before.

        if d.object(forKey: key) == nil || d.bool(forKey: key) == false {
            flagged = true
            d.set(true, forKey: key)
        }

        return flagged
    }

    /// Sets false to the NSUserDefaults key provided. This basically resets the flag state.
    ///
    /// - parameter key: The NSUserDefaults string key name.
    public class func resetFlag(forKey key: String) {
        standard.removeObject(forKey: key)
    }
}

/// A short macro to perform an `dispatch_async` (main thread) at a later time in seconds, using the `dispatch_after` call.
///
/// - parameter seconds: The number of seconds to wait before performing the closure
/// - parameter closure: A void closure to perform at a later time on the main thread.
public func async_delay(_ seconds: Double, closure: @escaping CompletionBlock) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: closure)
}

/// Dispatch a block on the main queue.
///
/// - parameter closure: The closure to execute on the main thread.
public func async_main(_ closure: @escaping CompletionBlock) {
    DispatchQueue.main.async(execute: closure)
}

/// Dispatch a block with in the background using a specified quality of service.
/// ```
///   dispatch(.background) {
///      // do some work in the background queue...
///   }
///
///   dispatch(.userInteractive) {
///      // do some work on the main thread.
///   }
/// ```
/// - note: To use dispatch a block to the main thread, use `.userInteractive`
/// - parameter qos: The quality of service class to use. Defaults to `.default`.
/// - parameter closure: The closure to execute.
public func dispatch(_ qos: DispatchQoS.QoSClass = .default, closure: @escaping CompletionBlock) {
    DispatchQueue.global(qos: qos).async(execute: closure)
}

extension CFTimeInterval {
    /// Returns the absolute current time.
    public static var currentTime: CFTimeInterval {
        CFAbsoluteTimeGetCurrent()
    }

    /// The amount of time that has lapsed up to 3 decimal places
    /// using this value as an absolute time interval.
    public var timeLapsed: CFTimeInterval {
        (CFAbsoluteTimeGetCurrent() - self).roundTo(3)
    }
}

extension Set {
    /// Return an array containing the elements of the Set
    public var array: [Element] {
        [Element](self)
    }
}

extension Array where Element: Equatable {
    /// Alias for `contains(value) == false`
    public func missing(_ value: Element) -> Bool {
        contains(value) == false
    }
}

extension ClosedRange {
    public func clamp(value: Bound) -> Bound {
        if value < lowerBound { return lowerBound }
        if value > upperBound { return upperBound }
        return value
    }
}

extension Comparable {
    public func clamp(in range: ClosedRange<Self>) -> Self {
        if self < range.lowerBound { return range.lowerBound }
        if self > range.upperBound { return range.upperBound }
        return self
    }
}

extension Encodable {
    /// Return the JSON encoded data for this object.
    public var jsonData: Data? {
        try? JSONEncoder().encode(self)
    }

    /// Return a serialized JSON string representing this object.
    public var jsonString: String? {
        jsonData?.utf8String
    }
}


// Easier to get the decoding error description
public extension DecodingError {
    static func debugDescription(error: Error) -> String {
        var m = error.localizedDescription
        switch error {
        case let DecodingError.dataCorrupted(context):
            m = "Failed to decode the object. \(context.debugDescription)"
        case let DecodingError.keyNotFound(key, context):
            m = "Failed decoding key \(key) note found: \(context.debugDescription)"
        case let DecodingError.typeMismatch(type, context):
            m = "Failed decoding type \(type) mismatch: \(context.debugDescription)"
        case let DecodingError.valueNotFound(type, context):
            m = "Failed decoding value of type \(type) not found: \(context.debugDescription)"
        default:
            m = "Unkonwn DecodingError type: \(error.localizedDescription)"
        }
        return m
    }

    var decodingErrorDescription: String {
        var key = "unknown"
        var msg = localizedDescription
        switch self {
        case let .dataCorrupted(context):
            key = context.codingPath.last?.stringValue ?? key
            msg = context.debugDescription
        case let .keyNotFound(_, context):
            key = context.codingPath.last?.stringValue ?? key
            msg = context.debugDescription
        case let .typeMismatch(_, context):
            key = context.codingPath.last?.stringValue ?? key
            msg = context.debugDescription
        case let .valueNotFound(_, context):
            key = context.codingPath.last?.stringValue ?? key
            msg = context.debugDescription
        @unknown default:
            print("Failed to handle new unknown value for decoding error.")
            assertionFailure("Failed to handle new unknown value for decoding error.")
        }
        return "[Decoding Error] \(key)] => \(msg)"
    }
}
