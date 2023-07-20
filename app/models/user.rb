class User < ActiveRecord::Base
  has_many :jobs, foreign_key: :employer_id
  has_many :applications, foreign_key: :job_seeker_id
  has_many :freelance_applications, foreign_key: :freelancer_id

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true
  validates :role, presence: true
end