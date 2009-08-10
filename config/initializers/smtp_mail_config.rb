ActionMailer::Base.smtp_settings = {
  :address        => APP_CONFIG[:smtp_server],
  :port           => APP_CONFIG[:smtp_port],
  :domain         => APP_CONFIG[:smtp_domain],
  :authentication => :login,
  :user_name      => APP_CONFIG[:smtp_user],
  :password       => APP_CONFIG[:smtp_pass]
}