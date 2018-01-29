RSpec.describe Controllers::Rights do

  before do
    DatabaseCleaner.clean
  end

  let!(:group) { create(:group) }
  let!(:category) { create(:category) }
  let!(:account) { create(:account) }
  let!(:right) { create(:right, groups: [group], category: category) }
  let!(:application) { create(:application, creator: account) }
  let!(:gateway) { create(:gateway) }

  def app
    Controllers::Rights.new
  end

  describe 'GET /' do
    describe 'in the nominal case' do
      let!(:other_category) { create(:category, slug: 'other_category') }
      let!(:other_right) { create(:right, slug: 'another_random_right', groups: [], category: other_category) }

      before do
        get '/', {app_key: 'test_key', token: 'test_token'}
      end
      it 'gives the correct status code when obtaining a right' do
        expect(last_response.status).to be 200
      end
      describe 'response parameters' do
        let!(:body) { JSON.parse(last_response.body) }

        it 'Returns the right counts for the rights list' do
          expect(body['count']).to be 2
        end
        it 'Returns a hash having categories slugs as keys, and content of categories as values' do
          expect(body['items']).to eq([
            {
              'slug' => 'test_category',
              'count' => 1,
              'items' => [{'slug' => 'test_right', 'groups' => 1}]
            },
            {
              'slug' => 'other_category',
              'count' => 1,
              'items' => [{'slug' => 'another_random_right', 'groups' => 0}]
            }
          ])
        end
      end
    end
    describe 'bad request errors' do
      describe 'no token error' do
        before do
          get '/', {app_key: 'test_key'}
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the token of the gateway' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a gateway token' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no application key error' do
        before do
          get '/', {token: 'test_token'}
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the application key' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a application key' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
    end
    describe 'not_found errors' do
      describe 'application not found' do
        before do
          get '/', {token: 'test_token', app_key: 'another_key'}
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'application_not_found'})
        end
      end
      describe 'gateway not found' do
        before do
          get '/', {token: 'other_token', app_key: 'test_key'}
        end
        it 'Raises a not found (404) error when the gateway does\'nt exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'gateway_not_found'})
        end
      end
    end
  end
  describe 'POST /' do
    describe 'in the nominal case' do
      before do
        post '/', {app_key: 'test_key', token: 'test_token', slug: 'test_other_right', category_id: category.id.to_s}
      end
      it 'gives the correct status code when successfully creating a right' do
        expect(last_response.status).to be 201
      end
      it 'returns the correct body when the right is successfully created' do
        expect(JSON.parse(last_response.body)).to eq({'message' => 'created'})
      end
    end
    describe 'unprocessable entity errors' do
      describe 'already existing slug error' do
        before do
          post '/', {app_key: 'test_key', token: 'test_token', slug: 'test_right', category_id: category.id.to_s}
        end
        it 'gives the correct status code when creating a right with an already existing slug' do
          expect(last_response.status).to be 422
        end
        it 'returns the correct body when creating a right with an already existing slug' do
          expect(JSON.parse(last_response.body)).to eq({'errors' => ['right.slug.uniq']})
        end
      end
    end
    describe 'bad request errors' do
      describe 'slug not given error' do
        before do
          post '/', {app_key: 'test_key', token: 'test_token', category_id: category.id.to_s}
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the slug' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a slug' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'category not given error' do
        before do
          post '/', {app_key: 'test_key', token: 'test_token', slug: 'any_other_slug'}
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the category' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a category' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no token error' do
        before do
          post '/', {app_key: 'test_key'}.to_json
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the token of the gateway' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a gateway token' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no application key error' do
        before do
          post '/', {token: 'test_token'}.to_json
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the application key' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a application key' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
    end
    describe 'not_found errors' do
      describe 'application not found' do
        before do
          post '/', {token: 'test_token', app_key: 'another_key'}.to_json
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'application_not_found'})
        end
      end
      describe 'gateway not found' do
        before do
          post '/', {token: 'other_token', app_key: 'test_key'}.to_json
        end
        it 'Raises a not found (404) error when the gateway does\'nt exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'gateway_not_found'})
        end
      end
      describe 'category not found' do
        before do
          post '/', {token: 'test_token', app_key: 'test_key', slug: 'perfectly_correct_slug', category_id: '1'}.to_json
        end
        it 'Raises a not found (404) error when the gateway does\'nt exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'category_not_found'})
        end
      end
    end
  end
  describe 'DELETE /:id' do
    describe 'the nominal case' do
      before do
        delete "/#{right.id.to_s}", {app_key: 'test_key', token: 'test_token'}
      end
      it 'Returns a OK (200) status code when deleting a right' do
        expect(last_response.status).to be 200
      end
      it 'Returns the correct body when deleting a right' do
        expect(JSON.parse(last_response.body)).to eq({'message' => 'deleted'})
      end
      it 'Has deleted the right in the database' do
        expect(Arkaan::Permissions::Right.all.count).to be 0
      end
    end
    describe 'bad request errors' do
      describe 'no token error' do
        before do
          delete "#{right.id.to_s}", {app_key: 'test_key'}
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the token of the gateway' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a gateway token' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no application key error' do
        before do
          delete "#{right.id.to_s}", {token: 'test_token'}
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the application key' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a application key' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
    end
    describe 'not_found errors' do
      describe 'right not found' do
        before do
          delete "/anything", {token: 'test_token', app_key: 'test_key'}
        end
        it 'Raises a not found (404) error when the right doesn\'t exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the right doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'right_not_found'})
        end
      end
      describe 'application not found' do
        before do
          delete "/#{right.id.to_s}", {token: 'test_token', app_key: 'another_key'}
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'application_not_found'})
        end
      end
      describe 'gateway not found' do
        before do
          delete "/#{right.id.to_s}", {token: 'other_token', app_key: 'test_key'}
        end
        it 'Raises a not found (404) error when the gateway does\'nt exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'gateway_not_found'})
        end
      end
    end
  end
  describe 'POST /categories' do
    describe 'in the nominal case' do
      before do
        post '/categories', {app_key: 'test_key', token: 'test_token', slug: 'test_other_category'}
      end
      it 'gives the correct status code when successfully creating a right' do
        expect(last_response.status).to be 201
      end
      it 'returns the correct body when the right is successfully created' do
        expect(JSON.parse(last_response.body)).to eq({'message' => 'created'})
      end
    end
    describe 'bad request errors' do
      describe 'slug not given error' do
        before do
          post '/categories', {app_key: 'test_key', token: 'test_token'}
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the slug' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a slug' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no token error' do
        before do
          post '/categories', {app_key: 'test_key', slug: 'test_category_two'}.to_json
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the token of the gateway' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a gateway token' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
      describe 'no application key error' do
        before do
          post '/categories', {token: 'test_token', slug: 'test_category_two'}.to_json
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the application key' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a application key' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'bad_request'})
        end
      end
    end
    describe 'not_found errors' do
      describe 'application not found' do
        before do
          post '/categories', {token: 'test_token', app_key: 'another_key', slug: 'test_category_two'}.to_json
        end
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'application_not_found'})
        end
      end
      describe 'gateway not found' do
        before do
          post '/categories', {token: 'other_token', app_key: 'test_key', slug: 'test_category_two'}.to_json
        end
        it 'Raises a not found (404) error when the gateway does\'nt exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'gateway_not_found'})
        end
      end
    end
  end
end