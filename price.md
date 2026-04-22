# Price Configuration

## Monetization Model
Auto-renewable Subscription + One-time Purchase (Hybrid)

## Subscription Group
Group Name: XRate Pro

### Subscription Tier 1: Monthly
- **Reference Name**: XRate Pro Monthly
- **Product ID**: com.zzoutuo.XRate.pro.monthly
- **Price**: $2.99 (USD)
- **Subscription Period**: 1 Month
- **Localization (English US)**:
  - Display Name: XRate Pro Monthly (max 35 chars)
  - Description: Access all Pro features for one month (max 55 chars)

### Subscription Tier 2: Yearly
- **Reference Name**: XRate Pro Yearly
- **Product ID**: com.zzoutuo.XRate.pro.yearly
- **Price**: $14.99 (USD)
- **Subscription Period**: 1 Year
- **Localization (English US)**:
  - Display Name: XRate Pro Yearly (max 35 chars)
  - Description: Save 58% with annual plan (max 55 chars)

### Subscription Tier 3: Lifetime
- **Reference Name**: XRate Pro Lifetime
- **Product ID**: com.zzoutuo.XRate.pro.lifetime
- **Price**: $29.99 (USD)
- **Type**: Non-consumable (One-time)
- **Localization (English US)**:
  - Display Name: XRate Pro Lifetime (max 35 chars)
  - Description: One-time purchase, forever access (max 55 chars)

## App Store Connect Setup Instructions
1. Go to App Store Connect → Your App → Subscriptions
2. Create Subscription Group: "XRate Pro"
3. Add subscriptions with above Product IDs
4. Configure localizations for each
5. Submit for review

## IAP Compliance Checklist
- [x] Paywall displays subscription names
- [x] Paywall displays subscription durations
- [x] Dynamic pricing from StoreKit (no hardcoded prices)
- [x] Renewal terms displayed
- [x] Cancellation instructions displayed
- [x] Free trial clause displayed (if applicable)
- [x] Restore Purchases button implemented
- [x] Privacy Policy link on paywall
- [x] Terms of Use link on paywall

## StoreKit Configuration File
Location: `XRate/XRate/Resources/XRateStoreKitConfig.storekit`

## Pro Features Unlocked
- Unlimited currency conversions
- Historical rate charts (up to 1 year)
- Desktop Widget (planned)
- Apple Watch App (planned)
- Batch conversion (planned)
- Travel mode with location-based suggestions (planned)
- Custom decimal places

## Pricing Rationale
- **Monthly ($2.99)**: Entry-level for casual users who need Pro features occasionally
- **Yearly ($14.99)**: 58% savings vs monthly, ideal for frequent travelers
- **Lifetime ($29.99)**: One-time purchase for users who prefer no subscription

## Competitive Analysis
| App | Monthly | Yearly | Lifetime |
|-----|---------|--------|----------|
| XRate | $2.99 | $14.99 | $29.99 |
| Currency Converter Plus | $3.99 | $19.99 | - |
| XE Currency Pro | - | - | $4.99 |
| CurrencyFair | Free | - | - |

XRate positions itself as a premium yet affordable option with flexible pricing.
