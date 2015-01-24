module Dpaths
  def self.add_validator(path)
    if path.match(%r(^/.*\*))
      path
    else
      "#{path}/*"
    end
  end

  def self.select_all?(query)
    ['/*', '/', '*'].include?(query)
  end

  def self.from_an_array?(key)
    key.to_i.to_s == key
  end

  def self.into_an_array?(key)
    Dpaths.from_an_array?(key)
  end

  def self.from_arrays?(key)
    key.empty?
  end

  def self.into_arrays?(key)
    Dpaths.from_arrays?(key)
  end

  def self.is_validator?(key)
    ['{}', '[]', '*'].include?(key)
  end

  def self.validate_target(validator, target)
    case
    when validator == "{}" && target.kind_of?(Hash)
      target
    when validator == "[]" && target.kind_of?(Array)
      target
    when validator ==  "*"
      target
    else
      raise "dselect target validation failed"
    end
  end

  def self.key_validator_and_remaining(query)
    query = query.gsub(/^\//,'')
    fields = query.split('/')
    key = fields.first

    [key, fields.last, query.gsub(/^\/*#{Regexp.escape(key)}/,'')]
  end

  def self.dseek(target, parts)
    part = parts.shift
    if target.present?
      if part.present?
        if parts.present?
          if index = Integer(part) rescue false
            dseek(Array.wrap(target)[index], parts)
          else
            dseek(target[part] || target[part.to_sym], parts)
          end
        else
          target[(Integer(part) rescue part)]
        end
      else
        if parts.present?
          Array.wrap(target).flat_map do |partial|
            dseek(partial, parts.dup)
          end
        else
          target
        end
      end
    end
  end

  def self.dselect(target, query = '/')
    parts = query.split('/')[1..-2]
    dseek(target, parts)
  rescue NoMethodError
  end

  def self.keys_and_remaining(query)
    query = query.gsub(/^\//,'')
    fields = query.split('/')
    key = fields.first

    [key, fields[1], query.gsub(/^\/*#{Regexp.escape(key)}/,'')]
  end

  def self.dput(target, query = '/*', value)
    key, next_key, new_query = keys_and_remaining(query)

    if is_validator?(key)
      case
      when (key == '{}' || key == '*') && value.is_a?(Hash) && target.is_a?(Hash)
        target.merge!(value)
      when (key == '[]' || key == '*') && target.is_a?(Array)
        target << value
      else
        raise "dput target validation failed"
      end

    elsif is_validator?(next_key)
      if into_arrays?(key) || into_an_array?(key)
        target << value
      else
        key = key.to_sym if target.keys.include? key.to_sym
        target[key] = value
      end

    elsif into_arrays?(key)
      if target.empty?
        if next_key && next_key.empty?
          target << []
        else
          target << {}
        end
      end

      target.each do |new_target|
        dput(new_target, new_query, value)
      end
    elsif into_an_array?(key)
      key = key.to_i
      unless target[key]
        target.insert(key, (next_key.empty? || into_arrays?(next_key)) ? [] : {})
      end

      dput(target[key], new_query, value)
    else
      key = key.to_sym if target.keys.include? key.to_sym
      if next_key && (into_arrays?(next_key) || into_an_array?(next_key))
        target[key] = Array.wrap(target[key])
      else
        target[key] ||= {}
      end

      dput(target[key], new_query, value)
    end

    target
  rescue NoMethodError => ex
  end
end
