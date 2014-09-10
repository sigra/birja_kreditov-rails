require 'nokogiri'
require 'base64'
require 'securerandom'
require 'digest'
require 'birja_kreditov/rails/routes'

module BirjaKreditov
  require 'birja_kreditov/logging'

  require 'birja_kreditov/builder'
  require 'birja_kreditov/request'
  require 'birja_kreditov/response'

  require 'birja_kreditov/status'
  require 'birja_kreditov/reason'

  mattr_accessor :time_format
  @@time_format = '%Y-%m-%d %H:%M:%S'

  mattr_accessor :private_key
  @@private_key = 'path_to_my_private.key'

  mattr_accessor :partner_id
  @@partner_id = 100000

  mattr_accessor :login
  @@login = 'my_email@example.com'

  mattr_accessor :password
  @@password = 'top_secret_password'

  mattr_accessor :model
  @@model = 'Order'

  mattr_accessor :status_field
  @@status_field = 'bk_status'

  mattr_accessor :reason_field
  @@reason_field = 'bk_reason'

  mattr_accessor :comment_field
  @@comment_field = 'bk_comment'

  mattr_accessor :uid_field
  @@uid_field = 'bk_uid'

  mattr_accessor :route_scope
  @@route_scope = 'birja_kreditov'

  mattr_accessor :logger

  def self.setup
    yield self
  end

  class Railties < ::Rails::Railtie
    initializer 'BirjaKreditov logger' do
      logfile = File.open("#{ Rails.root }/log/#{ Rails.env }.birja_kreditov.log", 'a+')  # create log file
      logfile.sync = true  # automatically flushes data to file

      BirjaKreditov.logger = BirjaKreditov::Logging.new(logfile)
    end
  end
end

_root_ = File.expand_path('../../',  __FILE__)

# Loading of concerns
require "#{_root_}/app/controllers/birja_kreditov/concerns/response_controller.rb"
require "#{_root_}/app/models/birja_kreditov/concerns/scopes.rb"
require "#{_root_}/app/models/birja_kreditov/concerns/dictionary_methods.rb"