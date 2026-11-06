# Guía de ejecución Android

1. Instalar Flutter y Android Studio.
2. En SDK Manager instalar Android SDK Platform 24 o superior, Build Tools,
   Emulator y Android SDK Command-line Tools.
3. Ejecutar:

```powershell
flutter doctor -v
flutter doctor --android-licenses
```

4. Crear o iniciar un AVD desde Device Manager. Para esta práctica se usó
   `Pixel_7`.

## Diagnóstico ADB seguro

```powershell
$adb = 'C:\Users\gerar\AppData\Local\Android\sdk\platform-tools\adb.exe'
& $adb version
& $adb devices -l
& $adb kill-server
& $adb start-server
& $adb devices -l
flutter devices
```

El estado correcto es `device`. `unauthorized` requiere autorizar la clave
RSA; `offline` requiere terminar el arranque, cerrar instancias duplicadas o
usar Cold Boot Now. No usar Wipe Data sin autorización.

En esta revisión `emulator-5554` correspondió a `Pixel_7` y terminó `offline`;
no se ejecutaron APKs manualmente.

## Ejecución y pruebas

```powershell
cd Practica4\gestor_archivos
flutter pub get
flutter run

cd ..\juego_archivos
flutter pub get
flutter run
```

Probar selector SAF, operaciones autorizadas, ambos niveles, los tres formatos,
importación/exportación, compartir, orientación, temas y modo avión. Obtener
capturas reales en `evidencias/android/`.
