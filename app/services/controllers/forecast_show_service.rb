module Services
  module Controllers
    class ForecastShowService
      include Callable

      validates :city,   presence: true, if: -> { zip.blank? }
      validates :state,  presence: true, if: -> { zip.blank? }
      validates :street, presence: true
      validates :zip,    presence: true, if: -> { city.blank? || state.blank? }

      def execute
        context.result =
          Services::Forecasting::Report.call(
            city:   city,
            state:  state,
            street: street,
            zip:    zip
          )
      end
    end
  end
end

