module BirjaKreditov
  class Builder
    def initialize options = {}
      options[:with_auth_data] = true if options[:with_auth_data].nil?

      @time     = Time.now.strftime(BirjaKreditov.time_format)
      @key      = OpenSSL::PKey::RSA.new File.read(BirjaKreditov.private_key)
      @nonce    = SecureRandom.base64
      @xml      = options[:xml].presence ? Nokogiri::XML(options[:xml], nil, 'UTF-8') : build_template(options[:with_auth_data])
      @products = []
      @user     = {}
      @uid      = ''
      @signed   = false

      raise 'Bad xml' unless correct_structure?
    end

    # format xml for request
    def body
      doc.serialize(format: 'UTF-8', save_with: Nokogiri::XML::Node::SaveOptions::FORMAT)
    end

    # nokogiri xml object
    def xml
      @xml
    end

    def doc
      if @xml.instance_of? Nokogiri::XML::Document
        @xml
      else
        @xml.doc
      end
    end

    # add StoreID node to package data
    def set_store id = nil
      id ||= BirjaKreditov.partner_id
      clean_partner_store
      add_node xml_package_data, 'StoreID', id
      id
    end

    # add PartnerID node to package data
    def set_partner id = nil
      id ||= BirjaKreditov.partner_id
      clean_partner_store
      add_node xml_package_data, 'PartnerID', id
      id
    end

    def products
      @products
    end

    # @products Array of Hashes
    # [{ :name, :details, :price, :quantity, :image, :articul, :url }]
    def products= products
      products = [products] unless products.is_a? Array
      @products = products
      build
    end

    def user
      @user
    end

    def user= data
      @user = data
      build
    end

    def uid
      @uid
    end

    def uid= id
      @uid = id
      build_uid
    end

    def build
      build_user
      build_products
      sign_xml
      body
    end

    def xml_root
      doc.at('Root')
    end

    def xml_package_data
      xml_root.at('PackageData')
    end

    def add_node path, key, value
      node = Nokogiri::XML::Node.new(key, doc)
      node.content = value
      path << node

      build
    end

    private

    # default XML template
    def build_template with_auth_data = true
      Nokogiri::XML::Builder.new(encoding: 'UTF-8') do |xml|
        xml.send('Root') {
          if with_auth_data
            xml.send('AuthData') {
              xml.send('Login', BirjaKreditov.login)
              xml.send('Password', generate_password_hash)
              xml.send('Nonce', @nonce)
              xml.send('Created', @time)
            }
          end
          xml.send('PackageData') { }
        }
      end
    end

    # build products xml data
    def build_products
      doc.at('Products').try(:remove)

      return unless products.present?

      Nokogiri::XML::Builder.with(xml_package_data) do |xml|
        xml.send('Products') {
          products.each do |product|
            xml.send('Product') {
              product.keys.each do |key|
                xml.send(key.to_s.capitalize, product[key])
              end
            }
          end
        }
      end
    end

    # build user xml data
    def build_user
      doc.at('User').try(:remove)

      return unless user.present?

      Nokogiri::XML::Builder.with(xml_package_data) do |xml|
        xml.send('User') {
          xml.send('Email', user[:email])
          xml.send('Phone', user[:phone])
          xml.send('FullName') {
            xml.send('FirstName', user[:first_name])
            xml.send('LastName', user[:last_name])
            xml.send('MiddleName', user[:middle_name])
          }
        }
      end
    end

    # add uid to xml
    def build_uid
      xml_package_data.at('UID').try(:remove)
      return unless uid.present?
      add_node(xml_package_data, 'UID', uid)
    end

    # base64_encode(sha1(md5($password) . $nonce . $created))
    def generate_password_hash
      Base64.strict_encode64(Digest::SHA1.hexdigest(Digest::MD5.hexdigest(BirjaKreditov.password) + @nonce + @time))
    end

    def generate_sign
      Base64.encode64(@key.sign(OpenSSL::Digest::SHA1.new, body))
    end

    def sign_xml
      # remove old sign
      if @signed
        xml_package_data.at('DateTime').try(:remove)
        xml_package_data.at('Sign').try(:remove)
      end

      time_node = Nokogiri::XML::Node.new('DateTime', doc)
      time_node.content = Time.now.strftime(BirjaKreditov.time_format)

      xml_package_data << time_node

      sign_node = Nokogiri::XML::Node.new('Sign', doc)
      sign_node.content = generate_sign

      xml_package_data << sign_node

      @signed = true
    end

    def clean_partner_store
      xml_package_data.at('StoreID').try(:remove)
      xml_package_data.at('PartnerID').try(:remove)
    end

    def correct_structure?
      begin
        xml_package_data
        true
      rescue
        return false
      end
    end
  end
end