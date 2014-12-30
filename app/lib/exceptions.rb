module Exceptions
  InvalidTimeFormat = Class.new StandardError
  ApiError = Class.new StandardError
  Unauthorized = Class.new ApiError
end
