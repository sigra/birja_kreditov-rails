module BirjaKreditov
  module Scopes
    extend ActiveSupport::Concern

    included do
      scope :with_bk_status, lambda { |id| where(BirjaKreditov.status_field => id) }
      scope :with_bk_reason, lambda { |id| where(BirjaKreditov.reason_field => id) }
    end
  end
end