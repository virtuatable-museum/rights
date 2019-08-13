# frozen_string_literal: true

module Decorators
  # Decorator for a right in the application, providing methods to format it.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Right < Draper::Decorator
    # Transforms the right in a usable hash, further transformed in JSON.
    # @return [Hash] the associative array representation of the right.
    def to_h
      {
        id: object.id.to_s,
        slug: object.slug,
        category: {
          id: object.category.id.to_s,
          slug: object.category.slug
        }
      }
    end
  end
end
