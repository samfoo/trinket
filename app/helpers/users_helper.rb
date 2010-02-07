module UsersHelper
  def gravatar_url(user, size=80)
    "http://www.gravatar.com/avatar/" + 
      Digest::MD5.hexdigest(user.nil? ? "trinket" : user.email) +
      "?d=identicon&s=" + size.to_s
  end
end
