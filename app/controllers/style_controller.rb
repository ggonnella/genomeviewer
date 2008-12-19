#
# This controller is responsible for the user-specific style
# settings page.
#
# The login is enforced, as these settings have a
# meaning only if an user is logged in.
#
# It is actually only a "thin" controller with only 1 action (index)
# embedding two active scaffolds (feature_types and format) that
# have each its own controller
#
class StyleController < ApplicationController

  before_filter :enforce_login
  append_before_filter :title

  ### actions with a template ###

  #
  # style page, embedding feature_types and format active scaffolds
  #
  # see +FeatureTypesController+ and +FormatController+
  #
  def index
  end

private

  def title
    @title = "Style Settings"
  end

end