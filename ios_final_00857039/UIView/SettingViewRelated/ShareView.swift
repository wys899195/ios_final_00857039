//
//  ShareView.swift
//  ios_final_00857039
//
//  Created by User04 on 2023/1/1.
//

import SwiftUI

struct ShareView : UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: ["台鐵查詢App",URL(string:"https://medium.com/@wys899195/4%E6%9C%9F%E6%9C%AB%E5%B0%88%E6%A1%88-%E5%8F%B0%E9%90%B5%E6%9F%A5%E8%A9%A2app-b57222e1ade")!],applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        //do nothing
    }
    
    typealias UIViewControllerType = UIActivityViewController
}

