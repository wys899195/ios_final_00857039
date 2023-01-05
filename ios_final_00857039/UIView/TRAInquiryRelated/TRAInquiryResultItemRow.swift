//
//  TRAInquiryResultItemRow.swift
//  ios_final_00857039
//
//  Created by User04 on 2022/12/21.
//

import SwiftUI

struct TRAInquiryResultItemRow: View {
    @EnvironmentObject var fetcher: DataFetcher
    
    let originDestinationTrainRowData:OriginDestinationTrainData
    
    var TimeDifferenceHours:Int
    var TimeDifferenceMinutes:Int
    
    var trainStationInformationDataItems:[TrainStationInformationData]{
        var items = [TrainStationInformationData]()
        for item in fetcher.trainStationInformationDataItems {
            items.append(item)
        }
        return items
    }
    
    init(originDestinationTrainRowData:OriginDestinationTrainData){
        self.originDestinationTrainRowData = originDestinationTrainRowData
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let originDate = formatter.date(from: originDestinationTrainRowData.OriginStopTime.DepartureTime)
        let destinationDate = formatter.date(from: originDestinationTrainRowData.DestinationStopTime.DepartureTime)
        let diff:DateComponents = Calendar.current.dateComponents([.minute], from: originDate!, to: destinationDate!)
        TimeDifferenceHours = 0
        TimeDifferenceMinutes = diff.minute ?? 0
        if(TimeDifferenceMinutes < 0){
            TimeDifferenceMinutes += 1440
        }
        while(TimeDifferenceMinutes > 60){
            TimeDifferenceMinutes -= 60
            TimeDifferenceHours += 1

        }
    }
    
    struct TrainTypeColor {
        let TypeName:String
        let color:Color
    }
        
    func TrainTypeIDtoString(ID: String) -> TrainTypeColor{
        switch ID{
        case "1100","1102","1103","1104","1105","1106","1108","1109","110A","110B","110C","110D","110E","110F","110G","110H","110K","110M":
            return TrainTypeColor(TypeName: "自強號", color: Color.orange)
        case "1101":
            return TrainTypeColor(TypeName: "太魯閣", color: Color.purple)
        case "1107":
            return TrainTypeColor(TypeName: "普悠瑪", color: Color.red)
        case "1110","1111","1112","1113","1114","1115":
            return TrainTypeColor(TypeName: "莒光號", color: Color.yellow)
        case "1120","1121","1122","1152","1155":
            return TrainTypeColor(TypeName: "復興號", color: Color.green)
        case "1130","1131","1133","1134","1135","1141","1154":
            return TrainTypeColor(TypeName: "區間車", color: Color.blue)
        case "1132":
            return TrainTypeColor(TypeName: "區間快", color: Color.blue)
        case "1140","1150","1151","1270","1280","1281","1282","12A0","12A1","12B0","4200","5230":
            return TrainTypeColor(TypeName: "普快", color: Color.gray)
        default:
            return TrainTypeColor(TypeName: "其他種", color: Color.black)
        }
    }
    var body: some View {
        ZStack{
            HStack{
                VStack{
                    Text(originDestinationTrainRowData.DailyTrainInfo.TrainNo)
                        .font(.custom(fontStyle, size: 12))
                        .foregroundColor(.primary)
                    Image(systemName: "tram.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(TrainTypeIDtoString(ID: originDestinationTrainRowData.DailyTrainInfo.TrainTypeID).color)
                        .padding(.vertical,-5)
                    Text(TrainTypeIDtoString(ID: originDestinationTrainRowData.DailyTrainInfo.TrainTypeID).TypeName)
                        .foregroundColor(TrainTypeIDtoString(ID: originDestinationTrainRowData.DailyTrainInfo.TrainTypeID).color)
                        .font(.custom(fontStyle, size: 14))
                }
   
                
                Spacer()
             
            }
            VStack{
                if(TimeDifferenceHours > 0){
                    Text("\(TimeDifferenceHours)小時\(TimeDifferenceMinutes)分")
                        .font(.custom(fontStyle, size: 12))
                        .foregroundColor(.blue)
                }else{
                    Text("\(TimeDifferenceMinutes)分")
                        .font(.custom(fontStyle, size: 12))
                    
                }
                Text("\(originDestinationTrainRowData.OriginStopTime.DepartureTime) ⇀ \(originDestinationTrainRowData.DestinationStopTime.DepartureTime)")
                    .font(.custom(fontStyle, size: 20))
                    .foregroundColor(.primary)
                
            }
            /*VStack(){
                
                HStack{
                    Spacer()
                    Text("\(originDestinationTrainRowData.DailyTrainInfo.Note.Zh_tw)")
                        .font(.custom(fontStyle, size: 8))
                        .foregroundColor(.secondary)
                   
                }
              
            }//.frame(width: UIScreen.main.bounds.width/10*8)*/
        }
        .frame(width: UIScreen.main.bounds.width)

    }
}

/*struct TRAInquiryResultItemRow_Previews: PreviewProvider {
    static var previews: some View {
        TRAInquiryResultItemRow()
    }
}*/
