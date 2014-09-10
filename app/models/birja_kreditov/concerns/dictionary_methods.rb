module BirjaKreditov
  module DictionaryMethods
    extend ActiveSupport::Concern

    included do
      def bk_status_human
        BirjaKreditov::Status[self.send(BirjaKreditov.status_field.to_sym)].to_s
      end

      def bk_reason_human
        BirjaKreditov::Reason[self.send(BirjaKreditov.reason_field.to_sym)].to_s
      end
    end
  end
end