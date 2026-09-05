# SGAC Android APK manifest analysis

- Last reviewed: 2026-09-05
- Status: Verified by static analysis of the supplied APKs
- Context: Android inputs for [T00](sgac-fork-refactor-tasks.md); fork assignments supplied by Edwin (`1...` = SGAC1.0, `2...` = SGAC2.0).

## Results

| Field | SGAC1.0 | SGAC2.0 |
| --- | --- | --- |
| Source ZIP in `icaApp/` | `1.9.1_1_417.apk.zip` | `2.0.0_12_418.apk.zip` |
| APK entry inside ZIP | `1.9.1_1_417.apk` | `2.0.0_12_418.apk` |
| Application label | `MyICA Mobile` | `MyICA Mobile` |
| Manifest `versionName` | `1.19.1` | `2.0.0` |
| Manifest `versionCode` | `417` | `418` |
| Package / application ID (`appPackage`) | `sg.gov.ica.mobile.app` | `sg.gov.ica.mobile.app` |
| Main launcher activity (`appActivity`) | `sg.gov.ica.mobile.app.MainActivity` | `sg.gov.ica.mobile.app.MainActivity` |
| Launcher exported | `true` | `true` |
| Launcher activity alias | None | None |
| Minimum SDK | `30` | `30` |
| Target SDK | `36` | `36` |
| Uncompressed APK bytes | `297668317` | `264282628` |

The SGAC1.0 filename says `1.9.1`, but both manifest tools report `1.19.1`. Use the manifest value when identifying the app version. The filenames were preserved.

## Launcher evidence

Android SDK Build Tools 36.1.0 `aapt dump badging` and `apkanalyzer manifest print` agree on the package, versions, and launcher. Each decoded manifest contains one direct activity with the following relevant attributes and intent filter:

```xml
<activity
    android:name="sg.gov.ica.mobile.app.MainActivity"
    android:exported="true">
    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>
</activity>
```

This is an excerpt with unrelated activity attributes omitted. No `activity-alias` is declared in either manifest.

Both builds therefore use these Appium capability values:

```json
{
  "appium:appPackage": "sg.gov.ica.mobile.app",
  "appium:appActivity": "sg.gov.ica.mobile.app.MainActivity"
}
```

## Implications for T00

Both Android forks have the same app identity. They cannot coexist as separate apps in the same Android profile; tests need the intended fork's APK installed for each run. This follows from the verified identical manifest package values and Android's rule that the [application ID identifies an app on the device](https://developer.android.com/build/configure-app-module#set-application-id).

These results supply the Android package, main activity, and coexistence answer for T00; the task board marks those Android inputs complete. The iOS bundle ID/coexistence details and flow/screen difference list remain open (no SGAC2.0 IPA will be supplied — iOS builds ship via TestFlight; see the task board). Device Farm project decisions are deferred with T12 and are not required to close T00. Installation, launch behavior, signing compatibility, and test flows were not exercised.

## SHA-256 fingerprints

Hashes of the extracted APK contents:

```text
3743d886ffb14e609d411bbbc35047361c855f95b64958878a49da42076d60ee  1.9.1_1_417.apk
215094377e10d7cb64e3b3e5923ea1ecf9b6e2315757173ca74c4e42d2600099  2.0.0_12_418.apk
```

Hashes of the supplied ZIP archives:

```text
8dbc940a39ab0192604779850cdbca1053693164f5fd33b3074c80f7e785cf13  icaApp/1.9.1_1_417.apk.zip
0c20f3047c204eaa0c79a0caaad6e3ac2175c4e5f104a31a8bfe43f9e8352123  icaApp/2.0.0_12_418.apk.zip
```

## Reproduce the analysis

Run from the repository root with Android SDK Build Tools 36.1.0 installed, `ANDROID_HOME` pointing to the SDK, and `apkanalyzer` on `PATH`:

```sh
analysis_dir="$(mktemp -d)"
unzip -n icaApp/1.9.1_1_417.apk.zip 1.9.1_1_417.apk -d "$analysis_dir"
unzip -n icaApp/2.0.0_12_418.apk.zip 2.0.0_12_418.apk -d "$analysis_dir"
for apk_name in 1.9.1_1_417.apk 2.0.0_12_418.apk; do
    "$ANDROID_HOME/build-tools/36.1.0/aapt" dump badging "$analysis_dir/$apk_name"
    apkanalyzer manifest print "$analysis_dir/$apk_name"
    shasum -a 256 "$analysis_dir/$apk_name"
done
```

Only the named APK members are extracted; the archives' `__MACOSX` metadata is not needed. The supplied archives are retained in `icaApp/`.
