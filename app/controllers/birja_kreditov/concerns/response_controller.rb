module BirjaKreditov
  module ResponseController
    extend ActiveSupport::Concern

    included do
      skip_before_action :verify_authenticity_token
      before_filter :parse_xml_response
      after_filter  :logger_success

      rescue_from Exception, with: :error_response

      # POST /birja_kreditov/update_info
      def update_info
        if @object.save
          render xml: BirjaKreditov::Response.success(uid: @uid)
        else
          raise 'Error during saving'
        end
      end

      protected

      def model
        BirjaKreditov.model.constantize
      end
    end

    protected

    def parse_xml_response
      BirjaKreditov.logger.info "*"*50
      BirjaKreditov.logger.info { "Received connection from #{ request.ip }" }
      BirjaKreditov.logger.info { "Received data: #{ request.raw_post.force_encoding('UTF-8') }" }

      body = request.raw_post
      raise 'Empty request' unless body.present?

      @response = BirjaKreditov::Response.new body
      raise 'Unveryfied sign' unless @response.verified?

      package_data = BirjaKreditov::Builder.new(xml: @response.body).xml_package_data

      @status  = package_data.at('Stage').try(:content)
      @comment = package_data.at('Comment').try(:content)
      @uid     = package_data.at('UID').try(:content)
      @date    = package_data.at('DateTime').try(:content)
      @reason  = package_data.at('ReasonID').try(:content)

      raise 'UID can not be empty' unless @uid.present?

      @object = model.where(BirjaKreditov.uid_field => @uid).first
      raise 'Wrong UID' unless @object.present?

      @object[BirjaKreditov.status_field]  = @status
      @object[BirjaKreditov.comment_field] = @comment
      @object[BirjaKreditov.reason_field]  = @reason
      @object.bk_updated_at                = @date
    end

    def error_response e
      BirjaKreditov.logger.error { "Error during incoming request: #{ e.message }" }
      render xml: BirjaKreditov::Response.error(e.message)
      return false
    end

    def logger_success
      BirjaKreditov.logger.info do
        "Requested object with UID=\"#{ @object[BirjaKreditov.uid_field] }\" has updated! "\
        "stage: \"#{ BirjaKreditov::Status[@object[BirjaKreditov.status_field]] }\", "\
        "reason: \"#{ BirjaKreditov::Reason[@object[BirjaKreditov.reason_field]] }\", "\
        "comment: \"#{ @object[BirjaKreditov.comment_field] }\""
      end
    end
  end
end