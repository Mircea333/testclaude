import SwiftUI

struct FontSizeModifier: ViewModifier {
    let preference: FontSizePreference

    func body(content: Content) -> some View {
        content
            .dynamicTypeSize(preference.dynamicTypeSize)
    }
}

extension View {
    func appFontSize(_ preference: FontSizePreference) -> some View {
        modifier(FontSizeModifier(preference: preference))
    }
}
