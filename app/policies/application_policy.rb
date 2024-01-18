class ApplicationPolicy < ActionPolicy::Base
  private

  def owner?
    record.user_id == user.id
  end

  def allow_admins
    deny! unless admin_up?
  end

  def admin_up?
    user.admin? || user.super_admin?
  end
end
