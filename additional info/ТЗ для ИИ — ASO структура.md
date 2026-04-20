# ТЗ для ИИ: ASO автоматизация — структура файлов и папок

## Контекст

Проект использует автоматизированную систему загрузки метаданных и скриншотов
в App Store Connect через Fastlane + GitHub Actions.

ИИ получает одно или несколько входных текстов и создаёт всю необходимую
структуру файлов и папок. Workflows подхватывают всё автоматически.

---

## Что нужно от тебя (ИИ) при старте нового проекта

### 1. Обновить `appstore_config.yml` (в корне проекта)

Заполни значения для этого конкретного приложения:

```yaml
app_name:      "Название приложения"
subtitle:      "Краткий слоган (до 30 символов)"
keywords:      "слово1,слово2,слово3"   # без пробелов, до 100 символов суммарно

support_url:   "https://example.com/support"
marketing_url: "https://example.com"
privacy_url:   "https://example.com/privacy-policy"
```

---

### 2. Создать файлы описаний (папка `descriptions/`)

Структура:
```
descriptions/
  gr/
    de-DE.txt
    da.txt
    en-GB.txt
    fi.txt
    fr-FR.txt
    el.txt
    it.txt
    ca.txt
    hr.txt
    no.txt
    nl-NL.txt
    pl.txt
    pt-PT.txt
    ro.txt
    ru.txt
    sv.txt
    sk.txt
    es-ES.txt
    cs.txt
    tr.txt
    hu.txt
  wh/
    en-US.txt
    en-CA.txt
    en-AU.txt
    ar-SA.txt
    fr-CA.txt
    he.txt
    hi.txt
    zh-Hant.txt
    zh-Hans.txt
    ja.txt
    ko.txt
    ms.txt
    es-MX.txt
    pt-BR.txt
    th.txt
    uk.txt
    vi.txt
    id.txt
```

**Правила:**
- Имя файла = точный код локали Apple (с учётом регистра и дефисов)
- Содержимое = текст описания приложения на соответствующем языке
- Кодировка: UTF-8, без BOM
- Максимум 4000 символов на App Store
- Группа `gr/` — европейские языки (серый дизайн ASO)
- Группа `wh/` — остальные языки (белый дизайн ASO)
- Переведи описание на все 39 языков из входного текста

---

### 3. Создать структуру папок для скриншотов (папка `Screenshots/`)

Создай ПУСТЫЕ папки — пользователь сам добавит файлы скриншотов.

```
Screenshots/
  gr/
    iphone/     ← пустая папка
    ipad/       ← пустая папка
  wh/
    iphone/     ← пустая папка
    ipad/       ← пустая папка
```

**Правила для скриншотов (для пользователя, не для ИИ):**
- Файлы называй: `01.png`, `02.png`, ..., `08.png` (до 8 штук)
- iPhone: 1242 × 2688 px (или больше — workflow ресайзнет)
- iPad: 2048 × 2732 px (или больше — workflow ресайзнет)
- Группа `gr/` = скриншоты с серым/тёмным фоном (для европейских стран)
- Группа `wh/` = скриншоты с белым/светлым фоном (для остальных стран)

---

## Что делают workflows (для справки)

### `.github/workflows/upload_metadata.yml`
1. Читает `descriptions/gr/*.txt` и `descriptions/wh/*.txt`
2. Копирует каждый файл в `fastlane/metadata/<locale>/description.txt`
3. Читает `appstore_config.yml` и записывает `name.txt`, `subtitle.txt`,
   `keywords.txt`, `support_url.txt`, `marketing_url.txt`, `privacy_url.txt`
   во все 39 локалей
4. Запускает `fastlane ios upload_metadata` → загружает в App Store Connect

### `.github/workflows/upload_screenshots.yml`
1. Читает `Screenshots/gr/iphone/*.png` и `Screenshots/wh/iphone/*.png` (и iPad)
2. Ресайзит если нужно до целевого размера через `sips`
3. Раскладывает по `fastlane/screenshots/<locale>/iphone_NN.png` и `ipad_NN.png`
4. Запускает `fastlane ios upload_screenshots` → загружает в App Store Connect

---

## Файлы которые нужно скопировать в новый проект

| Файл | Назначение |
|------|------------|
| `fastlane/AppstoreLanes.rb` | Fastlane lanes для upload_metadata и upload_screenshots |
| `fastlane/Deliverfile` | Настройки deliver (submit_for_review false и т.д.) |
| `.github/workflows/upload_metadata.yml` | GitHub Actions workflow для метаданных |
| `.github/workflows/upload_screenshots.yml` | GitHub Actions workflow для скриншотов |
| `appstore_config.yml` | Конфиг с данными приложения (редактировать!) |

В `fastlane/Fastfile` добавить строку:
```ruby
import "AppstoreLanes.rb"
```

---

## Список всех 39 локалей с группами

| Код Apple | Группа | Язык |
|-----------|--------|------|
| de-DE     | gr     | Немецкий |
| da        | gr     | Датский |
| en-GB     | gr     | Английский (UK) |
| fi        | gr     | Финский |
| fr-FR     | gr     | Французский |
| el        | gr     | Греческий |
| it        | gr     | Итальянский |
| ca        | gr     | Каталанский |
| hr        | gr     | Хорватский |
| no        | gr     | Норвежский |
| nl-NL     | gr     | Нидерландский |
| pl        | gr     | Польский |
| pt-PT     | gr     | Португальский (Португалия) |
| ro        | gr     | Румынский |
| ru        | gr     | Русский |
| sv        | gr     | Шведский |
| sk        | gr     | Словацкий |
| es-ES     | gr     | Испанский (Испания) |
| cs        | gr     | Чешский |
| tr        | gr     | Турецкий |
| hu        | gr     | Венгерский |
| en-US     | wh     | Английский (США) |
| en-CA     | wh     | Английский (Канада) |
| en-AU     | wh     | Английский (Австралия) |
| ar-SA     | wh     | Арабский |
| fr-CA     | wh     | Французский (Канада) |
| he        | wh     | Иврит |
| hi        | wh     | Хинди |
| zh-Hant   | wh     | Китайский традиционный |
| zh-Hans   | wh     | Китайский упрощённый |
| ja        | wh     | Японский |
| ko        | wh     | Корейский |
| ms        | wh     | Малайский |
| es-MX     | wh     | Испанский (Мексика) |
| pt-BR     | wh     | Португальский (Бразилия) |
| th        | wh     | Тайский |
| uk        | wh     | Украинский |
| vi        | wh     | Вьетнамский |
| id        | wh     | Индонезийский |
