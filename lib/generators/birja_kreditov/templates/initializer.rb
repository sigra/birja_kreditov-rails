# main config for BirjaKreditov API
BirjaKreditov.setup do |config|
  ## Path to your private key
  # config.private_key = File.join(Rails.root, 'birja_kreditov.key')

  ## Your shop ID
  # config.partner_id  = 100000

  ## Auth information
  # config.login    = 'my@email.com'
  # config.password = 'top_secret'

  ## ActiveRecord setup
  # config.model         = 'Order'
  # config.status_field  = 'bk_status'
  # config.reason_field  = 'bk_reason'
  # config.comment_field = 'bk_comment'
  # config.uid_field     = 'bk_uid'

  ## Routes
  # set URL prefix (e.g. /birja_kreditov/givestatus)
  # config.route_namespace = 'birja_kreditov'
end