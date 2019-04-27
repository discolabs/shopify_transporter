# frozen_string_literal: true
require 'shopify_transporter/pipeline/stage'
require 'shopify_transporter/shopify'

require 'pry'

module ShopifyTransporter
  module Pipeline
    module Bigcommerce
      module Order
        class LineItems < Pipeline::Stage
          def convert(input, record)
            record.merge!(
              {
                line_items: line_items(input),
              }.stringify_keys
            )
          end

          private

            def line_items(input)
              input['Product Details'].split('|').map do |input_line_item|
                line_item(input_line_item)
              end
            end

            def line_item(input_line_item)
              parsed_line_item = parse_input_line_item(input_line_item)
              {
                quantity: parsed_line_item['Product Qty'].to_i,
                sku: parsed_line_item['Product SKU'],
                name: parsed_line_item['Product Name'],
                price: parsed_line_item['Product Unit Price']
              }.stringify_keys
            end

            def parse_input_line_item(input_line_item)
              Hash[input_line_item.split(',').map do |pair|
                pair.split(':', 2).map(&:strip)
              end]
            end

        end
      end
    end
  end
end
