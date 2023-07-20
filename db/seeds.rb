require_relative "../config/environment.rb"

puts "Clearing database..."

Application.destroy_all
FreelanceApplication.destroy_all
FreelanceTask.destroy_all
Job.destroy_all
User.destroy_all


puts "🌱 Seeding data..."

puts "Users..."
10.times do
    User.create!(
      username: Faker::Internet.unique.username(specifier: 5..15),
      email: Faker::Internet.unique.email,
      password: Faker::Internet.password(min_length: 8),
      role: ['job seeker', 'employer', 'freelancer'].sample
    )
end

puts "Jobs..."
20.times do
  Job.create!(
    employer: User.where(role: 'employer').sample,
    title: Faker::Job.title,
    description: Faker::Lorem.paragraph,
    requirements: Faker::Lorem.sentences(number: 3).join(' '),
    location: Faker::Address.city
  )
end

puts "Applications..."
Job.all.each do |job_listing|
  rand(0..5).times do
    Application.create!(
      job: job_listing,
      job_seeker: User.where(role: 'job seeker').sample,
      cover_letter: Faker::Lorem.paragraph,
      resume: Faker::Lorem.words(number: 3).join('_') + '.pdf'
    )
  end
end

puts "Freelance tasks..."
15.times do
  FreelanceTask.create!(
    title: Faker::Job.field,
    description: Faker::Lorem.paragraph
  )
end

puts "Freelance applications..."
FreelanceTask.all.each do |freelance_task|
  rand(0..3).times do
    FreelanceApplication.create!(
      freelance_task: freelance_task,
      freelancer: User.where(role: 'freelancer').sample,
      proposal: Faker::Lorem.paragraph
    )
  end
end

puts ""
puts "🌱 Done seeding!"