# Convert Obsidian-style wiki links [[Link]] to Jekyll-compatible markdown links
Jekyll::Hooks.register :documents, :pre_render do |document|
  document.content = document.content.gsub(/\[\[([^\]|]+?)(?:\|([^\]]+?))?\]\]/) do |match|
    link = $1
    text = $2 || $1
    
    # Handle links with fragments (e.g., [[Page#Section]])
    if link.include?('#')
      page, fragment = link.split('#', 2)
      fragment = fragment.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-')
      "[#{text}](#{page.gsub(' ', '%20')}.html##{fragment})"
    else
      "[#{text}](#{link.gsub(' ', '%20')}.html)"
    end
  end
end

Jekyll::Hooks.register :pages, :pre_render do |page|
  page.content = page.content.gsub(/\[\[([^\]|]+?)(?:\|([^\]]+?))?\]\]/) do |match|
    link = $1
    text = $2 || $1
    
    # Handle links with fragments (e.g., [[Page#Section]])
    if link.include?('#')
      page_link, fragment = link.split('#', 2)
      fragment = fragment.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-')
      "[#{text}](#{page_link.gsub(' ', '%20')}.html##{fragment})"
    else
      "[#{text}](#{link.gsub(' ', '%20')}.html)"
    end
  end
end
