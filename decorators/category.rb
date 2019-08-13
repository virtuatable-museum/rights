# frozen_string_literal: true

module Decorators
  # Decorator for a category, wrapping its rights.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Category < Draper::Decorator
    delegate_all

    def to_h
      {
        id: object.id.to_s,
        slug: object.slug,
        count: object.rights.count,
        items: items
      }
    end

    def items
      object.rights.map do |right|
        Decorators::Right.new(right).to_h
      end
    end
  end
end
