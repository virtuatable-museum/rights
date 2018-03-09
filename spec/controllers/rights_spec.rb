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

    it_should_behave_like 'a route', 'post', '/'

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
          expect(JSON.parse(last_response.body)).to eq({'message' => 'missing.slug'})
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
          expect(JSON.parse(last_response.body)).to eq({'message' => 'missing.category_id'})
        end
      end
    end
    describe 'not_found errors' do
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

    it_should_behave_like 'a route', 'post', '/right_id'

    describe 'not_found errors' do
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
end