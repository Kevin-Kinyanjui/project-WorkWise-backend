require_relative "/home/vince/development/code/phase3/code-project-workwise/workwise-backend/config/environment.rb"

class ApplicationController < Sinatra::Base
    set :default_content_type, 'application/json'

    enable :sessions
    set :session_secret, ENV['SESSION_SECRET'] || '46b1963be3d827007d7a70ffb5fc6994b3ee9f9dc4e5bff28d48d7473acd244f'
    use Rack::Session::Cookie, key: 'rack.session', path: '/', expire_after: 3600

    register Sinatra::Flash
  
    get '/' do
      { name: 'Hello World' }.to_json
    end

    post '/users/login' do
      username = params[:username]
      password = params[:password]

      user = User.find_by(username: username)

      if user && password && user.password == password
        session[:user] = user
        { success: true, message: "Login successful" }.to_json
      else
        { success: false, message: "Invalid username or password" }.to_json
      end
    end

    get '/users/logout' do
      session.clear
    end

    post '/users/register' do
      username = params[:username]
      password = params[:password]
      email = params[:email]
      role = params[:role]
    
      if User.exists?(username: username) || User.exists?(email: email)
        { success: false, message: "Username or email already taken" }.to_json
      else
        new_user = User.create(username: username, password: password, email: email, role: role)

        if new_user.valid?
          { success: true, message: "Registration successful" }.to_json
        else
          { success: false, message: "Failed to register user" }.to_json
        end
      end
    end

    get '/users/dashboard' do
      @current_user = session[:user]
    
      if @current_user
        user_details = {
          name: @current_user.username,
          email: @current_user.email,
          role: @current_user.role
        }
    
        if @current_user.role == "job seeker"
          user_details[:applications] = @current_user.applications.map do |application|
            {
              id: application.id,
              job_id: application.job_id,
              job_title: application.job.title,
              job_description: application.job.description,
              job_requirements: application.job.requirements,
              job_location: application.job.location,
              cover_letter: application.cover_letter,
              resume: application.resume
            }
          end
        elsif @current_user.role == "employer"
          user_details[:jobs] = @current_user.jobs.map do |job|
            applicants = job.applications.map do |application|
              {
                applicant_id: application.job_seeker.id,
                applicant_name: application.job_seeker.username,
                applicant_email: application.job_seeker.email,
                applicant_resume: application.resume
              }
            end
    
            {
              id: job.id,
              title: job.title,
              description: job.description,
              requirements: job.requirements,
              location: job.location,
              applicants: applicants
            }
          end
        elsif @current_user.role == "freelancer"
          user_details[:freelance_applications] = @current_user.freelance_applications.map do |task|
            {
              id: task.id,
              freelance_task_id: task.freelance_task_id,
              proposal: task.proposal
            }
          end
        end
        
        user_details.to_json
      else
        { error: "You need to log in to access the dashboard." }.to_json
      end
    end
    
    get '/jobs' do
      jobs = Job.all
    
      jobs_json = jobs.map do |job|
        {
          id: job.id,
          title: job.title,
          description: job.description,
          location: job.location
        }
      end
      jobs_json.to_json
    end
    
    get '/jobs/:id' do |id|
      job = Job.find_by(id: id)
    
      if job
        applicants = job.applications.map do |application|
          {
            applicant_id: application.job_seeker.id,
            applicant_name: application.job_seeker.username,
            applicant_email: application.job_seeker.email,
            applicant_resume: application.resume
          }
        end
        job_json = {
          id: job.id,
          title: job.title,
          description: job.description,
          location: job.location,
          applicants: applicants
        }
    
        job_json.to_json
      else
        { error: "Job listing not found" }.to_json
      end
    end
    
    post '/jobs' do
      employer_name = params[:employer_name]
      title = params[:title]
      description = params[:description]
      requirements = params[:requirements]
      location = params[:location]

      employerId = User.find_by(username: employer_name).id
    
      new_job = Job.create(
        employer_id: employerId,
        title: title,
        description: description,
        requirements: requirements,
        location: location
      )
      if new_job.valid?
        { success: true, message: "Job listing created successfully" }.to_json
      else
        { success: false, message: "Failed to create job listing" }.to_json
      end
    end

    # get '/job_listings/:id/edit' do |id|
    #   @job_listing = JobListing.find_by(id: id)
    
    #   if @job_listing
    #     erb :edit_job_listing
    #   else
    #     flash[:error] = "Job listing not found"
    #     redirect '/job_listings'
    #   end
    # end
    
    patch '/job_listings/:id' do |id|
      @job = Job.find_by(id: id)

      if @job
        title = params[:title]
        description = params[:description]
        location = params[:location]

        if @job.update(title: title, description: description, location: location)
          flash[:success] = "Job listing updated successfully"
        else
          flash[:error] = "Failed to update job listing"
        end
      else
        flash[:error] = "Job listing not found"
      end
    end

    delete '/jobs/:id' do |id|
      @job = Job.find_by(id: id)
    
      if @job
        if @job.destroy
          flash[:success] = "Job listing deleted successfully"
        else
          flash[:error] = "Failed to delete job listing"
        end
      else
        flash[:error] = "Job listing not found"
      end
    end

    post '/jobs/:id/apply' do |id|
      job = Job.find_by(id: id)
    
      if job
        new_application = Application.create(
          name: params[:name],
          email: params[:email],
          cover_letter: params[:cover_letter],
          job_id: job.id
        )
    
        if new_application.valid?
          { success: true, message: "Job application submitted successfully" }.to_json
        else
          { success: false, message: "Failed to submit job application" }.to_json
        end
      else
        { error: "Job listing not found" }.to_json
      end
    end
    
    get '/freelance_tasks' do
      freelance_tasks = FreelanceTask.all

      freelance_tasks_json = freelance_tasks.map do |freelance_task|
        {
          id: freelance_task.id,
          title: freelance_task.title,
          description: freelance_task.description,
        }
      end
      freelance_tasks_json.to_json
    end
    
    get '/freelance_tasks/:id' do |id|
      freelance_task = FreelanceTask.find_by(id: id)
    
      if freelance_task
        freelance_task_json = {
          id: freelance_task.id,
          title: freelance_task.title,
          description: freelance_task.description,
        }
        freelance_task_json.to_json
      else
        { error: "Freelance task not found" }.to_json
      end
    end

    post '/freelance_tasks' do
      title = params[:title]
      description = params[:description]
    
      new_freelance_task = FreelanceTask.create(
        title: title,
        description: description,
      )
    
      if new_freelance_task.valid?
        { success: true, message: "Freelance task created successfully" }.to_json
      else
        { success: false, message: "Failed to create freelance task" }.to_json
      end
    end

    post '/freelance_tasks/:id/apply' do |id|
      freelance_task = FreelanceTask.find_by(id: id)
    
      if freelance_task
        new_application = FreelanceApplication.create(
          name: params[:name],
          email: params[:email],
          cover_letter: params[:cover_letter],
          freelance_task_id: freelance_task.id
        )
    
        if new_application.valid?
          { success: true, message: "Freelance application submitted successfully" }.to_json
        else
          { success: false, message: "Failed to submit freelance application" }.to_json
        end
      else
        { error: "Freelance task not found" }.to_json
      end
    end

    not_found do
      'This page does not exist.'
    end
  
  end