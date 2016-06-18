require "cthulhu/version"
require "cthulhu/uncrawlable_hierarchy"
require "cthulhu/scopper"
require "cthulhu/destroyer"
require "active_record"

module Cthulhu

  # Removes the object and all of its children by crawling through defined
  # associations.
  #
  # * +active_record_object+ - the record to be destroyed.
  # * +:blacklisted+ - models not to be destroyed. i.e. views that you are
  # using through active record.
  # * +:not_to_be_crawled+ - Association that should not be traveled. e.g.
  # 'Post-Comment' means crawling from Post to Comment model is forbidden.
  # * +:overrides+ - here you can override options of active record
  # associations. For example, you can set inverse_of or dependent: :nullify
  # without actually changing the association.
  def self.destroy! active_record_object,
    blacklisted: [],
    not_to_be_crawled: [],
    overrides: {}
    Destroyer.new(active_record_object, blacklisted, not_to_be_crawled, overrides).destroy!
  end

end
