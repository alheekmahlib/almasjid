# إعداد ملفات التوقيع - Signing Configuration

هذا الملف يوضح كيفية إعداد ملفات التوقيع المطلوبة للبناء.

## الملفات المطلوبة

### 1. للـ Huawei AppGallery

إنشئ ملف `android/key.properties`:
```
storePassword=YOUR_PASSWORD
keyPassword=YOUR_PASSWORD
keyAlias=huawei
storeFile=../huawei-release-key.keystore
```

### 2. للـ Google Play Store

إنشئ ملف `android/google-play-key.properties`:
```
googlePlayStorePassword=YOUR_PASSWORD
googlePlayKeyPassword=YOUR_PASSWORD
googlePlayKeyAlias=google-play
googlePlayStoreFile=../google-play-keystore.jks
```

### 3. للـ AppGallery Upload Key

إنشئ ملف `android/upload-key.properties`:
```
uploadStorePassword=YOUR_PASSWORD
uploadKeyPassword=YOUR_PASSWORD
uploadKeyAlias=upload
uploadStoreFile=../upload-keystore.jks
```

## إنشاء ملفات Keystore

### إنشاء keystore للـ Huawei:
```bash
keytool -genkey -v -keystore android/huawei-release-key.keystore -alias huawei -keyalg RSA -keysize 2048 -validity 10000
```

### إنشاء keystore للـ Google Play:
```bash
keytool -genkey -v -keystore android/google-play-keystore.jks -alias google-play -keyalg RSA -keysize 2048 -validity 10000
```

### إنشاء upload keystore:
```bash
keytool -genkey -v -keystore android/upload-keystore.jks -alias upload -keyalg RSA -keysize 2048 -validity 10000
```

## البناء

### للـ Huawei AppGallery:
```bash
flutter build appbundle --release
```

### للـ Google Play Store:
```bash
flutter build appbundle --flavor googlePlayRelease
```

## ⚠️ تحذير أمني

- لا تشارك ملفات `.keystore`, `.jks`, أو `.properties` مع أحد
- احتفظ بنسخ احتياطية آمنة من ملفات keystore
- لا ترفع هذه الملفات إلى Git أبداً

## الملفات المستبعدة من Git

جميع الملفات التالية مستبعدة تلقائياً:
- `*.jks`
- `*.keystore`  
- `*.pem`
- `*key.properties`