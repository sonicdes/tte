require 'dotenv'
Dotenv.load
ENV['SITE_NAME'] = 'uronga.ru' unless ENV['SITE_NAME']
Dotenv.load("#{ENV['SITE_NAME'] || 'uronga.ru'}.env")
