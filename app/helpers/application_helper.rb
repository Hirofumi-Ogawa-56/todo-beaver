# app/helpers/application_helper.rb
module ApplicationHelper
  # ナビ用クラス（前と同じ役割）
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


  def nav_class(path)
    base = "block px-3 py-1 rounded text-sm"

    if current_page?(path)
      "#{base} bg-blue-50 text-blue-700 font-semibold"
    else
      "#{base} text-gray-700 hover:bg-gray-50"
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

  def team_chip(team, size: :xs, wrapper_class: "")
    return "" if team.nil?

    content_tag :span,
                class: [ "inline-flex items-center space-x-1", wrapper_class ].reject(&:blank?).join(" ") do
      concat team_avatar(team, size: size)
      concat content_tag(:span, team.name, class: "truncate")
    end
  end
end
