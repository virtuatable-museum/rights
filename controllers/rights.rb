module Controllers
  # Controller for the rights, mapped on /rights
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Rights < Arkaan::Utils::Controller

      @@docs = {
        'uniq' => 'https://github.com/jdr-tools/rights/wiki/Creation-of-a-right#slug-already-used',
        'pattern' => 'https://github.com/jdr-tools/rights/wiki/Creation-of-a-right#slug-in-a-wrong-format',
        'minlength' => 'https://github.com/jdr-tools/rights/wiki/Creation-of-a-right#slug-too-short'
      }

    declare_route 'delete', '/:id' do
      right = Arkaan::Permissions::Right.where(id: params[:id]).first
      if right.nil?
        url = 'https://github.com/jdr-tools/rights/wiki/Deletion-of-a-right#right-id-not-found'
        halt 404, {status: 404, field: 'right_id', error: 'unknown', docs: url}.to_json
      else
        right.delete
        halt 200, {message: 'deleted'}.to_json
      end
    end

    declare_route 'post', '/' do
      check_presence 'slug', 'category_id'
      if Arkaan::Permissions::Category.where(id: params['category_id']).first.nil?
        url = 'https://github.com/jdr-tools/rights/wiki/Creation-of-a-right#category-id-not-found'
        halt 404, {status: 404, field: 'category_id', error: 'unknown', docs: url}.to_json
      else
        right = Arkaan::Permissions::Right.new(right_parameters)
        if right.save
          halt 201, {message: 'created', item: Decorators::Right.new(right).to_h}.to_json
        else
          error_key = right.errors.messages.keys.first
          error = right.errors.messages[error_key].first
          halt 400, {status: 400, field: error_key, error: error, docs: @@docs[error]}.to_json
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