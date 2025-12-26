# app/helpers/application_helper.rb
module ApplicationHelper
  # ナビ用クラス（前と同じ役割）
  THEME_CLASSES = {
    "default" => { header: "bg-gray-50 text-gray-800", nav: "bg-white text-gray-800 border-r border-gray-300" },

    # 濃い背景 + 白文字（ヘッダー/左ナビ）
    "slate"   => { header: "bg-slate-800 text-white",  nav: "bg-slate-900 text-white" },
    "indigo"  => { header: "bg-indigo-700 text-white", nav: "bg-indigo-800 text-white" },
    "emerald" => { header: "bg-emerald-700 text-white", nav: "bg-emerald-800 text-white" },
    "rose"    => { header: "bg-rose-700 text-white",   nav: "bg-rose-800 text-white" },
    "amber"   => { header: "bg-amber-700 text-white",  nav: "bg-amber-800 text-white" }
  }.freeze

  def submit_mode?
    ENV.fetch("DELIVER_EMAILS", "false") != "true"
  end

  def current_theme_key
    key = current_profile&.theme.presence || "default"
    THEME_CLASSES.key?(key) ? key : "default"
  end

  def header_theme_class
    THEME_CLASSES[current_theme_key][:header]
  end

  def sidebar_theme_class
    THEME_CLASSES[current_theme_key][:nav]
  end

  def dark_theme?
    current_theme_key != "default"
  end

  def nav_class(path)
    base = "block px-3 py-1 rounded text-sm"

    if dark_theme?
      if current_page?(path)
        "#{base} bg-white/10 text-white font-semibold"
      else
        "#{base} text-white/80 hover:bg-white/10 hover:text-white"
      end
    else
      if current_page?(path)
        "#{base} bg-blue-50 text-blue-700 font-semibold"
      else
        "#{base} text-gray-700 hover:bg-gray-50"
      end
    end
  end


  def profile_chip(profile, size: :xs, wrapper_class: "", show_label_fallback: true)
    return "" if profile.nil?

    name =
      profile.display_name.presence ||
      (show_label_fallback ? profile.label : "")

    content_tag :span,
                class: [ "inline-flex items-center space-x-1", wrapper_class ].reject(&:blank?).join(" ") do
      concat profile_avatar(profile, size: size)
      concat content_tag(:span, name, class: "truncate")
    end
  end

  # プロフィールアイコン
  def profile_avatar(profile, size: :md)
    sizes = {
      xs: 24,
      sm: 32,
      md: 40,
      lg: 64
    }

    dimension = sizes[size] || sizes[:md]

    if profile&.avatar&.attached?
      # ✅ vips / variant を使わず、そのまま表示して CSS でサイズ調整
      image_tag profile.avatar,
                class: "object-cover rounded",
                style: "width: #{dimension}px; height: #{dimension}px;",
                alt: profile.display_name || profile.label
    else
      initials = profile.display_initials

      content_tag :div,
                  initials,
                  class: "inline-flex items-center justify-center bg-gray-400 text-white font-semibold rounded",
                  style: "width: #{dimension}px; height: #{dimension}px; font-size: #{(dimension * 0.4).round}px;"
    end
  end

  def team_avatar(team, size: :md)
    return "" if team.nil?

    sizes = {
      xs: 24,
      sm: 32,
      md: 40,
      lg: 64
    }

    dimension = sizes[size] || sizes[:md]

    if team.avatar.attached?
      # ✅ variant をやめて、直接表示 + CSS でサイズ調整
      image_tag team.avatar,
                class: "rounded object-cover",
                style: "width: #{dimension}px; height: #{dimension}px;",
                alt: team.name
    else
      # アイコンが無いときのイニシャル表示とか
      initial = team.name.to_s[0].presence || "T"

      content_tag :div,
                  initial,
                  class: "inline-flex items-center justify-center rounded bg-blue-400 text-white font-semibold",
                  style: "width: #{dimension}px; height: #{dimension}px; font-size: #{(dimension * 0.5).round}px;"
    end
  end

  def chat_room_avatar(chat_room, size: :sm)
    sizes = { xs: 24, sm: 32, md: 40, lg: 64 }
    dimension = sizes[size] || sizes[:sm]

    if chat_room.avatar.attached?
      image_tag chat_room.avatar,
                class: "object-cover rounded",
                style: "width: #{dimension}px; height: #{dimension}px;",
                alt: chat_room.name
    else
      # アイコンがない場合は名前の頭文字を表示
      initial = chat_room.name.to_s[0].presence || "C"
      content_tag :div, initial,
                  class: "inline-flex items-center justify-center bg-blue-100 text-blue-600 font-bold rounded",
                  style: "width: #{dimension}px; height: #{dimension}px; font-size: #{(dimension * 0.5).round}px;"
    end
  end

  def team_chip(team, size: :xs, wrapper_class: "")
    return "" if team.nil?

    content_tag :span,
                class: [ "inline-flex items-center space-x-1", wrapper_class ].reject(&:blank?).join(" ") do
      concat team_avatar(team, size: size)
      concat content_tag(:span, team.name, class: "truncate")
    end
  end

  # 選択可能なプロフィールチップ（フォーム用）
  def profile_selection_chip(builder, profile)
    # builder は form.collection_check_boxes から渡される要素、または form 自体
    # 今回は builder.check_box を内包するスタイルにします

    builder.label(class: "cursor-pointer group") do
      concat builder.check_box(class: "hidden peer")
      concat(
        content_tag(:div, class: "flex items-center gap-2 px-3 py-1.5 border rounded-full transition-all peer-checked:bg-blue-600 peer-checked:text-white peer-checked:border-blue-600 hover:bg-gray-100 group-active:scale-95") do
          concat profile_avatar(profile, size: :xs)
          concat content_tag(:span, profile.display_name, class: "text-xs font-medium")
        end
      )
    end
  end

 def markdown(text)
    return "" if text.blank?

    options = {
      filter_html: true,
      hard_wrap: true,
      link_attributes: { rel: "nofollow", target: "_blank" },
      space_after_headers: true,
      fenced_code_blocks: true
    }

    extensions = {
      autolink: true,
      tables: true,
      strikethrough: true,
      fenced_code_blocks: true,
      space_after_headers: true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    # 1. MarkdownをHTMLに変換
    html_content = markdown.render(text)

    # 2. 危険なタグをサニタイズ（Brakeman対策）しつつ、安全とマーク
    sanitize(html_content).html_safe
  end
end
