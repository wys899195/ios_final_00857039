//
//  WeatherLocationSelectView.swift
//  ios_final_00857039
//
//  Created by User04 on 2022/12/27.
//

import SwiftUI

struct WeatherLocationSelectView: View {
    @EnvironmentObject var saver: DataSaver

    @Binding var show:Bool
    
    @State private var settingCity:String = ""
    
    var locationCitys:[String] = ["基隆市","臺北市","新北市","桃園市","新竹縣","新竹市","苗栗縣","臺中市",
                                  "彰化縣","雲林縣","嘉義縣","嘉義市","臺南市","高雄市","屏東縣","臺東縣",
                                  "花蓮縣","宜蘭縣","南投縣","澎湖縣","金門縣","連江縣"]
    var body: some View {
        VStack{
            Text("選擇城市")
                .font(.custom(fontStyle, size: 26))
                .foregroundColor(.primary)
            Picker(selection: $settingCity,label: Text("")) {
                ForEach(Array(locationCitys.enumerated()), id: \.element) { index,city in
                    Text(city).tag(index)
                }
            }
            HStack{
                Button{
                    show = false
                    settingCity = saver.weatherLocationCity
                }label:{
                    Text("取消")
                        .font(.custom(fontStyle, size: 20))
                        .frame(width: UIScreen.main.bounds.width/20*9, height: 40)
                        .background(Color.gray)
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button{
                    saver.weatherLocationCity = settingCity
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
            settingCity = saver.weatherLocationCity
        }
    }
}
