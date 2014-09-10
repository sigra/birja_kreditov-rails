module BirjaKreditov
  class Status
    def self.initialize
      builder = BirjaKreditov::Builder.new
      builder.set_store

      response  = BirjaKreditov::Request.fetch 'stagesref', builder.body
      @xml      = response.xml
      @statuses = {}

      @xml.xpath('./Root/Data').each do |s|
        @statuses[s.xpath('./id').first.try(:content)] = s.xpath('./name').first.try(:content)
      end
    end

    def self.[] id
      self.initialize unless @statuses.present?
      @statuses["#{ id }"]
    end

    def self.all
      self.initialize unless @statuses.present?
      @statuses
    end

    def self.reload!
      self.initialize
    end
  end
end