//
//  ContentView.swift
//  ios_final_00857039
//
//  Created by User20 on 2022/12/17.
//


import SwiftUI
import SwiftUITooltip

struct ContentView: View {
    
    @EnvironmentObject var saver: DataSaver
    @EnvironmentObject var fetcher: DataFetcher
    
    @State var mainViewBarColor: Color = themeColors_BackGround[0]
    
    //註冊登入登出相關
    @State private var viewMode:Int = 2 //1:註冊畫面 ２：登入畫面 3:登入成功後畫面
    @State private var showLogInSuccessAlert:Bool = false
    @State private var showPassword:Bool = false
    @State private var signUpLogInLoading:Bool = false
    //註冊錯誤訊息
    @State private var signUpUserNameMessage = ""
    @State private var signUpPasswordMessage = ""
    //註冊輸入
    @State private var userNameSignUpInput = ""
    @State private var passwordSignUpInput = ""
    //登入錯誤訊息
    @State private var logInUserAccountMessage = ""
    @State private var logInPasswordMessage = ""
    //登入輸入
    @State private var userAccountLoginInput = ""
    @State private var passwordLoginInput = ""
    //登入載入畫面
    @State private var tramIsHiddens:[Bool] = [true,true,true,true,true]
    @State private var progressValue:CGFloat = 0
    
    func FavQsSignUp(userName:String = "",password:String = ""){//註冊功能
        //輸入為空時 FavQs那邊好像不會報錯
        //向FavQs註冊之前 簡單檢查輸入內容是否合法
        let email:String = "\(userName)@mail.com"
        var isValid:Bool = true
        if userName.trimmingCharacters(in: CharacterSet.whitespaces) == "" || userName.count < 2{
            signUpUserNameMessage = "帳號長度須在2~20之間"
            isValid = false
        }else if userName.contains("_"){
            signUpUserNameMessage = "帳號只能包含英文字母和數字"
            isValid = false
        }
        if password.trimmingCharacters(in: CharacterSet.whitespaces) == "" || password.count < 5 || password.count > 20 {
            signUpPasswordMessage = "密碼長度須在5~20之間"
            isValid = false
        }
        
        if  isValid == false{
            signUpLogInLoading = false
            return
        }
        
        //輸入不為空 開始向FavQs註冊
        let url = URL(string: "https://favqs.com/api/users")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token token=9c5246b0bcab6a5887666c0341a9699d", forHTTPHeaderField: "Authorization")
        let data = "{\"user\": {\"login\": \"\(userName)\",\"email\": \"\(email)\",\"password\": \"\(password)\"}}".data(using: .utf8)
        request.httpBody = data
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data=data {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                if statusCode == 200{
                    let dataToString = String(data: data, encoding: .utf8)!
                    print(dataToString)
                    if !dataToString.contains("error_code"){//輸入合法 開始註冊
                        let decoder = JSONDecoder()
                        do{
                            let dataItem = try decoder.decode(UserTokenForLogin.self, from: data)
                            DispatchQueue.main.async {
                                saver.UserData.removeAll()
                                saver.UserData.append(dataItem)
                                signUpUserNameMessage  = ""
                                signUpPasswordMessage = ""
                                showLogInSuccessAlert = true
                                signUpLogInLoading = false
                            }
                            return
                        }catch{
                            print(error)
                        }
                    }else{//輸入不合法導致註冊失敗
                        //Username
                        if dataToString.contains("Username"){
                            if dataToString.contains("Username has already been taken"){
                                signUpUserNameMessage = "該帳號已被註冊"
                            }else if dataToString.contains("Username is too"){
                                signUpUserNameMessage = "帳號長度須在2~20之間"
                            }else{
                                signUpUserNameMessage = "帳號只能包含英文字母和數字"
                            }
                            if dataToString.contains("Email"){
                                signUpUserNameMessage = "該帳號已被註冊"
                            }
                        }
                        //Password
                        if dataToString.contains("Password"){
                            signUpPasswordMessage = "密碼長度須在5~20之間"
                        }
                        signUpLogInLoading = false
                        return
                    }
                }
            } else if let error=error {
                signUpLogInLoading = false
                print(error)
                
            }
        }.resume()
    }
    
    func FavQsLogIn(userNameOrEmail:String = "",password:String = ""){
        if userNameOrEmail.trimmingCharacters(in: CharacterSet.whitespaces) == "" {
            logInUserAccountMessage = "帳號不得為空"
            signUpLogInLoading = false
            return
        }
        if password.trimmingCharacters(in: CharacterSet.whitespaces) == "" {
            logInPasswordMessage = "密碼不得為空"
            signUpLogInLoading = false
            return
        }
        let url = URL(string: "https://favqs.com/api/session")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Token token=9c5246b0bcab6a5887666c0341a9699d", forHTTPHeaderField: "Authorization")
        let data = "{\"user\": {\"login\": \"\(userNameOrEmail)\",\"password\": \"\(password)\"}}".data(using: .utf8)
        request.httpBody = data
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                let statusCode = (response as? HTTPURLResponse)?.statusCode
                if statusCode == 200{
                    let dataToString = String(data: data, encoding: .utf8)!
                    print(dataToString)
                    if !dataToString.contains("error_code") {//登入成功
                        let decoder = JSONDecoder()
                        do{
                            let dataItem = try decoder.decode(UserTokenForLogin.self, from: data)
                            DispatchQueue.main.async {
                                saver.UserData.removeAll()
                                saver.UserData.append(dataItem)
                                logInUserAccountMessage  = ""
                                logInPasswordMessage = ""
                                
                                signUpLogInLoading = false
                                showLogInSuccessAlert = true
                            }
                            return
                        }catch{
                            signUpLogInLoading = false
                            print(error)
                        }
                    }else{//輸入不合法導致登入失敗
                        //UserAccount
                        if dataToString.contains("Invalid login or password"){
                            logInUserAccountMessage = "帳號或密碼有誤"
                            logInPasswordMessage = "帳號或密碼有誤"
                        }else{
                            logInUserAccountMessage = "登錄無效或帳號丟失,請聯繫support@favqs.com"
                            logInPasswordMessage = "登錄無效或帳號丟失,請聯繫support@favqs.com"
                        }
                        signUpLogInLoading = false
                        return
                    }
                }
                
            } else if let error=error {
                signUpLogInLoading = false
                print(error)
                
            }
        }.resume()
        
    }
    
    var tooltipConfig = DefaultTooltipConfig()
    
    init(){
        self.tooltipConfig.enableAnimation = true
                self.tooltipConfig.animationOffset = 10
        self.tooltipConfig.animationTime = 0.5
        self.tooltipConfig.backgroundColor = Color("contraryColor")
    }
    var body: some View {
        if !saver.UserData.isEmpty && signUpLogInLoading == false{
            MainView(showLogInSuccessAlert: $showLogInSuccessAlert, logInUserAccountMessage: $logInUserAccountMessage, logInPasswordMessage: $logInPasswordMessage, userAccountLoginInput: $userAccountLoginInput, passwordLoginInput: $passwordLoginInput, viewMode: $viewMode, barColor:       themeColors_BackGround[saver.ThemeColorID]).id(      themeColors_BackGround[saver.ThemeColorID])
        }else{
            ZStack{
                VStack{
                    if(viewMode == 1){
                        ZStack{
                            HStack(spacing:UIScreen.main.bounds.width * 0.15){
                                VStack{
                                    Image(systemName:"tram")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:UIScreen.main.bounds.width * 0.4,height:UIScreen.main.bounds.height * 0.4)
                                        .foregroundColor(.red)
                                    Image(systemName:"tram")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:UIScreen.main.bounds.width * 0.4,height:UIScreen.main.bounds.height * 0.4)
                                        .foregroundColor(.orange)
                                }
                                VStack{
                                    Image(systemName:"tram")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:UIScreen.main.bounds.width * 0.4,height:UIScreen.main.bounds.height * 0.4)
                                        .foregroundColor(.green)
                                    Image(systemName:"tram")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:UIScreen.main.bounds.width * 0.4,height:UIScreen.main.bounds.height * 0.4)
                                        .foregroundColor(.blue)
                                }
                             
                            }
                            VStack{
                                Text("台鐵查詢App")
                                    .font(.custom(fontStyle, size: 32))
                                    .padding(.bottom,40)
                                VStack(alignment:.leading){
                                    Group{
                                        HStack{
                                            Spacer()
                                            Text("建立新帳號")
                                                .font(.custom(fontStyle, size: 26))
                                                .foregroundColor(Color("contraryColor"))
                                            Spacer()
                                        }
                                        //帳號
                                        Text("帳號")
                                            .font(.custom(fontStyle, size: 16))
                                            .foregroundColor(Color("contraryColor"))
                                        TextField("2-20字,由英文和數字組成", text: $userNameSignUpInput)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .disabled(signUpLogInLoading)
                                        Text(signUpUserNameMessage != "" ? "x\(signUpUserNameMessage)" : " ")
                                            .offset(x:20).font(.custom(fontStyle, size: 12)).padding(.bottom,5).foregroundColor(.red)
                                        //密碼
                                        HStack{
                                            Text("密碼")
                                                .font(.custom(fontStyle, size: 16))
                                                .foregroundColor(Color("contraryColor"))
                                            Button{
                                                showPassword.toggle()
                                            }label:{
                                                Image(systemName:showPassword ? "eye.fill" : "eye.slash.fill")
                                                    .foregroundColor(Color("contraryColor"))
                                            }.disabled(signUpLogInLoading)
                                        }
                                        if showPassword == true{
                                            TextField("5-20位密碼,無其他限制", text: $passwordSignUpInput)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .disabled(signUpLogInLoading)
                                        }else{
                                            SecureField("5-20位密碼,無其他限制", text: $passwordSignUpInput)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                .disabled(signUpLogInLoading)
                                        }
                                        Text(signUpPasswordMessage != "" ? "x\(signUpPasswordMessage)" : " ")
                                            .offset(x:20).font(.custom(fontStyle, size: 12)).padding(.bottom,5).foregroundColor(.red)
                                    }
                                    //註冊按鈕
                                    Button{
                                        signUpUserNameMessage = ""
                                        signUpPasswordMessage = ""
                                        signUpLogInLoading = true
                                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: signUpLogInLoading) { timer in
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
                                            if(signUpLogInLoading == false){
                                                timer.invalidate()
                                            }
                                        }
                                        FavQsSignUp(userName:userNameSignUpInput,password:passwordSignUpInput)
                                        passwordLoginInput = ""
                                    }label:{
                                        Label("註冊",systemImage:"key")
                                            .font(.custom(fontStyle, size: 16))
                                            .frame(width: UIScreen.main.bounds.width/10*8, height: 40)
                                            .background(themeColors_Item[saver.ThemeColorID])
                                            .foregroundColor(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    }.disabled(signUpLogInLoading)
                                    HStack{
                                        Spacer()
                                        Text("已有帳號？")
                                            .font(.custom(fontStyle, size: 16))
                                            .foregroundColor(Color("contraryColor"))
                                        Button{
                                            userNameSignUpInput = ""
                                            passwordSignUpInput = ""
                                            showPassword = false
                                            viewMode = 2
                                        }label:{
                                            Text("前往登入 ➨")
                                                .font(.custom(fontStyle, size: 15))
                                                .foregroundColor(Color("contraryColor"))
                                                .underline()
                                        }.disabled(signUpLogInLoading)
                                        Spacer()
                                    }.padding(.top,10)
                                }
                                .padding(.all,20)
                                .frame(minWidth:UIScreen.main.bounds.width * 0.9,maxWidth:UIScreen.main.bounds.width * 0.9,idealHeight: UIScreen.main.bounds.height * 0.6)
                                .background(Color.secondary)
                                .cornerRadius(10)
                                .tooltip(.top, config: tooltipConfig) {
                                    Text("註冊帳號就能使用本App的所有功能!")
                                        .font(.custom(fontStyle, size: 12))
                                        .foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    else if(viewMode == 2){
                        ZStack{
                            HStack(spacing:UIScreen.main.bounds.width * 0.15){
                                VStack{
                                    Image(systemName:"tram")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:UIScreen.main.bounds.width * 0.4,height:UIScreen.main.bounds.height * 0.4)
                                        .foregroundColor(.red)
                                    Image(systemName:"tram")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:UIScreen.main.bounds.width * 0.4,height:UIScreen.main.bounds.height * 0.4)
                                        .foregroundColor(.orange)
                                }
                                VStack{
                                    Image(systemName:"tram")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:UIScreen.main.bounds.width * 0.4,height:UIScreen.main.bounds.height * 0.4)
                                        .foregroundColor(.green)
                                    Image(systemName:"tram")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width:UIScreen.main.bounds.width * 0.4,height:UIScreen.main.bounds.height * 0.4)
                                        .foregroundColor(.blue)
                                }
                             
                            }
                            VStack{
                                Text("台鐵查詢App")
                                    .font(.custom(fontStyle, size: 32))
                                    .padding(.bottom,40)
                                VStack(alignment:.leading){
                                    HStack{
                                        Spacer()
                                        Text("登入")
                                            .font(.custom(fontStyle, size: 26))
                                            .foregroundColor(Color("contraryColor"))
                                        Spacer()
                                    }

                                    //帳號
                                    Text("帳號")
                                        .font(.custom(fontStyle, size: 16))
                                        .foregroundColor(Color("contraryColor"))
                                    TextField("您的帳號", text: $userAccountLoginInput)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .disabled(signUpLogInLoading)
                                    Text(logInUserAccountMessage != "" ? "x\(logInUserAccountMessage)" : " ")
                                        .offset(x:20).font(.custom(fontStyle, size: 12)).padding(.bottom,5).foregroundColor(.red)
                                    //密碼
                                    HStack{
                                        Text("密碼")
                                            .font(.custom(fontStyle, size: 16))
                                            .foregroundColor(Color("contraryColor"))
                                        Button{
                                            showPassword.toggle()
                                        }label:{
                                            Image(systemName:showPassword ? "eye.fill" : "eye.slash.fill")
                                                .foregroundColor(Color("contraryColor"))
                                        }.disabled(signUpLogInLoading)
                                    }
                                    if showPassword == true{
                                        TextField("您的密碼", text: $passwordLoginInput)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .disabled(signUpLogInLoading)
                                    }else{
                                        SecureField("您的密碼", text: $passwordLoginInput)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                            .disabled(signUpLogInLoading)
                                    }
                                    Text(logInPasswordMessage != "" ? "x\(logInPasswordMessage)" : " ")
                                        .offset(x:20).font(.custom(fontStyle, size: 12)).padding(.bottom,5).foregroundColor(.red)
                                    //登入按鈕
                                    Button{
                                        logInUserAccountMessage = ""
                                        logInPasswordMessage = ""
                                        signUpLogInLoading = true
                                        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: signUpLogInLoading) { timer in
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
                                            if(signUpLogInLoading == false){
                                                timer.invalidate()
                                            }
                                        }
                                       
                                        FavQsLogIn(userNameOrEmail:userAccountLoginInput,password:passwordLoginInput)
                                        passwordLoginInput = ""
                                    }label:{
                                        Label("登入",systemImage:"person")
                                            .font(.custom(fontStyle, size: 16))
                                            .frame(width: UIScreen.main.bounds.width/10*8, height: 40)
                                            .background(   themeColors_Item[saver.ThemeColorID])
                                            .foregroundColor(.white)
                                            .clipShape(RoundedRectangle(cornerRadius: 12))
                                    } .disabled(signUpLogInLoading)
                                    HStack{
                                        Spacer()
                                        Text("尚無帳號？")
                                            .font(.custom(fontStyle, size: 16))
                                            .foregroundColor(Color("contraryColor"))
                                        Button{
                                            userAccountLoginInput = ""
                                            passwordLoginInput = ""
                                            viewMode = 1
                                            showPassword = false
                                        }label:{
                                            Text("前往註冊 ➨")
                                                .font(.custom(fontStyle, size: 15))
                                                .foregroundColor(Color("contraryColor"))
                                                .underline()
                                        } .disabled(signUpLogInLoading)
                                        Spacer()
                                    }.padding(.top,10)
                                }
                                .padding(.all,20)
                                .frame(minWidth:UIScreen.main.bounds.width * 0.9,maxWidth:UIScreen.main.bounds.width * 0.9,idealHeight: UIScreen.main.bounds.height * 0.5)
                                .background(Color.secondary)
                                .cornerRadius(10)
                                .tooltip(.top, config: tooltipConfig) {
                                    Text("登入帳號就能使用本App的所有功能!")
                                        .font(.custom(fontStyle, size: 12))
                                        .foregroundColor(.primary)
                                }
                                
                                
                            }
                        }
                    
                    }
                }
                if signUpLogInLoading == true{
                    Rectangle()
                        .frame(width:UIScreen.main.bounds.width,height:UIScreen.main.bounds.height)
                        .background(Color.secondary)
                        .ignoresSafeArea()
                        .opacity(0.5)
                    VStack{
                        if viewMode == 1{
                            Text("檢查註冊資訊中,請稍候")
                                .font(.custom(fontStyle, size: 24))
                                .foregroundColor(Color("contraryColor"))
                        }else if viewMode == 2{
                            Text("檢查登入資訊中,請稍候")
                                .font(.custom(fontStyle, size: 24))
                                .foregroundColor(Color("contraryColor"))
                        }else{
                            Text("載入中,請稍候")
                                .font(.custom(fontStyle, size: 24))
                                .foregroundColor(Color("contraryColor"))
                        }
                        HStack{
                            Image(systemName: "tram")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .isHidden(tramIsHiddens[1])
                                .foregroundColor(Color("contraryColor"))
                            Image(systemName: "tram")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .isHidden(tramIsHiddens[2])
                                .foregroundColor(Color("contraryColor"))
                            Image(systemName: "tram")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .isHidden(tramIsHiddens[3])
                                .foregroundColor(Color("contraryColor"))
                            Image(systemName: "tram")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30, height: 30)
                                .isHidden(tramIsHiddens[4])
                                .foregroundColor(Color("contraryColor"))
                        }
                    }
                }
              
            }
        
            
        }
        
    }
}



struct FunctionRow: View {
    
    let icon:String
    let iconColor:Color
    let title:String
    let description:String
    
    var body: some View {
        HStack{
            Image(systemName:icon)
                .resizable()
                .scaledToFit()
                .frame(width:40,height:40)
                .foregroundColor(iconColor)
            VStack(alignment:.leading){
                Text(title)
                    .font(.custom(fontStyle, size: 24))
                    .foregroundColor(.primary)
                Text(description)
                    .font(.custom(fontStyle, size: 14))
                    .foregroundColor(.primary)
            }
        }
    }
}
extension View {//隱藏功能：https://stackoverflow.com/questions/64878620/swiftui-progress-view-hidden
    @ViewBuilder func isHidden(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }
}
