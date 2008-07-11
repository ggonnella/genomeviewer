class RegisterController < ApplicationController

  def register
    # create a new user instance if here for the first time
    # or load it from the flash if coming back because of errors
    @user = flash[:user]||User.new
  end

  def do_register
    # create an user instance using the form parameters
    @user = User.new(params[:user])
    # try to save
    if @user.save
      # if successful:
      # go to the login page, displaying a success message
      flash[:notice] = "Registration successful, you can login now."
      redirect_to login_url
    else
      # back to the form if there was a problem
      flash[:user] = @user
      redirect_to :action => :register
    end
  end
  
  def recover_password
    @title = "Genomeviewer - Password Recovery"
    @user = User.new(:email => flash[:email])
  end
  
  def password_recovery_email_sent
    @title = "Genomeviewer - Password Recovery"
    @user = User.find_by_email(flash[:email])
  end
  
  def send_password_recovery_email
    flash[:email]=params[:user][:email]
    @user = User.find_by_email(params[:user][:email])
    if @user
      UserMailer.deliver_password_recovery_email_to(@user)
      redirect_to :action => :password_recovery_email_sent
    else
      flash[:errors]="Sorry, no user was registered under this email address."
      redirect_to :action => :recover_password
    end
  end

  private

  def initialize
    @title = "Genomeviewer - User Registration"
    # load the stylesheet to format errors in forms
    @stylesheets = 'form_errors'
    super
  end

end

