require_relative "/home/vince/development/code/phase3/code-project-workwise/workwise-backend/config/environment.rb"

class ApplicationController < Sinatra::Base
    set :default_content_type, 'application/json'

    enable :sessions
    register Sinatra::Flash
  
    get '/' do
      { name: 'Hello World' }.to_json
    end

    post '/users/login' do
      username = params[:username]
      password = params[:password]

      user = User.find_by(username: username)

      if user && password && user.password == password
        session[:user_id] = user.id
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

      else
        flash[:error] = "You need to log in to access the dashboard."
      end
    end

    get '/jobs' do
      jobs = Job.all
    
      jobs_json = jobs.map do |job|
        {
          id: job.id,
          title: job.title,
          description: job.description,
          location: job.location,
        }
      end
      jobs_json.to_json
    end
    
    get '/jobs/:id' do |id|
      job = Job.find_by(id: id)
    
      if job
        job_json = {
          id: job.id,
          title: job.title,
          description: job.description,
          location: job.location,
        }
    
        job_json.to_json
      else
        { error: "Job listing not found" }.to_json
      end
    end
    
    post '/jobs' do
      title = params[:title]
      description = params[:description]
      location = params[:location]
    
      new_job = Job.create(
        title: title,
        description: description,
        location: location,
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