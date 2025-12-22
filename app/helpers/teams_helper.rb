# app/helpers/team_helper.rb
module TeamsHelper
  def render_team_tree(team, current_team)
    # 現在表示中のチームかどうかでスタイルを変える
    is_current = (team.id == current_team.id)
    bg_color = is_current ? "bg-amber-100 border-amber-300" : "bg-white border-gray-200"

    content_tag(:li, class: "list-none my-1") do
      concat(
        content_tag(:div, class: "flex items-center gap-2 p-1 rounded border #{bg_color} w-fit") do
          concat team_chip(team, size: :xs)
        end
      )

      # 子チーム（下位チーム）があれば、さらにインデントして表示
      if team.children.any?
        concat(
          content_tag(:ul, class: "pl-6 border-l border-gray-200 ml-3 mt-1") do
            team.children.each do |child_team|
              concat render_team_tree(child_team, current_team)
            end
          end
        )
      end
    end
  end
end
