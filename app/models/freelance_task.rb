class FreelanceTask < ActiveRecord::Base
    has_many :freelance_applications
  
    validates :title, presence: true
end
  