class Job < ActiveRecord::Base
    belongs_to :employer, class_name: 'User'
    has_many :applications
  
    validates :title, presence: true
    validates :employer, presence: true
end