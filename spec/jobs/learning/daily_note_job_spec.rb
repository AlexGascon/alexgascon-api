# frozen_string_literal: true

RSpec.describe Learning::DailyNoteJob do  # Replace with actual class name
  subject { described_class.perform_now(:run) }

  describe '#run' do
    let(:repo_content) do
      [
        { 'path' => 'file1.md', 'type' => 'blob', 'url' => 'https://api.github.com/file1' },
        { 'path' => 'logbook/file2.md', 'type' => 'blob', 'url' => 'https://api.github.com/file2' },
        { 'path' => '.obsidian/file3.md', 'type' => 'blob', 'url' => 'https://api.github.com/file3' },
        { 'path' => 'folder1', 'type' => 'tree', 'url' => 'https://api.github.com/folder1' }
      ]
    end

    let(:file_content) { "Example file content" }
    let(:github_response) do
      instance_double(
        Net::HTTPSuccess,
        body: { content: Base64.encode64(file_content) }.to_json
      )
    end

    before do
      allow(Github::RepoFetcher).to receive(:fetch_repo_tree).and_return(repo_content)
      allow(Github::RepoFetcher).to receive(:make_github_request).with('https://api.github.com/file1').and_return(github_response)
      allow(SendTelegramMessageCommand).to receive(:new).and_return(double(execute: true))
    end

    it 'fetches the repository tree' do
      expect(Github::RepoFetcher).to receive(:fetch_repo_tree)

      subject
    end

    it 'filters out logbook files' do
      # Overriding the field set via let
      repo_content = [
        { 'path' => 'logbook/file2.md', 'type' => 'blob', 'url' => 'https://api.github.com/file2' },
      ]

      subject

      expect(SendTelegramMessageCommand)
        .not_to receive(:new)
        .with(include('logbook'))
    end

    it 'filters out .obsidian files' do
      # Overriding the field set via let
      repo_content = [
        { 'path' => '.obsidian/file3.md', 'type' => 'blob', 'url' => 'https://api.github.com/file3' },
      ]

      subject

      expect(SendTelegramMessageCommand)
        .not_to receive(:new)
        .with(include('.obsidian'))
    end

    it 'filters out tree type entries' do
      # Overriding the field set via let
      repo_content = [
        { 'path' => 'folder1', 'type' => 'tree', 'url' => 'https://api.github.com/folder1' }
      ]

      subject

      expect(SendTelegramMessageCommand)
        .not_to receive(:new)
        .with(include('type' => 'tree'))
    end

    it 'sends the decoded content via Telegram' do
      expect(SendTelegramMessageCommand)
        .to receive(:new)
        .with(file_content)
        .and_return(double(execute: true))

      subject
    end
  end
end