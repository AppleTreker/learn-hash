module BSBar
  class << self
    attr_accessor :strings
  end
  @strings   = {
      :group_plain    => '<?members?>',
      :item_default   => %(<li<%= ' class="active"' if request.path=="<?route?>" %>> <a href="<?route?>"><?item_name?></a></li>),
      :group_dropdown => %(<li class="dropdown"><a href="#" class="dropdown-toggle" data-toggle="dropdown"><?group_name?><b class="caret"></b></a><ul class="dropdown-menu"><?members?></ul></li>),
      :bar_default    => %(<div class="navbar navbar-default navbar-fixed-top">
    <div class="container">
      <div class="navbar-header">
        <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#navbar_collapse">
          <span class="sr-only">Toggle navigation</span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
          <span class="icon-bar"></span>
        </button>
        <a class="navbar-brand" href="/"><?brand?></a>
      </div>
      <div class="collapse navbar-collapse" id="navbar_collapse" style="height: auto;">
        <ul class="nav navbar-nav">
          <?main_items?>
        </ul>
        <ul class="nav navbar-nav navbar-right">
          <?right_items?>
        </ul>
    </div>
  </div>
</div>) #main_items, right_items, brand
  }
  @instances = {}
  @bars      = {}
  @queue     = []

  class Bar
    attr_reader :type
    attr_reader :groups
    attr_reader :name

    def initialize(name, type)
      @name   = name
      @string = BSBar.string_for(type)
      @groups = {}
      BSBar.add_instance self
      BSBar.queue self
    end

    def add_group(role, group)
      @groups.merge!({role => BSBar.instance(group)})
      return self
    end

    def add_groups(groups)
      groups.each_pair do |key, value|
        self.add_group(key, value)
      end
      return self
    end

    def remove_group(key)
      @groups.delete(key)
    end

    def generate
      generated_groups = {}
      @groups.each_pair do |role, group|
        generated_groups[role] = group.generate
      end
      BSBar.parse(@string, generated_groups)
    end
  end

  class Group
    attr_reader :members
    attr_reader :name
    attr_accessor :type

    def initialize(name, type, display: nil)
      @display = display ? display : name.to_s.capitalize
      @name    = name
      @string  = BSBar.string_for(type)
      @members = []
      BSBar.add_instance self
    end

    def add(*items)
      items.each do |item|
        @members << BSBar.instance(item)
      end
      return self
    end

    def remove(item)
      @members.delete(item)
    end

    def generate
      members_out = ''
      @members.each do |member|
        members_out << member.generate
      end
      BSBar.parse(@string, :group_name => @display, :members => members_out)
    end
  end

  class Item
    attr_reader :route
    attr_reader :name
    attr_accessor :type

    def initialize(name, route, display: nil, type: :item_default, string: nil)
      @display = display ? display : name.capitalize
      @name    = name
      @route   = route
      @string  = string ? string : BSBar.string_for(type)
      BSBar.add_instance self
    end

    def add_to(*groups)
      groups.each do |group|
        group.add(self)
      end
      return self
    end

    def generate
      BSBar.parse(@string, :item_name => @display, :route => @route)
    end
  end


  def BSBar.generate
    @queue.each do |symbol|
      bar = BSBar.instance(symbol)
      @bars.merge!({bar.name => bar.generate})
    end
  end

  def BSBar.instance(key)
    if @instances.has_key?(key)
      return @instances[key]
    else
      raise "No instance with name `#{key}' exists"
    end
  end

  def BSBar.bar(bar)
    if @bars.has_key?(bar)
      @bars[bar]
    else
      raise "No bar with name `#{bar}' exists"
    end
  end

  def BSBar.set_string(name, pattern)
    BSBar.set_strings({name => pattern})
  end

  def BSBar.set_strings(keys)
    BSBar.strings.merge!(keys)
  end

  private

  def BSBar.string_for(key)
    if BSBar.strings.has_key?(key)
      return BSBar.strings[key].clone
    else
      raise TypeError, "Type #{key} is not a valid string", caller
    end
  end

  def BSBar.add_instance(instance)
    if @instances.has_key?(instance.name)
      raise "An instance with name `#{instance.name}' already exists"
    else
      @instances.merge!({instance.name => instance})
    end
  end

  def BSBar.queue(bar)
    @queue << bar.name
  end

  def BSBar.parse(string, values)
    values.each_pair do |key, value|
      string.gsub!(Regexp.new('<\?' + key.to_s + '\?>'), value.to_s)
    end
    return string
  end
end
