module RedmineWatchersGroups
  module GroupPatch

    CSS_CLASS_BY_STATUS = {
      0 => '',
      1 => 'active',
      2 => 'inactive'
    }

    def active?
      self.status == Group::STATUS_ACTIVE
    end

    def css_classes
      "group #{CSS_CLASS_BY_STATUS[status]}"
    end

  end
end