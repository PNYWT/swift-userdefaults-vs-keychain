# swift-userdefaults-vs-keychain

โปรเจ็กต์ตัวอย่าง iOS SwiftUI ที่ใช้เปรียบเทียบ `UserDefaults` และ `Keychain` บนโครงสร้าง MVVM แบบที่ใกล้เคียงงานจริง พร้อม `WebService` ที่นำกลับมาใช้ซ้ำได้ และลำดับการทำงานของ local database สำหรับ cache ข้อมูลโปรไฟล์ผู้ใช้

## ภาพรวม

โปรเจ็กต์นี้สาธิตเรื่องหลัก ๆ ดังนี้:

- ควรใช้ `UserDefaults` เมื่อไร
- ควรใช้ `Keychain` เมื่อไร
- ข้อมูลแบบไหนควรอยู่ใน local database
- จะต่อทั้งหมดเข้ากับแอป SwiftUI MVVM โดยใช้ `Scenes`, `Models`, `Services`, และ `Storages` อย่างไร

แอปมี 3 ลำดับการทำงานหลักที่แยกชัดเจน:

- ลำดับการทำงานของ onboarding ที่ใช้ `UserDefaults`
- ลำดับการทำงานของ authentication ที่ใช้ `Keychain` และ decode ผลลัพธ์จาก API
- ลำดับการทำงานของโปรไฟล์ผู้ใช้ที่ใช้ `SwiftData` สำหรับ cache ข้อมูลผู้ใช้ที่ต้องใช้สิทธิ์เข้าถึง

repo นี้ยังมีตัวอย่าง local database ที่ใกล้เคียงการใช้งานจริง โดยใช้ `SwiftData` สำหรับ cache โปรไฟล์ของผู้ใช้ที่ login แล้ว

environment ที่ใช้งานอยู่จะถูกควบคุมจากจุดเดียวผ่าน `AppConfig.current`

## ข้อมูลแบบไหนควรเก็บที่ไหน

### UserDefaults

ใช้ `UserDefaults` สำหรับข้อมูลสถานะของแอปที่ไม่ใช่ความลับ เช่น:

- ผู้ใช้ผ่าน onboarding แล้วหรือยัง
- feature flags
- theme ที่เลือก
- preferences ทั่วไป

ในโปรเจ็กต์นี้:

- `hasCompletedOnboarding` ถูกเก็บไว้ใน `UserDefaults`

### Keychain

ใช้ `Keychain` สำหรับข้อมูลที่เป็นความลับ เช่น:

- access token
- refresh token
- password
- API key

ในโปรเจ็กต์นี้:

- `accessToken`
- `refreshToken`
- `userPassword`

ถูกเก็บไว้ใน `Keychain`

### Local Database

ใช้ local database สำหรับข้อมูลที่มีโครงสร้าง และต้องการเก็บไว้ใช้งานซ้ำหรือรองรับ offline เช่น:

- โปรไฟล์ผู้ใช้
- ที่อยู่
- ประวัติคำสั่งซื้อ
- cart
- order
- ข้อมูลที่ fetch มาครั้งหนึ่งแล้วต้องการนำกลับมาใช้ซ้ำ

ในโปรเจ็กต์นี้:

- `UserProfile` คือ model ปกติของแอป
- `CachedUserProfile` คือ persistence model ของ `SwiftData`
- `LocalDatabase` คือ wrapper ของ local store

## สถาปัตยกรรม

โปรเจ็กต์นี้ใช้โครงสร้าง MVVM ที่เอนไปทาง production-oriented:

```text
View
-> ViewModel
-> Service / Manager
```

ตัวอย่างความสัมพันธ์:

- `AppRootView` -> `AppRootViewModel` -> `AppPreferencesService`
- `OnboardingView` -> `OnboardingViewModel` -> `AppPreferencesService` -> `UserDefaultsManager`
- `AuthView` -> `AuthViewModel` -> `AuthWebService` -> `WebService` -> decode `LoginResponse`
- `AuthView` -> `AuthViewModel` -> `SecureStoreService` -> `KeychainManager`
- `UserProfileView` -> `UserProfileViewModel` -> `UserProfileService` -> `UserProfileWebService` + `LocalDatabase`

เป้าหมายคือทำให้ลำดับการทำงานอ่านง่ายและเอาไปอิงเขียนบทความหรือทำแอปต่อได้จริง:

- `View` รับผิดชอบการแสดงผล
- `ViewModel` รับผิดชอบ state ของหน้าจอและ action ของผู้ใช้
- `Models` อธิบาย request และ response payload
- `Services` เป็น app-level wrappers และ abstraction ของ web service
- `AppConfig` เป็นศูนย์กลางของ environment และ base URL
- `WebService` เป็นศูนย์กลางของการสร้าง request และ decode response
- `SecureStoreService` เป็นตัวกลางของข้อมูลที่เป็นความลับเหนือ Keychain
- `LocalDatabase` เป็นตัวกลางของข้อมูลแบบมีโครงสร้างเหนือ SwiftData
- storage managers รับผิดชอบรายละเอียดของ persistence

## โครงสร้างโปรเจ็กต์

```text
MyStorage
├── MyStorageApp.swift
├── Config
│   └── AppConfig.swift
├── Models
│   ├── Auth
│   │   ├── LoginRequest.swift
│   │   ├── LoginResponse.swift
│   │   └── AuthCredentials.swift
│   └── UserProfile
│       ├── CachedUserProfile.swift
│       ├── UserProfile.swift
│       └── UserProfileResponse.swift
├── Scenes
│   ├── Root
│   │   ├── AppRootView.swift
│   │   └── AppRootViewModel.swift
│   ├── Onboarding
│   │   ├── OnboardingView.swift
│   │   └── OnboardingViewModel.swift
│   ├── Auth
│       ├── AuthView.swift
│       └── AuthViewModel.swift
│   └── UserProfile
│       ├── UserProfileView.swift
│       └── UserProfileViewModel.swift
├── Services
│   ├── Preferences
│   │   ├── AppPreferencesService.swift
│   │   └── AppPreferencesServiceProtocol.swift
│   ├── LocalDatabaseService
│   │   ├── UserProfileService.swift
│   │   └── UserProfileServiceProtocol.swift
│   ├── SecureStore
│   │   ├── SecureStoreService.swift
│   │   └── SecureStoreServiceProtocol.swift
│   └── WebService
│       ├── Auth
│       │   └── AuthWebService.swift
│       ├── UserProfile
│       │   └── UserProfileWebService.swift
│       ├── WebService.swift
│       └── WebServiceError.swift
└── Storages
    ├── Keychain
    │   ├── KeychainConfiguration.swift
    │   ├── KeychainError.swift
    │   ├── KeychainManager.swift
    │   └── KeychainManagerProtocol.swift
    ├── LocalDatabase
    │   ├── LocalDatabase.swift
    │   └── LocalDatabaseProtocol.swift
    ├── UserDefaults
    │   ├── UserDefaultsManager.swift
    │   └── UserDefaultsManagerProtocol.swift
    └── StorageKeys.swift
```

## ไฟล์สำคัญ

- [AppConfig.swift](./MyStorage/Config/AppConfig.swift)
- [AppRootView.swift](./MyStorage/Scenes/Root/AppRootView.swift)
- [OnboardingViewModel.swift](./MyStorage/Scenes/Onboarding/OnboardingViewModel.swift)
- [AuthViewModel.swift](./MyStorage/Scenes/Auth/AuthViewModel.swift)
- [UserProfileViewModel.swift](./MyStorage/Scenes/UserProfile/UserProfileViewModel.swift)
- [LoginResponse.swift](./MyStorage/Models/Auth/LoginResponse.swift)
- [AuthCredentials.swift](./MyStorage/Models/Auth/AuthCredentials.swift)
- [UserProfile.swift](./MyStorage/Models/UserProfile/UserProfile.swift)
- [UserProfileResponse.swift](./MyStorage/Models/UserProfile/UserProfileResponse.swift)
- [CachedUserProfile.swift](./MyStorage/Models/UserProfile/CachedUserProfile.swift)
- [AppPreferencesService.swift](./MyStorage/Services/Preferences/AppPreferencesService.swift)
- [UserProfileService.swift](./MyStorage/Services/LocalDatabaseService/UserProfileService.swift)
- [SecureStoreService.swift](./MyStorage/Services/SecureStore/SecureStoreService.swift)
- [AuthWebService.swift](./MyStorage/Services/WebService/Auth/AuthWebService.swift)
- [UserProfileWebService.swift](./MyStorage/Services/WebService/UserProfile/UserProfileWebService.swift)
- [WebService.swift](./MyStorage/Services/WebService/WebService.swift)
- [LocalDatabase.swift](./MyStorage/Storages/LocalDatabase/LocalDatabase.swift)
- [UserDefaultsManager.swift](./MyStorage/Storages/UserDefaults/UserDefaultsManager.swift)
- [KeychainManager.swift](./MyStorage/Storages/Keychain/KeychainManager.swift)
- [StorageKeys.swift](./MyStorage/Storages/StorageKeys.swift)

## หมายเหตุเรื่อง WebService

`WebService` กลางของโปรเจ็กต์นี้รองรับ:

- `baseURL` ที่มาจาก `AppConfig`
- endpoint definitions ที่นำกลับมาใช้ซ้ำได้
- `GET` และ `POST`
- query items และ request body
- การ decode `Decodable` แบบ generic
- network transport จริงสำหรับ production

ค่าเริ่มต้นของ demo ตอนนี้ใช้:

- `AppConfig.current`
- mock response generation ภายใน `AuthWebService`
- request/response logging ที่ควบคุมผ่าน `AppConfig.shouldLogNetwork`
- การ mask ค่าที่เป็นความลับก่อน log เช่น `abc********`

โครงแบบนี้ช่วยให้ใกล้เคียง production แต่ยังรันตัวอย่างได้โดยไม่ต้องมี backend จริง

## หมายเหตุเรื่อง Local Database

local database ในโปรเจ็กต์นี้ใช้ `SwiftData` เพราะเหมาะกับแอป SwiftUI สมัยใหม่ และเหมาะกับงาน cache แบบไม่ซับซ้อนเกินไป

โครงสร้างตัวอย่างปัจจุบันตั้งใจให้เรียบแต่ยังสมจริง:

- `UserProfile` เป็น Swift model ปกติที่อาจมาจาก profile endpoint ที่ต้องใช้สิทธิ์เข้าถึง
- `CachedUserProfile` เป็น persisted model ของ `SwiftData`
- `LocalDatabase` รองรับการ save, fetch, และ clear cached user profile
- `UserProfileService` เป็นตัวกลางระหว่าง `SecureStoreService`, `UserProfileWebService`, และ `LocalDatabase`
- `UserProfileService` จะ update cache เฉพาะเมื่อข้อมูลที่ fetch มาเปลี่ยนจริง
- `UserProfileService` จะ fallback ไปใช้ cached data เมื่อ remote request ล้มเหลวแต่ local data ยังมีอยู่

แบบนี้ทำให้ local persistence แยกชัดจาก:

- `UserDefaults` ที่ใช้เก็บ app state ง่าย ๆ
- `Keychain` ที่ใช้เก็บข้อมูลลับ

## การทดสอบ

โปรเจ็กต์นี้ใช้ `XCTest` เป็นมาตรฐานหลักของการทดสอบ และใช้ hand-written mocks เป็นค่าเริ่มต้น

ขอบเขตการทดสอบปัจจุบันมี:

- unit tests ของ `Services`
- unit tests ของ `ViewModel`
- integration tests ของ `Keychain`
- integration tests ของ `LocalDatabase`

โครงสร้าง test ถูกจัดให้สอดคล้องกับ production structure:

```text
MyStorageTests
├── Scenes
├── Services
├── Storages
└── Support/Mocks
```

ดูรายละเอียดกติกาการทดสอบต่อได้ที่ [TESTING.md](./TESTING.md)

## หมายเหตุเรื่อง Keychain

`KeychainManager` ในโปรเจ็กต์นี้รองรับ:

- อ่าน `String`
- อ่าน `Data`
- save ค่า
- update เมื่อเจอ duplicate item
- delete ค่า

โดยใช้:

- `kSecClassGenericPassword`
- `kSecAttrService`
- `kSecAttrAccount`
- `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`

ค่า service เริ่มต้นตอนนี้คือ:

```swift
static let keychainService: String = "com.companyname.appname"
```

ค่านี้ควรถูกเก็บให้คงที่ ถ้าเปลี่ยนภายหลัง แอปจะอ่าน Keychain item เก่าไม่เจอ เว้นแต่มี migration รองรับไว้

## การรันโปรเจ็กต์

เปิด Xcode project:

```text
MyStorage.xcodeproj
```

หรือ build ผ่าน terminal:

```bash
xcodebuild -scheme MyStorage -project MyStorage.xcodeproj -configuration Debug -sdk iphonesimulator -derivedDataPath .xcodebuild CODE_SIGNING_ALLOWED=NO build
```

## ลำดับการทำงานตัวอย่าง

1. เปิดแอป
2. ผ่าน onboarding ให้ครบ
3. กรอก email และ password ในหน้าจอ auth
4. เรียก login ผ่าน `AuthWebService`
5. decode `LoginResponse`
6. บันทึก token และ password ลง `Keychain`
7. เข้า `UserProfile` อัตโนมัติหลัง login สำเร็จ
8. fetch ข้อมูลโปรไฟล์ที่ต้องใช้สิทธิ์เข้าถึงผ่าน `UserProfileWebService`
9. cache โปรไฟล์ไว้ใน `LocalDatabase`
10. reload, clear หรือ sign out ผ่าน UI ได้

## หมายเหตุ

- โปรเจ็กต์นี้ตั้งใจให้เรียบและโฟกัสที่การใช้งาน storage
- เหมาะใช้เป็นตัวอย่างอ้างอิงสำหรับการเลือกใช้ `UserDefaults` กับ `Keychain`
- ถ้าแอปโตต่อ สามารถเพิ่ม scenes ใหม่ได้โดยยังรักษาโครง `Scenes / Services / Storages` เดิมไว้
