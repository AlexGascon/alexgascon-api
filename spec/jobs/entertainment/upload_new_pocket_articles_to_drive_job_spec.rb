# frozen_string_literal: true

RSpec.describe Entertainment::UploadNewPocketArticlesToDriveJob do
  describe '#run' do
    let(:redis_start_time) { 1635526587 }
    let(:mock_pocket) { instance_double(Pocket::Client) }
    let(:mock_drive) { instance_double(GoogleServices::Drive) }

    subject { described_class.perform_now(:run) }

    before do
      Redis.current.set('POCKET_START_TIME', redis_start_time)

      allow(Pocket::Client).to receive(:new).and_return(mock_pocket)
      allow(mock_pocket).to receive(:retrieve).and_return(load_json_fixture('entertainment/pocket_response'))
      allow(GoogleServices::Drive).to receive(:new).and_return(mock_drive)
      allow(mock_drive).to receive(:upload_file).and_return nil
      allow(UrlConversor).to receive(:convert).and_return '/random/path.pdf'
    end

    after do
      Redis.current.flushall
    end

    it 'retrieves the articles from pocket' do
      expect(mock_pocket)
      .to receive(:retrieve)
      .exactly(:once)
      .with a_hash_including(count: 10, sort: 'newest', since: redis_start_time)

      subject
    end

    it 'converts the articles to files' do
      expect(UrlConversor)
      .to receive(:convert)
      .exactly(4).times

      subject
    end

    it 'uploads the files to Google Drive' do
      expect(mock_drive)
      .to receive(:upload_file)
      .exactly(4).times

      subject
    end

    it 'updates the last article time in Redis' do
      expect(Redis.current)
      .to receive(:set)
      .with('POCKET_START_TIME', 1635526982)

      subject
    end

    context 'when there are no new articles' do
      before do
        allow(mock_pocket).to receive(:retrieve).and_return(load_json_fixture('entertainment/pocket_response_empty'))
      end

      it 'does not upload anything' do
        expect(mock_drive)
        .not_to receive(:upload_file)
      end

      it 'does not update the Redis time' do
        expect(Redis.current)
        .not_to receive(:set)

        subject
      end
    end

    context 'when an article has been uploaded already' do
      before { subject }

      it 'is not uploaded again' do
        expect(mock_drive)
        .not_to receive(:upload_file)

        subject
      end
    end

    context 'when the current retrieval start time is greater than the max article time' do
      let(:redis_start_time) { 9999999999 }

      it 'does not update the value in Redis' do
        expect(Redis.current)
        .not_to receive(:set)

        subject
      end
    end

    context 'when the last article time is not available in Redis' do
      before do
        Redis.current.flushall
        Entertainment::Article.create(added_at: 9999999999)
      end

      it 'gets the time from the articles in DynamoDB' do
        expect(mock_pocket)
        .to receive(:retrieve)
        .exactly(:once)
        .with a_hash_including(count: 10, sort: 'newest', since: 9999999999)
       
        subject
      end
    end
  end
end
