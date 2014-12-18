class Insightly < Api
  has_many(:accounts,
    class_name: 'InsightlyAccount',
    foreign_key: 'api_id',
    dependent: :destroy
  )
end
