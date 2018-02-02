module Controllers
  # Controller for the rights, mapped on /rights
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Rights < Arkaan::Utils::Controller
    declare_route 'get', '/' do
      categories = Decorators::Category.decorate_collection(Arkaan::Permissions::Category.all)
      halt 200, {count: Arkaan::Permissions::Right.all.count, items: categories.map(&:to_h)}.to_json
    end

    declare_route 'delete', '/:id' do
      right = Arkaan::Permissions::Right.where(id: params[:id]).first
      if right.nil?
        halt 404, {message: 'right_not_found'}.to_json
      else
        right.delete
        halt 200, {message: 'deleted'}.to_json
      end
    end

    declare_route 'delete', '/categories/:id' do
      category = Arkaan::Permissions::Category.where(id: params[:id]).first
      if category.nil?
        halt 404, {message: 'category_not_found'}.to_json
      else
        category.rights.delete_all if category.rights.any?
        category.delete
        halt 200, {message: 'deleted'}.to_json
      end

    end

    declare_route 'post', '/' do
      check_presence 'slug', 'category_id'
      if Arkaan::Permissions::Category.where(id: params['category_id']).first.nil?
        halt 404, {message: 'category_not_found'}.to_json
      else
        right = Arkaan::Permissions::Right.new(right_parameters)
        if right.save
          halt 201, {message: 'created'}.to_json
        else
          halt 422, {errors: right.errors.messages.values.flatten}.to_json
        end
      end
    end

    declare_route 'post', '/categories' do
      check_presence 'slug'
      category = Arkaan::Permissions::Category.new(category_parameters)
      if category.save
        halt 201, {message: 'created'}.to_json
      else
        halt 422, {errors: category.errors.messages.values.flatten}.to_json
      end
    end

    def right_parameters
      return params.select do |key, value|
        ['slug', 'category_id'].include?(key)
      end
    end

    def category_parameters
      return params.select do |key, value|
        ['slug'].include?(key)
      end
    end
  end
end