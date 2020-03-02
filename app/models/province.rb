class Province < ApplicationRecord
  has_many :places, dependent: :destroy
  has_many :shippers, dependent: :destroy
  has_many :child_provinces, class_name: Province.name,
    foreign_key: :parent_id, dependent: :destroy

  validates :name, presence: true, uniqueness: {case_sensitive: false}

  scope :parent_only, ->(parent_id){where parent_id: parent_id}

  attr_accessor :key_name, :count_place

  def to_slug_province name
    name = name.tr("àáạảãâầấậẩẫăằắặẳẵÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴåèéẹẻẽêềếệểễÈÉẸẺẼÊỀẾỆỂỄëìíịỉĩÌÍỊỈĨîòóọỏõôồốộổỗơờớợởỡÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠøùúụủũưừứựửữÙÚỤỦŨƯỪỨỰỬỮůûỳýỵỷỹỲÝỴỶỸđĐ",
      "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeeeeeeeeiiiiiiiiiiiooooooooooooooooooooooooooooooooooouuuuuuuuuuuuuuuuuuuuuuuuyyyyyyyyyydd")
    name.parameterize.truncate(80, omission: "")
  end
end
