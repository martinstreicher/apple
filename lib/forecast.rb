# frozen_string_literal: true

class Forecast
  include ActiveModel::Model

  attr_accessor :city, :state, :street, :zip
end
