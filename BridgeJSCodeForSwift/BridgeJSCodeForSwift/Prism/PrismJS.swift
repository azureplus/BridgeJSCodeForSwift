//
//  PrismJS.swift
//  BridgeJSCodeForSwift
//
//  Created by anthann on 2019/3/14.
//  Copyright © 2019 anthann. All rights reserved.
//

import Foundation
import JavaScriptCore

class PrismJS {
    private let jsContext = JSContext()!
    
    init() {
        jsContext.exceptionHandler = { (ctx: JSContext!, value: JSValue!) in
            print(value!.toString())
        }
        guard let componentUrl = Bundle.main.url(forResource: "components", withExtension: "js", subdirectory: "prism")  else {
            fatalError()
        }
        jsContext.evaluateScript(try! String(contentsOf: componentUrl), withSourceURL: componentUrl)
        guard let prismUrl = Bundle.main.url(forResource: "prism-core", withExtension: "js", subdirectory: "prism/components") else {
            fatalError()
        }
        jsContext.evaluateScript(try! String(contentsOf: prismUrl), withSourceURL: prismUrl)
        
        if let markupUrl = Bundle.main.url(forResource: "prism-markup", withExtension: "js", subdirectory: "prism/components") {
            jsContext.evaluateScript(try! String(contentsOf: markupUrl), withSourceURL: markupUrl)
        }
        if let clikeUrl = Bundle.main.url(forResource: "prism-clike", withExtension: "js", subdirectory: "prism/components") {
            jsContext.evaluateScript(try! String(contentsOf: clikeUrl), withSourceURL: clikeUrl)
        }
        if let javascriptUrl = Bundle.main.url(forResource: "prism-javascript", withExtension: "js", subdirectory: "prism/components") {
            jsContext.evaluateScript(try! String(contentsOf: javascriptUrl), withSourceURL: javascriptUrl)
        }
        jsContext.globalObject.setObject("javascript" as NSString, forKeyedSubscript: "lang" as NSString)
    }
    
    public func highlight(_ text: String) -> String {
        jsContext.globalObject.setObject(text as NSString, forKeyedSubscript: "input" as NSString)
        guard let prism = jsContext.globalObject.objectForKeyedSubscript("Prism") else {
            return text
        }
        guard let grammar = prism.objectForKeyedSubscript("languages")?.objectForKeyedSubscript("javascript") else {
            return text
        }
        guard let ret = prism.invokeMethod("highlight", withArguments: [text, grammar, "javascript"]) else {
            return text
        }
        if let str = ret.toString() {
            return str
        } else {
            return text
        }
    }
    
    public func style(code: String, theme: String = "prism") -> NSAttributedString {
        guard let themeUrl = Bundle.main.url(forResource: theme, withExtension: "css", subdirectory: "prism/themes") else {
            return NSAttributedString(string: code)
        }
        let styleString = try! String(contentsOf: themeUrl)
        let html = "<style>" + styleString + "</style><pre><code class=\"language-javascript\">" + code + "</code></pre>"
        let opt: [NSAttributedString.DocumentReadingOptionKey : Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        guard let data = html.data(using: .utf8) else {
            return NSAttributedString(string: code)
        }
        do {
            let attributedStr = try NSAttributedString(data: data, options: opt, documentAttributes: nil)
            return attributedStr
        } catch {
            return NSAttributedString(string: code)
        }
        
    }
}
