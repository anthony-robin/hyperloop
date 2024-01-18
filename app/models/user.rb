class User < ApplicationRecord
  EMAIL_REGEX = /\A[^@\s]+@([^@.\s]+\.)+[^@.\s]+\z/

  enum :role, { standard: 0, admin: 1, super_admin: 2 },
       default: :standard,
       validate: true

  has_one_attached :avatar

  authenticates_with_sorcery!

  validates :email, presence: true,
                    format: { with: EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 8 },
                       presence: true,
                       confirmation: true,
                       if: :validate_password?
  validates :password_confirmation, presence: true, if: :validate_password?

  def full_name
    "#{first_name} #{last_name}"
  end

  private

  def validate_password?
    new_record? || changes[:crypted_password] || reset_password_token_changed?
  end
end
