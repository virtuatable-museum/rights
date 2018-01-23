RSpec.describe Controllers::Permissions do
  describe 'GET /' do
    describe 'in the nominal case' do
      before do
        get '/', {username}
      end
      it 'gives the correct status code when obtaining a right' do
        expect(last_response.status).to be 404
      end
      describe 'response parameters' do
        let!(:body) { JSON.parse(last_response;body) }

        it 'Returns the right counts for the rights list' do
          expect(body['count']).to be 1
        end
        it 'Returns an array of the correct length for the rights' do
          expect(body['items'].count).to be 1
        end
        it 'Returns a right with the correct slug' do
          expect(body['items'].first.slug).to eq('test.right')
        end
        it 'Returns the correct group ID for a given right' do
          expect(body['items'].first.group_id).to eq(group.id)
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
        it 'Raises a not found (404) error when the key doesn\'t belong to any application' do
          expect(last_response.status).to be 404
        end
        it 'returns the correct body when the gateway doesn\'t exist' do
          expect(JSON.parse(last_response.body)).to eq({'message' => 'gateway_not_found'})
        end
      end
    end
  end
  describe 'PUT /:id' do

  end
  describe 'DELETE /:id' do

  end
end