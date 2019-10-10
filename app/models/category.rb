class Category < ApplicationRecord
  has_many :places, dependent: :destroy

  validates :name, presence: true,
    length: {
      maximum: Settings.category.max_length,
      minimum: Settings.category.min_length
    },
    uniqueness: {case_sensitive: false}

  before_validation :to_slug

  private

  def to_slug
    # strip the string
    ret = name.strip

    # blow away apostrophes
    ret.gsub!(/['`]/, "")

    # @ --> at, and & --> and
    ret.gsub!(/\s*@\s*/, " at ")
    ret.gsub!(/\s*&\s*/, " and ")

    # replace all non alphanumeric, underscore or periods with underscore
    ret.gsub!(/\s*[^A-Za-z0-9\.\-]\s*/, "_")

    # convert double underscores to single
    ret.gsub!(/_+/, "_")

    # strip off leading/trailing underscore
    ret.gsub!(/\A[_\.]+|[_\.]+\z/, "")

    ret
  end
end
