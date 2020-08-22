import Cocoa


/// A utility class for displaying Xcode-like notifications, aka bezel notifications.
/// It currently only supports displaying a given text that will be centered on screen, will remain on screen for a given interval,
/// then fade out.
public class BezelNotification {
    
    public var string: String {
        set { self.attributedString = NSAttributedString(string: newValue) }
        get { self.attributedString.string }
    }
    
    public var attributedString: NSAttributedString {
        didSet {
            label.attributedStringValue = attributedString
        }
    }
    
    let window: NSWindow
    let dismissInterval: TimeInterval?
    var label: NSTextField!
    
    /// Create a BezelNotification with the given text. It is not displayed until `show()` or `runModal()` is called.
    /// It is then dismissed based on the given dismissInterval or when `dismiss()` is called.
    ///
    /// - Parameters:
    ///   - text: The text displayed with regular weight and a font size of 18, on a single line.
    ///   - dismissInterval: If not nil, the bezel notification is automatically dismiss after this interval. Otherwise it
    /// remains visible until `dismiss()` is called.
    public init(text: NSAttributedString = NSAttributedString(string: ""),
                dismissInterval: TimeInterval? = 2.0) {
        self.attributedString = text
        self.window = NSWindow(contentRect: NSRect(origin: .zero, size: CGSize(width: 100, height: 100)),
                               styleMask: .borderless, backing: .buffered, defer: true)
        self.dismissInterval = dismissInterval
        buildUI()
    }
    
    convenience init(text: String = "", dismissInterval: TimeInterval? = 2.0) {
        self.init(text: NSAttributedString(string: text), dismissInterval: dismissInterval)
    }
    
    class NotificationSession {
        var cancelled = false
        let modal: Bool
        
        init(modal: Bool) {
            self.modal = modal
        }
    }
    
    var previousShowSession: NotificationSession?
    
    public var isVisible: Bool { window.isVisible && window.alphaValue != 0 }
    
    /// Show the notification then return. After 3 seconds, the notification will fade out.
    public func show() {
        fadeOutTimer?.invalidate()
        fadeOutTimer = nil
        previousShowSession?.cancelled = true
        
        let newSession = NotificationSession(modal: false)
        self.previousShowSession = newSession
        fadeIn(session: newSession)
        
        let alreadyVisible = self.isVisible
        window.makeKeyAndOrderFront(nil)
        
        if !alreadyVisible {
            window.center()
        }
    }
    
    public func dismiss() {
        guard let session = self.previousShowSession, !session.cancelled else { return }
        session.cancelled = true
        self.fadeOut(session: session)
    }
    
    /// Show the notification, wait 3 seconds and fade out. Does not return until the fade out is over.
    public func runModal() {
        fadeIn(session: NotificationSession(modal: true))
        NSApp.runModal(for: window)
    }
    
    func buildUI() {
        window.hasShadow = false
        window.level = .modalPanel
        window.hidesOnDeactivate = true
        window.backgroundColor = .clear
        window.alphaValue = 0
        
        let contentView = NSView(frame: self.window.frame)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.wantsLayer = true
        contentView.layer!.masksToBounds = true
        contentView.layer!.cornerRadius = 10.0
        
        self.window.contentView = contentView
        let visualEffectView = NSVisualEffectView(frame: self.window.frame)
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        visualEffectView.material = .hudWindow
        visualEffectView.state = .active
        contentView.addSubview(visualEffectView)
        NSLayoutConstraint.activate([
            visualEffectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            visualEffectView.topAnchor.constraint(equalTo: contentView.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        label = NSTextField(labelWithAttributedString: self.attributedString)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = NSFont.systemFont(ofSize: 18)
        label.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        visualEffectView.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: visualEffectView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: visualEffectView.trailingAnchor, constant: -10),
            label.topAnchor.constraint(equalTo: visualEffectView.topAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: visualEffectView.bottomAnchor, constant: -10)
        ])
    }
    
    static let fadeInAnimationDuration: TimeInterval = 0.1
    static let fadeOutAnimationDuration: TimeInterval = 0.5
    
    var fadeOutTimer: Timer?
    func fadeIn(session: NotificationSession) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = Self.fadeInAnimationDuration
            window.animator().alphaValue = 1.0
        }, completionHandler: {
            guard !session.cancelled, let dismissInterval = self.dismissInterval else {
                return
            }
            let timer = Timer(timeInterval: dismissInterval, repeats: false) { _ in
                guard !session.cancelled else {
                    return
                }
                self.fadeOut(session: session)
            }
            
            // For modal run loop
            RunLoop.current.add(timer, forMode: .common)
            self.fadeOutTimer = timer
        })
    }
    
    func fadeOut(session: NotificationSession) {
        session.cancelled = true
        window.alphaValue = 1.0
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = Self.fadeOutAnimationDuration
            window.animator().alphaValue = 0.0
        }, completionHandler: {
            if session.modal {
                NSApp.stopModal()
            }
        })
    }
}
