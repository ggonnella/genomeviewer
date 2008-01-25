class InSessionController < ApplicationController

 prepend_before_filter :check_login

 include FileManager
 
 include Config::Formats
 include Config::Colors
 include Config::Styles
 include Config::Dominations
 include Config::Collapse

 def check_login
  unless session[:user]
   redirect_to :controller => :login, :action => :login
   session[:location]=params.clone
  end
  return true
 end

 def do_logout
  session[:user]=nil
  redirect_to :controller => :default, :action => :index
 end

 def do_create_feature_class
  fc = FeatureClass.new(params[:feature_class])
  if fc.save
    flash[:notice] = "New feature class #{fc.name} created successfully."
  else
    flash[:errors] = "Impossible to create #{fc.name}.<br/>Does it already exist?"
  end
  redirect_to :action => :create_feature_class
 end 

 private

 def initialize
  @stylesheets = "in_session"
 end

end