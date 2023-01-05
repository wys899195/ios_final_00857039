//
//  TimeSelectionView.swift
//  ios_final_00857039
//
//  Created by User20 on 2022/12/17.
//

import SwiftUI

struct TimeSelectionView: View {
    @EnvironmentObject var saver: DataSaver
    
    @Binding var departureTime:String
    @Binding var show:Bool
    
    @State private var settingDepartureTime:String = ""
    
    let timesAboutTRAInquiry = ["00:00","01:00","02:00","03:00","04:00","05:00","06:00","07:00","08:00","09:00",
                                "10:00","11:00","12:00","13:00","14:00","15:00","16:00","17:00","18:00","19:00",
                                "20:00","21:00","22:00","23:00"]
    var body: some View {
        VStack{
            Text("選擇出發時間")
                .font(.custom(fontStyle, size: 26))
                .foregroundColor(.primary)
            Picker(selection: $settingDepartureTime,label: Text("")) {
                ForEach(Array(timesAboutTRAInquiry.enumerated()), id: \.element) { index,time in
                    Text(time).tag(index)
                }
            }
            HStack{
                Button{
                    show = false
                    settingDepartureTime = departureTime
                }label:{
                    Text("取消")
                        .font(.custom(fontStyle, size: 20))
                        .frame(width: UIScreen.main.bounds.width/20*9, height: 40)
                        .background(Color.gray)
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button{
                    departureTime =  settingDepartureTime
                    show = false
                }label:{
                    Text("確定")
                        .font(.custom(fontStyle, size: 20))
                        .frame(width: UIScreen.main.bounds.width/20*9, height: 40)
                        .background(themeColors_Item[saver.ThemeColorID])
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            
        }
        .onAppear(){
            settingDepartureTime = departureTime
        }
    }
}


