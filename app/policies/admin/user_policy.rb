module Admin
  class UserPolicy < ApplicationPolicy
    pre_check :admin_up?

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
      true
    end

    def destroy?
      true
    end
  end
end
