require 'mail'
require 'octokit'
require 'logger'

def most_recent_release(client)
  client.releases(ENV['REPOSITORY']).first
end

REPOSITORY = ENV['REPOSITORY']
SMTP_ADDRESS = ENV['SMTP_ADDRESS']
SMTP_PORT = ENV['SMTP_PORT']
SMTP_DOMAIN = ENV['SMTP_DOMAIN']
SMTP_USERNAME = ENV['SMTP_USERNAME']
SMTP_PASSWORD = ENV['SMTP_PASSWORD']
RECIPIENT_EMAILS = ENV['RECIPIENT_EMAILS']
FROM_EMAIL = ENV['FROM_EMAIL']


Mail.defaults do
  delivery_method :smtp, { address:        SMTP_ADDRESS,
                           port:           SMTP_PORT,
                           domain:         SMTP_DOMAIN,
                           user_name:      SMTP_USERNAME,
                           password:       SMTP_PASSWORD,
                           authentication: 'plain',
                           enable_starttls_auto: true }
end

logger = Logger.new(STDOUT)
client = Octokit::Client.new
last_release_id = most_recent_release(client).id-1

loop do
  r = most_recent_release(client)
  if r.id > last_release_id
    logger.info "New release #{r.tag_name} detected! Sending email(s)..."
    RECIPIENT_EMAILS.split(',').each do |recipient|
      Mail.deliver do
        to recipient
        from FROM_EMAIL
        subject "New release #{r.tag_name} for #{REPOSITORY}"
        text_part do
          body <<-TEXT
#{r.author.login} just created release #{r.tag_name} for #{REPOSITORY}. Check
it out over at #{r.html_url}.
TEXT
        end
      end
    end
    last_release_id = r.id
  end

  sleep 10.minutes
end
