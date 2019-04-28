# frozen_string_literal: true
require 'shopify_transporter/pipeline/stage'
require 'shopify_transporter/shopify'

require 'bigdecimal'
require 'bigdecimal/util'

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
                line_item(input, input_line_item)
              end
            end

            def line_item(input, input_line_item)
              parsed_line_item = parse_input_line_item(input_line_item)
              {
                quantity: parsed_line_item['Product Qty'].to_i,
                sku: parsed_line_item['Product SKU'],
                name: parsed_line_item['Product Name'],
                price: parsed_line_item['Product Unit Price'],
                tax_lines: tax_lines(input, parsed_line_item)
              }.stringify_keys
            end

            def parse_input_line_item(input_line_item)
              Hash[input_line_item.split(',').map do |pair|
                pair.split(':', 2).map(&:strip)
              end]
            end

            def tax_lines(input, input_line_item)
              [
                {
                  title: 'Tax',
                  price: '%.2f' % (tax_percentage(input) * input_line_item['Product Total Price'].to_d).round(2),
                  rate: '%.2f' % tax_percentage(input),
                }.stringify_keys
              ]
            end

            def tax_percentage(input)
              return 0.to_d if input['Order Total (ex tax)'].to_d.zero?
              ((input['Order Total (inc tax)'].to_d - input['Order Total (ex tax)'].to_d) / input['Order Total (ex tax)'].to_d).round(2)
            end

        end
      end
    end
  end
end
