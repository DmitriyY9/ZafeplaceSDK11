# Zafeplace  SDK-IOS

 Zafeplace SDK is a library for simple working with some crypto currency, such as ethereum and stellar. Using the library, we can
 generate wallets, take wallet balance for coins and tokens, do transaction for translation coins and tokens, also we can take list with smart conract functions and 
 execute any of them. 
 
 Example
 -------
 
 You need to use functionality of the library using the object of Zafeplace class. It is main class in library, all needed methods you
 can find here. Object of Zefaplace class is created as singlton and you can use one instance in all project classes. It is created as follows - 
 
          let zafeplace = Zafeplace.default
 Further, when we received an instance of the Zafeplace class, we need to initialize the application
  
          let appId: String = ...
          let appSecret: String = ...
          Zafeplace.config(appId: appId, appSecret: appSecret)
 We can use any method using instance of Zafeplace class. For example 
                
        // get token balance
        let type = .Ethereum // or Stellar
        zafeplace.operation().getTokenBalance(network: type) { (result) in
            if result.ifSuccess {
                //result.value - get response
            } else {
                //handle an error
            }
        }
            
        // generate wallet
        let type = .Ethereum // or Stellar
        zafeplace.createNewWallet(type: type) { (state) in
        
             switch state {
                case .WALLET_CREATED:
                    //successfully created
                    
                case .WALLET_NOT_CREATED:
                    //an error has occurred
                    
                case .AUTHORIZED
                    //user authorized
                    
                case .NOT_AUTHORIZED
                    //user is not authorized
                }
            }
  Here we have two examples for two different methods: methods for taking token balance and method for generating new wallet. We have two different wallet types
  : etherum and stellar. You have to send in method params needed type of currency like enum.
  In first example we send into method type of currency, address of our wallet, and callback for taking result, because all methods of library is asynchronous.
  In second example we generate new etherum wallet we send to method params type of currency and callback for taking result.
  Also we can login for user authentication and using some methods like creating transactions and generating wallets.
  You can use fingerprint login and pin code login. For example - pin code login:
      
       zafeplace.user().authenticate(type: .PIN(pin)) { (state, type) in
            print("Auth state = \(type)")
            if type == .WRONG_PIN_CODE_NUMBER_COUNT {
                 //an error has occurred
            } else {
                 //user authorized
            }
        }
        
   fingerprint login:
   
        zafeplace.user().authenticate(type: .TOUCH) { (state, type) in
            print("Auth state = \(type)")
            if type == .SUCCESS {
                //user authorized
            } else {
                //an error has occurred
            }
        }

             
       
  
  Methods
  -------
  
| Name        | Description           | 
| ------------- |:-------------:| 
| config(String, String) | Set appId and appSecret | 
| createNewWallet(NetworkProvider.WalletType, result: (_ state: State) -> ()) | Generate wallet for the specified type. | 
| getBalance(NetworkProvider.WalletType, response: @escaping (_ balance: Result<Float>) -> ()) | Get balance of wallet for the specified type |
| getTokenBalance(NetworkProvider.WalletType, response: @escaping (_ tokenBalance: Result<[TokenBalance]>) -> ()) | Get balance tokens for wallet for specified type |
| createTransaction(NetworkProvider.WalletTyp, String, String, int, response: @escaping (_ response: Result<String>) -> ()) | Create transaction for translation coins for specified type, address sender and address recipient |
| createTransactionToken(NetworkProvider.WalletTyp, String, String, int, response: @escaping (_ response: Result<String>) -> ()) | Create transaction for translation tokens for specified type, address sender and address recipient |
| getNativeCoinRawTx(NetworkProvider.WalletType) |  Get list of smart contracts for ethereum currency |
| executeSmartContract(NetworkProvider.WalletType, SmartContractBody, response: @escaping (_ abi: Result<String>) -> ()) | Execute one of methods from list smart contracts for ethereum currency |
| authenticate(AuthType, result: @escaping (_ state: Bool, _ type: ResultType) -> ()) | Authorization with touch id or pin code |
| isAuthorized() | Method for checking is user is signed in |
| isWalletCreated(NetworkProvider.WalletType) | Check if a specific wallet was created |
| wallet(NetworkProvider.WalletType) | Get specific wallet by type |
| listOfAddresses() | List of networks and addresses associated with each network |
