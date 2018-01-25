module Controllers
  # Controller for the rights, mapped on /rights
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Rights < Arkaan::Utils::Controller
    declare_route 'get', '/' do
      rights = Decorators::Right.decorate_collection(Arkaan::Permissions::Right.all)
      halt 200, {count: rights.count, items: rights.map(&:to_h)}.to_json
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

    declare_route 'post', '/' do
      check_presence('slug', 'category_id')
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

    def right_parameters
      return params.select do |key, value|
        ['slug', 'category_id'].include?(key)
      end
    end
  end
end