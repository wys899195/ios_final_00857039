//
//  TRAInquiryResultItemRowDetail.swift
//  ios_final_00857039
//
//  Created by User04 on 2023/1/4.
//

import SwiftUI

struct TRAInquiryResultItemRowDetail: View {
    
    @EnvironmentObject var saver: DataSaver
    @EnvironmentObject var fetcher: DataFetcher
    
    @Binding var trainNumber:String
    @Binding var startingStopName:String
    @Binding var endingStopName:String
    @Binding var note:String
    @Binding var show:Bool
    var originStationName:String
    var destinationStationName:String
    var inquiryDate:String
    
    func isNormalStyle(targetStationName:String)->Bool{
        let originID = fetcher.timeTableOfTargetTrainNumber[0].StopTimes.firstIndex(where: {$0.StationName.Zh_tw == originStationName}) ?? -1
        let destinationID = fetcher.timeTableOfTargetTrainNumber[0].StopTimes.firstIndex(where: {$0.StationName.Zh_tw == destinationStationName}) ?? -1
        let targetID = fetcher.timeTableOfTargetTrainNumber[0].StopTimes.firstIndex(where: {$0.StationName.Zh_tw == targetStationName}) ?? -1
        if targetID > originID && targetID < destinationID {
            return true
        }else{
            return false
        }
    }
    
    var body: some View {
        VStack{
            HStack{
                VStack{
                    Text(trainNumber)
                        .font(.custom(fontStyle, size: 30))
                    Text("\(startingStopName)　➤　\(endingStopName)")
                        .font(.custom(fontStyle, size: 16))
                }.padding(.vertical,10)
            }.frame(width: UIScreen.main.bounds.width)
            .background(themeColors_BackGround[saver.ThemeColorID])
            HStack{
                Text(note)
                    .font(.custom(fontStyle, size: 12))
                    .foregroundColor(.secondary)
                    .padding(.horizontal,20)
            }
            Divider()
            List{
                if !fetcher.timeTableOfTargetTrainNumber.isEmpty{
                    ForEach(fetcher.timeTableOfTargetTrainNumber[0].StopTimes,id:\.StationName.Zh_tw){item in
                        if item.StationName.Zh_tw == originStationName{
                            TimeRow(type: .Origin, stopName: item.StationName.Zh_tw, arrivalTime: item.ArrivalTime, departureTime: item.DepartureTime)
                        }else if item.StationName.Zh_tw == destinationStationName{
                            TimeRow(type: .Destination, stopName: item.StationName.Zh_tw, arrivalTime: item.ArrivalTime, departureTime: item.DepartureTime)
                        }else if isNormalStyle(targetStationName:item.StationName.Zh_tw){
                            TimeRow(type: .Normal, stopName: item.StationName.Zh_tw, arrivalTime: item.ArrivalTime, departureTime: item.DepartureTime)
                        }else{
                            TimeRow(type: .None, stopName: item.StationName.Zh_tw, arrivalTime: item.ArrivalTime, departureTime: item.DepartureTime)
                        }
                    }
                }
                
                /*TimeRow(type: .None, stopName: "台北", arrivalTime: "00:00", departureTime: "00:00")
                TimeRow(type: .Origin, stopName: "萬華", arrivalTime: "00:00", departureTime: "00:00")
                TimeRow(type: .Normal, stopName: "板橋", arrivalTime: "00:00", departureTime: "00:00")
                TimeRow(type: .Normal, stopName: "浮洲", arrivalTime: "00:00", departureTime: "00:00")
                TimeRow(type: .Destination, stopName: "樹林", arrivalTime: "00:00", departureTime: "00:00")*/
            }
            HStack{
                Text("＊以上為表定時刻表，實際\n　列車動態以現場公告為準")
                    .font(.custom(fontStyle, size: 14))
                    .foregroundColor(.secondary)
                Spacer()
                Button{
                    show = false
                }label:{
                    Label("關閉",systemImage:"xmark")
                        .font(.custom(fontStyle, size: 16))
                        .frame(width: UIScreen.main.bounds.width/10*3, height: 30)
                        .background(themeColors_Item[saver.ThemeColorID])
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        //.padding(.vertical,4)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white, lineWidth: 3)
                        )
                }
            }.padding(.init(top: 0, leading: 10, bottom: 10, trailing: 10))
        }
        .onAppear(){
            fetcher.timeTableOfTargetTrainNumber.removeAll()
            fetcher.getTimeTableFromTrainNumber(TrainNo: trainNumber, inquiryDate: inquiryDate)
        }
    }
}

struct TimeRow: View {

    let type:RowType
    let stopName:String
    let arrivalTime:String
    let departureTime:String
    
    init(type:RowType,stopName:String,arrivalTime:String,departureTime:String){
        self.type = type
        
        switch stopName.count{
        case 2:
            self.stopName = stopName + "　　"
        case 3:
            self.stopName = stopName + "　"
        default:
            self.stopName = stopName
        }
        self.arrivalTime = arrivalTime
        self.departureTime = departureTime
    }

    var body: some View {
        switch self.type{
        case .None:
            HStack{
                Rectangle()
                    .frame(width: 10,height:30)
                    .padding(.horizontal,5)
                    .opacity(0)
                Text(stopName)
                    .font(.custom(fontStyle, size: 20))
                    .foregroundColor(.primary)
                Spacer()
                VStack{
                    Text("\(arrivalTime)到站")
                        .font(.custom(fontStyle, size: 14))
                        .foregroundColor(.primary)
                    Text("\(departureTime)發車")
                        .font(.custom(fontStyle, size: 14))
                        .foregroundColor(.primary)
                }
            }.frame(height:30)
            .opacity(0.2)
        case .Normal:
            HStack{
                VStack{
                    Rectangle()
                        .frame(width: 10,height:30)
                        .padding(.horizontal,5)
                        .foregroundColor(.primary)
                }
                Text(stopName)
                    .font(.custom(fontStyle, size: 20))
                    .foregroundColor(.primary)
                Spacer()
                VStack{
                    Text("\(arrivalTime)到站")
                        .font(.custom(fontStyle, size: 14))
                        .foregroundColor(.primary)
                    Text("\(departureTime)發車")
                        .font(.custom(fontStyle, size: 14))
                        .foregroundColor(.primary)
                }
            }.frame(height:30)
        case .Origin:
            HStack{
                ZStack{
                    VStack{
                        Spacer()
                        Rectangle()
                            .frame(width: 10,height:20)
                            .foregroundColor(.primary)
                    }
                    Circle()
                        .frame(width: 20,height:20)
                        .foregroundColor(.red)
                }
                Text(stopName)
                    .font(.custom(fontStyle, size: 20))
                    .foregroundColor(.red)
                Spacer()
                VStack{
                    Text("\(arrivalTime)到站")
                        .font(.custom(fontStyle, size: 14))
                        .foregroundColor(.primary)
                    Text("\(departureTime)發車")
                        .font(.custom(fontStyle, size: 14))
                        .foregroundColor(.red)
                }
            }.frame(height:30)
        case .Destination:
            HStack{
                ZStack{
                    VStack{
                        Rectangle()
                            .frame(width: 10,height:20)
                            .foregroundColor(.primary)
                        Spacer()
                    }
                    Circle()
                        .frame(width: 20,height:20)
                        .foregroundColor(.blue)
                }
                Text(stopName)
                    .font(.custom(fontStyle, size: 20))
                    .foregroundColor(.blue)
                Spacer()
                VStack{
                    Text("\(arrivalTime)到站")
                        .font(.custom(fontStyle, size: 14))
                        .foregroundColor(.blue)
                    Text("\(departureTime)發車")
                        .font(.custom(fontStyle, size: 14))
                        .foregroundColor(.primary)
                }
            }.frame(height:30)
        }
        
    }
}

enum RowType{
    case None           //沒經過的站
    case Normal         //有經過的站
    case Origin         //起站
    case Destination    //迄站
}
