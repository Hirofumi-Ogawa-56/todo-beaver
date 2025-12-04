# app/helpers/application_helper.rb
module ApplicationHelper
  def nav_class(path)
    base = "block px-3 py-2 rounded hover:bg-gray-100 text-sm"
    current_page?(path) ? "#{base} bg-gray-100 font-semibold" : base
  end
end
