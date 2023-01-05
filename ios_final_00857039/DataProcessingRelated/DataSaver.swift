//
//  DataSaver.swift
//  ios_final_00857039
//
//  Created by User20 on 2022/12/19.
//

import SwiftUI

class DataSaver: ObservableObject {
    @AppStorage("OriginStopNameForTRAinquiry") var originStopNameForTRAinquiryStorage:String?
    @AppStorage("DestinationStopNameForTRAinquiry") var destinationStopNameForTRAinquiryStorage:String?
    @AppStorage("WeatherLocationCity") var weatherLocationCityStorage:String?
    @AppStorage("TRAInquiryRecords") var TRAInquiryRecordsStorage:Data?
    @AppStorage("ThemeColorID") var ThemeColorIDStorage:Int?
    @AppStorage("MyFavoriteTRARoutes") var MyFavoriteTRARoutesStorage:Data?
    @AppStorage("UserData") var UserDataStorage:Data?

    @Published var originStopNameForTRAinquiry = String(){      //台鐵查詢之起站
        didSet {    //一旦@Published變數改變,就更新儲存的資料
            originStopNameForTRAinquiryStorage = originStopNameForTRAinquiry
        }
    }
    @Published var destinationStopNameForTRAinquiry = String(){ //台鐵查詢之迄站
        didSet {
            destinationStopNameForTRAinquiryStorage = destinationStopNameForTRAinquiry
        }
    }
    @Published var weatherLocationCity = String(){ //天氣所在城市
        didSet {
            weatherLocationCityStorage = weatherLocationCity
        }
    }
    @Published var TRAInquiryRecords = [TRAInquiryRecord](){ //台鐵查詢歷史紀錄
        didSet {
            let encoder = JSONEncoder()
            do {
                TRAInquiryRecordsStorage = try encoder.encode(TRAInquiryRecords)
            } catch {
                print(error)
            }
        }
    }
    @Published var ThemeColorID = Int(){  //App主題顏色
        didSet{
            ThemeColorIDStorage = ThemeColorID
        }
    }
    @Published var MyFavoriteTRARoutes = [MyFavoriteTRARoute](){
        didSet{
            let encoder = JSONEncoder()
            do {
                MyFavoriteTRARoutesStorage = try encoder.encode(MyFavoriteTRARoutes)
            } catch {
                print(error)
            }
        }
    }
    @Published var UserData = [UserTokenForLogin](){//目前登入的使用者資料
        didSet{
            let encoder = JSONEncoder()
            do {
                UserDataStorage = try encoder.encode(UserData)
            } catch {
                print(error)
            }
        }
    }
    @Published var originDestinationTrainData = [OriginDestinationTrainData]()
    
    init(){
        //@Published var originStopNameForTRAinquiry
        if let originStopNameForTRAinquiryStorage = originStopNameForTRAinquiryStorage{
            originStopNameForTRAinquiry = originStopNameForTRAinquiryStorage
        }else{
            originStopNameForTRAinquiry = "臺北"
        }
        
        //@Published var destinationStopNameForTRAinquiry
        if let destinationStopNameForTRAinquiryStorage = destinationStopNameForTRAinquiryStorage{
            destinationStopNameForTRAinquiry = destinationStopNameForTRAinquiryStorage
        }else{
            destinationStopNameForTRAinquiry = "高雄"
        }
        
        //@Published var WeatherLocationCity
        if let weatherLocationCityStorage = weatherLocationCityStorage{
            weatherLocationCity = weatherLocationCityStorage
        }else{
            weatherLocationCity = "基隆市"
        }

        //Published var TRAInquiryRecords
        if let TRAInquiryRecordsStorage = TRAInquiryRecordsStorage {
            let decoder = JSONDecoder()
            do {
                TRAInquiryRecords = try decoder.decode([TRAInquiryRecord].self, from: TRAInquiryRecordsStorage)
            } catch  {
                print(error)
            }
        }
        
        //@Published var ThemeColorID
        if let ThemeColorIDStorage = ThemeColorIDStorage{
            ThemeColorID = ThemeColorIDStorage
        }else{
            ThemeColorID = 0
        }
        
        //@Published var MyFavoriteTRARoutes
        if let MyFavoriteTRARoutesStorage = MyFavoriteTRARoutesStorage {
            let decoder = JSONDecoder()
            do {
                MyFavoriteTRARoutes = try decoder.decode([MyFavoriteTRARoute].self, from: MyFavoriteTRARoutesStorage)
            } catch  {
                print(error)
            }
        }
        
        //@Published var UserData
        if let UserDataStorage = UserDataStorage{
            let decoder = JSONDecoder()
            do {
                UserData = try decoder.decode([UserTokenForLogin].self, from: UserDataStorage)
            } catch  {
                print(error)
            }
        }
        //        //@Published var TRAInquiryDate
        //        //@Published var earliestDepartureTime
        //        let today = Date()
        //        let dateFormatter = DateFormatter()
        //        dateFormatter.dateFormat = "yyyy-MM-dd"
        //        TRAInquiryDate = dateFormatter.string(from: today)
        //        dateFormatter.dateFormat = "HH"
        //        TRAInquiryEarliestDepartureTime = dateFormatter.string(from: today) + ":00"
        //        //print(TRAInquiryEarliestDepartureTime)
    }

}
