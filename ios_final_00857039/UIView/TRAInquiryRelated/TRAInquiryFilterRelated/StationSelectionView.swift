//
//  StationSelectionView.swift
//  ios_final_00857039
//
//  Created by User04 on 2022/12/21.
//

import SwiftUI

struct StationSelectionView: View {
    
    @EnvironmentObject var fetcher: DataFetcher
    @EnvironmentObject var saver: DataSaver
    
    @Binding var isOriginStation:Bool
    @Binding var show:Bool
    
    let stationLocationCitys:[String] = [
        "基隆市","新北市","臺北市","桃園市","新竹縣",
        "新竹市","苗栗縣","臺中市","彰化縣","南投縣",
        "雲林縣","嘉義縣","嘉義市","臺南市","高雄市",
        "屏東縣","臺東縣","花蓮縣","宜蘭縣"
    ]
    
    @State private var searchText = ""
    @State private var isExpandeds:[Bool] = [
        false,false,false,false,false,
        false,false,false,false,false,
        false,false,false,false,false,
        false,false,false,false
    ]
    
    var trainStationInformationDataItems:[TrainStationInformationData]{
        var items = [TrainStationInformationData]()
        for item in fetcher.trainStationInformationDataItems {
            items.append(item)
        }
        return items
    }
    
    var searchResult: [TrainStationInformationData] {
        if searchText.isEmpty {
            return []
        } else {
            var temp = fetcher.trainStationInformationDataItems.filter {
                $0.StationName.Zh_tw.contains(searchText)
            }
            for item in fetcher.trainStationInformationDataItems{
                if(item.StationName.En).contains(searchText){
                    temp.append(item)
                }
            }
            return temp
        }
    }
    
    var body: some View {
        ZStack{
            VStack{
                Text(isOriginStation ? "選擇出發車站" : "選擇到達車站")
                    .font(.custom(fontStyle, size: 26))
                    .foregroundColor(.primary)
                    .padding(.top,20)
                
                TabView {
                    List {
                        ForEach(Array(stationLocationCitys.enumerated()), id: \.element){ index,LocationCity in
                            DisclosureGroup(isExpanded: $isExpandeds[index], content: {
                                ForEach(trainStationInformationDataItems,id:\.StationID) { item in
                                    if(item.LocationCity == LocationCity){
                                        if(isOriginStation == true && item.StationName.Zh_tw != saver.destinationStopNameForTRAinquiry){
                                            Button{
                                                saver.originStopNameForTRAinquiry = item.StationName.Zh_tw
                                                show = false
                                            }label:{
                                                StationRow(StationName:item.StationName.Zh_tw,pinColor:themeColors_Item[saver.ThemeColorID])
                                            }
                                        }
                                        else if(isOriginStation == false && item.StationName.Zh_tw != saver.originStopNameForTRAinquiry){
                                            Button{
                                                saver.destinationStopNameForTRAinquiry = item.StationName.Zh_tw
                                                show = false
                                            }label:{
                                                StationRow(StationName:item.StationName.Zh_tw,pinColor:themeColors_Item[saver.ThemeColorID])
                                            }
                                        }
                                    }
                                }
                            }) {
                                ZStack{
                                    Rectangle()
                                        .foregroundColor(Color("contraryColor"))
                                    HStack{
                                        Text(LocationCity).font(.custom(fontStyle, size: 24))
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                }
                                .onTapGesture {
                                    withAnimation {
                                        isExpandeds[index].toggle()
                                    }
                                }
                            }
                        }
                    }
                    .frame(width:UIScreen.main.bounds.width/10*9)
                    .tabItem {
                        Label("縣市分類", systemImage: "map")
                    }
                    VStack{
                        TextField("搜尋車站", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        List{
                            ForEach(searchResult,id:\.StationID){item in
                                if(isOriginStation == true && item.StationName.Zh_tw != saver.destinationStopNameForTRAinquiry){
                                    Button{
                                        saver.originStopNameForTRAinquiry = item.StationName.Zh_tw
                                        show = false
                                    }label:{
                                        StationRow(StationName:item.StationName.Zh_tw,pinColor:themeColors_Item[saver.ThemeColorID])
                                    }
                                }
                                else if(isOriginStation == false && item.StationName.Zh_tw != saver.originStopNameForTRAinquiry){
                                    Button{
                                        saver.destinationStopNameForTRAinquiry = item.StationName.Zh_tw
                                        show = false
                                    }label:{
                                        StationRow(StationName:item.StationName.Zh_tw,pinColor:themeColors_Item[saver.ThemeColorID])
                                    }
                                }
                            }
                        }
                    }
                    .frame(width:UIScreen.main.bounds.width/10*9)
                    .tabItem {
                        Label("文字搜尋", systemImage: "magnifyingglass")
                    }
                }
            }
        }
        .onAppear{
            if(fetcher.trainStationInformationDataItems.isEmpty){
                fetcher.getTrainStationID()
            }
        }
    }
}

struct StationRow:View{
    
    let StationName:String
    let pinColor:Color
    
    var body: some View{
        HStack{
            Image(systemName:"mappin.and.ellipse")
                .foregroundColor(pinColor)
            Text(StationName)
                .foregroundColor(.primary)
        }
    }
}
