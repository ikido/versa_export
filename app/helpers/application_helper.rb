module ApplicationHelper
  def url_for_public_file(path)
    path.to_s.slice((Rails.root.join('public').to_s.size)..-1)
  end
end
