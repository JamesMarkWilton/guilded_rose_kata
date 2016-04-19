def update_quality(items)
  items.each do |item|
    update_item item
  end
end

def update_item(item)
  case item.name
  when 'Aged Brie'
    UpdateAgedBrie.new(item).call
  when 'Backstage passes to a TAFKAL80ETC concert'
    UpdateBackstagePass.new(item).call
  when 'Sulfuras, Hand of Ragnaros'
  when "NORMAL ITEM"
    UpdateNormal.new(item).call
  when "Conjured Mana Cake"
    UpdateManaCake.new(item).call
  else
    raise item.name
  end
end

class UpdateItem
  attr_reader :item, :max, :min, :sell_delta, :reg_delta, :expired_delta

  def call
    item.sell_in -= 1
    update_quality
  end

  def set_to_min
    item.quality = min
  end

  def set_to_max
    item.quality = max
  end

  def quality_above_max?
    max < item.quality
  end

  def quality_below_min?
    item.quality < min
  end

  def decrease_quality
    if expired?
      decrease_by(expired_delta)
    else
      decrease_by(reg_delta)
    end
  end

  def increase_quality
    if expired?
      increase_by(expired_delta)
    else
      increase_by(reg_delta)
    end
  end

  def check_quality_bounds
    set_to_max if quality_above_max?
    set_to_min if quality_below_min?
  end

  def expired?
    item.sell_in < 0
  end

  def increase_by(amount)
    item.quality += amount
  end

  def decrease_by(amount)
    item.quality -= amount
  end
end

class UpdateAgedBrie < UpdateItem
  def initialize(item)
    @item = item
    @sell_delta = 1
    @expired_delta = 2
    @reg_delta = 1
    @max = 50
    @min = 0
  end

  def update_quality
    increase_quality
    check_quality_bounds
  end
end

class UpdateBackstagePass < UpdateItem
  def initialize(item)
    @item = item
    @max = 50
    @min = 0
  end

  def update_quality
    if expired?
      set_to_min
    else
      check_how_close
      increase_quality
    end
    check_quality_bounds
  end

  def check_how_close
    if item.sell_in < 5
      @reg_delta = 3
    elsif item.sell_in < 10
      @reg_delta = 2
    else
     @reg_delta = 1
    end
  end
end

class UpdateManaCake < UpdateItem
  def initialize(item)
    @item = item
    @sell_delta = 1
    @expired_delta = 4
    @reg_delta = 2
    @max = 50
    @min = 0
  end

  def update_quality
    decrease_quality
    check_quality_bounds
  end
end

class UpdateNormal < UpdateItem
  def initialize(item)
    @item = item
    @sell_delta = 1
    @expired_delta = 2
    @reg_delta = 1
    @max = 50
    @min = 0
  end

  def update_quality
    decrease_quality
    check_quality_bounds
  end
end

# DO NOT CHANGE THINGS BELOW -----------------------------------------

Item = Struct.new(:name, :sell_in, :quality)

# We use the setup in the spec rather than the following for testing.
#
# Items = [
#   Item.new("+5 Dexterity Vest", 10, 20),
#   Item.new("Aged Brie", 2, 0),
#   Item.new("Elixir of the Mongoose", 5, 7),
#   Item.new("Sulfuras, Hand of Ragnaros", 0, 80),
#   Item.new("Backstage passes to a TAFKAL80ETC concert", 15, 20),
#   Item.new("Conjured Mana Cake", 3, 6),
# ]
