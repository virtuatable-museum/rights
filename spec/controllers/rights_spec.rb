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
        post '/rights', {app_key: 'test_key', token: 'test_token', slug: 'test_other_right', category_id: category.id.to_s}
      end
      it 'gives the correct status code when successfully creating a right' do
        expect(last_response.status).to be 201
      end
      it 'returns the correct body when the right is successfully created' do
        expect(JSON.parse(last_response.body)).to eq({
          'message' => 'created',
          'item' => {
            'id' => Arkaan::Permissions::Right.order_by(created_at: :desc).first.id.to_s,
            'slug' => 'test_other_right',
            'category' => {
              'id' => category.id.to_s,
              'slug' => 'test_category'
            }
          }
        })
      end
    end

    it_should_behave_like 'a route', 'post', '/rights'

    describe 'bad request errors' do
      describe 'slug not given error' do
        before do
          post '/rights', {app_key: 'test_key', token: 'test_token', category_id: category.id.to_s}
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the slug' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a slug' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'slug',
            'error' => 'required',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Rights-API#slug-not-given'
          })
        end
      end
      describe 'slug too short error' do
        before do
          post '/rights', {app_key: 'test_key', token: 'test_token', slug: 'a', category_id: category.id.to_s}
        end
        it 'Raises a bad request (400) error when the given slug is less than four characters' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the slug is too short' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'slug',
            'error' => 'minlength',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Rights-API#slug-too-short'
          })
        end
      end
      describe 'slug in a wrong format error' do
        before do
          post '/rights', {app_key: 'test_key', token: 'test_token', slug: 'wrongFormatSlug', category_id: category.id.to_s}
        end
        it 'Raises a bad request (400) error when the given slug has a wrong format' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the slug has the wrong format' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'slug',
            'error' => 'pattern',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Rights-API#slug-with-wrong-format'
          })
        end
      end
      describe 'already existing slug error' do
        before do
          post '/rights', {app_key: 'test_key', token: 'test_token', slug: 'test_right', category_id: category.id.to_s}
        end
        it 'gives the correct status code when creating a right with an already existing slug' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct body when creating a right with an already existing slug' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'slug',
            'error' => 'uniq',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Rights-API#slug-already-taken'
          })
        end
      end
      describe 'category not given error' do
        before do
          post '/rights', {app_key: 'test_key', token: 'test_token', slug: 'any_other_slug'}
        end
        it 'Raises a bad request (400) error when the parameters don\'t contain the category' do
          expect(last_response.status).to be 400
        end
        it 'returns the correct response if the parameters do not contain a category' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 400,
            'field' => 'category_id',
            'error' => 'required',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Rights-API#category-id-not-given'
          })
        end
      end
    end
    describe 'not_found errors' do
      describe 'category not found' do
        before do
          post '/rights', {token: 'test_token', app_key: 'test_key', slug: 'perfectly_correct_slug', category_id: '1'}.to_json
        end
        it 'Raises a not found (404) error when the category does\'nt exist' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the category doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({
            'status' => 404,
            'field' => 'category_id',
            'error' => 'unknown',
            'docs' => 'https://github.com/jdr-tools/wiki/wiki/Rights-API#category-not-found'
          })
        end
      end
    end
  end
  describe 'DELETE /:id' do
    describe 'the nominal case' do
      before do
        delete "/rights/#{right.id.to_s}", {app_key: 'test_key', token: 'test_token'}
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

    it_should_behave_like 'a route', 'post', '/rights/right_id'
  end
end