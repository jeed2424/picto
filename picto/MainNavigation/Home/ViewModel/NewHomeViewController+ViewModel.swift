import Foundation
import Combine

extension NewHomeViewController {
    final class ViewModel: ObservableObject {

        enum CurrentPage: Int {
            case home
            case register
            case google
            case email
            case username
        }

        @Published private(set) var currentPage: CurrentPage = .home

        // MARK: - Functions

        func loadPageSelection(selection: CurrentPage) {
            if selection != currentPage {
                self.currentPage = selection
            }
        }
        
        func resetPaging() {
            self.currentPage = .home
        }

    }
}
