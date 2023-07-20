class FreelanceApplication < ActiveRecord::Base
    belongs_to :freelance_task
    belongs_to :freelancer, class_name: 'User'
  
    validates :freelance_task, presence: true
    validates :freelancer, presence: true
end
  