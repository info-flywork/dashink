# RevenueCat / Play Billing
-keep class com.revenuecat.purchases.** { *; }
-keep class com.android.vending.billing.** { *; }
-dontwarn com.revenuecat.purchases.**
-dontwarn com.amazon.**
-keep class com.amazon.** { *; }
-keepattributes *Annotation*
-keep class androidx.lifecycle.DefaultLifecycleObserver
-keep class org.xmlpull.v1.** { *; }
