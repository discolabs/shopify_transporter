# frozen_string_literal: true
require 'shopify_transporter/pipeline/stage'
require 'shopify_transporter/shopify'

module ShopifyTransporter
  module Pipeline
    module Bigcommerce
      module Order
        class AddressesAttribute < Pipeline::Stage

          BILLING_PREFIX = 'Billing '
          SHIPPING_PREFIX = 'Shipping '

          def convert(input, record)
            record['billing_address'] = address_attributes(input, BILLING_PREFIX)
            record['shipping_address'] = address_attributes(input, SHIPPING_PREFIX)
            record
          end

          private

            def address_attributes(input, prefix)
              {
                first_name: address_attribute(input, prefix, 'First Name'),
                last_name: address_attribute(input, prefix, 'Last Name'),
                name: address_attribute(input, prefix, 'Name'),
                phone: address_attribute(input, prefix, 'Phone'),
                address1: address_attribute(input, prefix, 'Street 1'),
                address2: address_attribute(input, prefix, 'Street 2'),
                city: address_attribute(input, prefix, 'Suburb'),
                province_code: address_attribute(input, prefix, 'State Abbreviation'),
                zip: address_attribute(input, prefix, 'Zip'),
                country: address_attribute(input, prefix, 'Country'),
                company: address_attribute(input, prefix, 'Company'),
              }.compact.stringify_keys
            end

            def address_attribute(input, prefix, attribute)
              input["#{prefix}#{attribute}"]
            end

        end
      end
    end
  end
end
