module BirjaKreditov
  class Request
    # parse url
    # @return Response.body
    def self.fetch path, body
      uri = URI.parse("https://birjakreditov.com/import/#{ path }")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE

      request = Net::HTTP::Post.new(uri.request_uri)
      request.body = body
      request["Content-Type"] = "application/xml; charset=UTF-8"

      BirjaKreditov.logger.info '*'*50
      BirjaKreditov.logger.info "Make new request to BirjaKreditov. URL: #{ uri.to_s }"
      BirjaKreditov.logger.info { "Send data: #{ body.force_encoding('UTF-8') }" }

      response = http.request(request).body

      BirjaKreditov.logger.info { "Recieved response: #{ response.force_encoding('UTF-8') }"}

      BirjaKreditov::Response.new response
    end
  end
end