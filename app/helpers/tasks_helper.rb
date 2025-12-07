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

    now = Time.current
    due = task.due_at

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
end
