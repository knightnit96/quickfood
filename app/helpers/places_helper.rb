module PlacesHelper
  def load_list_child_classify_category classify_category_id
    ClassifyCategory.parent_only classify_category_id
  end

  def by_category_name category_id
    Category.find_by(id: category_id).name
  end

  def by_province_name province_id
    Province.find_by(id: province_id).name
  end

  def to_slug_province name
    name = name.tr("àáạảãâầấậẩẫăằắặẳẵÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴåèéẹẻẽêềếệểễÈÉẸẺẼÊỀẾỆỂỄëìíịỉĩÌÍỊỈĨîòóọỏõôồốộổỗơờớợởỡÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠøùúụủũưừứựửữÙÚỤỦŨƯỪỨỰỬỮůûỳýỵỷỹỲÝỴỶỸđĐ",
      "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaeeeeeeeeeeeeeeeeeeeeeeeiiiiiiiiiiiooooooooooooooooooooooooooooooooooouuuuuuuuuuuuuuuuuuuuuuuuyyyyyyyyyydd")
    name.parameterize.truncate(80, omission: "")
  end

  def overall place
    @overall = place.rates.average(:rating) if place.present?
    @overall = 0 if @overall.blank?
  end
end
