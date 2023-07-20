class Application < ActiveRecord::Base
  belongs_to :job
  belongs_to :job_seeker, class_name: 'User'

  validates :job, presence: true
  validates :job_seeker, presence: true
end
