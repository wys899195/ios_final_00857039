//
//  GlobalVariable.swift
//  ios_final_00857039
//
//  Created by User20 on 2022/12/15.
//

import Foundation
import SwiftUI

//App system related.................................................
let fontStyle:String = "HannotateTC-W7"
let fontStyleSet:[String] = ["San Francisco","HannotateTC-W7"]
let themeColors_BackGround:[Color] = [Color("ThemeColorPink_Background"),Color("ThemeColorGreen_Background"),Color("ThemeColorOrange_Background"),Color("ThemeColorBlue_Background")]
let themeColors_Item:[Color] =       [Color("ThemeColorPink_Item")      ,Color.green                        ,Color("ThemeColorOrange_Item")      ,Color("ThemeColorBlue_Item")]
var inquiryRecordSerialNo:Int = 0

enum FetchError: Error {
    case invalidURL
    case invalidData
    case offline
}

//user signup and login related......................................
struct UserTokenForLogin:Codable{//temp
    let userToken:String
    let userName:String
    
    enum CodingKeys: String, CodingKey {//參考http://aiur3908.blogspot.com/2020/06/ios-swiftjson.html
        case userToken = "User-Token"
        case userName = "login"
    }
}

//current weather api related........................................
struct CityLatitudeAndLongitudeLocationData:Codable{//取得城市經緯度
    let name:String
    let local_names:LocalNames
    let lat:Double
    let lon:Double
    
    struct LocalNames:Codable{
        let zh:String
    }
}

struct CityCurrentWeatherData:Codable{
    let weather:[Weather]
    let main:WeatherMainData
    
    struct Weather:Codable {
        let main:String         //天氣狀況（晴天雨天等）
        let description:String  //天氣狀況描述
        let icon:String         //天氣圖標ID
    }
    struct WeatherMainData:Codable {
        let temp:Double         //溫度
        let feels_like:Double   //體感溫度
        let temp_min:Double     //目前最低氣溫
        let temp_max:Double     //目前最高氣溫
        let humidity:Double     //濕度
    }
    
}


//TDX API authorization related......................................
let clientId:String = "00857039-c07dd015-ff9a-40bf"
let clientSecret:String = "40b047c6-9c90-460d-a59c-e7b6d5c7698a"
let AccessTokenUrl:String = "https://tdx.transportdata.tw/auth/realms/TDXConnect/protocol/openid-connect/token"

struct accessTokenJSONData: Codable {
    let access_token:String?
}

//TRAInquiry myFavorites related.....................................
struct MyFavoriteTRARoute:Codable,Identifiable{
    var id:String{originStationName+destinationStationName}
    let originStationName:String
    let destinationStationName:String
}

//TRAInquiry history related.........................................
struct TRAInquiryRecord:Codable,Identifiable{
    var id:String{originStationName+destinationStationName+inquireDate+departureTime}
    let originStationName:String
    let destinationStationName:String
    let inquireDate:String
    let departureTime:String
}

//TRAInquiry JSON related............................................
struct StationNameData:Codable {
    let Zh_tw:String
    let En:String
}
struct TrainStationInformationData:Codable{  //火車站基本資料
    let StationID:String              //火車站代碼（查詢起迄站API用)
    let StationName:StationNameData   //火車站名稱
    let LocationCity:String           //火車站所在縣市
}
struct OriginDestinationTrainData:Codable{//基於火車起訖站、日期的班次資料(如從今天的基隆到台中的火車班次）
    let TrainDate:String                  //日期
    let DailyTrainInfo:DailyTrainInfoData //班次
    let OriginStopTime:StopTimeData       //起站
    let DestinationStopTime:StopTimeData  //訖站
    
    struct DailyTrainInfoData:Codable {
        let TrainNo:String                      //班次車號
        let StartingStationName:StationNameData //班次起點站
        let EndingStationName:StationNameData   //班次終點站
        let TrainTypeID:String                  //班次車種代號（如區間(1131)太魯閣(1102)等）
        let Note:NoteData                       //班次備註（如每日行駛或連假日停駛等）
        
        struct NoteData:Codable {
            let Zh_tw:String
        }
    }
    struct StopTimeData:Codable  {
        let StationName:StationNameData
        let DepartureTime:String  //火車駛離車站時間
    }
}
struct TimeTableOfTrainNumberData:Codable{
    let StopTimes:[StopTimeData]
    
    struct StopTimeData:Codable{
        let StationName:StationNameData
        let ArrivalTime:String
        let DepartureTime:String
    }
}


