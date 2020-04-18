class Ability
  include CanCan::Ability

  def initialize(employee)
    # set user to new User if not logged in
    employee ||= employee.new # i.e., a guest user
    
    # set authorizations for different user roles
    if employee.role? :admin
      # they get to do it all
      can :manage, :all
      
    elsif employee.role? :manager
      # can manage shifts and shiftjobs
      can :manage, Shift
      can :manage, ShiftJob
      
      # can index store see thier store
      can :index, Store
      can :show, Store do |s|
        my_store = employee.current_assignment.store_id
        my_store == s.id
      end

      # index assignment and see my store assignment
      can :index, Assignment
      can :show, Assignment do |a|
        my_store = employee.current_assignment.store_id
        a.store_id == my_store
      end

      # they can read their own profile
      can :index, Employee
      can :show, Employee do |e|  
        my_store = employee.current_assignment.store_id
        my_store == e.current_assignment.store_id
      end

      # they can update their stores employee
      can :edit, Employee do |e|  
        my_store = employee.current_assignment.store_id
        my_store == e.current_assignment.store_id
      end

      can :update, Employee do |e|  
        my_store = employee.current_assignment.store_id
        my_store == e.current_assignment.store_id
      end
      

    elsif employee.role? :employee
      # they can read their own data
      can :index, Assignment
      can :show, Assignment do |a|
        a.employee.id == employee.id
      end

      can :show, Employee do |e|
        e.id == employee.id
      end
      
      can :update, Employee do |e|
        e.id == employee.id
      end

      
    else
      # guests can only read animals covered (plus home pages)
      # can :read, Animal
    end
  end
end