//
//  DateSelectionView.swift
//  ios_final_00857039
//
//  Created by User04 on 2022/12/22.
//

import SwiftUI

struct DateSelectionView: View {
    @EnvironmentObject var saver: DataSaver
    
    @Binding var date:String
    @Binding var show:Bool
    
    @State private var settingDate:String = ""
    
    @State private var datesAboutTRAInquiry:[String] = []
    
    func initialize(){
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        for i in 0...30{
            let futureDate = Calendar.current.date(byAdding: .day, value: i, to: today)!
            datesAboutTRAInquiry.append(dateFormatter.string(from: futureDate))
        }
        settingDate = date
    }
    var body: some View {
        VStack{
            Text("選擇出發日期")
                .font(.custom(fontStyle, size: 26))
                .foregroundColor(.primary)
    
                .foregroundColor(Color.black)
            Picker(selection: $settingDate,label: Text("")) {
                ForEach(Array(datesAboutTRAInquiry.enumerated()), id: \.element) { index,date in
                    Text(date).tag(index)
                }
            }
        
            HStack{
                Button{
                    show = false
                }label:{
                    Text("取消")
                        .font(.custom(fontStyle, size: 20))
                        .frame(width: UIScreen.main.bounds.width/20*9, height: 40)
                        .background(Color.gray)
                        .foregroundColor(.primary)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                Button{
                    date = settingDate
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
            print(settingDate)
            initialize()
           
            //settingDepartureTime = departureTime
        }
    }
}

