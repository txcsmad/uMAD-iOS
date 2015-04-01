uMAD iOS App
------

Hosting a conference? We put together this app for our annual developer conference, [uMAD](http://umad.me), and it's simple to configure it for your event as well. Check it out on the [App Store](https://itunes.apple.com/us/app/umad-university-of-mad/id964728751?mt=8&ign-mpt=uo%3D4).

* Built on [Parse](http://parse.com) (free up to 30 requests a second), so you can change information and times without resubmitting
* Twitter stream from your organization
* About page with map of your event location
* Analytics for app opens, individual tab opens and crashes (free through Parse)

### Configuration

Rename the `Config.template.swift` file to `Config.swift`. Fill in each of the variables with the proper keys from Twitter and Parse. You will also want to sub in your own icon and tint color, as well as change out the information on the about page. Pull down the dependencies by running `pod install` in the project repo.

#### Parse Table Structure

We've exported the tables we used for uMAD 2015 and included them in the `Sample Data` directory. Import these on the Parse dashboard for your app and you should be up and running.