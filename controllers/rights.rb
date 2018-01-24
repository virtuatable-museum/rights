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
  end
end