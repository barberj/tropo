class ApiConfig < ActiveRecord::Base
  belongs_to :api, inverse_of: :api_config
end
