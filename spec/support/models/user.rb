class User
  include ActiveModel::Model

  attr_accessor :id, :name, :age, :created_at, :updated_at

  validates :name, presence: true
  validates :age, presence: true, numericality: { only_integer: true }

  def persisted?
    id
  end

  def ==(other)
    if id
      id == other.id
    else
      object_id == other.object_id
    end
  end
end