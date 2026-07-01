import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house.fill") }
            WeekGuideView()
                .tabItem { Label("Week Guide", systemImage: "calendar") }
            DailyLogView()
                .tabItem { Label("Daily Log", systemImage: "square.and.pencil") }
            ToolsView()
                .tabItem { Label("Tools", systemImage: "wrench.and.screwdriver.fill") }
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
        }
        .tint(BloomlyTheme.sageDark)
    }
}
