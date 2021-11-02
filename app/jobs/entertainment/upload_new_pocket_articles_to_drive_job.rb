# frozen_string_literal: true

module Entertainment
  class UploadNewPocketArticlesToDriveJob < ::ApplicationJob
    ARTICLE_QUERY_LIMIT = 10
    DRIVE_FOLDER_NAME = 'remarkable'
    REDIS_POCKET_START_TIME_KEY = 'POCKET_START_TIME'

    cron '12 03 * * ? *'
    def run
      retrieval_start_time = get_last_article_time
      pocket_articles = pocket.retrieve(
        sort: 'newest',
        since: retrieval_start_time.to_i,
        count: ARTICLE_QUERY_LIMIT
      )

      articles = pocket_articles['list']
        .values
        .select { |pocket_article| new_article?(pocket_article) }
        .map { |pocket_article| convert_to_article(pocket_article) }

      return if articles.empty?

      articles
        .each { |article| upload_to_drive(article) }
      
      oldest_article_time =
        articles
        .max_by(&:added_at)
        .added_at

      update_last_article_time(oldest_article_time) if oldest_article_time > retrieval_start_time
    end

    private

    def pocket
      @pocket ||= Pocket::Client.new(
        consumer_key: ENV['POCKET_CONSUMER_KEY'],
        access_token: ENV['POCKET_ACCESS_TOKEN']
      )
    end

    def new_article?(pocket_article)
      Entertainment::Article.where(id: pocket_article['item_id']).to_a.empty?
    end

    def convert_to_article(pocket_article)
      Entertainment::Article.create(
        id: pocket_article['item_id'],
        title: pocket_article['resolved_title'] || pocket_article['given_title'],
        url: pocket_article['resolved_url'] || pocket_article['given_url'],
        added_at: pocket_article['time_added'].to_i
      )
    end

    def drive
      @drive ||= GoogleServices::Drive.new
    end

    def upload_to_drive(article)
      pdf_path = UrlConversor.convert(article.url)

      destination_name = article.title.nil? ? nil : "#{article.title}.pdf"
      drive.upload_file(
        pdf_path,
        DRIVE_FOLDER_NAME,
        destination_name
      )

      File.delete(pdf_path) if File.exists?(pdf_path)
    end

    def get_last_article_time
      time_from_redis = Redis.current.get(REDIS_POCKET_START_TIME_KEY)

      if time_from_redis.nil?
        time_from_dynamodb = Entertainment::Article.all.map(&:added_at).max
        return time_from_dynamodb.to_i
      end

      time_from_redis.to_i
    end

    def update_last_article_time(time)
      Redis.current.set(REDIS_POCKET_START_TIME_KEY, time.to_i)
    end
  end
end
