# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable,
        :registerable,
        :recoverable,
        :rememberable,
        :validatable,
        :confirmable

  has_many :profiles, dependent: :destroy
  accepts_nested_attributes_for :profiles
  validates_presence_of :profiles
end
