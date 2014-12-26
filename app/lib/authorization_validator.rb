class AuthorizationValidator < ActiveModel::Validator
  def validate(record)
    record.authorized?
  rescue => ex
    record.errors.add :authorization,  ex.message
  end
end
