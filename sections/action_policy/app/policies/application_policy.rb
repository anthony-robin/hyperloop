class ApplicationPolicy < ActionPolicy::Base
  private

  def require_super_admin!
    deny! unless super_admin?
  end

  def require_admin!
    deny! unless admin? || super_admin?
  end

  def super_admin?
    user&.super_admin?
  end

  def admin?
    user&.admin?
  end

  def owner?
    record.user_id == user.id
  end
end
