module Spree
  class GiftCard < ActiveRecord::Base

   scope :admin_generated, -> { where(admin_generated: true) }

  end
end