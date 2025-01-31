module Admin
  class UserPolicy < ApplicationPolicy
    pre_check :require_admin!

    def index?
      true
    end

    def new?
      create?
    end

    def create?
      true
    end

    def show?
      true
    end

    def edit?
      update?
    end

    def update?
      return true if user.super_admin?
      return false if user.admin? && record.admin? && record != user
      return true if user.admin? && !record.super_admin?

      false
    end

    def destroy?
      update?
    end
  end
end
