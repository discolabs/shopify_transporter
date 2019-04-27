# frozen_string_literal: true
require 'shopify_transporter/pipeline/stage'
require 'shopify_transporter/shopify'

module ShopifyTransporter
  module Pipeline
    module Bigcommerce
      module Order
        class TopLevelAttributes < Pipeline::Stage
          def convert(hash, record)
            record.merge!(
              {
                name: hash['Order ID'],
                email: hash['Customer Email'],
                currency: hash['Order Currency Code'],
                cancelled_at: cancelled_at(hash),
                closed_at: closed_at(hash),
                processed_at: processed_at(hash),
                subtotal_price: hash['Subtotal (inc tax)'],
                total_tax: hash['Tax Total'],
                total_price: hash['Order Total (inc tax)'],
                source_name: ORDER_ORIGINATED_FROM,
                total_weight: hash['Combined Product Weight'],
                financial_status: financial_status(hash),
                fulfillment_status: fulfillment_status(hash),
              }.stringify_keys
            )
            customer = build_customer(hash)
            record['customer'] = customer unless customer.empty?
            record
          end

          private

            ORDER_ORIGINATED_FROM = 'BigCommerce'

            ORDER_TIMEZONE_OFFSET = ENV['ORDER_TIMEZONE_OFFSET'] || '+00:00'

            CANCELLED_ORDER_STATUSES = ['Cancelled']
            COMPLETED_ORDER_STATUSES = ['Completed', 'Shipped']

            PAID_ORDER_STATUSES = ['Completed', 'Shipped', 'Awaiting Fulfillment']
            PARTIALLY_PAID_ORDER_STATUSES = []
            PARTIALLY_REFUNDED_ORDER_STATUSES = ['Partially Refunded']
            REFUNDED_ORDER_STATUSES = ['Refunded', 'Cancelled']

            def build_customer(hash)
              {
                email: hash['Customer Email'],
                first_name: hash['Billing First Name'],
                last_name: hash['Billing Last Name'],
              }.stringify_keys
            end

            def financial_status(hash)
              if paid?(hash)
                'paid'
              elsif partially_paid?(hash)
                'partially_paid'
              elsif partially_refunded?(hash)
                'partially_refunded'
              elsif refunded?(hash)
                'refunded'
              else
                'pending'
              end
            end

            def fulfillment_status(hash)
              total_qty_ordered = hash['Total Quantity'].to_i
              total_qty_shipped = hash['Total Shipped'].to_i
              status = nil

              if total_qty_shipped == total_qty_ordered
                status = 'fulfilled'
              elsif total_qty_shipped > 0 && total_qty_shipped < total_qty_ordered
                status = 'partial'
              end
              status
            end

            def cancelled_at(hash)
              processed_at(hash) if cancelled?(hash)
            end

            def closed_at(hash)
              processed_at(hash) if closed?(hash)
            end

            def processed_at(hash)
              DateTime.strptime("#{hash['Order Date']} #{hash['Order Time']}#{ORDER_TIMEZONE_OFFSET}", "%m/%d/%Y %H:%M:%S%z")
            end

            def cancelled?(hash)
              CANCELLED_ORDER_STATUSES.include?(hash['Order Status'])
            end

            def closed?(hash)
              COMPLETED_ORDER_STATUSES.include?(hash['Order Status'])
            end

            def paid?(hash)
              PAID_ORDER_STATUSES.include?(hash['Order Status'])
            end

            def partially_paid?(hash)
              PARTIALLY_PAID_ORDER_STATUSES.include?(hash['Order Status'])
            end

            def partially_refunded?(hash)
              PARTIALLY_REFUNDED_ORDER_STATUSES.include?(hash['Order Status'])
            end

            def refunded?(hash)
              REFUNDED_ORDER_STATUSES.include?(hash['Order Status'])
            end

        end
      end
    end
  end
end
