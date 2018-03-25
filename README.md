# Kitab Sawti (Codeing Challenge)

“Career Viewer” is a personal resume app including the following pages:
# Oveview
Contains user picture and an introduction.
#### Features:
- **Offline First Strategy:** 
The application always try to load the overview from coredata first, it will  go for an online load option if only:
**1-Coredata is empty** ( first time load ) 
or 
**2- Coredata is outdated** (the expiry time is set to 10 mins) 
In case coredata is **empty** or it is **outdated** and **online load goes successful** the application will update coredata with latest data received from api and update the core data expiry date to the next 10 mins as well.
In case coredata is **empty** and **online load is also get fail** the application will provide user with an error message and ask user to connect her/his device to internet connection and try again. 
 In case coredata is **not empty** but it is **outdated** and **online load get fail** the application will let user to view the outdated information but provide user with a warning message that suggest user to connect her/his device to internet connection in order to load up-to-date data. 
- **Print**
User is enable to print the page from her iphone or iphad using Airprint

- **Pull Down to Refresh:**
In order to refresh the page user can simply pull down the screen, the page will get refresh. 
You can use this feature to test **"Offline First Strategy"**.Try to turn off your internet connection and come back to the app, then just pull down the overview page, it will be refresh with offline data. In order to see the warning message regarding an **outdated cache** , you have to make sure you at least wait for **10 mins** after an online load, then turn off your internet connection and pull down the page, you will see that the overview can still get load but a warning message also appears on top of the page.


# Education
Contains a list including degree,institute and duration
The education list is loaded from a json file saved inside the app.
##### Features:

- **Print**
- **Pull Down to Refresh**


# Work Experience
Contains a list including role,company and duration
The work experience list is loaded from a json file saved inside the app.
##### Features:
- Pull Down to Refresh:


# skill Set
Contains a list including skills
The skill list is loaded from a json file saved inside the app.
##### Features:
- **Instance Search:** Enable user to search among skill sets
- **Print**
- **Pull Down to Refresh**
# Contact
Contains a list including user cantacts.The contact list is loaded from a json file saved inside the app.
When user click on any contact, the app will provide user with a specific way to contact.

##### Supported Contact Types:
- **Email** ,the click action redirect user to the email manager
- **Phone number**, the click action will enable user to make a call
- **Website** , the click action will open the url in phone's browser
- **Github**, the click action will open the url in phone's browser
- **LinkedIn**, if LinkedIn app is install inside the phone then the click action will open user's LinkedIn profile inside the LinkedIn app otherwise will open the user's profile on LinkedIn website. Please note that in order to open user profile on LinkedIn app or LinkedIn website the url should be in **"yourName-yourLastName-yourID"** format otherwise the click action simply open the url in browser. 


##### Features:

- **Print**
- **Pull Down to Refresh**

# Unit Tests
The application includes the following unit tests:
- testFetchOverviewOnline
- testFetchOfflineOverviewNotExist
- testFetchOfflineOverviewNotExpired
- testFetchOfflineOverviewExpired
- testCreateOverview
- testFetchOverviewFromCoreData
- testReadJsonFromFile

# Architecture Pattern

 This app is developed based on  [Model View Controller (MVC)](https://developer.apple.com/library/content/documentation/General/Conceptual/DevPedia-CocoaCore/MVC.html) architecture pattern recommended by Apple.

# Language & Frameworks 
This app has been developeb by using the following frameworks and language
- Swift3 , 
- RxSwift,
-  RxCocoa,
 - CoreData
 - Alamofire
 # How to run?
First please make sure you have **xcode 9.2** or higher installed on your Mac. Now open the project folder and double click on **"CareerViewer.xcworkspace"** the app will be open inside the xcode, then from xcode's top bar select **product->run**. This will run the app on a simulator, however by running app on simulator you can not have access to all app's fetaurs like **print** or making a **phone call** , the best way to test this app is to run it on actual device.
If you would like to run this app on an actual device then you will need to configure the team and signing inside the xcode. The best way to do this is to use the **"Automatically Manage Signing"** feature of xcode. [This Link](https://developer.apple.com/library/content/qa/qa1814/_index.html) explains how to enable **"Automatically Manage Signing"** feature inside the xcode.


[//]: # (These are reference links used in the body of this note and get stripped out when the markdown processor does its job. There is no need to format nicely because it shouldn't be seen. Thanks SO - http://stackoverflow.com/questions/4823468/store-comments-in-markdown-syntax)


   [dill]: <https://github.com/joemccann/dillinger>
   [git-repo-url]: <https://github.com/joemccann/dillinger.git>
   [john gruber]: <http://daringfireball.net>
   [df1]: <http://daringfireball.net/projects/markdown/>
   [markdown-it]: <https://github.com/markdown-it/markdown-it>
   [Ace Editor]: <http://ace.ajax.org>
   [node.js]: <http://nodejs.org>
   [Twitter Bootstrap]: <http://twitter.github.com/bootstrap/>
   [jQuery]: <http://jquery.com>
   [@tjholowaychuk]: <http://twitter.com/tjholowaychuk>
   [express]: <http://expressjs.com>
   [AngularJS]: <http://angularjs.org>
   [Gulp]: <http://gulpjs.com>

   [PlDb]: <https://github.com/joemccann/dillinger/tree/master/plugins/dropbox/README.md>
   [PlGh]: <https://github.com/joemccann/dillinger/tree/master/plugins/github/README.md>
   [PlGd]: <https://github.com/joemccann/dillinger/tree/master/plugins/googledrive/README.md>
   [PlOd]: <https://github.com/joemccann/dillinger/tree/master/plugins/onedrive/README.md>
   [PlMe]: <https://github.com/joemccann/dillinger/tree/master/plugins/medium/README.md>
   [PlGa]: <https://github.com/RahulHP/dillinger/blob/master/plugins/googleanalytics/README.md>
