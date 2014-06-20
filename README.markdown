SGKeychain — A class for working with the iOS keychain
=========================

Created and maintained by [Justin Williams](http://www.secondgearsoftware.com)

What is SGKeychain?
-------------------------

SGKeychain is a class for working with the keychain on iOS and OS X. It has the following features:

 * Creating new keychain items
 * Fetching passwords from the keychain
 * Deleting items from your keychain
 * Supports keychain access groups for sharing a single keychain between multiple apps (not supported in the iPhone simulator)
 * Built for iOS 5/10.7 and above using automatic reference counting (ARC)
 * Unit tested

What's in the box?
-------------------------

SGKeychain includes:

* The SGKeychain class itself.
* A sample application that demonstrates how to use SGKeychain's main methods.

Requirements
-------------------------
* You will need to link your Xcode target with Security.framework in order to use SGKeychain.
* SGKeychain is built using ARC.  There are no plans to support reference counting.

Find this useful?
-------------------------

If you have found this useful, I'm always a sucker for receiving surprises from my [Amazon wishlist](http://amzn.to/HRZaNd).  

If you do use SGKeychain in your app, please do contact me and [let me know](http://carpeaqua.com/contact/).

All The Other Stuff
-------------------------

Please report bugs, feature requests and whatnot using Github Issues and (even better) a pull request.

