//
//  WebView.swift
//  tweetdecker
//
//  Created by いちご on 2022/06/09.
//

import SwiftUI
import AppKit
import WebKit

struct WebView: NSViewRepresentable {
    
    public typealias NSViewType = WKWebView
    @ObservedObject var viewModel: WebViewModel

    private let webView: WKWebView = WKWebView()
    
    public func makeNSView(context: NSViewRepresentableContext<WebView>) -> WKWebView {
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator as? WKUIDelegate
        webView.load(URLRequest(url: viewModel.url))
        
        return webView
    }

    public func updateNSView(_ nsView: WKWebView, context: NSViewRepresentableContext<WebView>) { }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(viewModel)
    }
    
    class Coordinator: NSObject, WKNavigationDelegate {
        private var viewModel: WebViewModel

        init(_ viewModel: WebViewModel) {
           self.viewModel = viewModel
        }

        // ページ読み込み後に呼ばれる
        public func webView(_ web: WKWebView, didFinish: WKNavigation!) {
            viewModel.url = web.url!
            viewModel.pageTitle = web.title!
            
            viewModel.didFinishLoading = true
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            if navigationAction.navigationType == .linkActivated  {
                if let url = navigationAction.request.url {
                    // TweetDeckかTwitter認証のとき以外はSafariなど外部ブラウザで開く
                    // TODO: Googleアカウントからの認証に対応させる
                    if let host = url.host, !host.hasPrefix("tweetdeck.twitter.com"), !url.absoluteString.hasPrefix("https://mobile.twitter.com/login?") {
                        NSWorkspace.shared.open(url)
                        decisionHandler(.cancel)
                        return
                    } else {
                        let request = URLRequest(url:url)
                        webView.load(request)
                        decisionHandler(.allow)
                    }
                } else {
                    decisionHandler(.cancel)
                    return
                }
            } else {
                decisionHandler(.allow)
                return
            }
        }
    }
}

class WebViewModel: ObservableObject {
    @Published var url: URL
    @Published var pageTitle: String
    @Published var didFinishLoading: Bool = false
    
    init (url: URL) {
        self.url = url
        self.pageTitle = ""
    }
}
