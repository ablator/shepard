# Ablator Python Client
This is *shepard* -- a Swift client for the [ablator functionality switching server](https://github.com/ablator/ablator/).

Using shepard, you can connect to a hosted or self-hosted instance of ablator from inside your app, and check which functionalities to present to your user. You can find more info about ablator at [ablator.io](http://ablator.io/).

## Installation
Inclusion in CocoaPods is planned. Right now, you'll have to clone this repository and include either the provided `Shepard.framework` or simply `shepard.swift` in your project.

## Usage
To use ablator, you'll need two things: 

- A username of some sort. A string of any kind that represents your user. On iOS, you cloud simply use `UIDevice.current.identifierForVendor!.uuidString`.
- The ID of your functionality. After you have created the functionality in the ablator web interface, copy and paste it into your code. 

If you call shepard's `caniuse` method, it will return either `true` or `false` depending on wether the functionality is enabled for your user. The result of this is cached in a plist file.

If you call shepard's `which` method, it will return either `nil` if the functionality is not enabled for your user, or a string like `orgname.appname.funcname.flavorname` for the flavour that has been selected.

### Example:

```
import shepard
let ablatorClient = AblatorClient(baseURL: "http://ablator.space/")
let username = UIDevice.current.identifierForVendor!.uuidString
let functionalityID = "f8077bfe-bb42-404c-a0d0-3fa107b01860"

# The function `which` will return immediately
# with a cached value that should be enough for most uses. If you need
# an up-to-date value and are willing to wait 50-100ms for it, use the
# provided completion block.
let availability = ablatorClient.which(
    user: username,
    functionalityID: functionalityID,
    completed:
    { functionalityString in
        print(functionalityString ?? "No Availability")
    }
)

# this will return one of the following:
# availability == "orgname.test-app.test-func.green"
# availability == "orgname.test-app.test-func.blue"
# availability == nil
```
