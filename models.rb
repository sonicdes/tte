require './db'
DB = DBConnection.new.connect

class Order < Sequel::Model
  # plugin :tactical_eager_loading
  many_to_one :delivery_method
  many_to_many :payments

  def check_paid
    return false if new?
    paid_amount >= total_with_shipping
  end

  def paid_amount
    payments_dataset.sum(:income).to_f
  end

  def check_enabled
    paid || payment_method == "cash"
  end

  def total_sum
    items.map {|i| i["price"].to_i*i['quantity'].to_f }.sum.ceil(2)
  end

  def total_with_shipping
    total_sum + shipping
  end

  def shipping
    total_sum >= 1500 ? 0 : delivery_method&.cost.to_i
  end

  def delivery_hours
    h = delivery_time.hour
    return if h == 0
    "#{h}:00 - #{h+2}:00"
  end

  def meat_order?
    items.any? { |i| Order.meat_item? i }
  end

  def meat_item?(item)
    Order.meat_item? item
  end

  def self.meat_item?(item)
    !!item['list'].to_s[/^мяс/i]
  end

  dataset_module do
    def stats
      orders = all
      total = sum(:sum).to_f
      total_paid_online = Payment.where(orders: self).sum(:income).to_f
      {
        count: count,
        sum: orders.map(&:total_sum).sum,
        shipping_sum: orders.map(&:shipping).sum,
        online_payment: total_paid_online,
        courier_payment: total-total_paid_online
      }
    end

    def by_month(date = Date.today)
      where{ Sequel[:delivery_time].extract(:year) =~ date.year }
      .where{ Sequel[:delivery_time].extract(:month) =~ date.month }
    end
  end
end

class Payment < Sequel::Model
  many_to_many :orders
end

class DeliveryMethod < Sequel::Model
  one_to_many :orders
end

class User < Sequel::Model
  many_to_one :orders
end
