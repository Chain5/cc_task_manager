module ApplicationHelper
  # Renders a circular avatar for a user.
  # Uses the user's avatar_url when set, otherwise generates an initials badge
  # with a deterministic colour derived from their id.
  #
  # Sizes: :xs (22 px)  :sm (30 px)  :md (38 px)
  def avatar_tag(user, size: :sm, tooltip: true)
    css   = "avatar avatar--#{size}"
    title = tooltip ? user&.nickname : nil

    if user.nil?
      content_tag(:span, "?", class: "#{css} avatar--unknown", title: "Unknown user")
    elsif user.photo.attached?
      image_tag(url_for(user.photo), class: css, alt: user.nickname, title: title)
    elsif user.avatar_url.present?
      image_tag(user.avatar_url, class: css, alt: user.nickname, title: title)
    else
      content_tag(:span, user.initials,
                  class: css,
                  style: "background-color:#{user.avatar_color}",
                  title: title)
    end
  end
end
