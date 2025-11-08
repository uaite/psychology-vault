# Convert Obsidian-style wiki links [[Link]] to Jekyll-compatible markdown links
# This needs to run early, before markdown processing
Jekyll::Hooks.register :documents, :pre_render do |document|
  document.content = document.content.gsub(/\[\[([^\]|]+?)(?:\|([^\]]+?))?\]\]/) do
    link = $1.strip
    text = $2 ? $2.strip : $1.strip
    
    # Handle links with fragments (e.g., [[Page#Section]])
    if link.include?('#')
      page, fragment = link.split('#', 2)
      fragment = fragment.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-')
      # Remove .md extension if present and use relative path
      page = page.gsub(/\.md$/, '')
      "[#{text}](#{page.gsub(' ', '%20')}##{fragment})"
    else
      # Remove .md extension if present
      link = link.gsub(/\.md$/, '')
      "[#{text}](#{link.gsub(' ', '%20')})"
    end
  end
end

Jekyll::Hooks.register :pages, :pre_render do |page|
  page.content = page.content.gsub(/\[\[([^\]|]+?)(?:\|([^\]]+?))?\]\]/) do
    link = $1.strip
    text = $2 ? $2.strip : $1.strip
    
    # Handle links with fragments (e.g., [[Page#Section]])
    if link.include?('#')
      page_link, fragment = link.split('#', 2)
      fragment = fragment.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-')
      # Remove .md extension if present and use relative path
      page_link = page_link.gsub(/\.md$/, '')
      "[#{text}](#{page_link.gsub(' ', '%20')}##{fragment})"
    else
      # Remove .md extension if present
      link = link.gsub(/\.md$/, '')
      "[#{text}](#{link.gsub(' ', '%20')})"
    end
  end
end
