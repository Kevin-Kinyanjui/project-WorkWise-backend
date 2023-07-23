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

      image_urls = [
        "https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8c21hbGwlMjBjb21wYW55JTIwbG9nb3N8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=400&q=40",
        "https://plus.unsplash.com/premium_photo-1664301554245-2727ff96dc8e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=400&q=40",
        "https://images.unsplash.com/photo-1554049701-29ca4d4ecd27?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjZ8fGNvbXBhbnklMjBsb2dvc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=40",
        "https://images.unsplash.com/photo-1686191128663-475c73d8de27?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjV8fGNvbXBhbnklMjBsb2dvc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=40",
        "https://images.unsplash.com/photo-1685062428514-2164290b3322?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mjl8fGNvbXBhbnklMjBsb2dvc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=40",
        "https://images.unsplash.com/photo-1563302111-eab4b145e6c9?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NDh8fGNvbXBhbnklMjBsb2dvc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=40",
        "https://images.unsplash.com/photo-1661347998996-dcf102498c63?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTh8fGNvbXBhbnklMjBsb2dvc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=40",
        "https://images.unsplash.com/photo-1661347998423-b15d37d6f61e?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NTR8fGNvbXBhbnklMjBsb2dvc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=40",
        "https://images.unsplash.com/photo-1633074263223-1d63d65363f6?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Njh8fGNvbXBhbnklMjBsb2dvc3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=400&q=40",
        "https://images.unsplash.com/photo-1494253109108-2e30c049369b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8YnJhbmR8ZW58MHx8MHx8fDA%3D&auto=format&fit=crop&w=400&q=40",
        "https://images.unsplash.com/photo-1617727553252-65863c156eb0?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjB8fGJyYW5kfGVufDB8fDB8fHww&auto=format&fit=crop&w=400&q=40",
        "https://images.unsplash.com/photo-1553835973-dec43bfddbeb?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mjd8fGJyYW5kfGVufDB8fDB8fHww&auto=format&fit=crop&w=400&q=40"
      ]    
    
      jobs_json = jobs.map do |job|
        {
          id: job.id,
          title: job.title,
          description: job.description,
          location: job.location,
          imageUrl: image_urls.sample
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
          requirements: job.requirements,
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
    
    patch '/jobs/:id' do |id|
      @job = Job.find(id)

      if @job
        title = params[:title]
        description = params[:description]
        requirements = params[:requirements]
        location = params[:location]

        if @job.update(title: title, description: description, requirements: requirements, location: location)
          flash[:success] = "Job listing updated successfully"
        else
          flash[:error] = "Failed to update job listing"
        end
      else
        flash[:error] = "Job listing not found"
      end
    end

    delete '/jobs/:id' do |id|
      job = Job.find(id)
    
      if job
        # Delete all associated applications first cause of validation
          job.applications.destroy_all
        if job.destroy
          flash[:success] = "Job listing deleted successfully"
        else
          flash[:error] = "Failed to delete job listing"
        end
      else
        flash[:error] = "Job listing not found"
      end
    end

    post '/jobs/:id/apply' do |id|
      job = Job.find(id)
    
      if job
        new_application = Application.create(
          job_id: job.id,
          job_seeker_id: session[:user].id,
          cover_letter: params[:cover_letter],
          resume: Faker::Lorem.words(number: 3).join('_') + '.pdf'
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

    delete '/applications/:id' do |id|
      @application = Application.find(id)
    
      if @application
        if @application.job_seeker == session[:user]
          if @application.destroy
            { success: true, message: "Application deleted successfully" }.to_json
          else
            { success: false, message: "Failed to delete the application" }.to_json
          end
        else
          { error: "You don't have permission to delete this application" }.to_json
        end
      else
        { error: "Application not found" }.to_json
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
      freelance_task = FreelanceTask.find(id)
    
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

    patch '/freelance_tasks/:id' do |id|
      @freelance_task = FreelanceTask.find(id)
    
      if @freelance_task
          title = params[:title]
          description = params[:description]
          if @freelance_task.update(title: title, description: description)
            { success: true, message: "Freelance task updated successfully" }.to_json
          else
            { success: false, message: "Failed to update the freelance task" }.to_json
          end
      else
        { error: "Freelance task not found" }.to_json
      end
    end    

    delete '/freelance_tasks/:id' do |id|
      task = FreelanceTask.find(id)
    
      if task
        # Delete all associated applications first cause of validation
          task.freelance_applications.destroy_all
        if task.destroy
          flash[:success] = "Freelance Task listing deleted successfully"
        else
          flash[:error] = "Failed to delete freelance task listing"
        end
      else
        flash[:error] = "Freelance task listing not found"
      end
    end 

    post '/freelance_tasks/:id/apply' do |id|
      freelance_task = FreelanceTask.find(id)
    
      if freelance_task
        new_application = FreelanceApplication.create(
          freelance_task_id: freelance_task.id,
          freelancer_id: session[:user].id,
          proposal: params[:proposal]
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

    delete '/freelance_applications/:id' do |id|
      @freelance_application = FreelanceApplication.find(id)
    
      if @freelance_application
        if @freelance_application.user == session[:user]
          if @freelance_application.destroy
            { success: true, message: "Freelance task deleted successfully" }.to_json
          else
            { success: false, message: "Failed to delete the freelance task" }.to_json
          end
        else
          { error: "You don't have permission to delete this freelance task" }.to_json
        end
      else
        { error: "Freelance task not found" }.to_json
      end
    end    

    not_found do
      'This page does not exist.'
    end
  
  end