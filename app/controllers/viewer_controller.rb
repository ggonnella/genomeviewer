class ViewerController < ApplicationController

  before_filter :initialization
  
  def image
    filename = "#{@annotation.name}_" +
               "#{@sequence_region.seq_id}_" +
               "#{@start}_#{@end}.png"
    send_data GTServer.img(filename), :type => "image/png", 
              :disposition => "inline", :filename => filename
  end
  
  def overview
    filename = "#{@annotation.name}_" +
               "#{@sequence_region.seq_id}_" +
               "overview.png"
    send_data GTServer.img(filename), :type => "image/png", 
              :disposition => "inline", :filename => filename
  end

  ### actions with a template ###
  
  #
  # The main page, with the sequence region selector
  #
  def index
    # visualization parameters
    @title = @annotation.name
    prepare_for_rendering
  end

  ### actions for ajax ###

  def ajax_movement
    # @start and @end are currently the old ones
    # their new values must be calculated using params[:movement]
    movement = params[:movement].to_f / @width
    if (@start == @seq_begin and movement > 0) or
       (@end == @seq_end and movement < 0)
      @out_of_range = true
    else
      old_window = @end-@start+1
      @start -= (old_window*movement).round
      @start = @seq_begin if @start < @seq_begin
      @start = @end -1 if @start >= @end
      @end = @start + old_window
      if @end > @seq_end
        @end = @seq_end
        @start = @end - old_window
      end
      prepare_for_rendering
    end

  end

  def ajax_reloader
    prepare_for_rendering
    render :action => "ajax_movement.js.rjs"
  end

private

  def initialization
    @user = user_from_params
    @annotation = annotation_from_params
    @sequence_regions = @annotation.sequence_regions
    @own = (@annotation.user == @current_user)
    raise "Private annotations can be visualized only by their owners." unless
                                                     @own or @annotation.public
    @sequence_region = sequence_region_from_params
    @seq_begin = @sequence_region.seq_begin
    @seq_end   = @sequence_region.seq_end
    @start = viewport_start_from_params
    @end   = viewport_end_from_params
    @width = determine_width
    @annotation_ft_settings = @annotation.feature_type_in_annotations
    @ft_settings = determine_ft_settings
    @add_introns = determine_add_introns_flag    
  rescue => err
    flash[:errors] = err.to_s
    redirect_to(@current_user ? own_files_url : root_url)
  end
  
  def user_from_params
    username = params["username"]
    user = User.find_by_username(username)
    raise "No such user: #{username}" unless user
    return user
  end
  
  def annotation_from_params
    raise "No annotation specified." unless params["annotation"]
    conditions = {:name => params[:annotation], :user_id => @user.id}
    annotation = Annotation.first(:include => :sequence_regions,
                                  :conditions => conditions)
    # load the annotation, including its sequence regions
    raise "This annotation is not available." unless annotation
    return annotation
  end
  
  def sequence_region_from_params
    # the current sequence region
    # if none specified in the parameters, the first one is taken
    sequence_region = params[:seq_region] ?
          @sequence_regions.find_by_seq_id(params[:seq_region]) :
          @sequence_regions.first 
    # the following may happen if a false seq_id is encoded in the URL:
    raise "Sequence region not available for this annotation." unless
                                                               sequence_region
    return sequence_region
  end
  
  # where should the current view start? Determine the start point, when 
  # available using params[:start_point], and correct clear errors 
  # (i.e. start point >= end of the sequence or < start of the sequence).
  def viewport_start_from_params
    case 
    when !params[:start_pos]                  : @seq_begin
    when params[:start_pos].to_i < @seq_begin : @seq_begin
    when params[:start_pos].to_i >= @seq_end  : @seq_end - 1
    else
      params[:start_pos].to_i
    end
  end
  
  def viewport_end_from_params
    case 
    when !params[:end_pos]                  : @seq_end
    when params[:end_pos].to_i > @seq_end   : @seq_end
    when params[:end_pos].to_i < @start     : @start + 1
    else
      params[:end_pos].to_i
    end
  end
  
  # get width from the params, the session, the current user style or 
  # a default value if everything else fails
  def determine_width
    session[:width] = # save it also in the session for future reference
      case 
      when params[:width] : params[:width].to_i
      when session[:width] : session[:width]
      when @current_user : @current_user.style.width
      else
        900
      end
  end
  
  def determine_add_introns_flag
    # add introns mode on?
    if params[:add_introns]
      add_introns = (params[:add_introns]=="1")
    elsif session[:add_introns] and session[:add_introns].has_key?(@annotation.name)
      add_introns = session[:add_introns][@annotation.name]
    else
      add_introns = @annotation.add_introns
    end
    # save in the session the add intron setting
    session[:add_introns] ||= {}
    session[:add_introns][@annotation.name] = add_introns
    # save in the db if own annotation
    @annotation.update_attributes(:add_introns => add_introns) if @own
    return add_introns
  end
  
  ### prepare_for_rendering ###

  def prepare_for_rendering
    @overview_margins = 20
    overview_settings = 
      [
        ['bool', 'format', 'show_track_captions', false],
        ['bool', 'format', 'show_block_captions', false],
        ['bool', 'format', 'split_lines',         false],
        ['num',  'format', 'margins', @overview_margins],
        ['num',  'format', 'bar_height',          2    ],
        ['num',  'format', 'bar_vspace',          2    ],
        ['num',  'format', 'track_vspace',        2    ],
        ['num',  'format', 'scale_arrow_width',   3    ],
        ['num',  'format', 'scale_arrow_height',  3    ],
        ['num',  'format', 'arrow_width',         3    ]
      ]
      
    GTServer.generate( "#{@annotation.name}_" +
                      "#{@sequence_region.seq_id}_overview.png", 
                      @annotation.gff3_data_storage, 
                      @sequence_region.seq_id, 
                      @seq_begin..@seq_end,
                      style_obj,
                      @width,
                      @add_introns,
                      overview_settings + style_override,
                      false)
    
    @info = GTServer.generate("#{@annotation.name}_" +
                      "#{@sequence_region.seq_id}_#{@start}_#{@end}.png",
                      @annotation.gff3_data_storage, 
                      @sequence_region.seq_id, 
                      @start..@end,
                      style_obj,
                      @width,
                      @add_introns,
                      style_override, 
                      true)

    @total_lenght   = (@seq_end - @seq_begin + 1).to_f
    @current_lenght = (@end - @start + 1).to_f
    overview_net_width = @width - (@overview_margins * 2)
    @slice_width    = (@current_lenght / @total_lenght * 
                        overview_net_width).round
    @slice_left     = ((@start - @seq_begin + 1) / @total_lenght *
                       overview_net_width).round + @overview_margins - 1
                       # -1 is to accomodate the slice div 1px border
  end
  
  def style_obj
    @current_user ?
      # logged in: use the user style object
      @current_user.style.gt :
      # not logged in: use the style object of
      # the user to whom the annotation belongs
      @annotation.user.style.gt
  end
    
  def style_override
    output = []
    @ft_settings.each do |section, setting|
      output << ['num', section, 'max_show_width',      setting[:show]]
      output << ['num', section, 'max_capt_show_width', setting[:capt]]
    end
    return output
  end


  #
  # Determine the settings for the feature types visualization.
  #
  # The checkboxes "show?" determine if a given feature type is to be visualized. 
  # If not, it is hidden, using the setting max_show_width, putting its value to 0, 
  # otherwise it is shown (in the default case, putting the value of max_show_width
  # to nil). If a value is written in the "up to ... nt" text field, then the 
  # max_show_width parameter is set to that value. 
  #
  # The second checkbox "with caption?" determines if a caption is to be shown. 
  # If not, then a value of 0 is set for max_capt_show_width. If it is to be shown 
  # then that parameter is set to nil and or if a value is specified in the "up to ... nt"
  # text field, that value is used for the max_capt_show_width parameter. 
  #
  # The set parameters returned by this method are saved in the variable @ft_settings 
  # in the initialisation method and later used in the style_override method. 
  #
  def determine_ft_settings
    ft_settings = {}
    if params[:commit] ### settings form ###
      params[:ft].each do |ft_name, setting|
        ft_settings[ft_name] = {}
        if setting["show"] == "true"
          # nil means infinite, show at any width
          show = (Integer(setting["max_show_width"]) rescue nil)
          ft_settings[ft_name][:show] = show
          if setting["capt"] == "true"
            # again: nil means infinite, show at any width
            capt = (Integer(setting["max_capt_show_width"]) rescue nil)
            ft_settings[ft_name][:capt] = capt
          else
            ft_settings[ft_name][:capt] = 0
          end
        else
          ft_settings[ft_name][:show] = 0
          ft_settings[ft_name][:capt] = 0
        end
        if @own
          # save settings in the DB
          ft_id = FeatureType.find_by_name_and_style_id(ft_name, @current_user.style.id).id
          ft_in_a = @annotation_ft_settings.find_by_feature_type_id(ft_id)
          ft_in_a.max_show_width      = ft_settings[ft_name][:show]
          ft_in_a.max_capt_show_width = ft_settings[ft_name][:capt]
          ft_in_a.save
        end
      end
    elsif session[:ft_settings] and  ### session hash ###
            session[:ft_settings].
              fetch(@annotation.name,{}).
                fetch(@sequence_region.seq_id, false)
      ft_settings =
        session[:ft_settings][@annotation.name][@sequence_region.seq_id]
    else ### annotation default options ###
      @annotation_ft_settings.each do |setting|
        ft_settings[setting.feature_type.name] = {}
        ft_settings[setting.feature_type.name][:show] =
                                                setting.max_show_width
        ft_settings[setting.feature_type.name][:capt] =
                                           setting.max_capt_show_width
      end
    end
    # save settings in the session hash
    session[:ft_settings] ||= {}
    session[:ft_settings][@annotation.name] ||= {}
    session[:ft_settings][@annotation.name][@sequence_region.seq_id] =
                                                             ft_settings
    return ft_settings
  end

end
