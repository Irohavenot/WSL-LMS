class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :first_name, :last_name, presence: true
  validates :middle_initial, length: { maximum: 1 }, allow_blank: true

  def full_name
    [first_name, middle_initial, last_name].compact.join(" ")
  end
end