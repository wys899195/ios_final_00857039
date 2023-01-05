//
//  TRAInquireResultView.swift
//  ios_final_00857039
//
//  Created by User20 on 2022/12/19.
//
//參考網址
//1.loding畫面隱藏功能：https://stackoverflow.com/questions/64878620/swiftui-progress-view-hidden
//2.loding時的Timer:https://juejin.cn/post/6981714936770592775
//3.停止Timer:https://juejin.cn/post/6844904131556016135
import SwiftUI

struct TRAInquireResultView: View {
    
    @EnvironmentObject var saver: DataSaver
    @EnvironmentObject var fetcher: DataFetcher
    
    var originStationName:String
    var destinationStationName:String
    var inquireDate:String
    var departureTime:String
    
    @State private var originStationID:String = "1000"
    @State private var destinationStationID:String = "4400"
    @State private var tramIsHiddens:[Bool] = [true,true,true,true,true]
    @State private var resultHiddens:Bool = false
    @State private var progressValue:CGFloat = 0
    @State private var isFavoriteRoute:Bool = false
    @State private var showFavoriteDeleteAlert: Bool = false
    @State private var updateButtonIsHidden:Bool = false
    @State private var updateButtonHiddenTime:Int = 3
    @State private var inquireDatee:String = "" //若原本查詢日期(inquireDate)是今天以前,則改成今天(inquireDatee)
    @State private var showRowDetail:Bool = false
    
    @State private var resultRowDetail_trainNumber:String = ""
    @State private var resultRowDetail_startingStopName:String = ""
    @State private var resultRowDetail_endingStopName:String = ""
    @State private var resultRowDetail_note:String = ""
    /*@State private var resultRowDetail_tempTRAInquiryResultItem:OriginDestinationTrainData = OriginDestinationTrainData(TrainDate: "", DailyTrainInfo: OriginDestinationTrainData.DailyTrainInfoData(TrainNo: "", StartingStationName: StationNameData(Zh_tw: "", En: ""), EndingStationName: StationNameData(Zh_tw: "", En: ""), TrainTypeID: "", Note: OriginDestinationTrainData.DailyTrainInfoData.NoteData(Zh_tw: "")), OriginStopTime: OriginDestinationTrainData.StopTimeData(StationName: StationNameData(Zh_tw: "", En: ""), DepartureTime: ""), DestinationStopTime: OriginDestinationTrainData.StopTimeData(StationName: StationNameData(Zh_tw: "", En: ""), DepartureTime: ""))*/
    func configureBackground() {
        let barAppearance = UINavigationBarAppearance()
        barAppearance.backgroundColor = UIColor(themeColors_BackGround[saver.ThemeColorID])
        UINavigationBar.appearance().standardAppearance = barAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = barAppearance
    }
    
    var originDestinationTrainDataItems:[OriginDestinationTrainData]{
        var items = [OriginDestinationTrainData]()
        for item in fetcher.originDestinationTrainDataItems {
            items.append(item)
        }
        return items
    }
    
    var body: some View {
        VStack{
            
            if(fetcher.isGettingOriginToDestinationStationTrain){
                ZStack{
                    VStack{
                        Text("查詢中,請稍候")
                            .font(.custom(fontStyle, size: 24))
                            .foregroundColor(.secondary)
                        HStack{
                            Image(systemName: "tram")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .isHidden(tramIsHiddens[1])
                            Image(systemName: "tram")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .isHidden(tramIsHiddens[2])
                            Image(systemName: "tram")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .isHidden(tramIsHiddens[3])
                            Image(systemName: "tram")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .isHidden(tramIsHiddens[4])
                        }
                    }
                    VStack{
                        HStack{
                            if(isFavoriteRoute == true){
                                Button{
                                    isFavoriteRoute = false
                                    if(saver.MyFavoriteTRARoutes.count > 0){
                                        var i = 0
                                        for item in saver.MyFavoriteTRARoutes{
                                            if (item.originStationName == self.originStationName && item.destinationStationName == self.destinationStationName){
                                                print(i)
                                                saver.MyFavoriteTRARoutes.remove(at: i)
                                                break
                                            }
                                            i += 1
                                        }
                                    }
                                }label:{
                                    Label("從最愛路線移除",systemImage:"heart.fill")
                                        .font(.custom(fontStyle, size: 16))
                                        .frame(width: UIScreen.main.bounds.width/10*8, height: 40)
                                        .background(themeColors_Item[saver.ThemeColorID])
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            else{
                                Button{
                                    isFavoriteRoute = true
                                    saver.MyFavoriteTRARoutes.append(MyFavoriteTRARoute(originStationName:self.originStationName, destinationStationName: self.destinationStationName))
                                }label:{
                                    Label("加入到最愛路線",systemImage:"heart")
                                        .font(.custom(fontStyle, size: 16))
                                        .frame(width: UIScreen.main.bounds.width/10*8, height: 40)
                                        .background(themeColors_Item[saver.ThemeColorID])
                                        .foregroundColor(.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            
                        }
                        .padding(.top,10)
                        Spacer()
                    }
                }
            }else{//showFavoriteDeleteAlert
                VStack(alignment: .center){
                    HStack{
                        if(isFavoriteRoute == true){
                            Button{
                                isFavoriteRoute = false
                                if(saver.MyFavoriteTRARoutes.count > 0){
                                    var i = 0
                                    for item in saver.MyFavoriteTRARoutes{
                                        if (item.originStationName == self.originStationName && item.destinationStationName == self.destinationStationName){
                                            print(i)
                                            saver.MyFavoriteTRARoutes.remove(at: i)
                                            break
                                        }
                                        i += 1
                                    }
                                }
                            }label:{
                                Label("從最愛路線移除",systemImage:"heart.fill")
                                    .font(.custom(fontStyle, size: 16))
                                    .frame(width: UIScreen.main.bounds.width/10*8, height: 40)
                                    .background(themeColors_Item[saver.ThemeColorID])
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        else{
                            Button{
                                isFavoriteRoute = true
                                saver.MyFavoriteTRARoutes.append(MyFavoriteTRARoute(originStationName:self.originStationName, destinationStationName: self.destinationStationName))
                            }label:{
                                Label("加入到最愛路線",systemImage:"heart")
                                    .font(.custom(fontStyle, size: 16))
                                    .frame(width: UIScreen.main.bounds.width/10*8, height: 40)
                                    .background(themeColors_Item[saver.ThemeColorID])
                                    .foregroundColor(.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        
                    }
                    .padding(.top,10)
                    Text("出發時間：\(inquireDatee)　\(departureTime)")
                        .foregroundColor(.secondary)
                        .font(.custom(fontStyle, size: 14))
                        .padding(.top,3)
                    ScrollView{
                        VStack(spacing: 0){//,id:\.DailyTrainInfo.TrainNo
                            Divider()
                            if(originDestinationTrainDataItems.isEmpty){
                                Text("（>﹏<）")
                                    .foregroundColor(.secondary)
                                    .font(.custom(fontStyle, size: 20))
                                    .padding(.top,UIScreen.main.bounds.height/10*3)
                                Text("查無列車班次")
                                    .font(.custom(fontStyle, size: 20))
                                    .foregroundColor(.secondary)
                                  
                            }else{
                                ForEach(originDestinationTrainDataItems, id: \.DailyTrainInfo.TrainNo) { item in
                                    /*NavigationLink(
                                        destination: TRAInquiryResultItemRowDetail(trainNumber: item.DailyTrainInfo.TrainNo, startingStopName: item.DailyTrainInfo.StartingStationName.Zh_tw, endingStopName: item.DailyTrainInfo.EndingStationName.Zh_tw , note: item.DailyTrainInfo.Note.Zh_tw, inquiryDate: inquireDate),
                                        label: {
                                            TRAInquiryResultItemRow(originDestinationTrainRowData: item)
                                                .frame(height: 80)
                                        })*/
                                    Button{
                                        //self.resultRowDetail_tempTRAInquiryResultItem = item
                                        self.resultRowDetail_trainNumber = item.DailyTrainInfo.TrainNo
                                        self.resultRowDetail_startingStopName = item.DailyTrainInfo.StartingStationName.Zh_tw
                                        self.resultRowDetail_endingStopName = item.DailyTrainInfo.EndingStationName.Zh_tw
                                        self.resultRowDetail_note = item.DailyTrainInfo.Note.Zh_tw
                                        showRowDetail = true
                                      
                                    }label:{
                                        TRAInquiryResultItemRow(originDestinationTrainRowData: item)
                                            .frame(height: 80)
                                            
                                    }
                                    .sheet(isPresented: $showRowDetail){
                                        TRAInquiryResultItemRowDetail(trainNumber: $resultRowDetail_trainNumber, startingStopName: $resultRowDetail_startingStopName, endingStopName: $resultRowDetail_endingStopName , note: $resultRowDetail_note,show: $showRowDetail, originStationName:originStationName, destinationStationName: destinationStationName, inquiryDate: inquireDate)
                                        /*TRAInquiryResultItemRowDetail(trainNumber:  $resultRowDetail_tempTRAInquiryResultItem.DailyTrainInfo.TrainNo, startingStopName: resultRowDetail_tempTRAInquiryResultItem.DailyTrainInfo.StartingStationName.Zh_tw, endingStopName: resultRowDetail_tempTRAInquiryResultItem.DailyTrainInfo.EndingStationName.Zh_tw, note: resultRowDetail_tempTRAInquiryResultItem.DailyTrainInfo.Note.Zh_tw)*/
                                    }
                                        
                                    Divider()
                                    /*Text("車號:\(item.DailyTrainInfo.TrainNo)\n起點：\(item.DailyTrainInfo.StartingStationName.En)\n終點：\(item.DailyTrainInfo.EndingStationName.En)\n車種ID：\(item.DailyTrainInfo.TrainTypeID)\n備註：\(item.DailyTrainInfo.Note.Zh_tw)\n日期\(item.TrainDate)\n時間：\(item.OriginStopTime.DepartureTime)～\(item.DestinationStopTime.DepartureTime)\n\n")*/
                                }
                            }
                           
                        }
                    }
                  
                    ZStack{
                        Text("\(updateButtonHiddenTime)")
                            .frame(width: UIScreen.main.bounds.width/10*6, height: 40)
                            .background(Color.secondary)
                            .foregroundColor(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        Button{
                            fetcher.isGettingOriginToDestinationStationTrain = true
                            updateButtonIsHidden = true
                            for item in saver.MyFavoriteTRARoutes{
                                if (item.originStationName == self.originStationName && item.destinationStationName == self.destinationStationName){
                                    self.isFavoriteRoute = true
                                    break
                                }
                            }
                            Timer.scheduledTimer(withTimeInterval: 1, repeats: updateButtonIsHidden) { timer in
                                updateButtonHiddenTime -= 1

                                if(updateButtonHiddenTime == 0){
                                    updateButtonIsHidden = false
                                    updateButtonHiddenTime = 3
                                    timer.invalidate()
                                }
                            }
                            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: fetcher.isGettingOriginToDestinationStationTrain) { timer in
                                progressValue += 1
                                if (progressValue > 0){
                                    tramIsHiddens[1] = false
                                }
                                if (progressValue > 1){
                                    tramIsHiddens[2] = false
                                }
                                if (progressValue > 2){
                                    tramIsHiddens[3] = false
                                }
                                if (progressValue > 3){
                                    tramIsHiddens[4] = false
                                }
                                if (progressValue > 4) {
                                    progressValue = 0
                                    tramIsHiddens[1] = true
                                    tramIsHiddens[2] = true
                                    tramIsHiddens[3] = true
                                    tramIsHiddens[4] = true
                                
                                }
                                if(fetcher.isGettingOriginToDestinationStationTrain == false){
                                    timer.invalidate()
                                }
                            }
                            print("訊息：開始查詢「\(originStationName)」到「\(destinationStationName)」之班次")
                            fetcher.trainStationInformationDataItems.forEach{
                                if($0.StationName.Zh_tw == originStationName){
                                    originStationID = $0.StationID
                                }
                                if($0.StationName.Zh_tw == destinationStationName){
                                    destinationStationID = $0.StationID
                                }
                            }
                            var i = 0
                            for item in saver.TRAInquiryRecords{
                                if(originStationName == item.originStationName && destinationStationName == item.destinationStationName && inquireDate == item.inquireDate && departureTime == item.departureTime){
                                    saver.TRAInquiryRecords.remove(at:i)
                                    break
                                }
                                i += 1
                            }
                            saver.TRAInquiryRecords.append(TRAInquiryRecord(originStationName: originStationName, destinationStationName: destinationStationName, inquireDate: inquireDate, departureTime: departureTime))
                            fetcher.getOriginToDestinationStationTrain(originStationID: originStationID, destinationStationID: destinationStationID,inquiryDate: inquireDate,departureTime:departureTime)
                        }label:{
                            Label("重新整理",systemImage:"arrow.clockwise")
                                .font(.custom(fontStyle, size: 16))
                                .frame(width: UIScreen.main.bounds.width/10*6, height: 40)
                                .background(themeColors_Item[saver.ThemeColorID])
                                .foregroundColor(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .isHidden(updateButtonIsHidden)
                    }
                    .padding(.bottom,10)
                }
            }
        }
        .onAppear() {
            inquireDatee = inquireDate
            fetcher.isGettingOriginToDestinationStationTrain = true
            for item in saver.MyFavoriteTRARoutes{
                if (item.originStationName == self.originStationName && item.destinationStationName == self.destinationStationName){
                    self.isFavoriteRoute = true
                    break
                }
            }
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: fetcher.isGettingOriginToDestinationStationTrain) { timer in
                //設計loding時的Timer:https://juejin.cn/post/6981714936770592775
                //停止Timer:https://juejin.cn/post/6844904131556016135
                progressValue += 1
                if (progressValue > 0){
                    tramIsHiddens[1] = false
                }
                if (progressValue > 1){
                    tramIsHiddens[2] = false
                }
                if (progressValue > 2){
                    tramIsHiddens[3] = false
                }
                if (progressValue > 3){
                    tramIsHiddens[4] = false
                }
                if (progressValue > 4) {
                    progressValue = 0
                    tramIsHiddens[1] = true
                    tramIsHiddens[2] = true
                    tramIsHiddens[3] = true
                    tramIsHiddens[4] = true
                }
                if(fetcher.isGettingOriginToDestinationStationTrain == false){
                    timer.invalidate()
                }
            }
            print("訊息：開始查詢「\(originStationName)」到「\(destinationStationName)」之班次")
            fetcher.trainStationInformationDataItems.forEach{
                if($0.StationName.Zh_tw == originStationName){
                    originStationID = $0.StationID
                }
                if($0.StationName.Zh_tw == destinationStationName){
                    destinationStationID = $0.StationID
                }
            }
            let now = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let temp:Date = dateFormatter.date(from: inquireDate)!
            let diff:Int = Calendar.current.dateComponents([.day], from: now, to: temp).day ?? 0
            let today:String = dateFormatter.string(from: now)
            if diff < 0 {
                inquireDatee = today
                print("訊息：查詢之日期已更新!")
            }
            var i = 0
            for item in saver.TRAInquiryRecords{
                if(originStationName == item.originStationName && destinationStationName == item.destinationStationName && inquireDate == item.inquireDate && departureTime == item.departureTime){
                    saver.TRAInquiryRecords.remove(at:i)
                    break
                }
                i += 1
            }
            saver.TRAInquiryRecords.append(TRAInquiryRecord(originStationName: originStationName, destinationStationName: destinationStationName, inquireDate: inquireDatee, departureTime: departureTime))
            fetcher.getOriginToDestinationStationTrain(originStationID: originStationID, destinationStationID: destinationStationID,inquiryDate: inquireDatee,departureTime:departureTime)
        }
        .alert(isPresented: $fetcher.showError, content: {
            var alert:Alert
            switch fetcher.error{
            case FetchError.invalidURL?:
                alert = Alert(title: Text("抓取資料時出現錯誤\n請聯絡開發人員"))
            case FetchError.invalidData?:
                alert = Alert(title: Text("抓取資料時出現錯誤\n請聯絡開發人員"))
            case FetchError.offline?:
                alert = Alert(title: Text("連線錯誤\n請確認是否有連上網路"))
            default:
                alert = Alert(title: Text(fetcher.error?.localizedDescription ?? ""))
                
            }
            return alert
          //
        })
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(content: {
            ToolbarItem(placement: .principal) {
                HStack{
                    Text(originStationName)
                        .font(.custom(fontStyle, size: 20))
                    Text("  ➤  ")
                        .font(.custom(fontStyle, size: 20))
                    Text(destinationStationName)
                        .font(.custom(fontStyle, size: 20))
                }
            }
        })
        //.edgesIgnoringSafeArea(.top)
        
        
        
    }
    
}




