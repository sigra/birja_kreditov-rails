module BirjaKreditov
  class Reason
    def self.initialize
      builder = BirjaKreditov::Builder.new
      builder.set_store

      response = BirjaKreditov::Request.fetch 'reasonsref', builder.body
      @xml     = response.xml
      @reasons = {}

      @xml.xpath('./Root/Data/Reason').each do |s|
        @reasons[s.xpath('./id').first.try(:content)] = s.xpath('./description').first.try(:content)
      end
    end

    def self.[] id
      self.initialize unless @reasons.present?
      @reasons["#{ id }"]
    end

    def self.all
      self.initialize unless @reasons.present?
      @reasons
    end

    def self.reload!
      self.initialize
    end
  end
end