#!/bin/bash
# Выпуск новой версии: ./release.sh 1.2 "Что нового — строка 1" "строка 2" ...
# Собирает APK, поднимает версию и публикует релиз на GitHub. Телефоны увидят его при следующем запуске.
set -euo pipefail
cd "$(dirname "$0")"
VER="${1:?Укажите версию, например 1.2}"; shift
[ $# -gt 0 ] || { echo "Добавьте хотя бы одну строку «что нового»"; exit 1; }

GRADLE=android/app/build.gradle
CODE=$(( $(sed -n 's/.*versionCode \([0-9]*\).*/\1/p' "$GRADLE") + 1 ))
sed -i '' "s/versionCode [0-9]*/versionCode $CODE/; s/versionName \"[^\"]*\"/versionName \"$VER\"/" "$GRADLE"

npx cap copy android
(cd android && JAVA_HOME=/opt/homebrew/opt/openjdk@25 ./gradlew assembleDebug -q)
APK="bar-na-vecher-$VER.apk"
cp android/app/build/outputs/apk/debug/app-debug.apk "$APK"
cp "$APK" "Бар-на-вечер.apk"

NOTES=$(printf -- '- %s\n' "$@")
git add -A && git commit -qm "Версия $VER" && git push -q
gh release create "v$VER" "$APK" --title "Версия $VER" --notes "$NOTES"
rm "$APK"
echo "Готово: v$VER (versionCode $CODE)"
