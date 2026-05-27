# มาตรฐานการทดสอบ

โปรเจ็กต์นี้ใช้ `XCTest` เป็น framework หลักของการทดสอบ

## หลักการ

- ใช้ `protocol`-based dependency injection เพื่อให้ `Services` และ `ViewModel` ทดสอบได้ง่าย
- ใช้ hand-written mocks เป็นมาตรฐานเริ่มต้นของ test doubles
- จัดโครงสร้าง test ให้สอดคล้องกับ production structure เพื่อให้ Finder อ่านง่าย
- ให้ความสำคัญกับ unit tests ของ `Services` และ `ViewModel` ก่อน
- เพิ่ม integration tests เฉพาะจุดที่ behavior ของระบบจริงสำคัญ เช่น `Keychain` และ `SwiftData`

## โครงสร้าง test

```text
MyStorageTests
├── Scenes
├── Services
├── Storages
└── Support
    └── Mocks
```

- `Scenes`
  ทดสอบ state และ user flow ของ `ViewModel`
- `Services`
  ทดสอบ business behavior และ orchestration logic
- `Storages`
  ทดสอบ persistence layer ของจริงในลักษณะ integration test
- `Support/Mocks`
  เก็บ hand-written test doubles ที่ใช้ร่วมกัน โดยแยกตาม responsibility

## สิ่งที่ทดสอบ

### Scenes

- การตัดสินใจเรื่อง route
- loading states
- success และ failure states
- status message ที่ส่งผลกับหน้าจอ

### Services

- behavior ของ app preferences
- behavior ของ secure credentials
- การประสานงานระหว่าง remote และ local data
- กติกา fallback และการ update cache

### Storages

- `KeychainManager` save, update, read, remove
- `LocalDatabase` save, fetch, clear

## มาตรฐานเรื่อง Mock

โปรเจ็กต์นี้ยังไม่ใช้ third-party mocking package เป็นค่าเริ่มต้น

เหตุผล:

- โปรเจ็กต์ Swift จำนวนมากใช้ `XCTest` ร่วมกับ hand-written mocks อยู่แล้ว
- hand-written mocks ทำให้ repo นี้อ่านและทำความเข้าใจได้ง่ายกว่า สำหรับคนที่ใช้เป็นตัวอย่างหรือประกอบบทความ
- โปรเจ็กต์ไม่ต้องพึ่ง code-generation หรือ mocking tools เพิ่ม

ถ้าวันหนึ่งทีมจะเพิ่ม mocking package เข้ามา ควรเป็นการตกลงกันในระดับทั้งโปรเจ็กต์ ไม่ใช่เพิ่มแบบเฉพาะจุด
