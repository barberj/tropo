module EncryptedData
  def encrypting
    @encrypting
  end

  def encrypting!
    @encrypting = true
  end

  def encrypted_data(attribute_name)
    if !encrypting
      encrypting!
      attr_encrypted(attribute_name,
        key: proc { |record| "#{Tropo.secret}#{record.id}#{record.created_at.to_s}" },
        marshal: true
      )

      define_method('data') do
        value = send(attribute_name)
        if value.kind_of?(Hash)
          value.with_indifferent_access
        else
          value || {}.with_indifferent_access
        end
      end

      define_method('data=') do |value|
        send("#{attribute_name}=", value)
        self.save
      end

      define_method('data!') do |value|
        if value.kind_of?(Hash) && self.data.kind_of?(Hash)
          self.data=(self.data.merge(value))
        else
          self.data=(value)
        end
      end
    else
      raise 'Can only have one encrypted_data per model'
    end
  end
end
