module Exceptions
  ApiError = Class.new StandardError
  Unauthorized = Class.new ApiError
end
