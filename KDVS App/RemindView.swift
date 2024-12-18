//
//  RemindMeView.swift
//  KDVS
//
//  Created by John Carraher on 5/13/23.
//

import Foundation
import SwiftUI
import UserNotifications
import UIKit
import EventKit

struct LargeRemindView: View {
    @Binding var show: Show
    @Binding var label: String
    @Binding var scheduleGrid: [Show]
    
    @State var loadedShow: Show?

    
    
    @State private var isLoaded = false
    @State private var isPerformingNotificationAction = false
    
    @State private var selectedDate = Date()
    @State private var dates: Set<DateComponents> = []
    @State private var notificationEnabledShows: [Show] = []
    
        
    var body: some View {
        VStack {
            if ((show.name != "")) {
                HStack {
                    AsyncImage(url: show.playlistImageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(width: 60, height: 60, alignment: .center)
                            .cornerRadius(10)
                    } placeholder: {
                        Rectangle()
                            .fill(Color("RemindLoading"))
                            .cornerRadius(10)
                        .frame(width: 60, height:60)
                    }.frame(width: 60, height: 60)
                    
                    VStack(alignment: .leading, spacing: 0){
                        Text(show.name)
                            .font(.system(size: 17, weight: .bold))
                            .environment(\.colorScheme, .dark)
                            .lineLimit(1)
                        Text(show.djName)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(Color("SecondaryText"))
                            .environment(\.colorScheme, .dark)
                            .lineLimit(1)
                    }.padding([.leading], 5)
                    Spacer()
                }
                .padding([.top, .bottom, .leading, .trailing], 20)
                .frame(maxWidth: .infinity)
                .background(Color("RemindCompiment"))
                
                VStack(alignment: .leading) {
                    Text(label)
                        .font(.system(size: 14, weight: .bold))
                        .environment(\.colorScheme, .dark)
                        .foregroundColor(Color("SecondaryText"))
                        .multilineTextAlignment(.leading)
                        .padding([.leading], 20)
                }
                .padding([.top], 10)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                // UICalendarView to display show.showDates
                if(!isLoaded){
                    ProgressView()
                        .frame(width: 325, height: 300, alignment: .center)
                }else{
                    if(!show.dates.isEmpty){
                        MultiDatePicker(
                            "Show Dates",
                            selection: $dates,
                            in: Date()...
                        ).frame(width: 325, height: 330, alignment: .center)
                            .tint(show.showColor?.brightened(by: 1)) // Set your desired color here
                            .padding([.top], 7)
                            .disabled(true)
                    } else{
                        Spacer()
                        Text("No Upcoming Shows")
                            .font(.system(size: 16, weight: .semibold))
                            .environment(\.colorScheme, .dark)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 15)
                        Spacer()
                    }
                }
                Spacer()
                Button(action: toggleRemindButton, label: {
                    if !isLoaded {
                        ProgressView()
                    } else if (!containsMatchingShow(shows: notificationEnabledShows, show: show)) {
                        Text("Notify Me!")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(.white))
                            .environment(\.colorScheme, .dark)
                    } else {
                        Text("Turn off Notifications")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(.white))
                            .environment(\.colorScheme, .dark)
                    }
                }).frame(width: 350, height: 50, alignment: .center)
                .background(Color("NotiButtonColor2"))
                .cornerRadius(10)
                .padding([.top, .bottom], 20)
                .disabled(!isLoaded)
            } else {
                Spacer()
                HStack {
                    Text("No Scheduled Programming")
                        .font(.system(size: 16, weight: .semibold))
                        .environment(\.colorScheme, .dark)
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 15)
                }.frame(alignment: .center)
                Spacer()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("RemindBackground"))
        .onAppear {
            findShowWithName(scheduleGrid, showName: show.name) { foundShow in
                show = foundShow!
                dates = getShowDates(for: show)
                loadNotificationEnabledShows()
                isLoaded = true
            }
            
        }
    }
    
    func toggleRemindButton() {
        guard !isPerformingNotificationAction else {
            return
        }
        isPerformingNotificationAction = true
        
        if !containsMatchingShow(shows: notificationEnabledShows, show: show) {
            notificationEnabledShows.append(show)
            saveNotificationEnabledShows()
            scheduleNotifications(inShow: show)
            printAllExistingNotifications()
        } else {
            removeMatchingShow(from: &notificationEnabledShows, showToRemove: show)
            saveNotificationEnabledShows()
            removeNotificationsForShow(withTitle: show.name)
            printAllExistingNotifications()
        }
        
        isPerformingNotificationAction = false
    }
    
    func scheduleNotifications(inShow show: Show) {
        let notificationCenter = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        
        let group = DispatchGroup()
        group.enter()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                for date in show.dates {
                    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    
                    let content = UNMutableNotificationContent()
                    content.title = show.name
                    content.body = "Your show is about to start!"
                    content.sound = .default
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    group.enter()
                    notificationCenter.add(request) { error in
                        if let error = error {
                            print("Failed to schedule notification: \(error)")
                        }
                        group.leave()
                    }
                }
            } else if let error = error {
                print("Failed to request notification authorization: \(error)")
            }
            group.leave()
        }
        
        group.wait()
    }

    func saveNotificationEnabledShows() {
        let data = try? JSONEncoder().encode(notificationEnabledShows)
        UserDefaults.standard.set(data, forKey: "NotificationEnabledShows")
    }

    func loadNotificationEnabledShows() {
        if let data = UserDefaults.standard.data(forKey: "NotificationEnabledShows") {
            do {
                notificationEnabledShows = try JSONDecoder().decode([Show].self, from: data)
            } catch {
                print("Error decoding notification enabled shows: \(error)")
            }
        }
    }
}

struct RemindView: View {
    @Binding var show : Show
    @Binding var label : String
    
    @State var scheduleGrid: [Show] = []
    @State private var isPerformingNotificationAction = false
    @State private var isLoading = true

    
    @State private var selectedDate = Date()
    @State private var dates: Set<DateComponents> = []
    @State private var notificationEnabledShows: [Show] = []
    
    var bounds: Range<Date> {
        let start = Date()
        let end = show.lastShowDate
        return start ..< end
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                Text(label)
                    .font(.system(size: 14, weight: .bold))
                    .environment(\.colorScheme, .dark)
                    .foregroundColor(Color("SecondaryText"))
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            if(show.name != ""){
                HStack {
                    AsyncImage(url: show.playlistImageURL) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .frame(width: 100, height: 100, alignment: .center)
                            .cornerRadius(5)
                    } placeholder: {
                        ProgressView()
                    }.frame(width: 100, height: 100)
                    
                    VStack(alignment: .leading, spacing: 5){
                        Text(show.name)
                            .font(.system(size: 20, weight: .bold))
                            .environment(\.colorScheme, .dark)
                        Text(show.djName)
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color("SecondaryText"))
                            .environment(\.colorScheme, .dark)
                        Text("\(Date().dayOfWeek()!)s from \(show.startTime.formattedTime(endTime: show.endTime))")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(Color("SecondaryText"))
                            .environment(\.colorScheme, .dark)
                    }.padding([.leading], 5)
                    Spacer()
                }.padding([.leading, .trailing], 20)
                
                Button(action: toggleRemindButton, label: {
                    if(isLoading){
                        Spacer()
                        ProgressView()
                        Spacer()
                    }else if(!containsMatchingShow(shows: notificationEnabledShows, show: show)){
                        Text("Notify Me!")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(.white))
                            .environment(\.colorScheme, .dark)
                    }else{
                        Text("Turn off Notifications")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(Color(.white))
                            .environment(\.colorScheme, .dark)
                    }
                }).frame(maxWidth: .infinity, maxHeight: 50, alignment: .center)
                    .background(Color("NotiButtonColor2"))
                    .cornerRadius(10)
                    .padding([.horizontal], 20)
                    .padding([.top], 5)
            }else {
                Spacer()
                HStack{
                    Text("No Scheduled Programming")
                        .font(.system(size: 16, weight: .semibold))
                        .environment(\.colorScheme, .dark)
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 15)
                }.frame(alignment: .center)
                Spacer()
            }
        }.frame(maxWidth: .infinity, maxHeight: 220)
            .background(Color("RemindBackground"))
        .onAppear{
            //Load in List of Shows to find current show
            fetchShows { Shows in
                scheduleGrid = Shows
                dates = getShowDates(for: show)
                loadNotificationEnabledShows()
                print("NotificationEnabledShows: \(notificationEnabledShows.count)")
                isLoading = false
            }
        }
    }
    
    func toggleRemindButton(){
        guard !isPerformingNotificationAction else {
            return // Ignore button taps when a notification action is already in progress
        }
        isPerformingNotificationAction = true // Set the flag to indicate the action is in progress

        
        if(!containsMatchingShow(shows: notificationEnabledShows, show: show) ){
            //TURNING ON NOTIFICATIONS
            notificationEnabledShows.append(show) //remember that notifications are on for this show
            saveNotificationEnabledShows() // P2 of above
            scheduleNotifications(inShow: show) //add Notifications for this Show
            
            print("RemindView: Added \(show.name) Notification!")
            printAllExistingNotifications()

        }else{
            //TURNING OFF NOTIFICATIONS
            removeMatchingShow(from: &notificationEnabledShows, showToRemove: show) //forget show noti
            saveNotificationEnabledShows() //P2 of above
            removeNotificationsForShow(withTitle: show.name) //remove existing notifications for show

            print("RemindView: Removed \(show.name) Notification!")
            printAllExistingNotifications()
        }
        
        isPerformingNotificationAction = false // Reset the flag to indicate the action is completed

    }
    
    func scheduleNotifications(inShow show: Show) {
        let notificationCenter = UNUserNotificationCenter.current()
        let calendar = Calendar.current
        
        let group = DispatchGroup()
        group.enter()
        
        notificationCenter.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                // Schedule notifications for selected dates
                for date in show.dates {
                    let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                    
                    let content = UNMutableNotificationContent()
                    content.title = show.name
                    content.body = "Your show is about to start!"
                    content.sound = .default
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
                    
                    group.enter()
                    notificationCenter.add(request) { error in
                        if let error = error {
                            print("Failed to schedule notification: \(error)")
                        }
                        group.leave()
                    }
                }
                
            } else if let error = error {
                print("Failed to request notification authorization: \(error)")
            }
            group.leave()
        }
        
        group.wait() // Wait for the group to complete before continuing
    }

    func saveNotificationEnabledShows() {
            let data = try? JSONEncoder().encode(notificationEnabledShows)
            UserDefaults.standard.set(data, forKey: "NotificationEnabledShows")
        }

    func loadNotificationEnabledShows() {
        if let data = UserDefaults.standard.data(forKey: "NotificationEnabledShows") {
            do {
                notificationEnabledShows = try JSONDecoder().decode([Show].self, from: data)
            } catch {
                // Handle the error if decoding fails
                print("Error decoding notification enabled shows: \(error)")
            }
        }
    }
    
}

struct MiniRemindView: View {
    @Binding var show : Show
    @Binding var label : String

    @State private var isPerformingNotificationAction = false
    
    @State private var image: UIImage?
    
    @State private var selectedDate = Date()
    @State private var dates: Set<DateComponents> = []
    
    var bounds: Range<Date> {
        let start = Date()
        let end = show.lastShowDate
        return start ..< end
    }
    
    var body: some View {
        VStack {
            HStack {
                //Display Rectangle with music note icon and a 30x30 rectangle with a background
                ZStack {
                    Rectangle()
                        .fill(show.showColor ?? Color(.clear))
                    Image(systemName: "music.note") // Outlined bell icon
                        .font(.system(size: 15))
                        .foregroundColor(Color(.white))
                }
                .frame(width: 30, height: 30)
                .cornerRadius(5)
                .padding([.leading], 12)

                
                Text(show.name)
                    .font(.system(size: 15, weight: .bold))
                    .environment(\.colorScheme, .dark)
                    .frame(alignment: .leading)
                    .padding([.leading], 8)
                Spacer()
            }.frame(width: 350)
            .padding([.leading, .trailing], 15)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
}

struct ReminderManagerView: View {
    @State private var notificationEnabledShows: [Show] = []

    var body: some View {
        VStack(spacing: 0){
            VStack(alignment: .leading) {
                Text("NOTIFICATIONS")
                    .font(.system(size: 14, weight: .bold))
                    .environment(\.colorScheme, .dark)
                    .foregroundColor(Color("SecondaryText"))
                    .multilineTextAlignment(.leading)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            if(!notificationEnabledShows.isEmpty){
                List{
                    ForEach(notificationEnabledShows, id: \.id) { show in
                        MiniRemindView(show: .constant(show), label: .constant("Existing Notifications"))
                            .listRowBackground(Color("ListBackground"))
                    }.onDelete(perform: deleteShow)
                }
                .background(Color("RemindBackground"))
                .scrollContentBackground(.hidden)
                .navigationBarTitle("Reminder Manager", displayMode: .inline)
                .listStyle(DefaultListStyle())
            } else {
                Spacer()
                HStack{
                    Text("No Reminders Scheduled :)")
                        .font(.system(size: 16, weight: .semibold))
                        .environment(\.colorScheme, .dark)
                        .foregroundColor(Color.white)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 15)
                }.frame(alignment: .center)
                Spacer()
            }
        }.onAppear {
            
            loadNotificationEnabledShows()
        }
    }
    
    func deleteShow(at offsets: IndexSet) {
        // Convert the IndexSet to an array of indices
        let indicesToRemove = Array(offsets)
        
        // Iterate over the indices and remove corresponding shows and notifications
        for index in indicesToRemove {
            if index < notificationEnabledShows.count {
                let show = notificationEnabledShows[index]
                removeNotificationsForShow(withTitle: show.name)
            }
        }
        
        // Remove the shows at the specified indices
        notificationEnabledShows.remove(atOffsets: offsets)
        
        // Save the updated notificationEnabledShows
        saveNotificationEnabledShows()
    }

    func saveNotificationEnabledShows() {
            let data = try? JSONEncoder().encode(notificationEnabledShows)
            UserDefaults.standard.set(data, forKey: "NotificationEnabledShows")
        }
    
    func loadNotificationEnabledShows() {
        if let data = UserDefaults.standard.data(forKey: "NotificationEnabledShows") {
            do {
                notificationEnabledShows = try JSONDecoder().decode([Show].self, from: data)
            } catch {
                // Handle the error if decoding fails
                print("Error decoding notification enabled shows: \(error)")
            }
        }
    }
}

func findShowWithName(_ shows: [Show], showName: String, completion: @escaping (Show?) -> Void) {
    let matchingShow = shows.first { $0.name == showName }
    completion(matchingShow)
}

//Removes Show from List of CoreData JSON
func removeNotificationsForShow(withTitle title: String) {
    let notificationCenter = UNUserNotificationCenter.current()
    
    let semaphore = DispatchSemaphore(value: 0)
    
    notificationCenter.getPendingNotificationRequests { notifications in
        let identifiersToRemove = notifications
            .filter { $0.content.title == title }
            .map { $0.identifier }
        
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiersToRemove)
        
        semaphore.signal()
    }
    
    _ = semaphore.wait(timeout: .distantFuture) // Wait for the task to complete
}

//Returns formatted set of show dates
func getShowDates(for show: Show) -> Set<DateComponents> {
    let calendar = Calendar.current
    let dates = Set(show.dates.map { calendar.dateComponents([.year, .month, .day], from: $0) })
    print(dates)
    return dates
}

//Deletes all shows from JSON memory
func wipeAllShows() {
    let notificationCenter = UNUserNotificationCenter.current()
    UserDefaults.standard.removeObject(forKey: "NotificationEnabledShows")
    notificationCenter.removeAllPendingNotificationRequests()
}

//Deletes all scheduled notifications
func wipeAllScheduledNotifications() {
    let notificationCenter = UNUserNotificationCenter.current()
    
    notificationCenter.removeAllPendingNotificationRequests()
    notificationCenter.removeAllDeliveredNotifications()
}

//Prints all esisting Shows
func printAllExistingNotifications(){
    
    let center = UNUserNotificationCenter.current()

    center.getPendingNotificationRequests { (notifications) in
            print("There are now: \(notifications.count) scheduled notifications")
            //for item in notifications {
            //print(item.content)
            //}
        }
}

extension UIColor {
    func adjusted(brightnessFactor: CGFloat, saturationFactor: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return UIColor(
                hue: hue,
                saturation: max(min(saturation * saturationFactor, 1.0), 0.0),
                brightness: max(min(brightness * brightnessFactor, 1.0), 0.0),
                alpha: alpha
            )
        }
        
        return self
    }
}

extension Color {
    func brightened(by factor: Double) -> Color {
        let uiColor = UIColor(self)
        guard let modifiedColor = uiColor.adjustedBrightness(by: CGFloat(factor)) else {
            return self
        }
        return Color(modifiedColor)
    }
}

extension UIColor {
    func adjustedBrightness(by factor: CGFloat) -> UIColor? {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            b = max(0, min(1, b + factor))
            return UIColor(hue: h, saturation: s, brightness: b, alpha: a)
        }
        return nil
    }
}

//Code to read average color of an image
extension UIImage {
    /// Average color of the image, nil if it cannot be found
    var averageColor: UIColor? {
        // convert our image to a Core Image Image
        guard let inputImage = CIImage(image: self) else { return nil }

        // Create an extent vector (a frame with width and height of our current input image)
        let extentVector = CIVector(x: inputImage.extent.origin.x,
                                    y: inputImage.extent.origin.y,
                                    z: inputImage.extent.size.width,
                                    w: inputImage.extent.size.height)

        // create a CIAreaAverage filter, this will allow us to pull the average color from the image later on
        guard let filter = CIFilter(name: "CIAreaAverage",
                                  parameters: [kCIInputImageKey: inputImage, kCIInputExtentKey: extentVector]) else { return nil }
        guard let outputImage = filter.outputImage else { return nil }

        // A bitmap consisting of (r, g, b, a) value
        var bitmap = [UInt8](repeating: 0, count: 4)
        let context = CIContext(options: [.workingColorSpace: kCFNull!])

        // Render our output image into a 1 by 1 image supplying it our bitmap to update the values of (i.e the rgba of the 1 by 1 image will fill out bitmap array
        context.render(outputImage,
                       toBitmap: &bitmap,
                       rowBytes: 4,
                       bounds: CGRect(x: 0, y: 0, width: 1, height: 1),
                       format: .RGBA8,
                       colorSpace: nil)

        // Convert our bitmap images of r, g, b, a to a UIColor
        return UIColor(red: CGFloat(bitmap[0]) / 255,
                       green: CGFloat(bitmap[1]) / 255,
                       blue: CGFloat(bitmap[2]) / 255,
                       alpha: CGFloat(bitmap[3]) / 255)
    }
}
