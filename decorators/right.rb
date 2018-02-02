module Decorators
  # Decorator for a right in the application, providing methods to format a right.
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Right < Draper::Decorator
    # Transforms the right in a usable hash, further transformed in JSON.
    # @return [Hash] the associative array representation of the right.
    def to_h
      return {
        id: object.id.to_s,
        slug: object.slug,
        groups: object.groups.count
      }
    end
  end
end