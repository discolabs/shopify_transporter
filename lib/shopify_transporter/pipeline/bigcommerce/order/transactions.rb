# frozen_string_literal: true
require 'shopify_transporter/pipeline/stage'
require 'shopify_transporter/shopify'
module ShopifyTransporter
  module Pipeline
    module Bigcommerce
      module Order
        class Transactions < Pipeline::Stage

          def convert(input, record)
            record.merge!(
              {
                transactions: transactions(input, record),
              }.stringify_keys
            )
          end

          private

            def transactions(input, record)
              [
                sale_transaction(input, record),
                refund_transaction(input),
              ].compact
            end

            def sale_transaction(input, record)
              return if financial_status_is_pending?(record)
              {
                amount: input['Order Total (inc tax)'].to_f,
                kind: 'sale',
                status: 'success',
              }.stringify_keys
            end

            def refund_transaction(input)
              return if input['Refund Amount'].to_f.zero?
              {
                amount: input['Refund Amount'].to_f,
                kind: 'refund',
                status: 'success',
              }.stringify_keys
            end

            def financial_status_is_pending?(record)
              record['financial_status'] == 'pending'
            end

        end
      end
    end
  end
end
