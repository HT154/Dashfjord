# Dashfjord
Dashfjord is an as-complete-as-possible native OS X reimplementation of the Tumblr Dashboard written almost entirely in Swift. Because some parts of the Tumblr API are locked down to first-party apps only (messages, activity, replies), they couldn't be included herein.

## Building
The project builds in Xcode 7.3.1. Insert you OAuth consumer key and secret in `AppDelegate.applicationDidFinishLaunching(_:)`. Dashfjord can complete the full three-legged OAuth flow and stores the obtained tokens in the OS X keychain.

## Caveats
I haven't actively developed Dashfjord for a few months. The language itself has changed significantly and I've started using Swift on the job since most of this code was written, so this code likely doesn't reflect the accepted patterns in Swift or my own current understanding of the language.

A few things are left unimplemented, including inline audio and video media playback, handling of embeds in post bodies, and any manner of persistence.
 
## Stuff I'm proud of

* TrailContentView - a custom NSStackView-based HTML renderer.
* APIRequest - handles API request construction, execution, and data conversion upon completion.
* The architecture is somewhat odd (it was created on-the-fly, after all), and is an odd blend of MVC and MVVM. The model classes themselves actually handle their instantiation from the JSON API data. I'd probably avoid this in the future.

## Libraries

* AudioStreamer https://github.com/mattgallagher/AudioStreamer
* DTHTMLParser https://github.com/Cocoanetics/DTFoundation
* SwiftKeychain (an old clone) https://github.com/yankodimitrov/SwiftKeychain
* TMTumblrSDK (for OAuth signing, actual API client is novel) https://github.com/tumblr/TMTumblrSDK
* WAYWindow https://github.com/weAreYeah/WAYWindow
