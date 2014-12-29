module Helpers
  module Common
    extend ActiveSupport::Concern
    included do
      let(:mock_base) { "spec/webmocks/#{described_class.to_s.downcase}" }
    end
  end

  module Request
    def json
      @json ||= JSON.parse(response.body)
    end
  end
end
