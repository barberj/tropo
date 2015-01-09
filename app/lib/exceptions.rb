module Exceptions
  Unprocessable = Class.new StandardError
  ApiError = Class.new StandardError
  Unauthorized = Class.new ApiError
end
