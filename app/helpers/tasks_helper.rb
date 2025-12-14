# app/helper/tasks_helper.rb
module TasksHelper
  def status_badge(task)
    base_class = "inline-flex items-center px-2 py-0.5 rounded text-xs font-semibold"

    color_class =
      case task.status
      when "todo"
        # 淡い赤
        "bg-red-100 text-red-700"
      when "in_progress"
        # 淡い青
        "bg-blue-100 text-blue-700"
      when "done"
        # 淡い緑
        "bg-green-100 text-green-700"
      when "archived"
        # 淡い黄色
        "bg-yellow-100 text-yellow-800"
      else
        "bg-gray-100 text-gray-600"
      end

    label =
      case task.status
      when "todo"        then "todo"
      when "in_progress" then "in_progress"
      when "done"        then "done"
      when "archived"    then "archived"
      else task.status
      end

    content_tag :span, label, class: "#{base_class} #{color_class}"
  end

  # ここから 期限バッジ
  def due_badge(task)
    base_class = "inline-flex items-center px-2 py-0.5 rounded text-xs font-semibold"

    # 期限未設定
    return content_tag(:span, "未設定", class: "#{base_class} bg-gray-100 text-gray-500") if task.due_at.blank?

    now = Time.zone.now
    due = task.due_at.in_time_zone(Time.zone)

    label = due.strftime("%m/%d %H:%M")

    color_class =
      if due < now
        # 期限切れ
        "bg-red-100 text-red-700"
      elsif due.to_date == now.to_date
        # 今日が期限
        "bg-blue-100 text-blue-700"
      else
        # 未来
        "bg-green-100 text-green-700"
      end

    content_tag :span, label, class: "#{base_class} #{color_class}"
  end

  # カラム名クリックでソートするリンク
  # 1回目クリック → 降順
  # 同じカラムをもう1回クリック → 昇順
  def sort_link(label, column)
    current_sort      = params[:sort]
    current_direction = params[:direction]

    # 次の direction を決める
    next_direction =
      if current_sort == column && current_direction == "desc"
        "asc"   # 今が desc で同じカラム → 昇順に切り替え
      else
        "desc"  # それ以外（初回 or 別カラム）→ 降順スタート
      end

    # 今の状態に応じて矢印アイコン
    icon =
      if current_sort == column
        current_direction == "desc" ? "▼" : "▲"
      else
        ""
      end

    link_to(
      safe_join([ label, icon ].reject(&:blank?), " "),
      tasks_path(
        # いまの検索/フィルタ/カラムフィルタのパラメータを維持しつつ
        request.query_parameters.merge(sort: column, direction: next_direction)
      ),
      class: "inline-flex items-center gap-1 text-xs text-gray-700 hover:underline"
    )
  end
end
