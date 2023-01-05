//
//  LearnMoreFromWebView.swift
//  ios_final_00857039
//
//  Created by User04 on 2023/1/5.
//

import SwiftUI
import WebKit

struct LearnMoreFromWebView: View {
    var body: some View {
        WebView()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .principal) {
                    HStack{
                        Text("關於App")
                            .font(.custom(fontStyle, size: 20))

                    }
                }
            })
    }
}

struct WebView:UIViewRepresentable{
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        if let url = URL(string: "https://medium.com/@wys899195/4%E6%9C%9F%E6%9C%AB%E5%B0%88%E6%A1%88-%E5%8F%B0%E9%90%B5%E6%9F%A5%E8%A9%A2app-b57222e1ade") {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        //do nothing
    }
    
    typealias UIViewType = WKWebView
}
