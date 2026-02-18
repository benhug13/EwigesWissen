# EwigesWissen - iOS Lern-App

## Projekt
Lern-App für Schweizer Oberstufenschüler (14 Jahre, 1./2. Sek) zum Lernen von europäischen Hauptstädten und Geografie.

## Technologie
- SwiftUI + SwiftData, iOS 17+, Swift 5.10
- XcodeGen für Projektgenerierung (`xcodegen generate`)
- Apple MapKit (SwiftUI API) für Geografie
- MVVM-Architektur
- Keine externen Abhängigkeiten

## Build
**WICHTIG: Vor jedem Build immer zuerst committen und pushen!** Dann `./build.sh` verwenden. Das Skript zählt Git-Commits als Build-Nummer, aktualisiert project.yml, führt xcodegen aus und baut direkt auf das iPhone.
```bash
git add ... && git commit -m "..." && git push
./build.sh
```

## Architektur
- **Core/Models**: SwiftData-Modelle (User, QuizSession, etc.) und Plain Structs (Capital, GeographyItem)
- **Core/Data**: Statische Referenzdaten (Hauptstädte, Geografie-Items)
- **Core/Services**: DataService, EngagementService, SoundService
- **Design**: Theme (Colors, Fonts), Components (AppButton, AppCard), Animations
- **Features**: Home, Capitals, Geography, Progress, Settings - je mit Views/ und ViewModels/

## Konventionen
- SchoolLevel.sek1 = Basis-Set, SchoolLevel.sek2 = erweitertes Set
- Fuzzy-Matching für Texteingaben (case-insensitive, Umlaute/Diakritika tolerant)
- Geografie: Toleranzradius in km für Pin-Placement
- SF Pro Rounded als Standardschrift
