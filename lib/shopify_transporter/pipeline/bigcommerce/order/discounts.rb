# frozen_string_literal: true
require 'shopify_transporter/pipeline/stage'
require 'shopify_transporter/shopify'

module ShopifyTransporter
  module Pipeline
    module Bigcommerce
      module Order
        class Discounts < Pipeline::Stage

          def convert(input, record)
            record.merge!(
              {
                discounts: discounts(input),
              }.stringify_keys
            )
          end

          private

            def discounts(input)
              input['Coupon Details'].to_s.split('|').map do |input_coupon|
                discount_line(input_coupon)
              end
            end

            def discount_line(input_coupon)
              parsed_coupon = parse_input_coupon(input_coupon)
              {
                code: parsed_coupon['Coupon Code'],
                amount: parsed_coupon['Coupon Value'],
                type: 'fixed_amount',
              }.stringify_keys
            end

            def parse_input_coupon(input_coupon)
              Hash[input_coupon.split(',').map do |pair|
                pair.split(':', 2).map(&:strip)
              end]
            end

        end
      end
    end
  end
end
