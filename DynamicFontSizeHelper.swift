import UIKit

private var fontSizeMultiplier : CGFloat {
    switch UIApplication.shared.preferredContentSizeCategory {
    case UIContentSizeCategory.accessibilityExtraExtraExtraLarge: return 23 / 16
    case UIContentSizeCategory.accessibilityExtraExtraLarge: return 22 / 16
    case UIContentSizeCategory.accessibilityExtraLarge: return 21 / 16
    case UIContentSizeCategory.accessibilityLarge: return 20 / 16
    case UIContentSizeCategory.accessibilityMedium: return 19 / 16
    case UIContentSizeCategory.extraExtraExtraLarge: return 19 / 16
    case UIContentSizeCategory.extraExtraLarge: return 18 / 16
    case UIContentSizeCategory.extraLarge: return 17 / 16
    case UIContentSizeCategory.large: return 1.0
    case UIContentSizeCategory.medium: return 15 / 16
    case UIContentSizeCategory.small: return 14 / 16
    case UIContentSizeCategory.extraSmall: return 13 / 16
    default: return 1.0
    }
}

private class ContentSizeCategoryChangeManager {
    static let sharedInstance = ContentSizeCategoryChangeManager()
    
    typealias ContentSizeCategoryDidChangeCallback = () -> Void
    
    class Observer {
        weak var object: AnyObject?
        var block: ContentSizeCategoryDidChangeCallback
        
        init(object: AnyObject, block: @escaping ContentSizeCategoryDidChangeCallback) {
            self.object = object
            self.block = block
        }
    }
    
    fileprivate var observerPool: [Observer] = []
    
    fileprivate init() {
        NotificationCenter.default.addObserver(self, selector: #selector(contentSizeCategoryDidChange(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
    }
    
    func addCallback(_ observer: AnyObject, block: @escaping ContentSizeCategoryDidChangeCallback) {
        // Don't readd the call back.
        guard !observerPool.contains(where: { $0.object === observer }) else { return }
        
        // Run the block once to make sure the font size is initialized correctly.
        block()
        
        observerPool.append(Observer(object: observer, block: block))
    }
    
    @objc func contentSizeCategoryDidChange(_ notification: Notification) {
        DispatchQueue.main.async { [unowned self] in
            self.observerPool = self.observerPool.filter { $0.object != nil }
            self.observerPool.forEach { $0.block() }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

protocol FontSizeScalable: class {
    var scalableFont: UIFont { get set }
}

extension FontSizeScalable {
    fileprivate func registerForSizeChange(_ defaultFontSize: CGFloat? = nil) {
        let defaultFontSize = defaultFontSize ?? scalableFont.pointSize
        
        ContentSizeCategoryChangeManager.sharedInstance.addCallback(self) { [weak self] _ in
            guard let _self = self else { return }
            _self.scalableFont = UIFont(descriptor: _self.scalableFont.fontDescriptor, size: defaultFontSize * fontSizeMultiplier)
        }
    }
}

extension UILabel: FontSizeScalable {
    @IBInspectable var registerForSizeChangeWithDefaultFontSize: CGFloat {
        get {
            return 0.0
        }
        set {
            registerForSizeChange(newValue)
        }
    }
    
    var scalableFont: UIFont {
        get {
            return self.font
        }
        set {
            self.font = newValue
        }
    }
}
