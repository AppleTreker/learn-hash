BSBar::Item.new(:brand, '/', string: 'Learn Ruby Hashes')

BSBar::Group.new(:public_main, :group_plain).add(:home, :concept, :game)

BSBar::Bar.new(:publicBar, :bar_default).add_groups({:main_items => :public_main, :brand => :brand})

BSBar.generate
