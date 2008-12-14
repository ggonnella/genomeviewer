$: << ENV['GTRUBY']
require 'gtruby'
require File.dirname(__FILE__)+"/parsing.rb"
require File.dirname(__FILE__)+"/style.rb"
require File.dirname(__FILE__)+"/output.rb"
require File.dirname(__FILE__)+"/get_hotspots.rb"

#
# The GTServer forwards requests from the GenomeViewer to the
# GenomeTools Ruby bindings GTRuby.
#
# Additionally it is responsible for caching
# feature_index, style structures and image maps
#
class GTServerClass

  #
  # GTServerClass.new initializes the GTServer, logging output on STDOUT
  # GTServerClass.new(nil) initializes in silent mode (no output logging)
  #
  def initialize(output_buffer = STDOUT)

    @buffer = output_buffer

    log('Initializing GT DRB server...', 0)

    cache_keys =
      [
      :on,  #feature_indeces, add_introns on
      :off, #feature_indeces, add_introns off
      :ft,  #feature_types
      :s,   #style objecs
      :img, #png images
      :map, #image maps of png images
      ]

    @cache = {}
    @mutex_on = {}
    cache_keys.each do |key|
      @cache[key]    = Hash.new
      @mutex_on[key] = Mutex.new
    end

  end

  def log(message, level = 1)
    return if @buffer.nil?
    prefix = level == 0 ? '' : "-"*level+" "
    message = prefix + message
    @buffer.puts(message)
    @buffer.flush
    return message
  end
  private :log

  def lock(cache, &block)
    @mutex_on[cache].synchronize(&block)
  end
  private :lock

  #
  # test the DRb connection
  #
  def test_call
    log    "tast_call() called"
    return "test_call() return value"
  end

  include Parsing
  include Style
  include Output

end
