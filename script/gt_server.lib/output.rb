#
# parameters are assumed to be correct and 
# must be validated at higher level or can
# bring the gtserver to crash
#
module Output

  require "benchmark"

  #
  # this saves the resulting image under a key 
  # which can be used subsequently to fetch it
  #
  # parameters:
  # - key
  # - filename:        string
  # - seq_id:          string
  # - range:           a ruby Range object
  # - style_obj:       a GT::Style object
  # - width:           integer (width in pixel)
  # - add_introns:     boolean (activate add introns mode?)
  # - style_override:  an array of options that will override
  #                    the options in the style object
  #
  # each option in style_override is an array:
  #
  #     [gt_ruby_type, section, attribute, value]
  #
  # if value.nil? the attribute will be unset, otherwise set to
  # the given value
  #
  # gt_ruby_type is one of: bool, cstr, color, num
  #
  def generate(key, filename, seqid, range, style_obj, width, add_introns, 
             style_override, return_image_info)
    
    log "generating img/info #{key}"
    log filename, 2
    log "#{seqid}, #{range.inspect}", 2
    
    info = ""
    
    time = Benchmark.measure do
      style_copy = style_obj.clone
      style_override.each do |gt_ruby_type, section, attribute, value|
        if value.nil?
          style_copy.unset(section, attribute)
        else
          style_copy.send("set_#{gt_ruby_type}", section, attribute, value)
        end
      end
      mode = add_introns ? :on : :off
      fix = feature_index(filename, mode)
      gtrange = fix.get_range_for_seqid(seqid)
      gtrange.start = range.first
      gtrange.end   = range.last
      diagram = GT::Diagram.from_index(fix, seqid, gtrange, style_copy)
      info    = GT::ImageInfo.new
      layout  = GT::Layout.new(diagram, width, style_copy)
      canvas  = GT::CanvasCairoFile.new(style_copy, width, layout.get_height, info)
      layout.sketch(canvas)
      lock(:img) do
        @cache[:img][key] = canvas.to_stream
      end
    end
    log "done (%.4fs)" % time.real, 3
    return info if return_image_info
  end
  
  #
  # returns the image saved under the specified key or nil
  #
  def img(key, delete = true)
    log("image #{key}")
    lock(:img) do
      delete ? @cache[:img].delete(key) : @cache[:img].fetch(key, nil)
    end
  end
  
  #
  # is there a generated img for the key 'key'?
  #
  def img_exists?(key)
    lock(:img) do
      @cache[:img].has_key?(key)
    end
  end

end
