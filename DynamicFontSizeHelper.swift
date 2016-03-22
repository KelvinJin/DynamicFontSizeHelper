import UIKit

private var fontSizeMultiplier : CGFloat {
    switch UIApplication.sharedApplication().preferredContentSizeCategory {
    case UIContentSizeCategoryAccessibilityExtraExtraExtraLarge: return 23 / 16
    case UIContentSizeCategoryAccessibilityExtraExtraLarge: return 22 / 16
    case UIContentSizeCategoryAccessibilityExtraLarge: return 21 / 16
    case UIContentSizeCategoryAccessibilityLarge: return 20 / 16
    case UIContentSizeCategoryAccessibilityMedium: return 19 / 16
    case UIContentSizeCategoryExtraExtraExtraLarge: return 19 / 16
    case UIContentSizeCategoryExtraExtraLarge: return 18 / 16
    case UIContentSizeCategoryExtraLarge: return 17 / 16
    case UIContentSizeCategoryLarge: return 1.0
    case UIContentSizeCategoryMedium: return 15 / 16
    case UIContentSizeCategorySmall: return 14 / 16
    case UIContentSizeCategoryExtraSmall: return 13 / 16
    default: return 1.0
    }
}

private class ContentSizeCategoryChangeManager {
    static let sharedInstance = ContentSizeCategoryChangeManager()
    
    typealias ContentSizeCategoryDidChangeCallback = () -> Void
    
    class Observer {
        weak var object: AnyObject?
        var block: ContentSizeCategoryDidChangeCallback
        
        init(object: AnyObject, block: ContentSizeCategoryDidChangeCallback) {
            self.object = object
            self.block = block
        }
    }
    
    private var observerPool: [Observer] = []
    
    private init() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(contentSizeCategoryDidChange(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)
    }
    
    func addCallback(observer: AnyObject, block: ContentSizeCategoryDidChangeCallback) {
        // Don't readd the call back.
        guard !observerPool.contains({ $0.object === observer }) else { return }
        
        // Run the block once to make sure the font size is initialized correctly.
        block()
        
        observerPool.append(Observer(object: observer, block: block))
    }
    
    @objc func contentSizeCategoryDidChange(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue()) { [unowned self] in
            self.observerPool = self.observerPool.filter { $0.object != nil }
            self.observerPool.forEach { $0.block() }
        }
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}

protocol FontSizeScalable: class {
    var scalableFont: UIFont { get set }
}

extension FontSizeScalable {
    private func registerForSizeChange(defaultFontSize: CGFloat? = nil) {
        let defaultFontSize = defaultFontSize ?? scalableFont.pointSize
        
        ContentSizeCategoryChangeManager.sharedInstance.addCallback(self) { [weak self] _ in
            guard let _self = self else { return }
            _self.scalableFont = UIFont(descriptor: _self.scalableFont.fontDescriptor(), size: defaultFontSize * fontSizeMultiplier)
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
