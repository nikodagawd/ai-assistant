module ApplicationHelper
  def render_markdown(text)
    renderer = Redcarpet::Render::HTML.new(
      filter_html: true,
      hard_wrap: true,
      with_toc_data: true
    )

    markdown = Redcarpet::Markdown.new(
      renderer,
      autolink: true,
      tables: true,
      fenced_code_blocks: true,
      strikethrough: true
    )

    sanitize(markdown.render(text.to_s)).html_safe
  end
end
