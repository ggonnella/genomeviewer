class ViewerController < ApplicationController

  before_filter :initialization, :except => "image"
  
  ### image ###

  def image
    send_data GTServer.img(@annotation.gff3_data_storage, 
                         @sequence_region.seq_id, 
                         @start..@end,
                         style_obj,
                         @width,
                         @add_introns,
                         style_override),
              :type => "image/png",
              :disposition => "inline",
              :filename => "#{@annotation.name}_#{@sequence_region.seq_id}_#@start_#@end.png"
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

  #
  # - check that the parameters are valid:
  #   - the annotation must be specified and be valid 
  #   - the annotation must be own or public 
  #   - the sequence region must be valid if specified
  #
  # - load the relevant data into the following instance variables
  #   that are used by the view templates:
  #   - @annotation
  #   - @sequence_region
  #   - @own (is the annotation one of the owns?)
  #   - @sequence_regions (list of all sequence regions of the annotation)
  #   - @width (width of the displayed image)
  #   - @seq_begin (begin of the whole sequence region)
  #   - @seq_end (end of the whole sequence region)
  #   - @start (begin of the current view)
  #   - @end (end of the current view)
  #   - @annotation_ft_settings (DB ft settings for this annotation)
  #   - @ft_settings
  #   - @add_introns (boolean value; add introns?)
  #  
  # - save settings in the database for logged in users showing own annotations
  #   (ft_settings, add_introns)
  #
  def initialization
    # an annotation must be specified in the parameters, otherwise 
    # nothing can be visualized:
    raise "No annotation specified!" unless params[:annotation]
    # load the annotation, including its sequence regions
    @annotation = Annotation.first(:include => :sequence_regions,
                                   :conditions =>
                                   {:name => params[:annotation],
                                    :user_id => User.
                                          find_by_username(params[:username])})
    raise "This annotation is not available." unless @annotation
    # check permission
    @own = (@annotation.user == @current_user)
    raise "Private annotations can be visualized only by their owners." unless
                                                     @own or @annotation.public
    # shortcut for the sequence regions collection:
    @sequence_regions = @annotation.sequence_regions
    # the current sequence region
    # if none specified in the parameters, the first one is taken
    @sequence_region = params[:seq_region] ?
          @sequence_regions.find_by_seq_id(params[:seq_region]) :
          @sequence_regions.first 
    # the following may happen only if the seq id is specified in the params:
    raise "Sequence region not available for this annotation." unless
                                                               @sequence_region
    # shortcuts for the begin and end of the sequence region
    @seq_begin = @sequence_region.seq_begin
    @seq_end = @sequence_region.seq_end
    # where should the current view start? Determine the start point, when 
    # available using params[:start_point], and correct clear errors 
    # (i.e. start point >= end of the sequence or < start of the sequence).
    @start = 
      case 
      when !params[:start_pos] : @seq_begin
      when params[:start_pos].to_i < @seq_begin : @seq_begin
      when params[:start_pos].to_i >= @seq_end : @seq_end - 1
      else
        params[:start_pos].to_i
      end
    # the same for the current view endpoint:
    @end = 
      case 
      when !params[:end_pos] : @seq_end
      when params[:end_pos].to_i > @seq_end : @seq_end
      when params[:end_pos].to_i < @seq_begin : @seq_begin + 1
      else
        params[:end_pos].to_i
      end
      
    # get width from the params, the session, the current user style or 
    # a default value if everything else fails
    @width = 
      case 
      when params[:width] : params[:width].to_i
      when session[:width] : session[:width]
      when @current_user : @current_user.style.width
      else
        900
      end
    # save it in the session   
    session[:width] = @width
    
    # shortcut for the feature type settings saved for this annotation:
    @annotation_ft_settings = @annotation.feature_type_in_annotations
    
    # get the ft settings specified in the settings form
    @ft_settings = {}
    if params[:commit] ### settings form ###
      params[:ft].each do |ft_name, setting|
        @ft_settings[ft_name] = {}
        ft_id = FeatureType.find_by_name(ft_name).id
        unless setting[:show]
          @ft_settings[ft_name][:show] = 0
          @ft_settings[ft_name][:capt] = 0
        else
          # nil means infinite, show at any width
          show = (Integer(setting[:max_show_width]) rescue nil)
          @ft_settings[ft_name][:show] = show
          unless setting[:capt]
            @ft_settings[ft_name][:capt] = 0
          else
            # again: nil means infinite, show at any width
            capt = (Integer(setting[:max_capt_show_width]) rescue nil)
            @ft_settings[ft_name][:capt] = capt
          end
        end
        if @own
          # save settings in the DB
          ft_in_a = @annotation_ft_settings.find_by_feature_type_id(ft_id)
          ft_in_a.max_show_width      = @ft_settings[ft_name][:show]
          ft_in_a.max_capt_show_width = @ft_settings[ft_name][:capt]
          ft_in_a.save
        end
      end
    elsif session[:ft_settings] and  ### session hash ###
            session[:ft_settings].
              fetch(@annotation.name,{}).
                fetch(@sequence_region.seq_id, false)
      @ft_settings =
        session[:ft_settings][@annotation.name][@sequence_region.seq_id]
    else ### annotation default options ###
      @annotation_ft_settings.each do |setting|
        @ft_settings[setting.feature_type.name] = {}
        @ft_settings[setting.feature_type.name][:show] =
                                                setting.max_show_width
        @ft_settings[setting.feature_type.name][:capt] =
                                           setting.max_capt_show_width
      end
    end
    # save settings in the session hash
    session[:ft_settings] ||= {}
    session[:ft_settings][@annotation.name] ||= {}
    session[:ft_settings][@annotation.name][@sequence_region.seq_id] =
                                                             @ft_settings
    # add introns mode on?
    if params[:add_introns]
      @add_introns = (params[:add_introns]=="1")
    elsif session[:add_introns] and session[:add_introns][@annotation.name]
      @add_introns = session[:add_introns][@annotation.name]
    else
      @add_introns = @annotation.add_introns
    end
    # save in the session the add intron setting
    session[:add_introns] ||= {}
    session[:add_introns][@annotation.name] = @add_introns
    # save in the db if own annotation
    @annotation.update_attributes(:add_introns => @add_introns) if @own
  rescue => err
    flash[:errors] = err.to_s
    redirect_to(@current_user ? own_files_url : root_url)
  end
  
  ### prepare_for_rendering ###

  def prepare_for_rendering
    # overview
    GTServer.img_and_map_generate(@annotation.gff3_data_storage, 
                                  @sequence_region.seq_id, 
                                  @seq_begin..@seq_end,
                                  style_obj,
                                  @width,
                                  @add_introns,
                                  style_override + overview_settings)
    prepare_measures
    # main image
    GTServer.img_and_map_generate(@annotation.gff3_data_storage, 
                                  @sequence_region.seq_id, 
                                  @start..@end,
                                  style_obj,
                                  @width,
                                  @add_introns,
                                  style_override)
    @info = GTServer.map(@annotation.gff3_data_storage, 
                         @sequence_region.seq_id, 
                         @start..@end,
                         style_obj,
                         @width,
                         @add_introns,
                         style_override)
  end
  
  def overview_settings
    @overview_margins = 20
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
  end

  def prepare_measures
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
    output
    @ft_settings.each do |section, setting|
      output << ['num', section, 'max_show_width',      setting[:show]]
      output << ['num', section, 'max_capt_show_width', setting[:capt]]
    end
    return output
  end

end
