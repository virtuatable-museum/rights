module Controllers
  # Controller for the rights, mapped on /rights
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Rights < Arkaan::Utils::Controller

    load_errors_from __FILE__

    declare_route 'delete', '/:id' do
      right = Arkaan::Permissions::Right.where(id: params[:id]).first
      if right.nil?
        custom_error(404, 'deletion.right_id.unknown')
      else
        right.delete
        halt 200, {message: 'deleted'}.to_json
      end
    end

    declare_route 'post', '/' do
      check_presence 'slug', 'category_id', route: 'creation'
      if Arkaan::Permissions::Category.where(id: params['category_id']).first.nil?
        custom_error(404, 'creation.category_id.unknown')
      else
        right = Arkaan::Permissions::Right.new(right_parameters)
        if right.save
          halt 201, {message: 'created', item: Decorators::Right.new(right).to_h}.to_json
        else
          model_error(right, 'creation')
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