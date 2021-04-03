require 'sendgrid-ruby'

module EmailCenter
  class Mailman
    include SendGrid

    def initialize(email)
      @to = pick_meaningful_recipient(email.to)
      @from = email.from
      @body = email.body
    end

    def handle_it
      byebug
    end

    def send!
      from = Email.new(email: "reply+#{123}@panel.kw.krakow.pl")
      to = Email.new(email: 'dariusz.finster@gmail.com')
      subject = 'Sending with SendGrid is Fun'
      content = Content.new(type: 'text/plain', value: '-- REPLY ABOVE THIS LINE -- \n and easy to do anywhere, even with Ruby')
      mail = Mail.new(from, subject, to, content)
      mail.add_header(Header.new(key: 'X-Test3', value: 'test3'))

      sg = SendGrid::API.new(api_key: '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')
      response = sg.client.mail._('send').post(request_body: mail.to_json)
      puts response.status_code
      puts response.body
      puts response.headers
    end

    private

    def pick_meaningful_recipient(recipients)
      recipients.find { |address| address =~ /@mydomain.com$/ }
    end
  end
end
