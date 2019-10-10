class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
    :recoverable, :rememberable, :validatable, :trackable, :lockable

  has_many :places, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :rates, dependent: :destroy
  has_many :shippers, dependent: :destroy
  has_many :addresses, dependent: :destroy
  has_many :messages, dependent: :destroy

  enum role: {customer: 0, admin: 1}
  mount_uploader :avatar, PictureUploader

  validates :name, presence: true,
    length: {maximum: Settings.user.name.max_length}
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true,
    length: {maximum: Settings.user.email.max_length},
    format: {with: VALID_EMAIL_REGEX},
    uniqueness: {case_sensitive: false}

  before_save :downcase_email
  skip_callback :commit, :after, :remove_previously_stored_avatar

  scope :by_name, ->{order(name: :asc)}

  attr_accessor :skip_password_validation

  def downcase_email
    self.email = email.downcase
  end
end
