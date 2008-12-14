#
# DRb can't serialize GTRuby Objects like GT::Color and GT::Style
# therefore only references to them are used in Genomeviewer, while
# the object instances themselves are created on the server.
#
module Style

  #
  # gtruby style object associated to
  # the given key or a new one if none cached
  #
  def style(key)
    st = nil
    lock(:s) do
      st = @cache[:s].fetch(key, nil)
    end
    if st
      log "style #{key} (cached)"
    else
      lock(:s) do
        @cache[:s][key] = style_new
        st = @cache[:s][key]
      end
      log "style #{key} (new)"
    end
    return st
  end

  #
  # a style object with
  # the default styleuration
  #
  def style_default
    lock(:s) do
      @cache[:s][:default] ||= style_new
    end
  end

  #
  # delete a style object from the cache
  # and return it (or nil if this did not exist)
  #
  def style_uncache(key)
    st = nil
    lock(:s) do
      st = @cache[:s].delete(key)
    end
    log st ?
      "style #{key} deleted" :
      "style #{key} not cached, not deleted"
    st
  end

  #
  # does the cache contain a style object for this key?
  #
  def style_cached?(key)
    lock(:s) do
      @cache[:s].has_key?(key)
    end
  end

  #
  # a new style object with settings from style/default.style
  #
  def style_new
    st = GT::Style.new
    style_file = File.expand_path("style/default.style",
                                  "#{File.dirname(__FILE__)}/../..")
    log "new style, trying to load #{style_file}", 2
    st.load_file style_file
    log "new style, default.style loaded", 2
    return st
  end

  #
  # a new color object
  #
  def color_new
    return GT::Color.malloc
  end

end
