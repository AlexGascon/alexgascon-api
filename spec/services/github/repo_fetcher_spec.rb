RSpec.describe Github::RepoFetcher do
  describe '.fetch_repo_tree' do
    let(:mock_response) { instance_double(Net::HTTPSuccess, body: '{"tree": []}') }

    before do
      allow(described_class).to receive(:make_github_request).and_return(mock_response)
    end

    it 'makes a request to the GitHub API' do
      expect(described_class)
        .to receive(:make_github_request)
        .with('https://api.github.com/repos/AlexGascon/logbook/git/trees/master?recursive=true')

      described_class.fetch_repo_tree
    end
  end

  describe '.make_github_request' do
    let(:url) { 'https://api.github.com/some/endpoint' }
    let(:token) { 'github_token' }
    let(:mock_http) { instance_double(Net::HTTP) }
    let(:mock_response) { instance_double(Net::HTTPOK) }

    before do
      ENV['GITHUB_TOKEN'] = token
      allow(Net::HTTP).to receive(:start).and_yield(mock_http)
      allow(mock_http).to receive(:request).and_return(mock_response)
    end

    it 'sets the correct authorization header' do
      expect(Net::HTTP::Get)
        .to receive(:new)
        .with(URI(url))
        .and_wrap_original do |method, *args|
          request = method.call(*args)
          expect(request['Authorization']).to eq("Bearer #{token}")
          request
        end

      described_class.make_github_request(url)
    end

    it 'sets the correct accept header' do
      expect(Net::HTTP::Get)
        .to receive(:new)
        .with(URI(url))
        .and_wrap_original do |method, *args|
          request = method.call(*args)
          expect(request['Accept']).to eq('application/vnd.github+json')
          request
        end

      described_class.make_github_request(url)
    end

    it 'sends the request to Github' do
      expect(Net::HTTP)
        .to receive(:start)
      expect(mock_http)
        .to receive(:request)

      described_class.make_github_request(url)
    end
  end
end