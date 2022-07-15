import Cocoa
import Foundation

public protocol WindowLogger {
    func log(msg: String)
}

public class WindowManager {
    static let shared = WindowManager()
    
    private(set) var activeWindows: [String : NSWindowController] = [:]
    
    /// The number of windows added in total
    /// This number doesn't decrease as windows are removed
    /// Ensures every new window will have a unique window Id
    private(set) var uniqueId: UInt = 0
    
    /// Simple structure to handle logging
    /// Assign to enable logging
    var logger: WindowLogger?
    
    private init() {}
    
    /// Creates a new window and adds as managed window
    @discardableResult func create(
        delegate: NSWindowDelegate?,
        root: NSViewController,
        shouldShow: Bool = true
    ) -> String {
        let window = self.create(delegate: delegate, root: root)
        let id = window.identifier!.rawValue
        
        _ = self.add(window)
        logger?.log(msg: "Window created with id: \(id)")
        
        if (shouldShow) {
            self.show(window)
        }
        
        return id
    }
    
    /// Wraps a custom window in controller and appends to manager. If the window doesn't have an identifier or the identifer
    /// is already taken the window is assigned a new identifer.
    /// This new identifer is returned in such cases otherwise nil
    func add(_ window: NSWindow) -> String? {
        var windowId: String!
        var override: String?
        
        if let id = window.identifier?.rawValue,
           self.activeWindows[id] == nil {
            windowId = id
        }
        else {
            override = self.newId()
            windowId = override
        }
        
        let windowController = NSWindowController(window: window)
        self.activeWindows[windowId] = windowController
        return override
    }
    
    /// Removes a given window from the manager
    func remove(with id: String) {
        self.activeWindows[id]?.window?.close()
        self.activeWindows[id]?.close()
        self.activeWindows.removeValue(forKey: id)
    }
    
    /// Removes a given window from the manager
    func remove(_ window: NSWindow) {
        guard let id = window.identifier?.rawValue else {
            logger?.log(msg: "Window must have an id \(#function)")
            return
        }
        self.remove(with: id)
    }
    
    /// Removes key window if present in active manged windows
    func removeKeyWindow() {
        logger?.log(msg: "Removing Key Window")
        guard let keyWindow = self.getKeyWindow() else {
            return
        }
        self.remove(keyWindow)
    }
    
    /// Returns the key window from all active managed windows
    func getKeyWindow() -> NSWindow? {
        for key in Array(self.activeWindows.keys) {
            guard let window = self.activeWindows[key]?.window else {
                continue
            }
            
            if window.isKeyWindow {
                return window
            }
        }
        
        logger?.log(msg: "No key window found")
        return nil
    }
    
    /// Orders the showing of the window with given id
    func show(_ id: String) {
        guard let window = self.activeWindows[id]?.window else {
            logger?.log(msg: "Must have controller for id: \(id) or window controller must have window")
            return
        }
        self.show(window)
    }
    
    private func create(delegate: NSWindowDelegate?, root: NSViewController) -> NSWindow {
        let window = NSWindow()
        let id = self.newId()
        
        if let delegate = delegate {
            window.delegate = delegate
        }
        else {
            logger?.log(msg: "Warning no delegate on new window with id: \(id)")
        }
        window.contentViewController = root
        window.identifier = NSUserInterfaceItemIdentifier(rawValue: id)
        return NSWindow()
    }

    private func show(_ window: NSWindow) {
        guard let id = window.identifier?.rawValue else {
            logger?.log(msg: "Window must have an id \(#function)")
            return
        }
        window.makeKeyAndOrderFront(self.activeWindows[id])
    }
    
    private func newId() -> String {
        let id = "WINDOW_\(self.uniqueId)"
        self.uniqueId += 1
        return id
    }
}

