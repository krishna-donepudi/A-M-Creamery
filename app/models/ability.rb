class Ability
  include CanCan::Ability

  def initialize(employee)
    # set employee to new Employee if not logged in
    employee ||= employee.new # i.e., a guest user
    
    # set authorizations for different employee roles
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
        if employee.current_assignment.nil? then false
        else
          my_store = employee.current_assignment.store_id
          my_store == s.id
        end
      end

      # index assignment and see my store assignments
      can :index, Assignment
      can :show, Assignment do |a|
        if employee.current_assignment.nil? then false
        else
          my_store = employee.current_assignment.store_id
          a.store_id == my_store
        end
      end

      # they can read their own profile and their store employees
      can :index, Employee
      can :show, Employee do |e|  
        if e.current_assignment.nil? then false
        else
          my_store = employee.current_assignment.store_id
          my_store == e.current_assignment.store_id unless e.current_assignment.nil?
        end
      end

      # they can update their stores employee
      can :edit, Employee do |e|  
        if e.current_assignment.nil? then false
        else
          my_store = employee.current_assignment.store_id
          my_store == e.current_assignment.store_id
        end
      end

      can :update, Employee do |e|  
        if e.current_assignment.nil? then false
        else
          my_store = employee.current_assignment.store_id
          my_store == e.current_assignment.store_id
        end
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
      # guests can only read ?
      # can :read, Animal
    end
  end
end