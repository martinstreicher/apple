# frozen_string_literal: true

class Forecast
  extend ActiveModel::Naming

  attr_accessor :city, :state, :street, :zip

  def to_key
    ['forecast']
  end
end
