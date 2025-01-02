# frozen_string_literal: true

module Learning
  class DailyNoteJob < ::ApplicationJob
    cron '23 09 * * ? *'
    def run
      repo_content = Github::RepoFetcher.fetch_repo_tree

      files_to_learn_from =
        repo_content
        .reject { |f| f['path'].include? 'logbook' }
        .reject { |f| f['path'].include? '.obsidian' }
        .reject { |f| f['type'] == 'tree' }

      selected_file = files_to_learn_from.sample

      response = Github::RepoFetcher.make_github_request(selected_file['url'])
      content = Base64.decode64(JSON.parse(response.body)['content'])

      SendTelegramMessageCommand.new(content).execute
    end
  end
end
