# frozen_string_literal: true
require 'shopify_transporter/pipeline/stage'
require 'shopify_transporter/shopify'

module ShopifyTransporter
  module Pipeline
    module Bigcommerce
      module Order
        class ShippingLines < Pipeline::Stage

          def convert(input, record)
            record.merge!(
              {
                shipping_lines: shipping_lines(input),
              }.stringify_keys
            )
          end

          private

            def shipping_lines(input)
              [
                {
                  code: shipping_method_code(input),
                  title: input['Ship Method'],
                  price: input['Shipping Cost (inc tax)'].to_f + input['Handling Cost (inc tax)'].to_f,
                  tax_lines: tax_lines(input)
                }.stringify_keys,
              ]
            end

            def shipping_method_code(input)
              input['Ship Method'].downcase.gsub(/[^a-zA-Z0-9]/, '_')
            end

            def tax_lines(input)
              [
                {
                  title: 'Tax',
                  price: shipping_tax_total(input),
                  rate: tax_percentage(input),
                }.stringify_keys
              ]
            end

            def shipping_tax_total(input)
              input['Shipping Cost (inc tax)'].to_f - input['Shipping Cost (ex tax)'].to_f
            end

            def tax_percentage(input)
              return 0.0 if input['Order Total (ex tax)'].to_f.zero?
              (input['Order Total (inc tax)'].to_f - input['Order Total (ex tax)'].to_f) / input['Order Total (ex tax)'].to_f
            end

        end
      end
    end
  end
end
