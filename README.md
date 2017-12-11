# Ablator Swift Client
This is *shepard* -- a Swift client for the [ablator functionality switching server](https://github.com/ablator/ablator/).

Using shepard, you can connect to a hosted or self-hosted instance of ablator from inside your app, and check which functionalities to present to your user. You can find more info about ablator at [ablator.io](http://ablator.io/).

## Installation
Inclusion in CocoaPods is planned. Right now, you'll have to clone this repository and include either the provided `Shepard.framework` or simply `shepard.swift` in your project.

## Usage
To use ablator, you'll need two things: 

- A username of some sort. A string of any kind that represents your user. On iOS, you cloud simply use `UIDevice.current.identifierForVendor!.uuidString`.
- The ID of your app entry in ablator. After you have created the app in the ablator web interface, copy and paste it into your code.

### Initialize

Using these two bits of information, you can initalize shepard during your app startup. During initialization, shepard will update the list
of enabled functionalities for your app, so they are cached for later use.

### Use

If you call shepard's `caniuse` method, it will return either `true` or `false` depending on wether the functionality is enabled for your user.

If you call shepard's `which` method, it will return either `nil` if the functionality is not enabled for your user, or a string like `orgname.appname.funcname.flavorname` for the flavour that has been selected.

### Example:

First, initialize the ablator client in your **`AppDelegate.swift`**:

```
var ablatorClient: AblatorClient?

func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

    // other initialization of your app
    // ...
    
    // Initialize the ablator client and set it aside for later use
    // This will automatically cache your user's availabilities,
    // so calls to which and canIUse are quick and and synchronous
    let username = UIDevice.current.identifierForVendor!.uuidString
    let appID = "8931262e-150c-41de-8be2-98a59c766314"
    let ablatorClient = AblatorClient(baseURL: "http://ablator.space/", username: username, appID: appID)

    self.ablatorClient = ablatorClient

    return true
}
```

This automatically retrieves the set of availabilities for your user. Then, when you want to use functionality switching in your **ViewController**:

```
override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.

    // Retrieve the ablatorClient from the app delegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let ablatorClient = appDelegate.ablatorClient!

    // These functionality names are copied from the web interface
    let super_advanced_functionality = "breakthesystem.test-app.super-advanced-functionality"
    let button_color_functionality = "breakthesystem.test-app.button-color"

    // `canIUse` example:
    if (ablatorClient.canIUse(functionalityName: super_advanced_functionality)) {
        // Enable Super Advanced Mode
    } else {
        // Disable Super Advanced Mode
    }
}
```

or, if you have defined more than one flavor, for e.g. A/B testing:

```
// `which` example
// The values for the individual cases are copied from the web interface
switch ablatorClient.which(functionalityName: button_color_functionality) {

case "breakthesystem.test-app.button-color.wine-red"?:
    print("make the buttons wine red")

case "breakthesystem.test-app.button-color.turquoise"?:
    print("make the buttons turquise")

default:
    print("Make the buttons the default color")
}
```
