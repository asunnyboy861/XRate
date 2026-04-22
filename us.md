# XRate - Instant Currency Converter

> **App Name**: XRate
> **Subtitle**: Instant Currency Converter
> **Bundle ID**: com.zzoutuo.XRate
> **Target Market**: United States
> **Platform**: iOS 17+ / Apple Watch / Widget
> **Minimum iOS**: 17.0

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Competitive Analysis](#2-competitive-analysis)
3. [Apple Design Guidelines Compliance](#3-apple-design-guidelines-compliance)
4. [Technical Architecture](#4-technical-architecture)
5. [Module Structure & File Organization](#5-module-structure--file-organization)
6. [Implementation Flow](#6-implementation-flow)
7. [UI/UX Design Specifications](#7-uiux-design-specifications)
8. [Code Generation Rules](#8-code-generation-rules)
9. [Testing & Validation Standards](#9-testing--validation-standards)
10. [Build & Deployment Checklist](#10-build--deployment-checklist)

---

## 1. Executive Summary

### Product Vision

XRate is a minimalist currency converter built for the Apple ecosystem. The core philosophy is **"One Tap to Know"** — users open the app and instantly see conversion results with zero learning curve. Unlike competitors that cram news feeds, stock tickers, crypto wallets, and ads into a single app, XRate focuses exclusively on one thing: fast, accurate, offline-capable currency conversion.

### Key Differentiators

| Differentiator | How XRate Delivers | Competitor Gap |
|---|---|---|
| **Minimalist Design** | Single-screen conversion, zero clutter | XE Currency has news/transfer features; Currency+ has ads |
| **Offline First** | Auto-caches rates, works without internet | Most free apps require constant connectivity |
| **Zero Ads** | Free version has no ads, Pro via subscription | Free competitors bombard users with ads |
| **Apple Ecosystem** | iPhone + Apple Watch + Widget | XE has no Watch app; Currency+ has no widget |
| **Smart Experience** | Location-aware suggestions, fuzzy search | No competitor offers location-based currency suggestions |

### Target Users

| User Segment | US Market Size | Core Need | Willingness to Pay |
|---|---|---|---|
| International Travelers | ~93M/year | Fast conversion, offline | Medium ($0.99-$4.99) |
| Cross-border Business | ~15M | Real-time accuracy, multi-currency | High (subscription acceptable) |
| International Students | ~5M | Frequent small conversions | Low-Medium |
| Light Forex Traders | ~10M | Trend charts, historical data | High (Pro features) |
| Online Shoppers | ~30M | Simple quick conversion | Low |

---

## 2. Competitive Analysis

### Competitor Overview

| Feature | XRate | XE Currency | Currency (Minimal) | Currency Converter (Batch) | My Currency Converter Pro |
|---|---|---|---|---|---|
| Minimalist UI | Yes | No | Yes | No | Yes |
| Offline Mode | Yes | Yes (paid) | Yes | Yes | Yes |
| Zero Ads (free) | Yes | No | Yes | No | Yes (paid) |
| Apple Watch | Yes | No | No | Yes | Yes |
| Desktop Widget | Yes | Yes | No | Yes | No |
| Trend Charts | Yes | Yes (paid) | No | Yes | Yes |
| Smart Suggestions | Yes | No | No | No | No |
| Location-aware | Yes | No | No | No | No |
| Money Transfer | No | Yes | No | No | No |
| Crypto | No | No | Yes (paid) | Yes | Yes |
| Price | Free + IAP | Free + IAP | Free + $5.99 one-time | Free + $3.99 IAP | $14.99 |
| iOS Requirement | 17.0+ | 16.0+ | 26.0+ | 12.0+ | 15.0+ |
| Data Privacy | No tracking | Collects data | No tracking | Collects usage data | No data collected |

### Strategic Positioning

XRate occupies the **"pure conversion experience"** niche — it deliberately avoids money transfer, crypto, and news features. This focus creates a clear brand identity: when users want to convert currency, they think XRate. When they want to transfer money, they think Wise or XE.

### Competitive Advantages

1. **Zero ads in free version** — Most free converters show interstitial ads
2. **Offline-first architecture** — Cached rates work for 24+ hours
3. **Apple Watch companion** — Only 2 competitors have Watch apps
4. **Location-aware suggestions** — Unique feature, no competitor offers this
5. **Modern tech stack** — SwiftUI + SwiftData + Swift Charts (iOS 17+), competitors use UIKit

---

## 3. Apple Design Guidelines Compliance

### HIG Principles Applied

| Principle | Implementation |
|---|---|
| **Hierarchy** | Clear visual hierarchy: currency cards > swap button > quick access > trend preview |
| **Harmony** | Consistent 16pt corner radius, .regularMaterial backgrounds, system fonts |
| **Consistency** | Standard NavigationStack, List, SearchBar patterns; native keyboard |

### Design Compliance Notes

1. **Navigation**: Use NavigationStack (not NavigationView) for iOS 17+
2. **Search**: Use `.searchable()` modifier for currency picker search
3. **Materials**: Use `.regularMaterial` for card backgrounds (translucent glass effect)
4. **Typography**: SF Pro for labels, SF Mono for numbers (system default monospaced)
5. **Colors**: Accent color #007AFF (system blue), support Dark Mode via semantic colors
6. **Haptics**: Use UIImpactFeedbackGenerator for swap button tap
7. **Dynamic Type**: All text supports Dynamic Type scaling
8. **VoiceOver**: All interactive elements have accessibility labels
9. **Safe Areas**: Content respects safe area insets on all devices
10. **Keyboard**: Use `.keyboardType(.decimalPad)` for amount input

### App Store Review Guidelines Compliance

- **4.1 Copycats**: XRate has unique design and features, no cloning
- **4.2 Minimum Functionality**: Full-featured currency converter with offline mode
- **5.1 Privacy**: No personal data collected; privacy policy required
- **3.1.2 Subscriptions**: Pro subscription follows all IAP rules (see Phase 8)

---

## 4. Technical Architecture

### Architecture Overview

```
┌─────────────────────────────────────────────────┐
│                    XRate App                     │
│                                                  │
│  ┌────────────────────────────────────────────┐  │
│  │              Views (SwiftUI)                │  │
│  │  ConversionView │ CurrencyPicker │ Trend   │  │
│  │  SettingsView   │ WatchView      │ Widget  │  │
│  └──────────────────┬─────────────────────────┘  │
│                     │                            │
│  ┌──────────────────▼─────────────────────────┐  │
│  │           ViewModels (@Observable)          │  │
│  │  ConversionVM │ CurrencyListVM │ TrendVM   │  │
│  │  SettingsVM   │ PurchaseManager            │  │
│  └──────────────────┬─────────────────────────┘  │
│                     │                            │
│  ┌──────────────────▼─────────────────────────┐  │
│  │             Services Layer                  │  │
│  │  ExchangeRateService │ CacheService         │  │
│  │  CurrencyDataService │ LocationService      │  │
│  └──────────────────┬─────────────────────────┘  │
│                     │                            │
│  ┌──────────────────▼─────────────────────────┐  │
│  │          Data Layer (SwiftData)             │  │
│  │  Currency │ CachedExchangeRate              │  │
│  │  UserDefaults (preferences)                 │  │
│  └────────────────────────────────────────────┘  │
│                                                  │
│  ┌────────────────────────────────────────────┐  │
│  │          External APIs                     │  │
│  │  Primary: Frankfurter (free, no key)       │  │
│  │  Fallback: ExchangeRate-API (1500/mo free) │  │
│  └────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────┘
```

### Tech Stack

| Layer | Technology | Purpose |
|---|---|---|
| Language | Swift 5.9+ | Modern Swift with async/await, @Observable |
| UI Framework | SwiftUI (iOS 17+) | Declarative UI, animations |
| Architecture | MVVM | Model-ViewModel-View separation |
| Networking | URLSession + async/await | No third-party networking libraries |
| Persistence | SwiftData (iOS 17+) | Declarative data persistence |
| Caching | SwiftData + UserDefaults | Rate cache + user preferences |
| Charts | Swift Charts (iOS 16+) | Native chart framework |
| Widget | WidgetKit | Home screen widgets |
| Watch | SwiftUI + WatchKit | Apple Watch companion |
| Search | Custom fuzzy matching | Country/currency/code search |
| Location | CoreLocation | Travel mode location awareness |
| IAP | StoreKit 2 | In-app purchases |

### API Strategy

**Primary: Frankfurter API**
- Base URL: `https://api.frankfurter.dev`
- Version: v2
- Auth: None required
- Currencies: 164+ active
- Data source: 54 central banks
- Rate limit: Unlimited
- Endpoints:
  - `GET /v2/rates?base=USD` — Latest rates
  - `GET /v2/rates?base=USD&quotes=EUR,GBP,JPY` — Specific rates
  - `GET /v2/rates?from=2026-01-01&base=USD&quotes=EUR` — Time series
  - `GET /v2/rate/USD/EUR` — Single pair
  - `GET /v2/currencies` — Available currencies

**Fallback: ExchangeRate-API**
- Base URL: `https://v6.exchangerate-api.com/v6/{KEY}`
- Free tier: 1,500 requests/month
- Update frequency: Every 30 minutes

**Cache Strategy**:
1. On launch: Check cache age < 30 min → use cache
2. Cache expired → Fetch from Frankfurter
3. Frankfurter fails → Fetch from ExchangeRate-API
4. Both fail → Use cache + show "Offline Mode"

### Data Models

```swift
@Model
final class Currency {
    @Attribute(.unique) var code: String
    var name: String
    var symbol: String
    var flagEmoji: String
    var continent: String
    var isPopular: Bool
    var lastUsedOrder: Int
}

@Model
final class CachedExchangeRate {
    @Attribute(.unique) var baseCurrency: String
    var rates: Data
    var fetchDate: Date
    var apiSource: String
}
```

---

## 5. Module Structure & File Organization

```
XRate/
├── App/
│   ├── XRateApp.swift
│   └── ContentView.swift
│
├── Models/
│   ├── Currency.swift
│   ├── CachedExchangeRate.swift
│   └── TrendDataPoint.swift
│
├── ViewModels/
│   ├── ConversionViewModel.swift
│   ├── CurrencyListViewModel.swift
│   ├── TrendViewModel.swift
│   └── SettingsViewModel.swift
│
├── Views/
│   ├── Main/
│   │   ├── ConversionView.swift
│   │   ├── CurrencyCardView.swift
│   │   ├── SwapButtonView.swift
│   │   ├── QuickAccessBarView.swift
│   │   └── NumberPadView.swift
│   │
│   ├── CurrencyPicker/
│   │   ├── CurrencyPickerView.swift
│   │   └── CurrencyRowView.swift
│   │
│   ├── Trend/
│   │   ├── TrendChartView.swift
│   │   └── TimeRangePickerView.swift
│   │
│   ├── Settings/
│   │   ├── SettingsView.swift
│   │   └── ContactSupportView.swift
│   │
│   └── Components/
│       ├── LoadingView.swift
│       └── OfflineBannerView.swift
│
├── Services/
│   ├── ExchangeRateService.swift
│   ├── CacheService.swift
│   ├── LocationService.swift
│   └── CurrencyDataService.swift
│
├── Extensions/
│   ├── Number+Formatting.swift
│   ├── Color+Theme.swift
│   ├── Date+Helpers.swift
│   └── View+Modifiers.swift
│
├── StoreKit/
│   └── PurchaseManager.swift
│
├── Resources/
│   ├── Assets.xcassets
│   └── Currencies.json
│
├── Widgets/
│   ├── XRateWidget.swift
│   ├── XRateWidgetBundle.swift
│   └── XRateWidgetView.swift
│
└── Watch/
    ├── XRateWatchApp.swift
    ├── WatchContentView.swift
    └── WatchCurrencyPicker.swift
```

---

## 6. Implementation Flow

### Step-by-Step Implementation Order

1. **Project Setup**: Configure Xcode project, Bundle ID, deployment target
2. **Data Models**: Create Currency and CachedExchangeRate SwiftData models
3. **Currency Data Service**: Build local Currencies.json loader with fuzzy search
4. **Exchange Rate Service**: Implement Frankfurter API + ExchangeRate-API fallback
5. **Cache Service**: Implement SwiftData-based rate caching with 30-min validity
6. **Conversion ViewModel**: Core conversion logic, rate loading, currency swapping
7. **Main Conversion View**: Currency cards, swap button, amount input
8. **Currency Picker View**: Searchable list grouped by continent with recent/popular sections
9. **Quick Access Bar**: Horizontal scrollable currency chips
10. **Trend Chart View**: Swift Charts line chart with time range picker
11. **Settings View**: App preferences, Pro upgrade, about section
12. **Contact Support View**: Feedback form with backend integration
13. **Purchase Manager**: StoreKit 2 integration for Pro subscription
14. **Extensions**: Number formatting, color theme, date helpers, view modifiers
15. **Widget**: WidgetKit home screen widget (small/medium/large)
16. **Apple Watch**: WatchOS companion app
17. **Offline Banner**: Network status indicator
18. **Final Integration**: Connect all modules, test, polish

---

## 7. UI/UX Design Specifications

### Design Philosophy

**"One Tap to Know"** — Users see conversion results immediately upon opening the app. All interaction happens on a single screen.

### Visual Style

| Element | Specification |
|---|---|
| Design Reference | Apple Calculator + Apple Weather minimalist style |
| Accent Color | System Blue (#007AFF) |
| Font | SF Pro (system default), SF Mono for numbers |
| Corner Radius | 16pt unified |
| Spacing | 20pt horizontal padding, 12-20pt vertical spacing |
| Animation | Lightweight spring animations (.spring(response: 0.3, dampingFraction: 0.7)) |
| Material | .regularMaterial translucent glass effect |
| Dark Mode | Full support via semantic colors |

### Main Screen Layout

```
┌──────────────────────────────────┐
│  XRate                    [⚙️]   │  Brand (left) + Settings (right)
│                                  │
│  ┌────────────────────────────┐  │
│  │ 🇺🇸 USD              ▼    │  │  Source currency selector
│  │ 1,000.00                    │  │  Input amount (42pt SF Mono)
│  └────────────────────────────┘  │
│                                  │
│           ⇅  Swap Button         │  Circular, accent color
│                                  │
│  ┌────────────────────────────┐  │
│  │ 🇪🇺 EUR              ▼    │  │  Target currency selector
│  │ 923.45                      │  │  Converted result (42pt, accent)
│  └────────────────────────────┘  │
│                                  │
│  ┌──────┐┌──────┐┌──────┐┌──┐  │  Quick access bar (horizontal scroll)
│  │🇬🇧GBP││🇯🇵JPY││🇨🇦CAD││+ │  │
│  └──────┘└──────┘└──────┘└──┘  │
│                                  │
│  ┌────────────────────────────┐  │
│  │ 📈 7-Day Trend       >    │  │  Mini trend chart entry
│  │ ~~~~~~~~~~~~~~~~~~~~~~~~   │  │  Mini sparkline
│  └────────────────────────────┘  │
│                                  │
│  ✅ Updated 2 min ago           │  Data status indicator
└──────────────────────────────────┘
```

### Trend Chart Page

```
┌──────────────────────────────────┐
│  ←  USD / EUR                    │
│                                  │
│  1 USD = 0.9234 EUR             │  Current rate
│  ▲ +0.12% today                 │  Daily change
│                                  │
│  ┌────────────────────────────┐  │
│  │           📈                │  │  Swift Charts line chart
│  │      /\      /\            │  │
│  │   /\/  \  /\/  \          │  │
│  │  /      \/      \          │  │
│  │----------------------------│  │
│  └────────────────────────────┘  │
│                                  │
│  [1D] [1W] [1M] [3M] [1Y]      │  Time range selector
│                                  │
│  High: 0.9345  Low: 0.9102     │  Period high/low
└──────────────────────────────────┘
```

### Currency Picker Page

```
┌──────────────────────────────────┐
│  ←  Select Currency              │
│  ┌────────────────────────────┐  │
│  │ 🔍 Search currency...      │  │  Search bar
│  └────────────────────────────┘  │
│                                  │
│  Recent                          │
│  🇯🇵 JPY  Japanese Yen      ✅  │
│  🇬🇧 GBP  British Pound         │
│                                  │
│  Popular                         │
│  🇺🇸 USD  US Dollar             │
│  🇪🇺 EUR  Euro                  │
│  🇬🇧 GBP  British Pound         │
│  🇯🇵 JPY  Japanese Yen         │
│  🇨🇦 CAD  Canadian Dollar       │
│                                  │
│  Europe                          │
│  🇨🇭 CHF  Swiss Franc           │
│  🇸🇪 SEK  Swedish Krona         │
│  ...                             │
└──────────────────────────────────┘
```

### Widget Designs

**Small (2x2)**:
```
┌──────────────┐
│  XRate        │
│  🇺🇸→🇪🇺     │
│  0.9234      │
│  ✅ 2m ago   │
└──────────────┘
```

**Medium (4x2)**:
```
┌──────────────────────────┐
│  XRate                    │
│  🇺🇸 USD → 🇪🇺 EUR       │
│  1,000 = 923.45          │
│  ~~~~~~~~📈~~~~          │
└──────────────────────────┘
```

### Apple Watch Interface

```
┌──────────────┐
│   XRate       │
│               │
│  🇺🇸 → 🇪🇺   │
│               │
│   923.45     │  Large font result
│               │
│  1 USD =     │
│  0.9234 EUR  │
│               │
│  [⇅]  [📋]  │  Swap / Favorites
└──────────────┘
```

---

## 8. Code Generation Rules

| Rule | Description |
|---|---|
| Minimum iOS | 17.0 (SwiftData + @Observable) |
| Swift Version | 5.9+ |
| Concurrency | Strict async/await, no callback hell |
| Architecture | MVVM: Model for data, ViewModel for logic, View for display |
| Networking | URLSession + async/await, no third-party libraries |
| Persistence | SwiftData (iOS 17+), no CoreData |
| Dependencies | Zero third-party dependencies (except StoreKit 2) |
| Localization | String Catalog (.xcstrings) for all strings |
| Accessibility | All UI elements support VoiceOver and Dynamic Type |
| Performance | Main thread for UI only, all heavy work in Task/Actor |
| Design | Strictly follow Apple Human Interface Guidelines |
| No Comments | Do not add comments in code unless explicitly asked |
| iPad Layout | Main content in ScrollView: `.frame(maxWidth: 720).frame(maxWidth: .infinity)` |
| TabView Style | Never use `.tabViewStyle(.sidebarAdaptable)` |
| Observable | Do not use `ObservableObject` on views already marked `@Observable` |
| iOS 17 Only | Do not use iOS 18+ only APIs |
| Accent Color | Use `Color.accentColor` instead of `ShapeStyle.accent` |
| SwiftData | ALL attributes MUST be optional OR have a default value; ALL relationships MUST have inverse relationships |

---

## 9. Testing & Validation Standards

### Unit Testing Requirements

| Module | Test Coverage Target | Key Test Cases |
|---|---|---|
| ConversionViewModel | 100% | Rate calculation, currency swap, amount formatting |
| ExchangeRateService | 100% | API parsing, fallback logic, error handling |
| CacheService | 100% | Cache validity, expiration, data integrity |
| CurrencyDataService | 100% | JSON parsing, search filtering, grouping |

### UI Testing Requirements

| Flow | Test Cases |
|---|---|
| Quick Conversion | Open app → see cached rates → type amount → see result |
| Currency Selection | Tap currency → search → select → verify conversion updates |
| Swap Currencies | Tap swap → verify source/target swap → verify amount updates |
| Offline Mode | Disable network → open app → verify cached data displays |
| Trend Chart | Tap trend → verify chart loads → switch time range |

### Validation Checklist

- [ ] App launches without crashes
- [ ] Conversion calculates correctly (verify against known rates)
- [ ] Offline mode works with cached data
- [ ] Currency search returns expected results
- [ ] Swap button correctly exchanges currencies
- [ ] Trend chart displays historical data
- [ ] Settings persist across app launches
- [ ] Widget displays current conversion
- [ ] Watch app syncs with phone
- [ ] IAP purchase flow completes
- [ ] No memory leaks in long-running sessions
- [ ] Dark mode renders correctly

---

## 10. Build & Deployment Checklist

### Pre-Build

- [ ] Xcode project configured with correct Bundle ID: `com.zzoutuo.XRate`
- [ ] iOS Deployment Target set to 17.0
- [ ] All SwiftData models have optional attributes or default values
- [ ] No hardcoded API keys in source code
- [ ] Privacy permissions configured (NSLocationWhenInUseUsageDescription if using location)

### Build Verification

- [ ] Build succeeds with zero errors
- [ ] Build succeeds with zero warnings (or only acceptable warnings)
- [ ] App launches on iOS Simulator
- [ ] All views render correctly
- [ ] No runtime crashes

### App Store Preparation

- [ ] App icon configured (1024x1024)
- [ ] Launch screen configured
- [ ] Privacy Policy page deployed
- [ ] Terms of Use page deployed
- [ ] Support page deployed
- [ ] App Store metadata prepared (keytext.md)
- [ ] IAP products configured in App Store Connect
- [ ] StoreKit configuration file created for testing
- [ ] Subscription terms displayed in paywall
- [ ] Restore Purchases button implemented

### Monetization

| Plan | Product ID | Price | Type |
|---|---|---|---|
| Monthly | com.zzoutuo.XRate.pro.monthly | $2.99/month | Auto-renewable Subscription |
| Yearly | com.zzoutuo.XRate.pro.yearly | $14.99/year | Auto-renewable Subscription |
| Lifetime | com.zzoutuo.XRate.pro.lifetime | $29.99 | Non-consumable |

### Free vs Pro Features

| Feature | Free | Pro |
|---|---|---|
| Basic currency conversion | Yes | Yes |
| 5 popular currencies | Yes | Yes |
| 7-day trend chart | Yes | Yes |
| Offline cache | Yes | Yes |
| Zero ads | Yes | Yes |
| Unlimited currencies | No (5 max) | Yes |
| Desktop Widget | No | Yes |
| Apple Watch | No | Yes |
| Historical rates (1 year+) | No | Yes |
| Batch conversion | No | Yes |
| Travel mode (location) | No | Yes |
| Custom decimal places | No | Yes |
