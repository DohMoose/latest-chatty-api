class Message
  attr_reader :id, :from, :subject, :date, :body, :unread
  
  def self.fetch(username, password)
    response = PrivateRequest.new(username, password, 'http://www.shacknews.com/msgcenter/')
    
    if response.status != :not_authorized
      page = Downloader.parse_string(response.body)
    
      messages = []
    
      returning [] do |messages|
        page.find('//table[@id="msgresults"]//tr').each do |row|
          next if row[:id] == 'msgfilters' || row[:class].include?('msgview_container')
        
          id = row.find_first('.//td[contains(@class, "subject")]')[:id].gsub('subject_', '').to_i
          
          messages << self.new({
            :id       => id,
            :from     => row.find_first('.//td[contains(@class, "shackname")]//a').content,
            :subject  => row.find_first('.//td[contains(@class, "subject")]//a').content,
            :unread   => row.find_first('.//td[contains(@class, "subject")]')[:class].include?('unread'),
            :date     => Time.parse(row.find_first('.//td[contains(@class, "date")]').content),
            :body     => page.find_first("//tr[@id='msgview_#{id}']//div[@id='msgcopy']").to_s.inner_html.gsub(/^&#13;|&#13;$/, '').strip,
          })
        end
      end
    else
      response.status
    end
  end
  
  # This doesn't seem to work yet.
  def self.read(username, password, message_id)
    response = PrivateRequest.new(username, password, "http://www.shacknews.com/msgcenter/_read.x?id=#{message_id}")
    if response.status != :not_authorized
      response.status
    else
      true
    end
  end
  
  def self.create(username, password, attributes)
    attributes = {
      # Hidden Fields
      :mode => 'new',
      :id => '',
      :from => username,
      :saveon => '1',
      
      # Visible fields
      :to => attributes[:to],
      :subject => attributes[:subject],
      :bodytext => attributes[:body],
    }
    response = PrivateRequest.new(username, password, "http://www.shacknews.com/msgcenter/send_message.x", :post => attributes)
    if response.status != :not_authorized
      response.status
    else
      false
    end
  end
  
  def initialize(options = {})
    @id   = options[:id]
    @from = options[:from]
    @subject = options[:subject]
    @date = options[:date].is_a?(Time) ? options[:date] : Time.parse(options[:date])
    @body = options[:body]
    @unread = options[:unread]
  end
end