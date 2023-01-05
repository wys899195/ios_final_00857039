//
//  TRAInquiryMainView.swift
//  ios_final_00857039
//
//  Created by User20 on 2022/12/17.
//

import SwiftUI

struct TRAInquiryMainView: View {
    
    @EnvironmentObject var saver: DataSaver
    @EnvironmentObject var fetcher: DataFetcher
    
    @State private var showTimeSelectionView: Bool = false
    @State private var showDateSelectionView: Bool = false
    @State private var showStationSelectionView: Bool = false
    @State private var TRAInquiryDate:String = ""
    @State private var TRAInquiryDepartureTime:String = ""
    @State private var isOrigin: Bool = false
    @State private var showRecordDeleteAllAlert: Bool = false
    @State private var isEditRecordMode:EditMode = .inactive
    
    @State var originStopName:String = ""
    @State var destinationStopName:String = ""
    
    func deleteRecord(at offsets: IndexSet) {
        saver.TRAInquiryRecords = saver.TRAInquiryRecords.reversed()
        saver.TRAInquiryRecords.remove(atOffsets: offsets)
        saver.TRAInquiryRecords = saver.TRAInquiryRecords.reversed()
    }
    
    var body: some View {
        ZStack{
            themeColors_BackGround[saver.ThemeColorID]
            VStack{
                
                HStack{
                    VStack{
                        Button{
                            isOrigin = true
                            showStationSelectionView = true
                        }label:{
                            TowRingCircleButton_ChooseStation(StationName: saver.originStopNameForTRAinquiry, isOriginStop: true)
                                .sheet(isPresented: $showStationSelectionView){
                                    StationSelectionView(isOriginStation: $isOrigin, show: $showStationSelectionView)
                                        .environmentObject(saver)
                                        .environmentObject(fetcher)
                                }
                        }
                        Button{
                            showDateSelectionView = true
                        }label:{
                            DateSelectionLabel(titie: TRAInquiryDate, systemIcon: "calendar")
                                .sheet(isPresented: $showDateSelectionView){
                                    DateSelectionView(date: $TRAInquiryDate, show: $showDateSelectionView)
                                }
                        }.frame(minWidth: 120, maxWidth: .infinity)
                    }
                    VStack{
                        Button{
                            let temp:String = saver.originStopNameForTRAinquiry
                            saver.originStopNameForTRAinquiry = saver.destinationStopNameForTRAinquiry
                            saver.destinationStopNameForTRAinquiry = temp
                        }label:{
                            Image(systemName: "arrow.left.arrow.right")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .padding(.horizontal,15)
                        }
                    }.padding(EdgeInsets(top: 0, leading: -20, bottom: 25, trailing: -20))
                    
                    VStack{
                        Button{
                            isOrigin = false
                            showStationSelectionView = true
                        }label:{
                            TowRingCircleButton_ChooseStation(StationName: saver.destinationStopNameForTRAinquiry, isOriginStop: false)
                                .sheet(isPresented: $showStationSelectionView){
                                    StationSelectionView(isOriginStation: $isOrigin, show: $showStationSelectionView)
                                        .environmentObject(saver)
                                        .environmentObject(fetcher)
                                }
                        }
                        Button{
                            self.showTimeSelectionView = true
                        }label:{
                            DateSelectionLabel(titie: TRAInquiryDepartureTime + " 後出發", systemIcon: "clock")
                                .sheet(isPresented: $showTimeSelectionView){
                                    TimeSelectionView(departureTime: $TRAInquiryDepartureTime, show: $showTimeSelectionView)
                                }
                        }.frame(minWidth: 120, maxWidth: .infinity)
                    }
                    
                }
                .padding(EdgeInsets(top: 15, leading: 10, bottom: 0, trailing: 10))
                /*Rectangle()
                    .foregroundColor(themeColors_BackGround[saver.ThemeColorID])
                    .frame(height:4)*/
                NavigationLink(
                    destination: TRAInquireResultView(originStationName: saver.originStopNameForTRAinquiry, destinationStationName: saver.destinationStopNameForTRAinquiry, inquireDate: TRAInquiryDate, departureTime: TRAInquiryDepartureTime),
                    label: {
                        Label("查詢",systemImage:"magnifyingglass")
                            .font(.custom(fontStyle, size: 16))
                            .frame(width: UIScreen.main.bounds.width/10*8, height: 40)
                            .background(themeColors_Item[saver.ThemeColorID])
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.vertical,4)
                    })
                HStack{
                    Text("查詢紀錄").font(.custom(fontStyle, size: 24))
                    Spacer()
                    if isEditRecordMode.isEditing && !saver.TRAInquiryRecords.isEmpty{
                        Button{
                            showRecordDeleteAllAlert = true
                        }label:{
                            Label("清空", systemImage: "trash.slash")
                                .font(.custom(fontStyle, size: 16))
                                .foregroundColor(saver.TRAInquiryRecords.isEmpty ? .secondary : .red)
                        }
                        .disabled(saver.TRAInquiryRecords.isEmpty)
                        Button{
                            self.isEditRecordMode = .inactive
                        }label:{
                            Label("完成", systemImage: "checkmark")
                                .font(.custom(fontStyle, size: 16))

                                .foregroundColor(saver.TRAInquiryRecords.isEmpty ? .secondary : .green)
                        }
                        .padding(.trailing,5)
                        .disabled(saver.TRAInquiryRecords.isEmpty)
                    }else{
                        Button{
                            self.isEditRecordMode = .active
                        }label:{
                            Label("刪除", systemImage: "trash")
                                .font(.custom(fontStyle, size: 16))
                                .foregroundColor(saver.TRAInquiryRecords.isEmpty ? .secondary : .red)
                        }
                        .padding(.trailing,5)
                        .disabled(saver.TRAInquiryRecords.isEmpty)
                    }
                    
                    
                }
                .alert(isPresented: $showRecordDeleteAllAlert, content: {
                    Alert(title: Text("清空查詢記錄"), message: Text("確定刪除所有查詢記錄？"),
                          primaryButton:
                            .default(Text("取消")),
                          secondaryButton:
                            .destructive(Text("確定"), action: {
                                saver.TRAInquiryRecords.removeAll()
                                isEditRecordMode = .inactive
                            }))
                })
                .background(Color("contraryColor"))
                .offset(y:3)
                List{
                    if saver.TRAInquiryRecords.isEmpty{
                        HStack{
                            Spacer()
                            Text("目前沒有查詢記錄")
                                .font(.custom(fontStyle, size: 20))
                                .foregroundColor(.secondary)
                            Spacer()
                        }
                    }else{
                        if isEditRecordMode.isEditing{
                            ForEach(Array(saver.TRAInquiryRecords.reversed().enumerated()),id:\.element.id){ index,item in
                                HStack{
                                    RecordRow(originStationName: item.originStationName, destinationStationName: item.destinationStationName, inquireDate: item.inquireDate, departureTime: item.departureTime, isLastRecord: false)
                                    Spacer()
                                    Text("⇠左滑刪除")
                                        .font(.custom(fontStyle, size: 15))
                                        .foregroundColor(.secondary)
                                }
                            }
                            .onDelete(perform: deleteRecord)
                        }else{
                            ForEach(Array(saver.TRAInquiryRecords.reversed().enumerated()),id:\.element.id){ index,item in
                                if(index == 0){
                                    NavigationLink(
                                        destination: TRAInquireResultView(originStationName: item.originStationName, destinationStationName: item.destinationStationName, inquireDate: item.inquireDate, departureTime: item.departureTime),
                                        label: {
                                            RecordRow(originStationName: item.originStationName, destinationStationName: item.destinationStationName, inquireDate: item.inquireDate, departureTime: item.departureTime, isLastRecord: true)
                                        })
                                }else{
                                    NavigationLink(
                                        destination: TRAInquireResultView(originStationName: item.originStationName, destinationStationName: item.destinationStationName, inquireDate: item.inquireDate, departureTime: item.departureTime),
                                        label: {
                                            RecordRow(originStationName: item.originStationName, destinationStationName: item.destinationStationName, inquireDate: item.inquireDate, departureTime: item.departureTime, isLastRecord:false)
                                        })
                                }
                            }
                        }
                    }
                    
                        
                    
                }
                .padding(.top,-5)
            }
        }
        .onAppear(){
            if(self.originStopName != ""){
                saver.originStopNameForTRAinquiry = self.originStopName
                self.originStopName = ""
            }
            if(self.destinationStopName != ""){
                saver.destinationStopNameForTRAinquiry = self.destinationStopName
                self.destinationStopName = ""
            }
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            TRAInquiryDate = dateFormatter.string(from: now)
            dateFormatter.dateFormat = "HH:00"
            TRAInquiryDepartureTime  = dateFormatter.string(from: now)
            
            if(fetcher.trainStationInformationDataItems.isEmpty){
                fetcher.getTrainStationID()
            }
            
        }
        .onDisappear(){
            self.isEditRecordMode = .inactive
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                Text("台鐵查詢")
                    .font(.custom(fontStyle, size: 20))
            }
        })
        //.edgesIgnoringSafeArea(.top)
    }
}

struct TRAInquiryMainView_Previews: PreviewProvider {
    static var previews: some View {
        TRAInquiryMainView()
    }
}

struct TowRingCircleButton_ChooseStation: View {
    
    var StationName:String
    let isOriginStop:Bool
    
    var body: some View {
        VStack{
            ZStack{
                switch StationName.count {
                case 2:
                    Text(StationName)
                        .font(.custom(fontStyle, size: 32))
                case 3:
                    Text(StationName)
                        .font(.custom(fontStyle, size: 27))
                case 4:
                    Text(StationName)
                        .font(.custom(fontStyle, size: 22))
                default:
                    Text(StationName)
                        .font(.custom(fontStyle, size: 16))
                }
                Text(isOriginStop ? "出發站" : "到達站")
                    .font(.custom(fontStyle, size: 14))
                    .padding(.bottom,60)
            }
            .frame(width: 100, height: 100)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .strokeBorder(Color.white, lineWidth: 6)
            )
            .foregroundColor(.white)
        }
        .frame(width: 120, height: 120)
        .clipShape(Circle())
        .overlay(
            Circle()
                .strokeBorder(Color.white, lineWidth: 2)
        )
    }
}

struct DateSelectionLabel: View {
    
    let titie:String
    let systemIcon:String
    
    var body: some View {
        Label(
            title: {
                Text(titie)
                    .font(.custom(fontStyle, size: 16))
            },
            icon: {
                Image(systemName: systemIcon)
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        )
        .foregroundColor(.white)
    }
}

struct RecordRow:View{
    
    let originStationName:String
    let destinationStationName:String
    let inquireDate:String
    let departureTime:String
    let isLastRecord:Bool
    
    init(originStationName:String,destinationStationName:String,inquireDate:String,departureTime:String,isLastRecord:Bool){
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
        self.inquireDate = inquireDate
        self.departureTime = departureTime
        self.isLastRecord = isLastRecord
    }
    
    var body: some View{
        HStack{
            VStack(alignment:.leading){
                Text("\(originStationName) ➤ \(destinationStationName)")
                    .font(.custom(fontStyle, size: 18))
                HStack {
                    Image(systemName: "figure.walk")
                        .foregroundColor(Color.secondary)
                    Text("出發時間：\(inquireDate)  \(departureTime)")
                        .font(.custom(fontStyle, size: 12))
                        .foregroundColor(Color.secondary)
                }
            }
            if(isLastRecord == true){
                Spacer()
                VStack{
                    Text("最新")
                        .font(.custom(fontStyle, size: 14))
                        .foregroundColor(Color.secondary)
                    Text("紀錄")
                        .font(.custom(fontStyle, size: 14))
                        .foregroundColor(Color.secondary)
                }
            }
        }
    }
}
