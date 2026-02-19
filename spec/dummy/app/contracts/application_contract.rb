# frozen_string_literal: true

class ApplicationContract < Apiwork::Contract::Base
  abstract!

  def hash(ahh: true, cool: false)
    object.hash
  end
end
