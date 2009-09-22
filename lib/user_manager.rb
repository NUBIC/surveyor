module UserManager

  def current_user
    @current_user= User.new(:login => "foobaz")
    @current_user.id = 123
    @current_user
  end

end