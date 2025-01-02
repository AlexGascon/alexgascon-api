# frozen_string_literal: true

module Github
  class RepoFetcher
    def self.fetch_repo_tree
      make_github_request('https://api.github.com/repos/AlexGascon/logbook/git/trees/master?recursive=true')
    end

    def self.make_github_request(url_string)
      auth_token = ENV['GITHUB_TOKEN']

      url = URI(url_string)
      request = Net::HTTP::Get.new(url)
      request['Authorization'] = "Bearer #{auth_token}"
      request['Accept'] = 'application/vnd.github+json'
      request['X-GitHub-Api-Version'] = '2022-11-28'

      Net::HTTP.start(url.hostname, url.port, use_ssl: true) { |http| http.request(request) }
    end
  end
end