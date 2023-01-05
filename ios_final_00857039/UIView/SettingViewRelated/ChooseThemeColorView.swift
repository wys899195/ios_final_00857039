//
//  ChooseThemeColorView.swift
//  ios_final_00857039
//
//  Created by User04 on 2023/1/1.
//

import SwiftUI

struct ChooseThemeColorView: View {
    
    @EnvironmentObject var saver: DataSaver
    
    @State private var themeColorID:Int = 0
    @State private var showChangeColorAlert:Bool = false
    
    @Binding var mainViewBarColor: Color
    @State private var mainViewOriginBarColor: Color = Color.white
    
    var body: some View {
        VStack{
            let columns = Array(repeating: GridItem(), count: 2)
            LazyVGrid(columns: columns, spacing: 30) {
                ForEach(0..<4){index in
                    Button{
                        if index != saver.ThemeColorID {
                            showChangeColorAlert = true
                            themeColorID = index
                        }

                    }label:{
                        ZStack{
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 100, height: 100)
                                .foregroundColor(themeColors_Item[index])
                            Text(saver.ThemeColorID == index ? "✔️" : "")//YYY
                        }
                    }
                }
            }
            .frame(width: 250, height: 250)
            //.position(x: UIScreen.main.bounds.width/2, y: UIScreen.main.bounds.height/2)
        }
        .alert(isPresented: $showChangeColorAlert) {
            Alert(title: Text("確定要更改App主題顏色嗎？"),
                  primaryButton: .default(Text("取消"),action: {
                    themeColorID = saver.ThemeColorID
                  }),
                  secondaryButton: .destructive(Text("確定"),action: {
                    if themeColorID > -1 && themeColorID < 4{
                        saver.ThemeColorID = themeColorID
                    }
                    
                  }))
        }
        .onAppear(){
            themeColorID = saver.ThemeColorID
            mainViewOriginBarColor = mainViewBarColor
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                HStack{
                    Text("選擇App主題顏色")
                        .font(.custom(fontStyle, size: 20))

                }
            }
        })
    }
    
}

