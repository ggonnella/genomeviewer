class OwnAnnotationsController < ApplicationController
  
  before_filter :enforce_login
  
  active_scaffold :annotations do |config|
  
    config.actions.exclude :show
    # create action will be used for uploads
    config.create.link.label = "Upload&nbsp;GFF3"
    config.create.multipart = true
    config.list.columns = [:name, :description, :sequence_regions, :public]
    config.columns[:public].label = "File&nbsp;Access"
    config.action_links.add :open,
                            :label => "Open",
                            :type => :record, 
                            :page => true
                            
  end
  
  def conditions_for_collection
    ["user_id = ?", session[:user]]
  end
  
  def open 
    annotation = Annotation.find(params["id"])
    redirect_to :controller => :viewer, 
                    :annotation => annotation.name, 
                    :username => annotation.user.username
  end

  # upload callback
  def before_create_save(record)
    record.name = params[:record][:gff3_file].original_filename
    record.user_id = session[:user]
    record.gff3_data = params[:record][:gff3_file].read
  end
  
  ### ajax actions ###
  
  def file_access_control
    annotation = Annotation.find(params[:id])
    user = User.find(session[:user])
    # prevent others from modifying own data
    if annotation.user == user
      previously_public = annotation.public
      annotation.public = (params[:checked]=="public")
      if annotation.public
        user.increment(:public_annotations_count) unless previously_public        
      else # private
        user.decrement(:public_annotations_count) if previously_public
      end
      ActiveRecord::Base.transaction do 
        user.save
        annotation.save
      end
      render :inline => '', :status => 200
    else 
      render :inline => "Authorization Error. Are you logged in?", :status => 500
    end
  end  

  private
  
  def initialize
    @title = "My Annotations"
    super
  end
    
end
