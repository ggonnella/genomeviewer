class BlockStyle

  DefinedBlockStyles =
    {
      1 => "box",
      2 => "caret",
      3 => "dashes",
      4 => "line"
    }

  def initialize(key)
    @key = ([1,2,3,4].include?(key.to_i) ? key.to_i : nil)
  end

  attr_reader :key

  def string
    DefinedBlockStyles.fetch(key, "undefined")
  end

  alias_method :to_s, :string

  def ==(other)
    return nil unless other.respond_to?(:key)
    @key == other.key
  end

  def self.undefined
    new(nil)
  end

  def undefined?
    @key.nil?
  end

  String.class_eval do

    def to_block_style
      BlockStyle.new(BlockStyle::DefinedBlockStyles.index(self))
    end

  end

end
