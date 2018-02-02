module Decorators
  class Category < Draper::Decorator
    delegate_all

    def to_h
      return {
        id: object.id.to_s,
        slug: object.slug,
        count: object.rights.count,
        items: items
      }
    end

    def items
      return object.rights.map do |right|
        Decorators::Right.new(right).to_h
      end
    end
  end
end