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
                  price: input['Shipping Cost (inc tax)'].to_f + input['Handling Cost (inc tax)'].to_f
                }.stringify_keys,
              ]
            end

            def shipping_method_code(input)
              input['Ship Method'].downcase.gsub(/[^a-zA-Z0-9]/, '_')
            end

        end
      end
    end
  end
end
