# frozen_string_literal: true

class UrlConversor
  def self.convert(url)
    prepare_chromedriver

    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--headless')
    chrome = Selenium::WebDriver.for :chrome, options: options

    pdf_path = "/tmp/#{SecureRandom.uuid}.pdf"

    chrome.navigate.to url
    chrome.save_print_page(pdf_path)

    pdf_path
  end

  def self.prepare_chromedriver
    chromedriver_path = File.join(Jets.root, 'bin', 'chromedriver')
    Selenium::WebDriver::Chrome::Service.driver_path = chromedriver_path
  end
end
