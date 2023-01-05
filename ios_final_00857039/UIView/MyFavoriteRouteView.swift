//
//  MyFavoriteRouteView.swift
//  ios_final_00857039
//
//  Created by User04 on 2022/12/24.
//

import SwiftUI

struct MyFavoriteRouteView: View {
    
    @EnvironmentObject var saver: DataSaver
    @EnvironmentObject var fetcher: DataFetcher
    
    @State private var isEditRecordMode:EditMode = .inactive
    
    func deleteRecord(at offsets: IndexSet) {
        saver.MyFavoriteTRARoutes = saver.MyFavoriteTRARoutes.reversed()
        saver.MyFavoriteTRARoutes.remove(atOffsets: offsets)
        saver.MyFavoriteTRARoutes = saver.MyFavoriteTRARoutes.reversed()
    }
    func moveRecord(from source:IndexSet,to destination:Int) {
        saver.MyFavoriteTRARoutes = saver.MyFavoriteTRARoutes.reversed()
        saver.MyFavoriteTRARoutes.move(fromOffsets: source, toOffset: destination)
        saver.MyFavoriteTRARoutes = saver.MyFavoriteTRARoutes.reversed()
    }
    
    var today:String
    var currentTime:String
    
    init(){
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        today = dateFormatter.string(from: now)
        dateFormatter.dateFormat = "HH:00"
        currentTime = dateFormatter.string(from: now)
    }
    
    var body: some View {
        VStack{
            if saver.MyFavoriteTRARoutes.isEmpty{
                Label("編輯我的最愛路線",systemImage: "pencil")
                    .font(.custom(fontStyle, size: 16))
                    .frame(width: UIScreen.main.bounds.width/10*8, height: 40)
                    .background(Color.secondary)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.top,10)
            }else{
                Button{
                    if isEditRecordMode.isEditing{
                        isEditRecordMode = .inactive
                    }else if !saver.MyFavoriteTRARoutes.isEmpty{
                            isEditRecordMode = .active
                    }
                }label:{
                    Label(isEditRecordMode.isEditing ? "　　完成編輯　　" : "編輯我的最愛路線",systemImage: isEditRecordMode.isEditing ? "checkmark" : "pencil")
                        .font(.custom(fontStyle, size: 16))
                        .frame(width: UIScreen.main.bounds.width/10*8, height: 40)
                        .background(themeColors_Item[saver.ThemeColorID])
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.top,10)
            }
           
            if(!saver.MyFavoriteTRARoutes.isEmpty){
                Text("👇直接點擊路線將以目前時間查詢,或可設定時間")
                     .font(.custom(fontStyle, size: 12))
                     .foregroundColor(.secondary)
                    .padding(.top,10)
            }
            if(!saver.MyFavoriteTRARoutes.isEmpty){
                if isEditRecordMode.isEditing{
                        List{
                            ForEach(saver.MyFavoriteTRARoutes.reversed()){item in
                                HStack{
                                    FavoriteRouteRow(isEdited: $isEditRecordMode, originStationName: item.originStationName, destinationStationName: item.destinationStationName)
                                        //.frame(width: UIScreen.main.bounds.width-20)
                                        .padding(.leading,-2)
                                      
                                }.frame(height: 38.5)
                            }       .onDelete(perform: deleteRecord)
                            .onMove(perform: moveRecord)
                        }.padding(.leading,-6)
                }else{
                    ScrollView{
                        VStack(spacing: 0){
                            ForEach(saver.MyFavoriteTRARoutes.reversed()){item in
                                HStack{
                                    ZStack{
                                        NavigationLink(
                                            destination: TRAInquireResultView(originStationName: item.originStationName, destinationStationName: item.destinationStationName, inquireDate: today, departureTime: currentTime),
                                            label: {
                                                FavoriteRouteRow(isEdited: $isEditRecordMode, originStationName: item.originStationName, destinationStationName: item.destinationStationName)
                                                    .frame(width: UIScreen.main.bounds.width-20)
                                            })
                                        HStack{
                                            Spacer()
                                            NavigationLink(
                                                destination: TRAInquiryMainView(originStopName:item.originStationName,destinationStopName: item.destinationStationName),
                                                label: {
                                                    Text(" 設定時間 ")
                                                        .font(.custom(fontStyle, size: 14))
                                                        .frame(width:80,height: 35)
                                                        .background(themeColors_Item[saver.ThemeColorID])
                                                        .foregroundColor(.white)
                                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                                })
                                         
                                        }
                                    }.padding(.horizontal,10)
                                }.frame(height: 50)
                                Divider()
                            }
                            Spacer()
                        }
                    }
                }
            }else{
                VStack{
                    Text("(・∀・)")
                        .foregroundColor(.secondary)
                        .font(.custom(fontStyle, size: 20))
                        .padding(.top,UIScreen.main.bounds.height/10*3)
                    Text("目前沒有最愛路線")
                        .font(.custom(fontStyle, size: 20))
                        .foregroundColor(.secondary)
                    NavigationLink(
                        destination: TRAInquiryMainView(),
                        label: {
                            Text("按此查詢")
                                .font(.custom(fontStyle, size: 16))
                                 .frame(width: 90, height: 30)
                                 .background(themeColors_Item[saver.ThemeColorID])
                                 .foregroundColor(.white)
                                 .clipShape(RoundedRectangle(cornerRadius: 10))
                        })
                   
                    Spacer()
                }
            }
            
            
        }
        .onDisappear(){
            self.isEditRecordMode = .inactive
        }
        .environment(\.editMode, $isEditRecordMode)
        .navigationBarTitleDisplayMode(.inline)
        //.edgesIgnoringSafeArea(.top)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                HStack{
                    Text("我的最愛路線")
                        .font(.custom(fontStyle, size: 20))
                }
            }
        })
        
    }
}

struct FavoriteRouteRow:View{
    
    @Binding var isEdited:EditMode
    let originStationName:String
    let destinationStationName:String
    
    init(isEdited:Binding<EditMode>,originStationName:String,destinationStationName:String){
        self._isEdited = isEdited
        switch originStationName.count{
        case 2:
            self.originStationName = originStationName + "　　"
        case 3:
            self.originStationName = originStationName + "　"
        default:
            self.originStationName = originStationName
        }
        switch destinationStationName.count{
        case 2:
            self.destinationStationName = "　　" + destinationStationName
        case 3:
            self.destinationStationName = "　" + destinationStationName
        default:
            self.destinationStationName = destinationStationName
        }
    }
    
    var body: some View{
            HStack{
                
                VStack(alignment:.leading){
                    Text("\(originStationName)　➤　\(destinationStationName)")
                        .font(.custom(fontStyle, size: 18))
                        .foregroundColor(.primary)
                   /* */
                }
                Spacer()
            }
        
    }
}
