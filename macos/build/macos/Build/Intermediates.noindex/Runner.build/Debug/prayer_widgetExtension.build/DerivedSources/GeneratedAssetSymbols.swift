import Foundation
#if canImport(AppKit)
import AppKit
#endif
#if canImport(UIKit)
import UIKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif
#if canImport(DeveloperToolsSupport)
import DeveloperToolsSupport
#endif

#if SWIFT_PACKAGE
private let resourceBundle = Foundation.Bundle.module
#else
private class ResourceBundleClass {}
private let resourceBundle = Foundation.Bundle(for: ResourceBundleClass.self)
#endif

// MARK: - Color Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ColorResource {

}

// MARK: - Image Symbols -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension DeveloperToolsSupport.ImageResource {

    /// The "1" asset catalog image resource.
    static let _1 = DeveloperToolsSupport.ImageResource(name: "1", bundle: resourceBundle)

    /// The "10" asset catalog image resource.
    static let _10 = DeveloperToolsSupport.ImageResource(name: "10", bundle: resourceBundle)

    /// The "11" asset catalog image resource.
    static let _11 = DeveloperToolsSupport.ImageResource(name: "11", bundle: resourceBundle)

    /// The "12" asset catalog image resource.
    static let _12 = DeveloperToolsSupport.ImageResource(name: "12", bundle: resourceBundle)

    /// The "2" asset catalog image resource.
    static let _2 = DeveloperToolsSupport.ImageResource(name: "2", bundle: resourceBundle)

    /// The "3" asset catalog image resource.
    static let _3 = DeveloperToolsSupport.ImageResource(name: "3", bundle: resourceBundle)

    /// The "4" asset catalog image resource.
    static let _4 = DeveloperToolsSupport.ImageResource(name: "4", bundle: resourceBundle)

    /// The "5" asset catalog image resource.
    static let _5 = DeveloperToolsSupport.ImageResource(name: "5", bundle: resourceBundle)

    /// The "6" asset catalog image resource.
    static let _6 = DeveloperToolsSupport.ImageResource(name: "6", bundle: resourceBundle)

    /// The "7" asset catalog image resource.
    static let _7 = DeveloperToolsSupport.ImageResource(name: "7", bundle: resourceBundle)

    /// The "8" asset catalog image resource.
    static let _8 = DeveloperToolsSupport.ImageResource(name: "8", bundle: resourceBundle)

    /// The "9" asset catalog image resource.
    static let _9 = DeveloperToolsSupport.ImageResource(name: "9", bundle: resourceBundle)

    /// The "aqem_logo_stroke" asset catalog image resource.
    static let aqemLogoStroke = DeveloperToolsSupport.ImageResource(name: "aqem_logo_stroke", bundle: resourceBundle)

}

// MARK: - Color Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSColor {

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

}
#endif

// MARK: - Image Symbol Extensions -

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    /// The "1" asset catalog image.
    static var _1: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._1)
#else
        .init()
#endif
    }

    /// The "10" asset catalog image.
    static var _10: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._10)
#else
        .init()
#endif
    }

    /// The "11" asset catalog image.
    static var _11: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._11)
#else
        .init()
#endif
    }

    /// The "12" asset catalog image.
    static var _12: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._12)
#else
        .init()
#endif
    }

    /// The "2" asset catalog image.
    static var _2: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._2)
#else
        .init()
#endif
    }

    /// The "3" asset catalog image.
    static var _3: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._3)
#else
        .init()
#endif
    }

    /// The "4" asset catalog image.
    static var _4: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._4)
#else
        .init()
#endif
    }

    /// The "5" asset catalog image.
    static var _5: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._5)
#else
        .init()
#endif
    }

    /// The "6" asset catalog image.
    static var _6: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._6)
#else
        .init()
#endif
    }

    /// The "7" asset catalog image.
    static var _7: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._7)
#else
        .init()
#endif
    }

    /// The "8" asset catalog image.
    static var _8: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._8)
#else
        .init()
#endif
    }

    /// The "9" asset catalog image.
    static var _9: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: ._9)
#else
        .init()
#endif
    }

    /// The "aqem_logo_stroke" asset catalog image.
    static var aqemLogoStroke: AppKit.NSImage {
#if !targetEnvironment(macCatalyst)
        .init(resource: .aqemLogoStroke)
#else
        .init()
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    /// The "1" asset catalog image.
    static var _1: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._1)
#else
        .init()
#endif
    }

    /// The "10" asset catalog image.
    static var _10: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._10)
#else
        .init()
#endif
    }

    /// The "11" asset catalog image.
    static var _11: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._11)
#else
        .init()
#endif
    }

    /// The "12" asset catalog image.
    static var _12: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._12)
#else
        .init()
#endif
    }

    /// The "2" asset catalog image.
    static var _2: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._2)
#else
        .init()
#endif
    }

    /// The "3" asset catalog image.
    static var _3: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._3)
#else
        .init()
#endif
    }

    /// The "4" asset catalog image.
    static var _4: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._4)
#else
        .init()
#endif
    }

    /// The "5" asset catalog image.
    static var _5: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._5)
#else
        .init()
#endif
    }

    /// The "6" asset catalog image.
    static var _6: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._6)
#else
        .init()
#endif
    }

    /// The "7" asset catalog image.
    static var _7: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._7)
#else
        .init()
#endif
    }

    /// The "8" asset catalog image.
    static var _8: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._8)
#else
        .init()
#endif
    }

    /// The "9" asset catalog image.
    static var _9: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: ._9)
#else
        .init()
#endif
    }

    /// The "aqem_logo_stroke" asset catalog image.
    static var aqemLogoStroke: UIKit.UIImage {
#if !os(watchOS)
        .init(resource: .aqemLogoStroke)
#else
        .init()
#endif
    }

}
#endif

// MARK: - Thinnable Asset Support -

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ColorResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if AppKit.NSColor(named: NSColor.Name(thinnableName), bundle: bundle) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIColor(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIColor {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(SwiftUI)
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
extension SwiftUI.ShapeStyle where Self == SwiftUI.Color {

    private init?(thinnableResource: DeveloperToolsSupport.ColorResource?) {
        if let resource = thinnableResource {
            self.init(resource)
        } else {
            return nil
        }
    }

}
#endif

@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
@available(watchOS, unavailable)
extension DeveloperToolsSupport.ImageResource {

    private init?(thinnableName: Swift.String, bundle: Foundation.Bundle) {
#if canImport(AppKit) && os(macOS)
        if bundle.image(forResource: NSImage.Name(thinnableName)) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#elseif canImport(UIKit) && !os(watchOS)
        if UIKit.UIImage(named: thinnableName, in: bundle, compatibleWith: nil) != nil {
            self.init(name: thinnableName, bundle: bundle)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}

#if canImport(AppKit)
@available(macOS 14.0, *)
@available(macCatalyst, unavailable)
extension AppKit.NSImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !targetEnvironment(macCatalyst)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

#if canImport(UIKit)
@available(iOS 17.0, tvOS 17.0, *)
@available(watchOS, unavailable)
extension UIKit.UIImage {

    private convenience init?(thinnableResource: DeveloperToolsSupport.ImageResource?) {
#if !os(watchOS)
        if let resource = thinnableResource {
            self.init(resource: resource)
        } else {
            return nil
        }
#else
        return nil
#endif
    }

}
#endif

