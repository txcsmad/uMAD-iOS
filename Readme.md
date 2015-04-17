uMAD iOS App
------
[![Build Status](http://img.shields.io/travis/utcsmad/uMAD-iOS/master.svg?style=flat)](https://travis-ci.org/utcsmad/uMAD-iOS)

Hosting a conference? We put together this app for our annual developer conference, [uMAD](http://umad.me), and it's simple to configure it for your event as well. Check it out on the [App Store](https://itunes.apple.com/us/app/umad-university-of-mad/id964728751?mt=8&ign-mpt=uo%3D4).

* Built on [Parse](http://parse.com) (free up to 30 requests a second), so you can change information and times without resubmitting
* Twitter stream from your organization
* About tab with map of your event location
* Analytics for app opens, individual tab opens and crashes (free through Parse)

### Configuration

Rename the `Config.template.swift` file to `Config.swift`. Fill in each of the variables with the proper keys from Twitter and Parse. You will also want to sub in your own icon and tint color. If you don't need one of the default tabs, simply comment out its addition to the TabViewController in the AppDelegate. Pull down the dependencies by running `pod install` in the project repo, and you should be ready to compile. Note that you will need a [developer account](https://developer.apple.com/programs/ios/) if you intend to distribute your app to attendees.

#### Parse

We've exported the tables we used for uMAD 2015 and included them in the `Sample Data` directory. Import these on the Parse dashboard for your app and you should be up and running. Due to the way Parse stores images, the company logos and thumbnails will not be imported. The app will show grey placeholders until you upload your own.

If you'd like to use the About tab, you'll want to fill in some information in the Config panel of the Parse dashboard. 

Parameter               | Type
-----------------|------
conferenceAbout         | String
conferenceLocation      | GeoPoint
conferenceLocationName | String
organizationAbout       | String

