#
# This class defines a color through its RGB & alpha components.
# It is used as aggregation for data saved as three separate
# floats in the database. 
#
class Color

  Channels = [:red, :green, :blue, :alpha]
  attr_reader *Channels

  def initialize(red, green, blue, alpha = 1.0)
    begin
      @red   = Float(red)
      @green = Float(green)
      @blue  = Float(blue)
      @alpha = Float(alpha)
    rescue
      @red = @green = @blue = @alpha = nil
    else
      raise RangeError, "Channel value out of range 0..1"\
        unless [@red, @green, @blue, @alpha].all? {|ch| (0..1).include?(ch)}
    end
  end

  def ==(other)
    Channels.all? do |ch|
      return nil unless other.respond_to?(ch)
      send(ch)==other.send(ch)
    end
  end

  # returns a reference to a gt ruby
  # color object with the same colors
  def to_gt
    color = GTServer.color_new
    color.red   = @red
    color.green = @green
    color.blue  = @blue
    color.alpha = @alpha
    return color
  end

  # return the corresponding 24 (or 32) bit hexadecimal color code string
  def to_hex(alpha = false)
    return "undefined" if undefined?
    collection = alpha ? Channels : Channels-[:alpha]
    "#"+collection.map{|c| sprintf("%02X",(send(c) * 255).round)}.join
  end
  alias_method :to_s, :to_hex

  def undefined?
    [@red, @green, @blue, @alpha].any?(&:nil?)
  end

  def self.undefined
    new(nil, nil, nil, nil)
  end

  Kernel.module_eval do
    #
    # Return a new Color based on an object.
    # Raises an exception if the object does not provide the
    # proper methods (alpha is not mandatory).
    #
    def Color(x)
      return Color.undefined if x.nil?
      begin
        if x.respond_to? :alpha
          Color.new(*(Color::Channels.map{|c| x.send(c)}))
        else
          Color.new(*((Color::Channels-[:alpha]).map{|c| x.send(c)}))
        end
      rescue
        raise ArgumentError, "invalid value for Color: #{x.inspect}"
      end
    end
  end

  String.class_eval do

    # Convert a string containing a valid 24 bit hex code 
    # (or 32 bit with alpha channel)
    # in an instance of the Color class.
    # Anything invalid returns the undefinite color.
    def to_color
      m = match(/^#([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})$/)
      if m
        Color.new(*[m[1],m[2],m[3]].map{|x|x.to_i(16)/255.0})
      else
        m = match(/^#([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})([0-9A-Fa-f]{2})$/)
        if m 
          Color.new(*[m[1],m[2],m[3],m[4]].map{|x|x.to_i(16)/255.0})
        else
          Color.undefined
        end
      end
    end
    
  end

end
