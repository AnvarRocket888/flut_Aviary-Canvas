# ─────────────────────────────────────────────────────────────────────────────
# AppstoreLanes.rb — универсальные ASO-lanes для iOS проектов.
#
# Что делает этот файл:
#   upload_metadata    — загружает описания, subtitle, keywords, URL-ы
#   upload_screenshots — загружает скриншоты (без метаданных и бинарника)
#
# Подключение в Fastfile проекта (одна строка в начале файла):
#   import "AppstoreLanes.rb"
#
# Необходимые переменные окружения (GitHub Secrets):
#   APPSTORE_KEY_ID     — Key ID из App Store Connect API
#   APPSTORE_ISSUER_ID  — Issuer ID из App Store Connect API
#   APPSTORE_P8         — содержимое .p8 файла ключа (весь текст)
#   IOS_BUNDLE_ID       — bundle identifier приложения (com.example.app)
#
# Необходимая структура файлов в проекте:
#   fastlane/metadata/<locale>/description.txt  — собирается workflow
#   fastlane/screenshots/<locale>/iphone_NN.png — собирается workflow
#   fastlane/screenshots/<locale>/ipad_NN.png   — собирается workflow
#
# Полное ТЗ по структуре папок: additional data/ТЗ для ИИ — ASO структура.md
# ─────────────────────────────────────────────────────────────────────────────

platform :ios do

  desc "Upload metadata only (descriptions, subtitle, keywords, URLs) — no binary, no screenshots"
  lane :upload_metadata do
    api_key = app_store_connect_api_key(
      key_id:      ENV["APPSTORE_KEY_ID"],
      issuer_id:   ENV["APPSTORE_ISSUER_ID"],
      key_content: ENV["APPSTORE_P8"]
    )

    upload_to_app_store(
      api_key:            api_key,
      app_identifier:     ENV["IOS_BUNDLE_ID"],
      skip_binary_upload: true,
      skip_screenshots:   true,
      metadata_path:      "./fastlane/metadata",
      submit_for_review:  false,
      automatic_release:  false,
      force:              true,
      run_precheck_before_submit:           false,
      ignore_language_directory_validation: true
    )
  end

  desc "Upload screenshots only — no binary, no metadata"
  lane :upload_screenshots do
    api_key = app_store_connect_api_key(
      key_id:      ENV["APPSTORE_KEY_ID"],
      issuer_id:   ENV["APPSTORE_ISSUER_ID"],
      key_content: ENV["APPSTORE_P8"]
    )

    ss_path = "./fastlane/screenshots"

    # Count expected screenshots by device type
    expected_iphone = Dir.glob("#{ss_path}/**/iphone_*.{png,PNG}").count
    expected_ipad   = Dir.glob("#{ss_path}/**/ipad_*.{png,PNG}").count

    attempt        = 0
    max_retries    = 3
    errors_500     = 0
    upload_success = false

    begin
      attempt += 1
      upload_to_app_store(
        api_key:               api_key,
        app_identifier:        ENV["IOS_BUNDLE_ID"],
        skip_binary_upload:    true,
        skip_metadata:         true,
        skip_screenshots:      false,
        screenshots_path:      ss_path,
        overwrite_screenshots: true,
        submit_for_review:     false,
        force:                 true,
        run_precheck_before_submit:           false,
        ignore_language_directory_validation: true
      )
      upload_success = true
    rescue => e
      is_500 = e.message.to_s.include?("500") || e.message.to_s.include?("Server error")
      errors_500 += 1 if is_500
      if attempt <= max_retries
        wait = 30 * attempt
        UI.important("App Store Connect error (#{e.message.lines.first&.strip}). Retrying in #{wait}s... (#{attempt}/#{max_retries})")
        sleep(wait)
        retry
      end
    end

    # ── Upload statistics ────────────────────────────────────────────────────
    uploaded_iphone   = upload_success ? expected_iphone : 0
    uploaded_ipad     = upload_success ? expected_ipad   : 0
    errors_recovered  = (upload_success && errors_500 > 0) ? errors_500 : 0
    errors_remaining  = upload_success ? 0 : errors_500

    UI.message("")
    UI.message("┌─────────────────────────────────────────────┐")
    UI.message("│          📊  Upload Statistics              │")
    UI.message("├─────────────────────────────────────────────┤")
    UI.message("│  Expected                                   │")
    UI.message("│    📱 iPhone : #{expected_iphone.to_s.ljust(28)}│")
    UI.message("│    🖥  iPad   : #{expected_ipad.to_s.ljust(28)}│")
    UI.message("│    📦 Total  : #{(expected_iphone + expected_ipad).to_s.ljust(28)}│")
    UI.message("├─────────────────────────────────────────────┤")
    UI.message("│  Uploaded                                   │")
    UI.message("│    📱 iPhone : #{uploaded_iphone.to_s.ljust(28)}│")
    UI.message("│    🖥  iPad   : #{uploaded_ipad.to_s.ljust(28)}│")
    UI.message("│    📦 Total  : #{(uploaded_iphone + uploaded_ipad).to_s.ljust(28)}│")
    UI.message("├─────────────────────────────────────────────┤")
    UI.message("│  500 errors                                 │")
    UI.message("│    ⚡ Total occurred   : #{errors_500.to_s.ljust(20)}│")
    UI.message("│    ✅ Recovered (retry): #{errors_recovered.to_s.ljust(20)}│")
    UI.message("│    ❌ Still failed     : #{errors_remaining.to_s.ljust(20)}│")
    UI.message("└─────────────────────────────────────────────┘")
    UI.message("")

    UI.user_error!("Upload failed after #{max_retries} retries") unless upload_success
  end

end
