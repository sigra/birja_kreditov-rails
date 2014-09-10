module BirjaKreditov
  class Response
    def initialize response_body
      @body    = response_body
      @xml     = Nokogiri::XML(@body)
      @key     = OpenSSL::PKey::RSA.new File.read(BirjaKreditov.private_key)
      @builder = BirjaKreditov::Builder.new xml: @body

      raise 'unverified' unless verified?
    end

    def xml
      @xml
    end

    def body
      @body
    end

    def verified?
      data      = @body
      digest    = OpenSSL::Digest::SHA256.new
      signature = @key.sign(digest, data)

      @key.public_key.verify(digest, signature, data)
    end

    # return xml status code
    def status
      @builder.xml_package_data.at('Status').try(:content).to_s
    end

    def success?
      status == '1'
    end

    def failure?
      status.presence || status == '0'
    end

    def self.success options = {}
      builder = BirjaKreditov::Builder.new with_auth_data: false

      builder.uid = options[:uid] if options[:uid].present?
      builder.add_node(builder.xml_package_data, 'Status', 1)

      builder.body
    end

    def self.error msg, options = {}
      builder = BirjaKreditov::Builder.new with_auth_data: false

      builder.uid = options[:uid] if options[:uid].present?
      builder.add_node(builder.xml_package_data, 'Status', 0)
      builder.add_node(builder.xml_package_data, 'ErrorDescription', msg)

      builder.body
    end
  end
end