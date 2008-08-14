xml.instruct!
xml.comment! 'Documentation at http://shackchatty.com/readme'
xml.comments :story_id => @feed.story_id, :story_name => @feed.story_name, :page => @feed.page, :last_page => @feed.last_page do
  @feed.posts.each do |post|
    render_post(xml, post)
  end
end