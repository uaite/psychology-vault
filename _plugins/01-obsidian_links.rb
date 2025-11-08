# Convert Obsidian-style wiki links [[Link]] to Jekyll-compatible markdown links
# Priority: 1 ensures this runs early
Jekyll::Hooks.register :documents, :pre_render do |document|
  convert_obsidian_links(document)
end

Jekyll::Hooks.register :pages, :pre_render do |page|
  convert_obsidian_links(page)
end

def convert_obsidian_links(doc)
  doc.content = doc.content.gsub(/\[\[([^\]|]+?)(?:\|([^\]]+?))?\]\]/) do
    link = $1.strip
    text = $2 ? $2.strip : $1.strip
    
    # Handle links with fragments (e.g., [[Page#Section]])
    if link.include?('#')
      page, fragment = link.split('#', 2)
      fragment = fragment.downcase.gsub(/[^a-z0-9\s-]/, '').gsub(/\s+/, '-')
      # Remove .md extension if present
      page = page.gsub(/\.md$/, '')
      "[#{text}](#{page.gsub(' ', '%20')}##{fragment})"
    else
      # Remove .md extension if present
      link = link.gsub(/\.md$/, '')
      "[#{text}](#{link.gsub(' ', '%20')})"
    end
  end
end
