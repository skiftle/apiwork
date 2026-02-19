# frozen_string_literal: true

class ApplicationContract < Apiwork::Contract::Base
  abstract!

  def hash(cool: false, ahh: true)
    object.hash
  end
end
