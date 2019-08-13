# frozen_string_literal: true

module Controllers
  # Controller for the rights, mapped on /rights
  # @author Vincent Courtois <courtois.vincent@outlook.com>
  class Rights < Arkaan::Utils::Controllers::Checked
    load_errors_from __FILE__

    declare_status_route

    declare_route 'delete', '/:id' do
      right = Arkaan::Permissions::Right.where(id: params[:id]).first
      if right.nil?
        custom_error(404, 'deletion.right_id.unknown')
      else
        right.delete
        halt 200, { message: 'deleted' }.to_json
      end
    end

    declare_route 'post', '/' do
      check_presence 'slug', 'category_id', route: 'creation'
      category_id = params['category_id']
      if Arkaan::Permissions::Category.where(id: category_id).first.nil?
        custom_error(404, 'creation.category_id.unknown')
      else
        right = Arkaan::Permissions::Right.new(right_parameters)
        if right.save
          item = Decorators::Right.new(right).to_h
          halt 201, { message: 'created', item: item }.to_json
        else
          model_error(right, 'creation')
        end
      end
    end

    def right_parameters
      params.select do |key, _|
        %w[slug category_id].include?(key)
      end
    end
  end
end
