//
//  ios_final_00857039App.swift
//  ios_final_00857039
//
//  Created by User20 on 2022/12/4.
//

import SwiftUI

@main
struct ios_final_00857039App: App {

    @StateObject private var saver = DataSaver()
    @StateObject private var fetcher = DataFetcher()
    
    var body: some Scene {
        WindowGroup {
            //DataFetcher().environmentObject(saver)
            ContentView()
                .environmentObject(saver)
                .environmentObject(fetcher)
        }
    }
}
