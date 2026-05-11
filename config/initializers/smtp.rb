# Resend SMTP config — chỉ load trong production
if Rails.env.production?
  ActionMailer::Base.smtp_settings = {
    address:              ENV.fetch('SMTP_HOST', 'smtp.resend.com'),
    port:                 ENV.fetch('SMTP_PORT', 587).to_i,
    domain:               ENV.fetch('SMTP_DOMAIN', 'ao3.ducvu.vn'),
    user_name:            ENV.fetch('SMTP_USER', 'resend'),
    password:             ENV['SMTP_PASSWORD'],
    authentication:       :plain,
    enable_starttls_auto: true
  }

  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.default_url_options = {
    host:     ENV.fetch('AO3_HOST', 'ao3.ducvu.vn'),
    protocol: ENV.fetch('AO3_PROTOCOL', 'https')
  }
end
