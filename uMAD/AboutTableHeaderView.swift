import Foundation

class AboutTableHeaderView: UIView {
    @IBOutlet var umadAbout: UILabel!
    @IBOutlet var madAbout: UILabel!
    let organizationAboutText  = "We are a student organization at the University of Texas. We are focused on building the UT community by creating a learning environment for all students through ourworkshops, hack nights, conferences, and other awesome events. We want to build the next generation of successful developers, designers, and entrepreneurs."

    let conferenceAboutText = "The University of MAD is a daylong conference hosted within the Department of Computer Science at the University of Texas at Austin, and intends to provide computer science students a comprehensive overview of core mobile, web, and cloud technologies used in industry everyday. The conference will consist of in-depth technical training sessions led by industry engineers similar to a developer's conference. Similar to Google I/O and Apple WWDC, uMAD is led by engineers and designers from some of the best companies that built some of the most widely used products. Along with attending technical sessions, students will be able to showcase their personal projects to company engineers and recruiters attending the event. Don't worry about your experience level, there will be sessions catered to both both the beginner and advanced developers!"
    override func awakeFromNib() {
        umadAbout.text = conferenceAboutText
        madAbout.text = organizationAboutText
        layoutSubviews()
    }

}