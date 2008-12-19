class Style < ActiveRecord::Base

  belongs_to :user
  has_many :feature_types, :dependent => :destroy
  has_one  :format, :dependent => :destroy

  def section_objects
    [format]+feature_types
  end

  def sections
    section_objects.map(&:section)
  end

  after_save       :make_sure_there_is_a_format
  after_create     :uncache

  def make_sure_there_is_a_format
    unless format(true)
     f = Format.default_new(:style_id => self[:id])
     f.save
     format(true) # update the cache
    end
  end

  # reference to the GT::Style object
  # corresponding to this object
  #
  # if there is no cache, upload all setting
  # from the DB into the gt config object
  # but allow an exception to avoid circular
  # references
  #
  def gt(upload_exception_section = nil, upload_exception_attr = nil)
    if !GTServer.style_cached?(self[:id])
      GTServer.style(self[:id])
      section_objects.each do |x|
        if x.section == upload_exception_section
          x.upload_except(upload_exception_attr)
        else
          x.upload
        end
      end
    end
    GTServer.style(self[:id])
  end

  def uncache
    GTServer.style_uncache(self[:id])
  end

  def self.default
    GTServer.style_default
  end

end
